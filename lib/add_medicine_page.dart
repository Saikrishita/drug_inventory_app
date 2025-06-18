import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddMedicinePage extends StatefulWidget {
  @override
  _AddMedicinePageState createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _tabletNameController = TextEditingController();
  final TextEditingController _mgController = TextEditingController();
  final TextEditingController _tabletsPerStripController = TextEditingController();
  final TextEditingController _stripRateController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  DateTime? _manufactureDate;
  DateTime? _expiryDate;

  Future<void> _selectDate(BuildContext context, bool isManufacture) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isManufacture) {
          _manufactureDate = picked;
        } else {
          _expiryDate = picked;
        }
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _manufactureDate != null &&
        _expiryDate != null) {
      await FirebaseFirestore.instance.collection('medicines').add({
        'company_name': _companyNameController.text.trim(),
        'tablet_name': _tabletNameController.text.trim(),
        'mg': _mgController.text.trim(),
        'tablets_per_strip': int.parse(_tabletsPerStripController.text.trim()),
        'strip_rate': double.parse(_stripRateController.text.trim()),
        'quantity': int.parse(_quantityController.text.trim()),
        'manufacture_date': _manufactureDate,
        'expiry_date': _expiryDate,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Medicine added successfully!')));
      _formKey.currentState!.reset();
      setState(() {
        _manufactureDate = null;
        _expiryDate = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Medicine')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _companyNameController,
                decoration: InputDecoration(labelText: 'Company Name'),
                validator: (value) => value!.isEmpty ? 'Enter company name' : null,
              ),
              TextFormField(
                controller: _tabletNameController,
                decoration: InputDecoration(labelText: 'Tablet Name'),
                validator: (value) => value!.isEmpty ? 'Enter tablet name' : null,
              ),
              TextFormField(
                controller: _mgController,
                decoration: InputDecoration(labelText: 'Dosage (mg)'),
                validator: (value) => value!.isEmpty ? 'Enter dosage' : null,
              ),
              TextFormField(
                controller: _tabletsPerStripController,
                decoration: InputDecoration(labelText: 'Tablets per Strip'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Enter tablets per strip' : null,
              ),
              TextFormField(
                controller: _stripRateController,
                decoration: InputDecoration(labelText: 'Strip Rate (₹)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Enter strip rate' : null,
              ),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: 'Quantity in Stock'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Enter quantity' : null,
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text(
                  _manufactureDate == null
                      ? 'Select Manufacture Date'
                      : 'Manufacture Date: ${_manufactureDate!.toLocal()}'.split(' ')[0],
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, true),
              ),
              ListTile(
                title: Text(
                  _expiryDate == null
                      ? 'Select Expiry Date'
                      : 'Expiry Date: ${_expiryDate!.toLocal()}'.split(' ')[0],
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, false),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Add Medicine'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
