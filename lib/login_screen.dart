import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
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
            child: SingleChildScrollView( // Added SingleChildScrollView here
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8EB8FF).withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Welcome to Imagenia',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                          const SizedBox(height: 20),
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
                            suffixIcon: Icons.visibility_off_outlined,
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
                          const SizedBox(height: 20.0),
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                var email = emailController.text;
                                var password = passwordController.text;
                                try {
                                  UserCredential userCredential = await FirebaseAuth.instance
                                      .signInWithEmailAndPassword(email: email, password: password);
                                  if (userCredential != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Login successfully"),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => DashboardScreen()),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Login failed: $e"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF3B82F6),
                              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () async {
                              if (emailController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Please enter your email address"),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }

                              try {
                                await FirebaseAuth.instance
                                    .sendPasswordResetEmail(email: emailController.text);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Password reset email sent"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Error: $e"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(color: Color(0xFF1E3A8A)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
                                if (googleUser != null) {
                                  final GoogleSignInAuthentication googleAuth =
                                  await googleUser.authentication;
                                  final AuthCredential credential = GoogleAuthProvider.credential(
                                    accessToken: googleAuth.accessToken,
                                    idToken: googleAuth.idToken,
                                  );
                                  await FirebaseAuth.instance.signInWithCredential(credential);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => DashboardScreen()),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Google sign-in failed: $e"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(color: Color(0xFFCCCCCC)),
                              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                            ),
                            icon: Icon(Icons.login, color: Color(0xFF3B82F6)),
                            label: Text(
                              'Sign in with Google',
                              style: TextStyle(color: Color(0xFF3B82F6)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Do you have an account? '),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/signup');
                                },
                                child: const Text(
                                  'Sign Up',
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
    IconData? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Color(0xFF1E3A8A)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: Color(0xFFCCCCCC)),
        ),
        prefixIcon: Icon(prefixIcon, color: Color(0xFF1E3A8A)),
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Color(0xFF1E3A8A)) : null,
      ),
    );
  }
}
