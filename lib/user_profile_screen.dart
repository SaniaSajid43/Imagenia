import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool isEditing = false;
  bool obscureText = true;

  // Controllers to manage input fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late User user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
    _loadUserData();
  }

  // Fetch user data from Firestore
  _loadUserData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;

    setState(() {
      nameController.text = userData['name'] ?? '';
      emailController.text = userData['email'] ?? '';
    });
  }

  // Update profile data in Firestore
  _updateProfile() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'name': nameController.text,
        'email': emailController.text,
      });

      if (passwordController.text.isNotEmpty) {
        await user.updatePassword(passwordController.text);
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
      setState(() {
        isEditing = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Toggle password visibility
  _togglePasswordVisibility() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: const Color(0xFF8EB8FF),
                            child: const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          buildProfileTextField(
                            label: 'Name',
                            controller: nameController,
                            isEditable: isEditing,
                          ),
                          const SizedBox(height: 16),
                          buildProfileTextField(
                            label: 'Email',
                            controller: emailController,
                            isEditable: isEditing,
                          ),
                          const SizedBox(height: 16),
                          if (isEditing)
                            TextField(
                              controller: passwordController,
                              obscureText: obscureText,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  ),
                                  onPressed: _togglePasswordVisibility,
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              if (isEditing) {
                                _updateProfile();
                              } else {
                                setState(() {
                                  isEditing = !isEditing;
                                });
                              }
                            },
                            child: Text(isEditing ? 'Save Profile' : 'Edit Profile'),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () {
                              FirebaseAuth.instance.signOut();
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            child: const Text('Log Out'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for Profile TextFields
  Widget buildProfileTextField({
    required String label,
    required TextEditingController controller,
    required bool isEditable,
  }) {
    return isEditable
        ? TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
    )
        : Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCCCCCC)),
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade100,
      ),
      child: Text(
        controller.text,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
