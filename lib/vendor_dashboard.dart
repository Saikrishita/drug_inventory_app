import 'package:flutter/material.dart';
import 'add_medicine_page.dart';
import 'vendor_orders_page.dart';
import 'vendor_txn_page.dart';
import 'vendor_medicine_list_page.dart';

class VendorDashboard extends StatelessWidget {
  final String vendorName;
  final String companyName;

  const VendorDashboard({
    super.key,
    required this.vendorName,
    required this.companyName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome $vendorName from $companyName'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add New Medicine'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 177, 198, 83),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddMedicinePage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.list),
              label: const Text('View All Medicines'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VendorMedicineListPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.shopping_cart),
              label: const Text('View Orders'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VendorOrdersPage(companyName: companyName),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.receipt_long),
              label: const Text('Transaction History'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 231, 169, 233),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VendorTxnPage(
                      vendorName: vendorName,
                      companyName: companyName,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
