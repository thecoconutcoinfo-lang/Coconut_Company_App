
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF34EB89);

    Widget buildStatCard(String title, String value, IconData icon, Color color) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              radius: 25,
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('dashboard').doc('metrics').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No dashboard data found.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final int totalQuantity = (data['total quantity'] as num? ?? 0).toInt();
          final double totalPayment = (data['total amount'] as num? ?? 0).toDouble();
          final double cashPayment = (data['total Cash'] as num? ?? 0).toDouble();
          final double upiPayment = (data['total UPI'] as num? ?? 0).toDouble();


          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                buildStatCard(
                    'Total Quantity Sold', '$totalQuantity pcs', Icons.shopping_bag_outlined, primaryColor),
                const SizedBox(height: 16),
                buildStatCard(
                    'Total Payment', '₹${totalPayment.toStringAsFixed(2)}', Icons.attach_money_outlined, Colors.black),
                const SizedBox(height: 16),
                buildStatCard(
                    'Cash Payment', '₹${cashPayment.toStringAsFixed(2)}', Icons.money_outlined, Colors.green),
                const SizedBox(height: 16),
                buildStatCard(
                    'UPI Payment', '₹${upiPayment.toStringAsFixed(2)}', Icons.qr_code_2_outlined, Colors.blue),
              ],
            ),
          );
        },
      ),
    );
  }
}