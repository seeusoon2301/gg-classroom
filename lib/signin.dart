import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gg_classroom/signup.dart';
import 'home_screen.dart';
import 'forget_password_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool _obscurePassword = true;
  String message = "";

  Future<void> _signIn() async {
    setState(() {
      isLoading = true;
      message = "";
    });

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        message = "Please enter both email and password.";
        isLoading = false;
      });
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      Future.delayed(const Duration(milliseconds: 400), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      });
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'invalid-credential':
        case 'user-not-found':
        case 'wrong-password':
          errorMessage = 'Incorrect email or password.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Please try again later.';
          break;
        default:
          errorMessage = 'Login failed. Please try again.';
      }
      setState(() => message = errorMessage);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<UserCredential?> loginWithGoogle() async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        // Web
        await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);

        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('profile');
        googleProvider.addScope('email');
        googleProvider.setCustomParameters({'prompt': 'select_account'});
        userCredential = await FirebaseAuth.instance.signInWithPopup(googleProvider);

        await userCredential.user?.reload();
      } else {
        GoogleSignIn googleSignIn = GoogleSignIn();
        await googleSignIn.signOut();

        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return null;

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      }

      final user = userCredential.user;
      if (user != null) {
        final dbRef = FirebaseDatabase.instance.ref("users/${user.uid}");
        await dbRef.update({
          "uid": user.uid,
          "name": user.displayName ?? "No Name",
          "email": user.email ?? "",
          "photoUrl": user.photoURL ?? "https://ui-avatars.com/api/?name=${Uri.encodeComponent(user.displayName ?? "User")}",
          "loginMethod": "google",
          "createdAt": DateTime.now().toIso8601String(),
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
      return userCredential;
    } catch (e) {
      setState(() => message = "Google login failed.");
      //print("Google login error: $e");
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            "images/bg.png",
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.12),
                      blurRadius: 18,
                      spreadRadius: 3,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Welcome Back 👋",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "Continue your learning journey!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black.withOpacity(.8),
                      ),
                    ),

                    const SizedBox(height: 30),

                    _inputField(
                      controller: emailController,
                      hint: "Email address",
                      icon: Icons.email,
                    ),
                    const SizedBox(height: 16),

                    _inputField(
                      controller: passwordController,
                      hint: "Password",
                      icon: Icons.lock,
                      obscure: true,
                    ),

                    const SizedBox(height: 6),

                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ForgetPasswordScreen()),
                        ),
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                              color: Color(0xFF2F855A),
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    if (message.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: message.contains("success")
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              message.contains("success")
                                  ? Icons.check_circle
                                  : Icons.error,
                              color: message.contains("success")
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                message,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                            )
                          ],
                        ),
                      ),

                    const SizedBox(height: 18),

                    GestureDetector(
                      onTap: isLoading ? null : _signIn,
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8BC34A), Color.fromARGB(255, 40, 170, 84)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  strokeWidth: 3, color: Colors.white)
                              : const Text(
                                  "Sign In",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? "),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SignUp()),
                          ),
                          child: const Text(
                            "Create Account",
                            style: TextStyle(
                              color: Color(0xFF2F855A),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 22),

                    GestureDetector(
                      onTap: loginWithGoogle,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.black12),
                          color: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("images/google.png", height: 28),
                            const SizedBox(width: 10),
                            const Text(
                              "Continue with Google",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    bool obscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black26),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure ? _obscurePassword : false,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Color(0xFF2F855A)),
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
          suffixIcon: obscure
              ? IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                )
              : null,
        ),
      ),
    );
  }
}
