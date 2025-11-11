import 'package:flutter/material.dart';
import 'dart:ui';
import 'signin.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  _ForgetPasswordScreenState createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _emailController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  bool _isSending = false;
  String message = "";

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
    return emailRegex.hasMatch(email) &&
        (email.endsWith('@gmail.com') || email.endsWith('@yahoo.com'));
  }

  Future<void> _sendResetEmail() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => message = "Please enter your email!");
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() => message = "Invalid email format. Only @gmail.com or @yahoo.com domains are supported.");
      return;
    }

    setState(() {
      _isSending = true;
      message = "";
    });

    try {
      await _auth.sendPasswordResetEmail(email: email);
      setState(() => message = "Liên kết đặt lại mật khẩu đã gửi tới $email.");
      await Future.delayed(Duration(seconds: 2));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignIn()),
      );
    } on FirebaseAuthException catch (e) {
      String msg = "Something went wrong.Please try again.";
      if (e.code == 'user-not-found') msg = 'This email is not registered.';
      if (e.code == 'invalid-email') msg = 'The email format is invalid.';
      if (e.code == 'too-many-requests') msg = 'Too many attempts. Please try again later.';
      setState(() => message = msg);
    } catch (e) {
      setState(() => message = "Something went wrong: $e");
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignIn()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Image.asset(
            "images/bg.png",
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),

          // Form container
          Center(
            child: SingleChildScrollView(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: EdgeInsets.all(25),
                    margin: EdgeInsets.symmetric(horizontal: 25),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.green, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(2, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_reset, size: 80, color: Colors.green),
                        SizedBox(height: 15),
                        Text(
                          'Password Recovery',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 25),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(color: Colors.green),
                            prefixIcon: Icon(Icons.email, color: Colors.green),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: Colors.green, width: 1.5),
                            ),
                            errorText: !_isValidEmail(_emailController.text.trim()) &&
                                    _emailController.text.isNotEmpty
                                ? 'Only @gmail.com or @yahoo.com'
                                : null,
                          ),
                          style: TextStyle(color: Colors.black),
                          onChanged: (value) => setState(() {}),
                        ),
                        SizedBox(height: 20),

                        // Message hiển thị
                        if (message.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                            margin: EdgeInsets.only(bottom: 15),
                            decoration: BoxDecoration(
                              color: message.contains("Liên kết") ? Colors.green[200] : Colors.red[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  message.contains("Liên kết") ? Icons.check_circle : Icons.error,
                                  color: message.contains("Liên kết") ? Colors.green : Colors.red,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    message,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        ElevatedButton(
                          onPressed: _isSending ? null : _sendResetEmail,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: _isSending
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text('Send Reset Link', style: TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                        SizedBox(height: 15),
                        GestureDetector(
                          onTap: _navigateToLogin,
                          child: Text(
                            "Back to Login",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
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
}


