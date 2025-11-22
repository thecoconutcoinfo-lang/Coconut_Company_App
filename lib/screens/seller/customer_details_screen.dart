// lib/screens/seller/customer_details_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/seller/invoice_screen.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final int quantity;
  final double subtotal;
  final double discount;
  final double finalPrice;
  final DocumentSnapshot? appliedOffer;

  const CustomerDetailsScreen({
    super.key,
    required this.quantity,
    required this.subtotal,
    required this.discount,
    required this.finalPrice,
    this.appliedOffer,
  });

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  final _addressCtl = TextEditingController();
  final _emailCtl = TextEditingController();

  @override
  void dispose() {
    _nameCtl.dispose();
    _phoneCtl.dispose();
    _addressCtl.dispose();
    _emailCtl.dispose();
    super.dispose();
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String offerTitle = widget.appliedOffer != null 
        ? (widget.appliedOffer!.data() as Map<String, dynamic>)['title'] ?? 'Discount' 
        : 'Discount';

    return Scaffold(
      appBar: AppBar(title: const Text("Customer Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
             Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text('Order Summary', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildSummaryRow('Quantity:', '${widget.quantity} coconuts'),
                    _buildSummaryRow('Subtotal:', '₹${widget.subtotal.toStringAsFixed(2)}'),
                    _buildSummaryRow(
                      '$offerTitle Applied:',
                      '- ₹${widget.discount.toStringAsFixed(2)}',
                    ),
                    const Divider(thickness: 1, height: 20),
                    _buildSummaryRow('Final Price:', '₹${widget.finalPrice.toStringAsFixed(2)}', isBold: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameCtl,
                      decoration: const InputDecoration(
                        labelText: "Customer Name",
                        border: OutlineInputBorder(),
                         prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? "Enter name" : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneCtl,
                      decoration: const InputDecoration(
                        labelText: "Mobile Number",
                        border: OutlineInputBorder(),
                         prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (v) => (v == null || v.trim().length < 6)
                          ? "Enter valid phone"
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressCtl,
                      decoration: const InputDecoration(
                        labelText: "Address",
                        border: OutlineInputBorder(),
                         prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailCtl,
                      decoration: const InputDecoration(
                        labelText: "Email (optional)",
                        border: OutlineInputBorder(),
                         prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                       style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                      ),
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => InvoiceScreen(
                                quantity: widget.quantity,
                                subtotal: widget.subtotal,
                                discount: widget.discount,
                                finalPrice: widget.finalPrice,
                                appliedOffer: widget.appliedOffer,
                                customerDetails: {
                                  "CustomerName": _nameCtl.text.trim(),
                                  "CustomerPhone": _phoneCtl.text.trim(),
                                  "CustomerEmail": _emailCtl.text.trim(),
                                  "CustomerAddress": _addressCtl.text.trim(),
                                },
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text("Generate Invoice"),
                    ),
                  ],
                ), 
              ),
            ),
          ],
        ),
      ),
    );
  }
}
