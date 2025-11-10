import 'package:flutter/material.dart';

class AdminOfferDetailsScreen extends StatefulWidget {
  const AdminOfferDetailsScreen({super.key});

  @override
  State<AdminOfferDetailsScreen> createState() =>
      _AdminOfferDetailsScreenState();
}

class _AdminOfferDetailsScreenState extends State<AdminOfferDetailsScreen> {
  List<Map<String, dynamic>> offers = [
    {
      'title': 'Buy 4+ Coconuts',
      'discount': '40% OFF',
      'description': 'Get 40% discount when buying 4 or more coconuts.'
    },
    {
      'title': 'Festive Offer',
      'discount': '20% OFF',
      'description': 'Flat 20% off on all UPI payments.'
    },
  ];

  void _addOfferDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController discountController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Add New Offer',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInputField(titleController, 'Offer Title'),
              _buildInputField(discountController, 'Discount (e.g. 30% OFF)'),
              _buildInputField(descriptionController, 'Description', maxLines: 2),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF34eb89),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  discountController.text.isNotEmpty) {
                setState(() {
                  offers.add({
                    'title': titleController.text,
                    'discount': discountController.text,
                    'description': descriptionController.text,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF34eb89), width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  void _removeOffer(int index) {
    setState(() {
      offers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Offer Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: offers.length,
        itemBuilder: (context, index) {
          final offer = offers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF34eb89),
                child: const Icon(Icons.local_offer, color: Colors.black),
              ),
              title: Text(
                offer['title'],
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 16),
              ),
              subtitle: Text(offer['description']),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _removeOffer(index),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF34eb89),
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text(
          'Add Offer',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        onPressed: _addOfferDialog,
      ),
    );
  }
}
