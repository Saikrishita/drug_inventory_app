import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VendorTxnPage extends StatelessWidget {
  final String vendorName;
  final String companyName;

  VendorTxnPage({required this.vendorName, required this.companyName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transactions - $vendorName')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('company_name', isEqualTo: companyName)
            .where('status', isEqualTo: 'received') // ✅ Show only completed orders
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          var txns = snapshot.data!.docs;

          if (txns.isEmpty) {
            return Center(child: Text('No transactions found.'));
          }

          return ListView.builder(
            itemCount: txns.length,
            itemBuilder: (context, index) {
              var data = txns[index].data() as Map<String, dynamic>;
              final timestamp = (data['timestamp'] as Timestamp).toDate();

              return ListTile(
                title: Text("Tablet: ${data['tablet_name']} x${data['quantity']}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Customer: ${data['customer_name']}"),
                    Text("Paid: ₹${data['total']} via ${data['payment_method']}"),
                    Text("Status: ${data['status']}"),
                  ],
                ),
                trailing: Text(
                  timestamp.toLocal().toString().split('.')[0],
                  style: TextStyle(fontSize: 12),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
