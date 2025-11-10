// lib/screens/seller/customer_details_screen.dart
import 'package:flutter/material.dart';
import 'package:myapp/screens/seller/invoice_screen.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final int quantity;
  const CustomerDetailsScreen({super.key, required this.quantity});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Customer Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Quantity: ${widget.quantity}",
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
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
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailCtl,
                      decoration: const InputDecoration(
                        labelText: "Email (optional)",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => InvoiceScreen(
                                quantity: widget.quantity,
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
