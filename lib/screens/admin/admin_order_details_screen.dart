import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const AdminOrderDetailsScreen({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    final Timestamp timestamp = orderData['timestamp'] as Timestamp;
    final date = timestamp.toDate();
    final String formattedDate = '${date.day}/${date.month}/${date.year}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Customer Name', orderData['Customer Name']),
                _buildDetailRow(
                  'Customer Phone',
                  orderData['Customer Mobile no'],
                ),
                _buildDetailRow(
                  'Customer Address',
                  orderData['Customer Address'],
                ),
                _buildDetailRow(
                  'Total Quantity',
                  orderData['Total Quantity Purchased']?.toString(),
                ),
                _buildDetailRow(
                  'Total Amount',
                  '₹${orderData['Total Amount']}',
                ),
                _buildDetailRow('Payment Method', orderData['paymentMethod']),
                _buildDetailRow('Date', formattedDate),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value ?? 'N/A')),
        ],
      ),
    );
  }
}
