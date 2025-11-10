import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/admin/add_seller_screen.dart';

class AdminSellerDetailsScreen extends StatefulWidget {
  const AdminSellerDetailsScreen({super.key});

  @override
  State<AdminSellerDetailsScreen> createState() =>
      _AdminSellerDetailsScreenState();
}

class _AdminSellerDetailsScreenState extends State<AdminSellerDetailsScreen> {
  Future<List<QueryDocumentSnapshot>> _fetchSellers() async {
    final sellersQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'seller')
        .get();
    return sellersQuery.docs;
  }

  Future<void> _deleteSeller(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text(
            'Are you sure you want to remove this seller? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).delete();
        // Refresh the list
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seller removed successfully.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove seller: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Seller Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: _fetchSellers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('An error occurred: ${snapshot.error}'));
          }

          final sellerDocs = snapshot.data ?? [];

          if (sellerDocs.isEmpty) {
            return const Center(
              child: Text(
                'No sellers found.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: sellerDocs.length,
            itemBuilder: (context, index) {
              final doc = sellerDocs[index];
              final data = doc.data() as Map<String, dynamic>;

              final String sellerName = data['name'] as String? ?? 'N/A';
              final String location = data['address'] as String? ?? 'N/A';
              final String phoneNumber = data['mobile'] as String? ?? 'N/A';
              final int totalOrders =
                  (data['orders'] as List<dynamic>? ?? []).length;

              return SellerCard(
                sellerName: sellerName,
                location: location,
                totalOrders: totalOrders,
                phoneNumber: phoneNumber,
                onDelete: () => _deleteSeller(doc.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF34eb89),
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text(
          'Add Seller',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddSellerScreen()),
          ).then((_) {
            setState(() {});
          });
        },
      ),
    );
  }
}

class SellerCard extends StatelessWidget {
  final String sellerName;
  final String location;
  final int totalOrders;
  final String phoneNumber;
  final VoidCallback onDelete;

  const SellerCard({
    super.key,
    required this.sellerName,
    required this.location,
    required this.totalOrders,
    required this.phoneNumber,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade700,
          child: const Icon(Icons.store, color: Colors.white),
        ),
        title: Text(
          sellerName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(location),
            Text('Total Orders: $totalOrders'),
            Text('Contact: $phoneNumber'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.person_remove_outlined,
              size: 20,
              color: Colors.redAccent),
          tooltip: 'Remove Seller',
          onPressed: onDelete,
        ),
      ),
    );
  }
}
