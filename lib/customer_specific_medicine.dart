import 'package:flutter/material.dart';
import 'customer_order_confirmation.dart'; // Ensure this file exists
import 'package:intl/intl.dart';

class CustomerSpecificMedicinePage extends StatefulWidget {
  final String medicineId;
  final Map<String, dynamic> medicineData;
  final String customerEmail; // ✅ Add this

  CustomerSpecificMedicinePage({
    required this.medicineId,
    required this.medicineData,
    required this.customerEmail, // ✅ Include in constructor
  });

  @override
  _CustomerSpecificMedicinePageState createState() =>
      _CustomerSpecificMedicinePageState();
}

class _CustomerSpecificMedicinePageState
    extends State<CustomerSpecificMedicinePage> {
  int quantity = 1;

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    try {
      DateTime date = timestamp.toDate(); // For Firestore Timestamp
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.medicineData;

    return Scaffold(
      appBar: AppBar(title: Text(data['tablet_name'] ?? 'Medicine Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dose: ${data['mg']} mg', style: TextStyle(fontSize: 16)),
            Text('Rate: ₹${data['strip_rate']} per strip',
                style: TextStyle(fontSize: 16)),
            Text('Stock: ${data['quantity']}', style: TextStyle(fontSize: 16)),
            Text('Manufacturer: ${data['company_name'] ?? 'N/A'}', style: TextStyle(fontSize: 16)),
            Text('Manufacture Date: ${_formatDate(data['manufacture_date'])}',
                style: TextStyle(fontSize: 16)),
            Text('Expiry Date: ${_formatDate(data['expiry_date'])}',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text('Select Quantity:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () => setState(() {
                    if (quantity > 1) quantity--;
                  }),
                ),
                Text('$quantity'),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => setState(() {
                    quantity++;
                  }),
                ),
              ],
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                child: Text('Buy Now'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CustomerOrderConfirmationPage(
                        medicineId: widget.medicineId,
                        medicineData: data,
                        quantity: quantity,
                        customerEmail: widget.customerEmail, // ✅ Add this
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
