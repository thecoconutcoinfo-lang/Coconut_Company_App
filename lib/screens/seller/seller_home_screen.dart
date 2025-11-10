// lib/screens/seller/seller_home_screen.dart
import 'package:flutter/material.dart';
import 'order_quantity_screen.dart';

class SellerHomeScreen extends StatelessWidget {
  const SellerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Seller Home")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Quick summary card
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
                      MaterialPageRoute(builder: (_) => const OrderQuantityScreen()),
                    );
                  },
                  child: const Text("Start New Order"),
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              "Recent orders & stats will appear here (UI placeholder)",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
