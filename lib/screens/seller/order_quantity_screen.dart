// lib/screens/seller/order_quantity_screen.dart
import 'package:flutter/material.dart';
import 'customer_details_screen.dart';

class OrderQuantityScreen extends StatefulWidget {
  const OrderQuantityScreen({super.key});

  @override
  State<OrderQuantityScreen> createState() => _OrderQuantityScreenState();
}

class _OrderQuantityScreenState extends State<OrderQuantityScreen> {
  int _quantity = 1;
  static const double pricePerCoconut = 60.0; // ₹60 inclusive of 5% tax
  static const int discountThreshold = 4; // qty > 4 -> 40% discount (applied later)

  void _increase() => setState(() => _quantity++);
  void _decrease() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  double get _subtotal => _quantity * pricePerCoconut;
  String get _discountHint {
    if (_quantity > discountThreshold) {
      return "Offer applicable: 40% off (will be applied on invoice)";
    }
    return "No offer applied";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Order — Quantity"),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Product card
            Card(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.black.withOpacity(0.08)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
                child: Row(
                  children: [
                    // Placeholder icon
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black.withOpacity(0.06)),
                      ),
                      child: const Center(child: Text("🥥", style: TextStyle(fontSize: 30))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Fresh Coconut", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text("Price: ₹${pricePerCoconut.toStringAsFixed(0)} (incl. 5% tax)", style: const TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Quantity controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _decrease,
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.black87,
                  iconSize: 32,
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black.withOpacity(0.08)),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: Text(
                    '$_quantity',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: _increase,
                  icon: const Icon(Icons.add_circle_outline),
                  color: const Color(0xFF34EB89),
                  iconSize: 32,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Quick preset buttons
            Wrap(
              spacing: 10,
              children: [1, 2, 4, 6, 10].map((n) {
                final isSelected = _quantity == n;
                return ChoiceChip(
                  label: Text("$n"),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _quantity = n),
                  selectedColor: const Color(0xFF34EB89).withOpacity(0.15),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Slider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Adjust Quantity", style: TextStyle(fontWeight: FontWeight.w600)),
                Slider(
                  min: 1,
                  max: 50,
                  divisions: 49,
                  value: _quantity.toDouble(),
                  onChanged: (v) => setState(() => _quantity = v.round()),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Subtotal & discount hint
            Card(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.black.withOpacity(0.06)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                title: Text("Estimated Total: ₹${_subtotal.toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(_discountHint),
                trailing: const Icon(Icons.info_outline),
              ),
            ),

            const Spacer(),

            // Next button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to Customer Details with selected quantity
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CustomerDetailsScreen(quantity: _quantity),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF34EB89),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Next — Customer Details", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}