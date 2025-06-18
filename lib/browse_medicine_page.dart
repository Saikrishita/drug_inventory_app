import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BrowseMedicinesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Browse Medicines')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('medicines').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) return Center(child: Text('No medicines available.'));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final tabletName = data['tablet_name'] ?? 'Unknown';
              final company = data['company_name'] ?? 'Unknown';
              final price = data['strip_rate'] ?? 0;
              final expiry = data['expiry_date'] ?? 'N/A';
              final stock = data['quantity'] ?? 0;

              return ListTile(
                title: Text('$tabletName ($company)'),
                subtitle: Text('Price: ₹$price | Stock: $stock'),
                trailing: Text('Expiry: $expiry'),
              );
            },
          );
        },
      ),
    );
  }
}
