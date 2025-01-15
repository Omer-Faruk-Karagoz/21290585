import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String _gender = "Male";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = data['firstName'] ?? '';
          _surnameController.text = data['lastName'] ?? '';
          _usernameController.text = data['username'] ?? '';
          _ageController.text = data['age']?.toString() ?? '';
          _gender = data['gender'] ?? 'Male';
        });
      }
    }
  }

  Future<void> _updateUserProfile() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'firstName': _nameController.text,
          'lastName': _surnameController.text,
          'username': _usernameController.text,
          'age': int.tryParse(_ageController.text) ?? 0,
          'gender': _gender,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile updated successfully")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "First Name"),
              ),
              TextField(
                controller: _surnameController,
                decoration: InputDecoration(labelText: "Last Name"),
              ),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: "Username"),
              ),
              TextField(
                controller: _ageController,
                decoration: InputDecoration(labelText: "Age"),
                keyboardType: TextInputType.number,
              ),
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
              Center(
                child: ElevatedButton(
                  onPressed: _updateUserProfile,
                  child: Text("Update Profile"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
