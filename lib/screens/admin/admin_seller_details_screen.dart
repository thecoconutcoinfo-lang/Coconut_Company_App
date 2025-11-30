import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/admin/add_seller_screen.dart';
import 'package:myapp/screens/admin/admin_order_details_screen.dart';

class AdminSellerDetailsScreen extends StatefulWidget {
  const AdminSellerDetailsScreen({super.key});

  @override
  State<AdminSellerDetailsScreen> createState() =>
      _AdminSellerDetailsScreenState();
}

class _AdminSellerDetailsScreenState extends State<AdminSellerDetailsScreen> {
  Future<List<QueryDocumentSnapshot>> _fetchSellers() async {
    final sellersQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'seller')
        .get();
    return sellersQuery.docs;
  }

  Future<void> _deleteSeller(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text(
            'Are you sure you want to remove this seller? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).delete();
        // Refresh the list
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seller removed successfully.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove seller: $e')),
        );
      }
    }
  }

  void _showSellerDetailsDialog(BuildContext context, Map<String, dynamic> sellerData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final List<dynamic> orderIds = sellerData['orders'] ?? [];

        return AlertDialog(
          title: Text(sellerData['name'] ?? 'Seller Details'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Email', sellerData['email']),
                _buildDetailRow('Phone', sellerData['mobile']),
                _buildDetailRow('Address', sellerData['address']),
                const Divider(height: 20),
                const Text('Orders', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 8),
                Expanded(
                  child: orderIds.isEmpty
                      ? const Center(child: Text('No orders found.'))
                      : FutureBuilder<List<DocumentSnapshot>>(
                          future: _fetchOrdersForSeller(orderIds),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            }
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Center(child: Text('No order details found.'));
                            }

                            final orders = snapshot.data!;
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: orders.length,
                              itemBuilder: (context, index) {
                                final order = orders[index].data() as Map<String, dynamic>;
                                final Timestamp timestamp = order['timestamp'] as Timestamp;
                                final date = timestamp.toDate();
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: ListTile(
                                    title: Text("Customer: ${order['Customer Name'] ?? 'N/A'}"),
                                    subtitle: Text("Amount: ₹${order['Total Amount']}"),
                                    trailing: Text('${date.day}/${date.month}/${date.year}'),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AdminOrderDetailsScreen(orderData: order),
                                        ),
                                      );
                                    },
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
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<List<DocumentSnapshot>> _fetchOrdersForSeller(List<dynamic> orderIds) async {
    if (orderIds.isEmpty) return [];
    final salesCollection = FirebaseFirestore.instance.collection('sales');
    final List<Future<DocumentSnapshot>> futures = [];
    for (final orderId in orderIds) {
      if (orderId is String && orderId.isNotEmpty) {
        futures.add(salesCollection.doc(orderId).get());
      }
    }
    final results = await Future.wait(futures);
    return results.where((doc) => doc.exists).toList();
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text.rich(
        TextSpan(
          text: '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
          children: [
            TextSpan(
              text: value?.toString() ?? 'N/A',
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Seller Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: _fetchSellers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('An error occurred: ${snapshot.error}'));
          }

          final sellerDocs = snapshot.data ?? [];

          if (sellerDocs.isEmpty) {
            return const Center(
              child: Text(
                'No sellers found.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: sellerDocs.length,
            itemBuilder: (context, index) {
              final doc = sellerDocs[index];
              final data = doc.data() as Map<String, dynamic>;

              final String sellerName = data['name'] as String? ?? 'N/A';
              final String location = data['address'] as String? ?? 'N/A';
              final String phoneNumber = data['mobile'] as String? ?? 'N/A';
              final int totalOrders =
                  (data['orders'] as List<dynamic>? ?? []).length;

              return SellerCard(
                sellerName: sellerName,
                location: location,
                totalOrders: totalOrders,
                phoneNumber: phoneNumber,
                onDelete: () => _deleteSeller(doc.id),
                onTap: () => _showSellerDetailsDialog(context, data),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF34eb89),
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text(
          'Add Seller',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddSellerScreen()),
          ).then((_) {
            setState(() {});
          });
        },
      ),
    );
  }
}

class SellerCard extends StatelessWidget {
  final String sellerName;
  final String location;
  final int totalOrders;
  final String phoneNumber;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const SellerCard({
    super.key,
    required this.sellerName,
    required this.location,
    required this.totalOrders,
    required this.phoneNumber,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade700,
          child: const Icon(Icons.store, color: Colors.white),
        ),
        title: Text(
          sellerName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(location),
            Text('Total Orders: $totalOrders'),
            Text('Contact: $phoneNumber'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.person_remove_outlined,
              size: 20,
              color: Colors.redAccent),
          tooltip: 'Remove Seller',
          onPressed: onDelete,
        ),
      ),
    );
  }
}
