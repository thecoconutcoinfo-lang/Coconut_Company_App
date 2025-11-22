import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:provider/provider.dart';

class AdminOfferDetailsScreen extends StatefulWidget {
  const AdminOfferDetailsScreen({super.key});

  @override
  State<AdminOfferDetailsScreen> createState() =>
      _AdminOfferDetailsScreenState();
}

class _AdminOfferDetailsScreenState extends State<AdminOfferDetailsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showOfferDialog({DocumentSnapshot? offerDoc}) {
    final bool isEditing = offerDoc != null;
    final String docId = isEditing ? offerDoc.id : '';
    
    final Map<String, dynamic> initialData =
        isEditing ? offerDoc.data() as Map<String, dynamic> : {};

    final titleController = TextEditingController(text: initialData['title']);
    final descriptionController = TextEditingController(text: initialData['description']);
    final discountValueController = TextEditingController(
      text: initialData['discountValue']?.toString() ?? '',
    );
    final quantityValueController = TextEditingController(
      text: initialData['quantityConditionValue']?.toString() ?? '',
    );

    String discountType = initialData['discountType'] ?? 'percentage';
    String? quantityConditionType = initialData['quantityConditionType'];
    bool isActive = initialData['isActive'] ?? true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(isEditing ? 'Edit Offer' : 'Add New Offer', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildInputField(titleController, 'Offer Title'),
                  _buildInputField(descriptionController, 'Description', maxLines: 3),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildInputField(discountValueController, 'Value', keyboardType: TextInputType.number),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          value: discountType,
                          decoration: InputDecoration(
                            labelText: 'Type',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: ['percentage', 'fixed']
                              .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type == 'percentage' ? '% Off' : 'Fixed Off'),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() => discountType = value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                   Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String?>(
                          value: quantityConditionType,
                          hint: const Text('Rule'),
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Quantity Rule',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: {
                            null: 'None',
                            'greaterThan': 'Quantity >',
                            'lessThan': 'Quantity <',
                            'equalTo': 'Quantity =',
                          }.entries.map((entry) => DropdownMenuItem(
                                value: entry.key,
                                child: Text(entry.value),
                              )).toList(),
                          onChanged: (value) {
                              setDialogState(() => quantityConditionType = value);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      if(quantityConditionType != null)
                      Expanded(
                        flex: 2,
                        child: _buildInputField(quantityValueController, 'Count', keyboardType: TextInputType.number),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    title: const Text('Activate Offer'),
                    value: isActive,
                    onChanged: (value) => setDialogState(() => isActive = value),
                    activeColor: const Color(0xFF34eb89),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF34eb89), foregroundColor: Colors.black),
            onPressed: () {
              final double? discountValue = double.tryParse(discountValueController.text);
              final int? quantityValue = int.tryParse(quantityValueController.text);

              if (titleController.text.isNotEmpty && discountValue != null) {
                final offerData = {
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'discountType': discountType,
                  'discountValue': discountValue,
                  'isActive': isActive,
                  'quantityConditionType': quantityConditionType,
                  'quantityConditionValue': quantityConditionType == null ? null : quantityValue,
                  'lastUpdated': FieldValue.serverTimestamp(),
                };

                if (isEditing) {
                  _firestore.collection('offers').doc(docId).update(offerData);
                } else {
                   _firestore.collection('offers').add(offerData);
                }
                Navigator.pop(context);
              } else {
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('Please fill all fields correctly.'))
                 );
              }
            },
            child: Text(isEditing ? 'Save' : 'Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label,
      {int maxLines = 1, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF34eb89), width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final bool isAdmin = userProvider.userRole == UserRole.admin;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Manage Offers'),
            backgroundColor: const Color(0xFF34eb89),
            foregroundColor: Colors.black,
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('offers').orderBy('lastUpdated', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No offers found. Add one!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              final offers = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: offers.length,
                itemBuilder: (context, index) {
                  final offerDoc = offers[index];
                  final offer = offerDoc.data() as Map<String, dynamic>;
                  final bool isActive = offer['isActive'] ?? false;
                  final String discountString = offer['discountType'] == 'percentage'
                      ? '${offer['discountValue']}% OFF'
                      : '₹${offer['discountValue']} OFF';
                  
                  final String? conditionType = offer['quantityConditionType'];
                  final num? conditionValue = offer['quantityConditionValue'];
                  String conditionText = '';
                  if (conditionType != null && conditionValue != null) {
                    final symbol = {
                      'greaterThan': '>',
                      'lessThan': '<',
                      'equalTo': '=',
                    }[conditionType];
                    conditionText = 'If Quantity $symbol $conditionValue';
                  }

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isActive ? Colors.green.shade300 : Colors.grey.shade300,
                        width: 1.5,
                      )
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      offer['title'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (offer['description'] != null && offer['description'].isNotEmpty)
                                      Text(
                                        offer['description'],
                                        style: TextStyle(color: Colors.grey.shade700),
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColorLight,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  discountString,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF34eb89),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (conditionText.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              conditionText,
                              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade600),
                            ),
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(isActive ? 'Active' : 'Inactive', style: TextStyle(color: isActive ? Colors.green : Colors.red, fontWeight: FontWeight.bold),),
                                  if(isAdmin)
                                  Switch(
                                    value: isActive,
                                    onChanged: (value) {
                                      _firestore.collection('offers').doc(offerDoc.id).update({'isActive': value});
                                    },
                                    activeColor: const Color(0xFF34eb89),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ],
                              ),
                              if(isAdmin)
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blueGrey),
                                    onPressed: () => _showOfferDialog(offerDoc: offerDoc),
                                    tooltip: 'Edit Offer',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                                    tooltip: 'Delete Offer',
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Confirm Deletion'),
                                          content: const Text('Are you sure you want to delete this offer?'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                            TextButton(
                                              onPressed: () {
                                                _firestore.collection('offers').doc(offerDoc.id).delete();
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          floatingActionButton: isAdmin
              ? FloatingActionButton.extended(
                  onPressed: () => _showOfferDialog(),
                  label: const Text('New Offer'),
                  icon: const Icon(Icons.add),
                  backgroundColor: const Color(0xFF34eb89),
                  foregroundColor: Colors.black,
                )
              : null,
        );
      },
    );
  }
}
