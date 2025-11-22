import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'payment_screen.dart';

class InvoiceScreen extends StatelessWidget {
  final int quantity;
  final double subtotal;
  final double discount;
  final double finalPrice;
  final DocumentSnapshot? appliedOffer;
  final Map<String, String> customerDetails;

  const InvoiceScreen({
    super.key,
    required this.quantity,
    required this.subtotal,
    required this.discount,
    required this.finalPrice,
    this.appliedOffer,
    required this.customerDetails,
  });

  @override
  Widget build(BuildContext context) {
    const double pricePerCoconut = 60.0; // Hardcoded for display, not for calculation
    const double taxPercent = 5.0;

    // Tax is calculated on the final discounted price
    double basePrice = finalPrice / (1 + taxPercent / 100);
    double taxAmount = finalPrice - basePrice;

    final String offerTitle = appliedOffer != null 
        ? (appliedOffer!.data() as Map<String, dynamic>)['title'] ?? 'Discount' 
        : 'Discount';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice'),
        backgroundColor: const Color(0xFF34eb89),
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             // Customer Info Header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    customerDetails['CustomerName'] ?? 'N/A',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  if (customerDetails['CustomerPhone']!.isNotEmpty)
                    Text('Mobile: ${customerDetails['CustomerPhone']}'),
                  if (customerDetails['CustomerAddress']!.isNotEmpty)
                    Text('Address: ${customerDetails['CustomerAddress']}'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildDetailRow('Item', 'Quantity', 'Price'),
            const Divider(),
            _buildDetailRow(
              'Fresh Coconut', 
              '$quantity', 
              '₹${pricePerCoconut.toStringAsFixed(2)}'
            ),
            const SizedBox(height: 20),

            // Pricing section
             _buildPricingRow('Subtotal', '₹${subtotal.toStringAsFixed(2)}'),
            
            if (discount > 0)
             Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Text('Discount ($offerTitle)', style: const TextStyle(color: Colors.green, fontSize: 16)),
                     Text('-₹${discount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontSize: 16)),
                  ],
                ),
              ),

             _buildPricingRow('Taxable Amount', '₹${basePrice.toStringAsFixed(2)}'),
             _buildPricingRow('Tax (5%)', '₹${taxAmount.toStringAsFixed(2)}'),

            const Divider(thickness: 2, height: 24),

            // Total
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Amount', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('₹${finalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF34eb89))),
              ],
            ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF34eb89),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                   textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentScreen(
                        totalAmount: finalPrice,
                        sellerName: 'Seller_Name', // Placeholder
                        quantity: quantity,
                        customerDetails: customerDetails,
                      ),
                    ),
                  );
                },
                child: const Text('Proceed to Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String item, String qty, String price, {bool isHeader = false}) {
    final style = TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal, fontSize: 15);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(item, style: style)),
          Expanded(flex: 1, child: Text(qty, textAlign: TextAlign.center, style: style)),
          Expanded(flex: 1, child: Text(price, textAlign: TextAlign.right, style: style)),
        ],
      ),
    );
  }

  Widget _buildPricingRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
