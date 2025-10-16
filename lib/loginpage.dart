import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

// --- 1. THE UI: Login Screen (Purely Visual) ---

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    if (_formKey.currentState!.validate()) {
      print('Login submitted for Email: ${_emailController.text}');
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    bool isPassword = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    TextInputAction? textInputAction,
    VoidCallback? onEditingComplete,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        validator: validator,
        style: const TextStyle(color: Colors.black87),
        textInputAction: textInputAction,
        onEditingComplete: onEditingComplete,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w500),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: InputBorder.none,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bool isLoading = false;
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth > 400 ? 360.0 : screenWidth * 0.9;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            width: contentWidth,
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Lock Icon
                  Icon(
                    Icons.lock_open,
                    size: 80,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(height: 20),

                  // Welcome Text
                  const Text(
                    'Welcome back, you\'ve been missed!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- Email Input ---
                  _buildInputField(
                    controller: _emailController,
                    hintText: 'Enter email',
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || !value.contains('@')) {
                        return 'Please enter a valid email.';
                      }
                      return null;
                    },
                  ),

                  // --- Password Input and Forgot Password Link ---
                  _buildInputField(
                    controller: _passwordController,
                    hintText: 'Enter password',
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    onEditingComplete: _submitLogin,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Password must be at least 6 characters.';
                      }
                      return null;
                    },
                    suffixIcon: TextButton(
                      onPressed: () {
                        print('Forgot Password? button pressed');
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.indigo.shade400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),

                  // --- Login Button ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      //ignore: dead_code
                      onPressed: isLoading ? null : _submitLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // --- Divider and Google Sign-In Label ---
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text('Or Sign In With', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- Google Button ---
                  InkWell(
                    // Note: 'dead_code' ignore is for the 'isLoading ? null' part
                    onTap: isLoading ? null : loginwithGoogle,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                           BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/google_logo.png',
                          height: 30,
                          width: 30,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  } // <--- build method ends her
  Future<void> loginwithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        print('Google sign-in aborted by user');
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print('Google Sign-In successful. Access Token: ${googleAuth.accessToken}');
    } catch (error) {
      print('Error during Google sign-in: $error');
    }
  }
} // <--- _LoginScreenState class ends here 