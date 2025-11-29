import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/seller/order_quantity_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  late Future<List<DocumentSnapshot>> _recentOrdersFuture;

  @override
  void initState() {
    super.initState();
    _recentOrdersFuture = _fetchRecentOrders();
  }

  Future<List<DocumentSnapshot>> _fetchRecentOrders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (!userDoc.exists) return [];

    final List<dynamic> orderIds = userDoc.data()?['orders'] ?? [];
    if (orderIds.isEmpty) return [];

    final recentOrderIds = orderIds.cast<String>().reversed.take(15).toList();
    if (recentOrderIds.isEmpty) return [];

    final salesSnapshot = await FirebaseFirestore.instance
        .collection('sales')
        .where(FieldPath.documentId, whereIn: recentOrderIds)
        .get();

    final salesMap = {for (var doc in salesSnapshot.docs) doc.id: doc};
    final orderedSales = recentOrderIds
        .map((id) => salesMap[id])
        .whereType<DocumentSnapshot>()
        .toList();

    return orderedSales;
  }

  void _refreshOrders() {
    setState(() {
      _recentOrdersFuture = _fetchRecentOrders();
    });
  }

  Future<void> _processReturn({
    required String saleId,
    required int originalQuantity,
    required num totalAmount,
    required String paymentMethod,
    required int quantityToReturn,
    required String returnType, // 'Refund' or 'Replacement'
  }) async {
    // Use the screen's context, which is safe.
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text("Error: Not logged in.")),
      );
      return;
    }

    final firestore = FirebaseFirestore.instance;
    final saleRef = firestore.collection('sales').doc(saleId);
    final userRef = firestore.collection('users').doc(user.uid);
    final returnRef = firestore.collection('returns').doc();

    try {
      await firestore.runTransaction((transaction) async {
        final saleSnapshot = await transaction.get(saleRef);
        final userSnapshot = await transaction.get(userRef);

        if (!saleSnapshot.exists || !userSnapshot.exists) {
          throw Exception("Document does not exist!");
        }

        final saleData = saleSnapshot.data() as Map<String, dynamic>;

        // 1. Calculate refund amount (only if it's a refund)
        final pricePerItem = originalQuantity > 0
            ? totalAmount / originalQuantity
            : 0;
        final refundAmount = (returnType == 'Refund')
            ? (pricePerItem * quantityToReturn)
            : 0;

        // 2. Create a new return document
        transaction.set(returnRef, {
          'saleId': saleId,
          'sellerId': user.uid,
          'returnedQuantity': quantityToReturn,
          'refundAmount': refundAmount, // Will be 0 for replacements
          'returnType': returnType,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // 3. Update the returnedQuantity on the sale document
        final currentReturnedQty = (saleData['returnedQuantity'] ?? 0) as num;
        final Map<String, dynamic> saleUpdateData = {
          'returnedQuantity': currentReturnedQty + quantityToReturn,
        };

        if (returnType == 'Refund') {
          final currentReturnedAmount =
              (saleData['returnedAmount'] ?? 0) as num;
          final currentTotalAmount = (saleData['Total Amount'] ?? 0) as num;

          saleUpdateData['returnedAmount'] =
              currentReturnedAmount + refundAmount;
          saleUpdateData['Total Amount'] = currentTotalAmount - refundAmount;
        }

        transaction.update(saleRef, saleUpdateData);

        // 4. Update seller's analytics ONLY if it's a refund
        if (returnType == 'Refund') {
          final currentTotalSale =
              (userSnapshot.data()?['totalSaleAmount'] ?? 0) as num;
          final currentTotalRefund =
              (userSnapshot.data()?['totalRefundAmount'] ?? 0) as num;

          final updateData = {
            'totalSaleAmount': currentTotalSale - refundAmount,
            'totalRefundAmount': currentTotalRefund + refundAmount,
          };

          if (paymentMethod == 'Cash') {
            final currentCashSale =
                (userSnapshot.data()?['totalCashSale'] ?? 0) as num;
            final currentCashRefund =
                (userSnapshot.data()?['totalCashRefund'] ?? 0) as num;
            updateData['totalCashSale'] = currentCashSale - refundAmount;
            updateData['totalCashRefund'] = currentCashRefund + refundAmount;
          } else {
            // UPI
            final currentUpiSale =
                (userSnapshot.data()?['totalUpiSale'] ?? 0) as num;
            final currentUpiRefund =
                (userSnapshot.data()?['totalUpiRefund'] ?? 0) as num;
            updateData['totalUpiSale'] = currentUpiSale - refundAmount;
            updateData['totalUpiRefund'] = currentUpiRefund + refundAmount;
          }

          transaction.update(userRef, updateData);
        }
      });

      // **THE FIX**: Check if the widget is still mounted before showing UI.
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text("$returnType processed successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      _refreshOrders();
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text("Failed to process $returnType: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showReturnDialog(BuildContext context, DocumentSnapshot order) {
    final orderData = order.data() as Map<String, dynamic>;
    final originalQuantity =
        (orderData['Total Quantity Purchased'] ?? 0) as int;
    final alreadyReturned = (orderData['returnedQuantity'] ?? 0) as int;
    final remainingQuantity = originalQuantity - alreadyReturned;

    int quantityToReturn = 1;
    String returnType = 'Refund';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Process Return/Replacement'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Original Quantity: $originalQuantity"),
                    Text("Already Returned: $alreadyReturned"),
                    const Divider(height: 20),
                    const Text(
                      "Select Action Type:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const <ButtonSegment<String>>[
                        ButtonSegment<String>(
                          value: 'Refund',
                          label: Text('Refund'),
                          icon: Icon(Icons.currency_rupee),
                        ),
                        ButtonSegment<String>(
                          value: 'Replacement',
                          label: Text('Replace'),
                          icon: Icon(Icons.sync),
                        ),
                      ],
                      selected: {returnType},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() => returnType = newSelection.first);
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Quantity:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          iconSize: 32,
                          onPressed: quantityToReturn > 1
                              ? () => setState(() => quantityToReturn--)
                              : null,
                        ),
                        Text(
                          '$quantityToReturn',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          iconSize: 32,
                          onPressed: quantityToReturn < remainingQuantity
                              ? () => setState(() => quantityToReturn++)
                              : null,
                        ),
                      ],
                    ),
                    Center(child: Text('of $remainingQuantity remaining')),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // **THE FIX**: No longer passing unsafe context.
                    _processReturn(
                      saleId: order.id,
                      originalQuantity: originalQuantity,
                      totalAmount: orderData['Total Amount'] ?? 0,
                      paymentMethod: orderData['Payment Method'] ?? 'Cash',
                      quantityToReturn: quantityToReturn,
                      returnType: returnType,
                    );
                  },
                  child: Text('Process $returnType'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshOrders,
            tooltip: "Refresh Orders",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.black.withOpacity(0.08)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                title: const Text("Welcome, Seller"),
                subtitle: const Text("Start a new order or check your stats"),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OrderQuantityScreen(),
                      ),
                    ).then((_) => _refreshOrders());
                  },
                  child: const Text("Start New Order"),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Recent Orders",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<DocumentSnapshot>>(
                future: _recentOrdersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Error fetching orders: ${snapshot.error}"),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No recent orders found."));
                  }

                  final orders = snapshot.data!;

                  return ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final orderData = order.data() as Map<String, dynamic>;

                      final originalQty =
                          orderData['Total Quantity Purchased'] as int? ?? 0;
                      final returnedQty =
                          orderData['returnedQuantity'] as int? ?? 0;
                      final isFullyReturned =
                          originalQty > 0 && originalQty == returnedQty;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(
                            "Customer: ${orderData['Customer Name'] ?? 'N/A'}",
                          ),
                          subtitle: Text(
                            "Amount: \u20b9${orderData['Total Amount'] ?? '0.00'} | Returned: $returnedQty/$originalQty",
                          ),
                          trailing: ElevatedButton(
                            onPressed: isFullyReturned
                                ? null
                                : () => _showReturnDialog(context, order),
                            style: isFullyReturned
                                ? ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                  )
                                : ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                  ),
                            child: Text(
                              isFullyReturned ? "Returned" : "Return/Replace",
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
