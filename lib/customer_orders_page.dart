import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerOrdersPage extends StatefulWidget {
  const CustomerOrdersPage({super.key});

  @override
  State<CustomerOrdersPage> createState() => _CustomerOrdersPageState();
}

class _CustomerOrdersPageState extends State<CustomerOrdersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Customer Orders')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('status', whereIn: ['ordered', 'dispatched'])
            //.orderBy('timestamp', descending: true) // You can enable if using valid timestamps
            .snapshots(),
        builder: (context, snapshot) {
          debugPrint('📡 Querying all orders with status ordered/dispatched');

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final data = orders[index].data() as Map<String, dynamic>;
              final docId = orders[index].id;
              final dateTime = (data['timestamp'] as Timestamp?)?.toDate();
              final status = data['status'] ?? 'ordered';

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text('${data['tablet_name']} x${data['quantity']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Customer: ${data['customer_name']}'),
                      Text('Email: ${data['customer_email']}'),
                      Text('Address: ${data['address']}'),
                      Text('Payment: ${data['payment_method']}'),
                      Text('Total: ₹${data['total']}'),
                      Text('Status: $status'),
                      if (status == 'dispatched')
                        TextButton(
                          child: const Text('Mark as Received'),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('orders')
                                .doc(docId)
                                .update({'status': 'received'});

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Order marked as received')),
                            );
                          },
                        ),
                    ],
                  ),
                  trailing: dateTime != null
                      ? Text(
                          '${dateTime.toLocal()}'.split('.')[0],
                          style: const TextStyle(fontSize: 12),
                        )
                      : const Text('No time'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
