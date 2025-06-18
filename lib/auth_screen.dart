import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _orgController = TextEditingController();

  String _selectedRole = 'hospital';

  Future<void> _signUpUser() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim());

      // Save role, name, and hospital/company to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'role': _selectedRole,
        'email': _emailController.text.trim(),
        'name': _nameController.text.trim(),
        'organization': _orgController.text.trim(), // Unified key
      });

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign up: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Full Name"),
            ),
            TextField(
              controller: _orgController,
              decoration: InputDecoration(
                labelText: _selectedRole == 'hospital'
                    ? "Hospital Name"
                    : "Company Name",
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text("I am a: "),
                Expanded(
                  child: ListTile(
                    title: const Text("Customer from a Hospital"),
                    leading: Radio<String>(
                      value: 'hospital',
                      groupValue: _selectedRole,
                      onChanged: (value) {
                        setState(() => _selectedRole = value!);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text("Vendor"),
                    leading: Radio<String>(
                      value: 'vendor',
                      groupValue: _selectedRole,
                      onChanged: (value) {
                        setState(() => _selectedRole = value!);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signUpUser,
              child: const Text("Sign Up"),
            )
          ],
        ),
      ),
    );
  }
}
