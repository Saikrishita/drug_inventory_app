import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'customer_specific_medicine.dart';

class CustomerMedicinePage extends StatelessWidget {
  final String customerEmail;

  const CustomerMedicinePage({super.key, required this.customerEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Browse Medicines')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('medicines').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return Center(child: Text('No medicines available.'));

          final medicines = snapshot.data!.docs;

          return ListView.builder(
            itemCount: medicines.length,
            itemBuilder: (context, index) {
              final doc = medicines[index];
              final data = doc.data() as Map<String, dynamic>;

              final name = data['tablet_name'] ?? 'Unnamed';
              final dose = data['mg']?.toString() ?? '';
              final rate = data['strip_rate']?.toString() ?? '';

              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text(name),
                  subtitle: Text('$dose mg - ₹$rate per strip'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CustomerSpecificMedicinePage(
                          medicineId: doc.id,
                          medicineData: data,
                          customerEmail: customerEmail, // ✅ passed here
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
