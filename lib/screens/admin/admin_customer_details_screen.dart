import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:myapp/services/downloader.dart';

class AdminCustomerDetailsScreen extends StatefulWidget {
  const AdminCustomerDetailsScreen({super.key});

  @override
  State<AdminCustomerDetailsScreen> createState() => _AdminCustomerDetailsScreenState();
}

class _AdminCustomerDetailsScreenState extends State<AdminCustomerDetailsScreen> {
  late Future<List<QueryDocumentSnapshot>> _customerDetailsFuture;

  @override
  void initState() {
    super.initState();
    _customerDetailsFuture = _fetchCustomerDetails();
  }

  Future<List<QueryDocumentSnapshot>> _fetchCustomerDetails() async {
    final salesQuery = await FirebaseFirestore.instance
        .collection('sales')
        .orderBy('timestamp', descending: true)
        .get();
    return salesQuery.docs;
  }

  Future<void> _generateAndDownloadCsv(List<QueryDocumentSnapshot> salesDocs) async {
    if (salesDocs.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to export.')),
      );
      return;
    }

    List<List<dynamic>> rows = [];
    // Header row
    rows.add([
      'Customer Name',
      'Customer Mobile no',
      'address',
      'Total Quantity Purchased',
      'Total Amount',
      'payment_method',
      'timestamp',
      'Seller Email ID',
    ]);

    // Data rows
    for (var doc in salesDocs) {
      final data = doc.data() as Map<String, dynamic>;
      rows.add([
        data['Customer Name'] ?? 'N/A',
        data['Customer Mobile no'] ?? 'N/A',
        data['address'] ?? 'N/A',
        data['Total Quantity Purchased'] ?? 0,
        (data['Total Amount'] as num? ?? 0).toDouble(),
        data['payment_method'] ?? 'N/A',
        (data['timestamp'] as Timestamp?)?.toDate().toIso8601String() ?? 'N/A',
        data['Seller Email ID'] ?? 'N/A',
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);
    const String fileName = "customer_details.csv";

    try {
      final String? path = await downloadFile(csv, fileName);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(path != null 
              ? 'CSV saved to: $path' 
              : 'CSV downloaded successfully.'
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save CSV: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Customer Orders'),
        backgroundColor: const Color(0xFF34eb89),
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: _customerDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('An error occurred: ${snapshot.error}'));
          }

          final salesDocs = snapshot.data ?? [];

          if (salesDocs.isEmpty) {
            return const Center(
              child: Text(
                'No customer orders found.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: salesDocs.length,
            itemBuilder: (context, index) {
              final doc = salesDocs[index];
              final data = doc.data() as Map<String, dynamic>;

              final String name = data['Customer Name'] as String? ?? 'N/A';
              final int quantity = data['Total Quantity Purchased'] as int? ?? 0;
              final double amount = (data['Total Amount'] as num? ?? 0).toDouble();

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  subtitle: Text('Quantity: $quantity'),
                  trailing: Text(
                    '₹${amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                  ),
                  onTap: () => _showCustomerDetailsDialog(context, data),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FutureBuilder<List<QueryDocumentSnapshot>>(
          future: _customerDetailsFuture,
          builder: (context, snapshot) {
            return FloatingActionButton(
              onPressed: () {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  _generateAndDownloadCsv(snapshot.data!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No customer data to export.')),
                  );
                }
              },
              backgroundColor: const Color(0xFF34eb89),
              tooltip: 'Download Customer Data as CSV',
              child: const Icon(Icons.download, color: Colors.black),
            );
          }),
    );
  }

  void _showCustomerDetailsDialog(BuildContext context, Map<String, dynamic> data) {
    final String name = data['Customer Name'] as String? ?? 'N/A';
    final String phone = data['Customer Mobile no'] as String? ?? 'N/A';
    final String address = data['address'] as String? ?? 'N/A';
    final String paymentMethod = data['payment_method'] as String? ?? 'N/A';
    final Timestamp? timestamp = data['timestamp'] as Timestamp?;
    final String sellerEmail = data['Seller Email ID'] as String? ?? 'N/A';
    final int quantity = data['Total Quantity Purchased'] as int? ?? 0;
    final double amount = (data['Total Amount'] as num? ?? 0).toDouble();


    String formattedDate = 'N/A';
    if (timestamp != null) {
      final DateTime orderDate = timestamp.toDate();
      formattedDate = '${orderDate.day}/${orderDate.month}/${orderDate.year}';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(),
              const SizedBox(height: 8),
              _buildDetailRow(context, Icons.phone_outlined, phone),
              const SizedBox(height: 8),
              _buildDetailRow(context, Icons.location_on_outlined, address),
               const SizedBox(height: 8),
              _buildDetailRow(context, Icons.shopping_cart_outlined, 'Quantity: $quantity'),
              const SizedBox(height: 8),
              _buildDetailRow(context, Icons.currency_rupee, 'Amount: ${amount.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              _buildDetailRow(context, Icons.payment_outlined, 'Paid via $paymentMethod'),
              const SizedBox(height: 8),
              _buildDetailRow(context, Icons.calendar_today_outlined, 'Date: $formattedDate'),
              const SizedBox(height: 8),
              _buildDetailRow(context, Icons.email_outlined, 'Sold by: $sellerEmail'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[700]),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
