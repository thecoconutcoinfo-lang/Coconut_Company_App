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

    // Mock data
    final int totalQuantity = 1200;
    final double totalSale = 72000;
    final int cashQuantity = 700;
    final double cashSale = 42000;
    final int upiQuantity = 500;
    final double upiSale = 30000;

    Widget buildStatCard(
        String title, String value, IconData icon, Color color) {
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
        margin: const EdgeInsets.only(bottom: 16),
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

    Widget buildActionButton(String title, IconData icon, VoidCallback onTap,
        {Color? color}) {
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
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.black54, size: 18),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Summary Cards
            buildStatCard('Total Sale', '₹$totalSale | $totalQuantity pcs',
                Icons.bar_chart_outlined, primaryColor),
            buildStatCard('Cash Sale', '₹$cashSale | $cashQuantity pcs',
                Icons.money_outlined, Colors.green),
            buildStatCard('UPI Sale', '₹$upiSale | $upiQuantity pcs',
                Icons.qr_code_2_outlined, Colors.blue),

            const SizedBox(height: 10),
            const Divider(thickness: 1),
            const SizedBox(height: 10),

            // Management Buttons
            buildActionButton('Customer Details', Icons.people_outline, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AdminCustomerDetailsScreen()),
              );
            }),
            buildActionButton('Seller Details', Icons.store_outlined, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AdminSellerDetailsScreen()),
              );
            }),
            buildActionButton('Offer Details', Icons.local_offer_outlined, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AdminOfferDetailsScreen()),
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
