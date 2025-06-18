import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'vendor_specific_medicine.dart';

class VendorMedicineListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('View All Medicines')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('medicines').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return Center(child: Text('No medicines found.'));

          final medicines = snapshot.data!.docs;

          return ListView.builder(
            itemCount: medicines.length,
            itemBuilder: (context, index) {
              final doc = medicines[index];
              final data = doc.data() as Map<String, dynamic>;

              final name = data['tablet_name'] ?? 'Unnamed';
              final dose = data['mg'] ?? '';
              final price = data['strip_rate']?.toString() ?? 'N/A';
              final stock = data['quantity']?.toString() ?? '0';

              // Parse and format expiry date
              String expiry = 'N/A';
              if (data['expiry_date'] != null && data['expiry_date'] is Timestamp) {
                final expiryDate = (data['expiry_date'] as Timestamp).toDate();
                expiry = DateFormat('dd MMM yyyy').format(expiryDate);
              }

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text('$name ($dose mg)'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Price: ₹$price / strip'),
                      Text('Stock: $stock'),
                      Text('Expiry: $expiry'),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VendorSpecificMedicinePage(
                          medicineId: doc.id,
                          medicineData: data,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
