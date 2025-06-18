import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerOrderConfirmationPage extends StatefulWidget {
  final String medicineId;
  final Map<String, dynamic> medicineData;
  final int quantity;

  CustomerOrderConfirmationPage({
    required this.medicineId,
    required this.medicineData,
    required this.quantity,
    required this.customerEmail,
  });

  final String customerEmail;

  @override
  _CustomerOrderConfirmationPageState createState() =>
      _CustomerOrderConfirmationPageState();
}

class _CustomerOrderConfirmationPageState
    extends State<CustomerOrderConfirmationPage> {
  final _formKey = GlobalKey<FormState>();
  String customerName = '';
  String address = '';
  String paymentMethod = 'UPI';
  String paymentDetails = '';

  void _placeOrder() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final user = FirebaseAuth.instance.currentUser;
      final currentCustomerEmail = user?.email ?? '';

      final stripRate = widget.medicineData['strip_rate'] ?? 0;
      final companyName = widget.medicineData['company_name'] ?? '';
      final medicineName = widget.medicineData['tablet_name'] ?? '';

      final orderData = {
        'medicine_id': widget.medicineId,
        'tablet_name': medicineName,
        'quantity': widget.quantity,
        'price': stripRate,
        'total': widget.quantity * stripRate,
        'address': address,
        'customer_name': customerName,
        'payment_method': paymentMethod,
        'payment_details': paymentDetails,
        'company_name': companyName,
        'customer_email': currentCustomerEmail, // ✅ Correct now
        'status': 'ordered',
        'timestamp': Timestamp.now(),
      };

      await FirebaseFirestore.instance.collection('orders').add(orderData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order placed successfully!')),
      );

      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount =
        widget.quantity * (widget.medicineData['strip_rate'] ?? 0);

    return Scaffold(
      appBar: AppBar(title: Text('Confirm Order')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Medicine: ${widget.medicineData['tablet_name']}'),
              Text('Quantity: ${widget.quantity}'),
              Text('Total: ₹$totalAmount'),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: 'Your Name'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter name' : null,
                onSaved: (val) =>
                    customerName = val?.trim().toLowerCase() ?? '',
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Delivery Address'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter address' : null,
                onSaved: (val) => address = val ?? '',
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: paymentMethod,
                items: ['UPI', 'Card'].map((method) {
                  return DropdownMenuItem(value: method, child: Text(method));
                }).toList(),
                onChanged: (val) => setState(() => paymentMethod = val!),
                decoration: InputDecoration(labelText: 'Payment Method'),
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: paymentMethod == 'UPI'
                      ? 'Enter UPI ID'
                      : 'Enter Card CVV',
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter details' : null,
                onSaved: (val) => paymentDetails = val ?? '',
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _placeOrder,
                child: Text('Place Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
