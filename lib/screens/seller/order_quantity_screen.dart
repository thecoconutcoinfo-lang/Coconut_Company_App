import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'customer_details_screen.dart';

class OrderQuantityScreen extends StatefulWidget {
  const OrderQuantityScreen({super.key});

  @override
  State<OrderQuantityScreen> createState() => _OrderQuantityScreenState();
}

class _OrderQuantityScreenState extends State<OrderQuantityScreen> {
  int _quantity = 1;
  static const double pricePerCoconut = 60.0;
  List<DocumentSnapshot> _offers = [];
  DocumentSnapshot? _appliedOffer;

  @override
  void initState() {
    super.initState();
    _fetchOffers();
  }

  Future<void> _fetchOffers() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('offers')
        .where('isActive', isEqualTo: true)
        .get();
    setState(() {
      _offers = snapshot.docs;
    });
  }

  void _increase() => setState(() => _quantity++);
  void _decrease() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  double get _subtotal => _quantity * pricePerCoconut;

  Map<String, dynamic> _getBestOffer() {
    double bestDiscount = 0;
    DocumentSnapshot? bestOfferDoc;

    for (final offerDoc in _offers) {
      final offer = offerDoc.data() as Map<String, dynamic>;
      final conditionType = offer['quantityConditionType'];
      final conditionValue = offer['quantityConditionValue'];
      bool isApplicable = false;

      if (conditionType == null) {
        isApplicable = true; // No quantity condition
      } else if (conditionValue != null) {
        switch (conditionType) {
          case 'greaterThan':
            isApplicable = _quantity > conditionValue;
            break;
          case 'lessThan':
            isApplicable = _quantity < conditionValue;
            break;
          case 'equalTo':
            isApplicable = _quantity == conditionValue;
            break;
        }
      }

      if (isApplicable) {
        final discountType = offer['discountType'];
        final discountValue = offer['discountValue'];
        double currentDiscount = 0;

        if (discountType == 'percentage') {
          currentDiscount = (_subtotal * discountValue) / 100;
        } else if (discountType == 'fixed') {
          currentDiscount = discountValue;
        }
        
        if (currentDiscount > bestDiscount) {
          bestDiscount = currentDiscount;
          bestOfferDoc = offerDoc;
        }
      }
    }

    _appliedOffer = bestOfferDoc;
    return {'discount': bestDiscount, 'offer': bestOfferDoc};
  }

  @override
  Widget build(BuildContext context) {
    final bestOfferData = _getBestOffer();
    final double discount = bestOfferData['discount'];
    final double finalPrice = _subtotal - discount;

    String offerTitle = "No offer applied";
    if (bestOfferData['offer'] != null) {
      final offer = bestOfferData['offer'].data() as Map<String, dynamic>;
      offerTitle = offer['title'] ?? 'Unnamed Offer';
    }

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
                title: Text(
                  "Final Price: ₹${finalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF34EB89)),
                ),
                subtitle: Text(
                  discount > 0
                      ? 'Offer: $offerTitle (-₹${discount.toStringAsFixed(2)})'
                      : 'No offer applied',
                ),
                trailing: Icon(discount > 0 ? Icons.check_circle : Icons.info_outline, color: discount > 0 ? Colors.green : Colors.grey),
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
                      builder: (_) => CustomerDetailsScreen(
                        quantity: _quantity,
                        subtotal: _subtotal,
                        discount: discount,
                        finalPrice: finalPrice,
                        appliedOffer: _appliedOffer,
                      ),
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
