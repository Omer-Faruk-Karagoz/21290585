import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _ageController = TextEditingController();
  String _gender = "Male";

  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: "Password"), obscureText: true),
            TextField(controller: _nameController, decoration: InputDecoration(labelText: "First Name")),
            TextField(controller: _surnameController, decoration: InputDecoration(labelText: "Last Name")),
            TextField(controller: _usernameController, decoration: InputDecoration(labelText: "Username")),
            TextField(controller: _ageController, decoration: InputDecoration(labelText: "Age"), keyboardType: TextInputType.number),
            DropdownButton<String>(
              value: _gender,
              onChanged: (String? newValue) {
                setState(() {
                  _gender = newValue!;
                });
              },
              items: <String>['Male', 'Female', 'Other']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String result = await _firebaseService.registerUser(
                  _emailController.text,
                  _passwordController.text,
                  _nameController.text,
                  _surnameController.text,
                  _usernameController.text,
                  int.parse(_ageController.text),
                  _gender,
                );
                if (result == "success") {
                  Navigator.pushReplacementNamed(context, '/login');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
                }
              },
              child: Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}
