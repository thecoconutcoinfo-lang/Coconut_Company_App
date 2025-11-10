import 'package:flutter/material.dart';
import 'payment_screen.dart';

class InvoiceScreen extends StatelessWidget {
  final int quantity;
  final Map<String, String> customerDetails;

  const InvoiceScreen({
    super.key,
    required this.quantity,
    required this.customerDetails,
  });

  @override
  Widget build(BuildContext context) {
    const double pricePerCoconut = 60.0; // inclusive of 5% tax
    const double taxPercent = 5.0;

    double subtotal = pricePerCoconut * quantity;
    double discount = quantity > 4 ? subtotal * 0.4 : 0.0;
    double totalAfterDiscount = subtotal - discount;

    // Calculate tax breakdown
    double basePrice = totalAfterDiscount / (1 + taxPercent / 100);
    double taxAmount = totalAfterDiscount - basePrice;

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
            Text(
              'Customer: ${customerDetails['CustomerName']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            Text('Mobile: ${customerDetails['CustomerPhone']}'),
            Text('Address: ${customerDetails['CustomerAddress']}'),
            const SizedBox(height: 16),

            const Divider(thickness: 1),

            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Quantity'),
                Text('$quantity'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Price per Coconut'),
                Text('₹$pricePerCoconut'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal'),
                Text('₹${subtotal.toStringAsFixed(2)}'),
              ],
            ),
            if (discount > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Discount (40%)', style: TextStyle(color: Colors.green)),
                  Text('-₹${discount.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.green)),
                ],
              ),
            const SizedBox(height: 8),

            const Divider(thickness: 1),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tax (5%)'),
                Text('₹${taxAmount.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '₹${totalAfterDiscount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF34eb89),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentScreen(
                        totalAmount: totalAfterDiscount,
                        sellerName: 'Seller_Name', // can be dynamic later
                        quantity: quantity,
                        customerDetails: customerDetails,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Proceed to Payment',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
