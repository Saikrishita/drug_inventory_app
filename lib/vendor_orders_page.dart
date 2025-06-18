import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VendorOrdersPage extends StatelessWidget {
  final String companyName;

  VendorOrdersPage({required this.companyName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Orders for $companyName')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('company_name', isEqualTo: companyName)
            .where('status', whereIn: ['ordered', 'dispatched'])
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return Center(child: Text('No orders found.'));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index].data() as Map<String, dynamic>;
              var docId = orders[index].id;
              var status = order['status'] ?? 'ordered';

              return ExpansionTile(
                title: Text("Medicine: ${order['tablet_name']}"),
                subtitle: Text("Status: $status"),
                children: [
                  ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Quantity: ${order['quantity']}"),
                        Text("Customer: ${order['customer_name']}"),
                        Text("Address: ${order['address']}"),
                        Text("Payment: ${order['payment_method']}"),
                        Text("Total: ₹${order['total']}"),
                        const SizedBox(height: 10),
                        if (status == 'ordered') 
                          ElevatedButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('orders')
                                  .doc(docId)
                                  .update({'status': 'dispatched'});

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Order marked as dispatched')),
                              );
                            },
                            child: Text("Dispatch Order"),
                          ),
                        if (status == 'dispatched')
                          Text("Dispatched ✅", style: TextStyle(color: Colors.green)),
                      ],
                    ),
                  )
                ],
              );
            },
          );
        },
      ),
    );
  }
}
