import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class VendorSpecificMedicinePage extends StatefulWidget {
  final String medicineId;
  final Map<String, dynamic> medicineData;

  VendorSpecificMedicinePage({
    required this.medicineId,
    required this.medicineData,
  });

  @override
  _VendorSpecificMedicinePageState createState() => _VendorSpecificMedicinePageState();
}

class _VendorSpecificMedicinePageState extends State<VendorSpecificMedicinePage> {
  late TextEditingController _companyController;
  late TextEditingController _tabletNameController;
  late TextEditingController _doseController;
  late TextEditingController _tabletsPerStripController;
  late TextEditingController _stripRateController;
  late TextEditingController _quantityController;
  DateTime? _manufactureDate;
  DateTime? _expiryDate;

  @override
  void initState() {
    super.initState();
    final data = widget.medicineData;

    _companyController = TextEditingController(text: data['company_name'] ?? '');
    _tabletNameController = TextEditingController(text: data['tablet_name'] ?? '');
    _doseController = TextEditingController(text: data['mg']?.toString() ?? '');
    _tabletsPerStripController = TextEditingController(text: data['tablets_per_strip']?.toString() ?? '');
    _stripRateController = TextEditingController(text: data['strip_rate']?.toString() ?? '');
    _quantityController = TextEditingController(text: data['quantity']?.toString() ?? '');

    _manufactureDate = data['manufacture_date'] is Timestamp
        ? (data['manufacture_date'] as Timestamp).toDate()
        : null;

    _expiryDate = data['expiry_date'] is Timestamp
        ? (data['expiry_date'] as Timestamp).toDate()
        : null;
  }

  Future<void> _selectDate(BuildContext context, bool isExpiry) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isExpiry ? (_expiryDate ?? DateTime.now()) : (_manufactureDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isExpiry) {
          _expiryDate = picked;
        } else {
          _manufactureDate = picked;
        }
      });
    }
  }

  Future<void> _updateMedicine() async {
    await FirebaseFirestore.instance.collection('medicines').doc(widget.medicineId).update({
      'company': _companyController.text.trim(),
      'tablet_name': _tabletNameController.text.trim(),
      'mg': _doseController.text.trim(),
      'tablets_per_strip': int.tryParse(_tabletsPerStripController.text.trim()) ?? 0,
      'strip_rate': double.tryParse(_stripRateController.text.trim()) ?? 0,
      'quantity': int.tryParse(_quantityController.text.trim()) ?? 0,
      'manufacture_date': _manufactureDate != null ? Timestamp.fromDate(_manufactureDate!) : null,
      'expiry_date': _expiryDate != null ? Timestamp.fromDate(_expiryDate!) : null,
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Medicine updated successfully.")));
  }

  Future<void> _deleteMedicine() async {
    await FirebaseFirestore.instance.collection('medicines').doc(widget.medicineId).delete();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _companyController.dispose();
    _tabletNameController.dispose();
    _doseController.dispose();
    _tabletsPerStripController.dispose();
    _stripRateController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Medicine'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteMedicine,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextFormField(
              controller: _companyController,
              decoration: InputDecoration(labelText: 'Company Name'),
            ),
            TextFormField(
              controller: _tabletNameController,
              decoration: InputDecoration(labelText: 'Tablet Name'),
            ),
            TextFormField(
              controller: _doseController,
              decoration: InputDecoration(labelText: 'Dose (mg)'),
            ),
            TextFormField(
              controller: _tabletsPerStripController,
              decoration: InputDecoration(labelText: 'Tablets Per Strip'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _stripRateController,
              decoration: InputDecoration(labelText: 'Strip Rate'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(labelText: 'Quantity in Stock'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                int quantity = int.tryParse(value) ?? 0;
                if (quantity <= 0) {
                  _deleteMedicine();
                }
              },
            ),
            ListTile(
              title: Text('Manufacture Date'),
              subtitle: Text(_manufactureDate != null ? dateFormat.format(_manufactureDate!) : 'Select Date'),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, false),
            ),
            ListTile(
              title: Text('Expiry Date'),
              subtitle: Text(_expiryDate != null ? dateFormat.format(_expiryDate!) : 'Select Date'),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, true),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateMedicine,
              child: Text('Update Medicine'),
            ),
          ],
        ),
      ),
    );
  }
}
