import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/admin/admin_customer_details_screen.dart';
import 'package:myapp/screens/admin/admin_offer_details_screen.dart';
import 'package:myapp/screens/admin/admin_seller_details_screen.dart';
import 'package:myapp/screens/login_screen.dart';

class AdminAboutScreen extends StatelessWidget {
  const AdminAboutScreen({super.key});

  // Logout function
  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate back to the login screen and clear the navigation stack
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      // Show an error message if logout fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF34EB89);
    final user = FirebaseAuth.instance.currentUser;

    Widget _buildSummaryCard({
      required String title,
      required double amount,
      required Color color,
    }) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '₹${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget buildActionButton(
      String title,
      IconData icon,
      VoidCallback onTap, {
      Color? color,
    }) {
      return InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: color ?? Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: primaryColor, size: 26),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.black54,
                size: 18,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin About',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            // Summary Cards
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(
                    child: Text("No data found for this seller."),
                  );
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;
                final double totalSaleAmount = (data['totalSaleAmount'] ?? 0.0)
                    .toDouble();
                final double totalCashAmount = (data['totalCashSale'] ?? 0.0)
                    .toDouble();
                final double totalUpiAmount = (data['totalUpiSale'] ?? 0.0)
                    .toDouble();

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildSummaryCard(
                        title: 'Total Sale',
                        amount: totalSaleAmount,
                        color: const Color(0xFF34eb89),
                      ),
                      const SizedBox(height: 5),
                      _buildSummaryCard(
                        title: 'Cash Sale',
                        amount: totalCashAmount,
                        color: Colors.orangeAccent,
                      ),
                      const SizedBox(height: 5),
                      _buildSummaryCard(
                        title: 'UPI Sale',
                        amount: totalUpiAmount,
                        color: Colors.lightBlueAccent,
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 10),
            const Divider(thickness: 1),
            const SizedBox(height: 10),

            // Management Buttons
            buildActionButton('Customer Details', Icons.people_outline, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminCustomerDetailsScreen(),
                ),
              );
            }),
            buildActionButton('Seller Details', Icons.store_outlined, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminSellerDetailsScreen(),
                ),
              );
            }),
            buildActionButton('Offer Details', Icons.local_offer_outlined, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminOfferDetailsScreen(),
                ),
              );
            }),
            const SizedBox(height: 20),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () => _logout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
