import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:imageniaa_app/screens/login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isPasswordVisible = false;

  final _formKey = GlobalKey<FormState>();

  bool validateEmail(String email) {
    final validDomain = "@punjab.gov.pk";
    final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");

    return emailRegex.hasMatch(email) && email.toLowerCase().endsWith(validDomain);
  }




  bool validatePassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password) &&
        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
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
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Create Your Account',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                          const SizedBox(height: 20),
                          buildTextFormField(
                            controller: usernameController,
                            prefixIcon: Icons.person,
                            labelText: 'Username',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Username is required";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16.0),
                          buildTextFormField(
                            controller: emailController,
                            prefixIcon: Icons.email,
                            labelText: 'Email',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Email is required";
                              }
                              if (!validateEmail(value)) {
                                return "Enter a valid police email";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16.0),
                          buildTextFormField(
                            controller: passwordController,
                            prefixIcon: Icons.lock,
                            labelText: 'Password',
                            isPassword: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Password is required";
                              }
                              if (!validatePassword(value)) {
                                return "Password must be 8+ chars with uppercase, number & symbol";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16.0),
                          buildTextFormField(
                            controller: confirmPasswordController,
                            prefixIcon: Icons.lock,
                            labelText: 'Confirm Password',
                            isPassword: true,
                            validator: (value) {
                              if (value == null || value != passwordController.text) {
                                return "Passwords do not match";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20.0),
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                try {
                                  FirebaseAuth auth = FirebaseAuth.instance;
                                  UserCredential userCredential = await auth.createUserWithEmailAndPassword(
                                    email: emailController.text,
                                    password: passwordController.text,
                                  );
                                  if (userCredential.user != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("User signed up successfully")),
                                    );
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => LoginScreen()),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Signup failed: $e")),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF3B82F6),
                              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                            ),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Already have an account? '),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Login',
                                  style: TextStyle(color: Color(0xFF3B82F6)),
                                ),
                              ),
                            ],
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

  TextFormField buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !isPasswordVisible,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Color(0xFF1E3A8A)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: Color(0xFFCCCCCC)),
        ),
        prefixIcon: Icon(prefixIcon, color: Color(0xFF1E3A8A)),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Color(0xFF1E3A8A),
          ),
          onPressed: () {
            setState(() {
              isPasswordVisible = !isPasswordVisible;
            });
          },
        )
            : null,
      ),
    );
  }
}
