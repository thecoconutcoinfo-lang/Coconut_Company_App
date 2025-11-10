import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminCustomerDetailsScreen extends StatelessWidget {
  const AdminCustomerDetailsScreen({super.key});

  Future<List<QueryDocumentSnapshot>> _fetchCustomerDetails() async {
    final salesQuery = await FirebaseFirestore.instance
        .collection('sales')
        .orderBy('timestamp', descending: true)
        .get();
    return salesQuery.docs;
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
        future: _fetchCustomerDetails(),
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