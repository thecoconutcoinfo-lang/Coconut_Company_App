
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'verification_screen.dart';

class PaymentScreen extends StatefulWidget {
  final double totalAmount;
  final String sellerName;
  final int quantity;
  final Map<String, String> customerDetails;

  const PaymentScreen({
    super.key,
    required this.totalAmount,
    required this.sellerName,
    required this.quantity,
    required this.customerDetails,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? selectedPayment;
  bool _isProcessing = false;

  Future<void> _processAndSaveSale() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: You are not logged in.')),
      );
      return;
    }

    final dashboardRef =
        FirebaseFirestore.instance.collection('dashboard').doc('metrics');
    final newSaleRef = FirebaseFirestore.instance.collection('sales').doc();
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Get current snapshots
      final dashboardSnapshot = await transaction.get(dashboardRef);
      final userSnapshot = await transaction.get(userRef);

      // 1. Update Global Dashboard Metrics
      if (!dashboardSnapshot.exists) {
        transaction.set(dashboardRef, {
          'total amount': widget.totalAmount,
          'total quantity': widget.quantity,
          'total UPI': selectedPayment == 'UPI' ? widget.totalAmount : 0,
          'total Cash': selectedPayment == 'Cash' ? widget.totalAmount : 0,
        });
      } else {
        final data = dashboardSnapshot.data() as Map<String, dynamic>;
        transaction.update(dashboardRef, {
          'total amount': (data['total amount'] ?? 0) + widget.totalAmount,
          'total quantity': (data['total quantity'] ?? 0) + widget.quantity,
          'total UPI': selectedPayment == 'UPI'
              ? (data['total UPI'] ?? 0) + widget.totalAmount
              : data['total UPI'],
          'total Cash': selectedPayment == 'Cash'
              ? (data['total Cash'] ?? 0) + widget.totalAmount
              : data['total Cash'],
        });
      }
      
      // 2. Update Seller's Personal Sales Totals (and create if they don't exist)
      final userData = userSnapshot.data() as Map<String, dynamic>?;
      transaction.set(userRef, {
        'totalSaleAmount': (userData?['totalSaleAmount'] ?? 0) + widget.totalAmount,
        'totalCashSale': selectedPayment == 'Cash'
            ? (userData?['totalCashSale'] ?? 0) + widget.totalAmount
            : (userData?['totalCashSale'] ?? 0),
        'totalUpiSale': selectedPayment == 'UPI'
            ? (userData?['totalUpiSale'] ?? 0) + widget.totalAmount
            : (userData?['totalUpiSale'] ?? 0),
        'orders': FieldValue.arrayUnion([newSaleRef.id]),
      }, SetOptions(merge: true)); // <-- This is the crucial fix

      // 3. Create the New Sale Document
      transaction.set(newSaleRef, {
        'Customer Name': widget.customerDetails['CustomerName'],
        'Customer Mobile no': widget.customerDetails['CustomerPhone'],
        'Total Quantity Purchased': widget.quantity,
        'Total Amount': widget.totalAmount,
        'Seller Email ID': user.email,
        'paymentMethod': selectedPayment, // New field
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> _navigateToVerification() async {
    if (_isProcessing) return;

    if (selectedPayment == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method.')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await _processAndSaveSale();
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationScreen(
            paymentMethod: selectedPayment!,
            amount: widget.totalAmount,
            sellerName: widget.sellerName,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Method'),
        backgroundColor: const Color(0xFF34eb89),
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            RadioListTile<String>(
              title: const Text('Cash'),
              value: 'Cash',
              groupValue: selectedPayment,
              activeColor: const Color(0xFF34eb89),
              onChanged: (value) {
                setState(() => selectedPayment = value);
              },
            ),
            RadioListTile<String>(
              title: const Text('UPI'),
              value: 'UPI',
              groupValue: selectedPayment,
              activeColor: const Color(0xFF34eb89),
              onChanged: (value) {
                setState(() => selectedPayment = value);
              },
            ),
            const SizedBox(height: 30),
            if (selectedPayment == 'UPI')
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black26),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Scan QR to Pay',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 150,
                            width: 150,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black12),
                            ),
                            child: const Icon(
                              Icons.qr_code_2,
                              size: 120,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Amount: ₹${widget.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF34eb89),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: _isProcessing ? null : _navigateToVerification,
                      child: _isProcessing
                          ? const CircularProgressIndicator()
                          : const Text('Payment Done'),
                    ),
                  ],
                ),
              ),
            const Spacer(),
            if (selectedPayment == 'Cash')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF34eb89),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _isProcessing ? null : _navigateToVerification,
                  child: _isProcessing
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Confirm Cash Collection',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
