import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gg_classroom/signin.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUp extends StatefulWidget {
const SignUp({super.key});

@override
State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
final TextEditingController fullnameController = TextEditingController();
final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
final TextEditingController confirmController = TextEditingController();

final FirebaseAuth _auth = FirebaseAuth.instance;
final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("users");

bool isLoading = false;
bool _obscurePassword = true;
bool _obscureConfirm = true;
String message = "";

Future<void> _signUp() async {
String fullname = fullnameController.text.trim();
String email = emailController.text.trim();
String password = passwordController.text.trim();
String confirm = confirmController.text.trim();

if (fullname.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
  setState(() => message = "Please fill in all fields!");
  return;
}
if (password != confirm) {
  setState(() => message = "Passwords do not match!");
  return;
}

setState(() {
  isLoading = true;
  message = "";
});

try {
  UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(email: email, password: password);

  User? user = userCredential.user;
  String uid = user!.uid;

  await _dbRef.child(uid).set({
    "uid": uid,
    "loginMethod": "email",
    "name": fullname,
    "email": email,
    "photoURL": "",
    "createdAt": DateTime.now().toIso8601String(),
  });

  setState(() => message = "Account created successfully!");

  // ✅ Gửi email xác nhận đăng ký thành công
  try {
    final serverUrl = "https://gg-classroom-test.vercel.app/api/send-mail";

    final response = await http.post(
      Uri.parse(serverUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email, // phải khớp với NodeJS nhận
        "name": fullname,
      }),
    );

    print("📤 Email API status: ${response.statusCode}");
    print("📤 Email API body: ${response.body}");
  } catch (e) {
    print("❌ Failed to send email: $e");
  }

  // ✅ Chuyển sang màn hình đăng nhập
  Future.delayed(const Duration(seconds: 1), () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignIn()),
    );
  });
} on FirebaseAuthException catch (e) {
  String msg = "Unknown error!";
  if (e.code == 'email-already-in-use') msg = "Email already in use!";
  if (e.code == 'weak-password') msg = "Weak password!";
  if (e.code == 'invalid-email') msg = "Invalid email format!";
  setState(() => message = msg);
} finally {
  setState(() => isLoading = false);
}

}

@override
Widget build(BuildContext context) {
return Scaffold(
body: Stack(
children: [
Positioned.fill(
child: Image.asset("images/bg.png", fit: BoxFit.cover),
),
Center(
child: SingleChildScrollView(
padding: const EdgeInsets.symmetric(horizontal: 32),
child: Container(
padding: const EdgeInsets.all(25),
decoration: BoxDecoration(
color: Colors.white.withOpacity(0.92),
borderRadius: BorderRadius.circular(20),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.15),
blurRadius: 20,
offset: const Offset(0, 6),
)
],
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text("Create Account",
style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
const Text("Start your study journey!",
style: TextStyle(fontSize: 16, color: Colors.grey)),
const SizedBox(height: 25),

                _inputField(
                    controller: fullnameController,
                    hint: "Full Name",
                    icon: Icons.person,
                    isName: true),
                const SizedBox(height: 15),
                _inputField(
                    controller: emailController,
                    hint: "Email",
                    icon: Icons.email_rounded),
                const SizedBox(height: 15),
                _inputField(
                    controller: passwordController,
                    hint: "Password",
                    icon: Icons.lock,
                    obscure: true,
                    isPassword: true),
                const SizedBox(height: 15),
                _inputField(
                    controller: confirmController,
                    hint: "Confirm Password",
                    icon: Icons.lock_outline,
                    obscure: true,
                    isConfirm: true),
                const SizedBox(height: 20),

                if (message.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: message.contains("success")
                          ? Colors.green[200]
                          : Colors.red[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                const SizedBox(height: 20),

                GestureDetector(
                  onTap: isLoading ? null : _signUp,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8BC34A), Color.fromARGB(255, 40, 170, 84)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Sign Up",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SignIn())),
                    child: const Text(
                      "Already have an account? Sign in",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                  ),
                )
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
bool isName = false,
bool isPassword = false,
bool isConfirm = false,
}) {
return TextField(
controller: controller,
obscureText: obscure ? (isConfirm ? _obscureConfirm : _obscurePassword) : false,
decoration: InputDecoration(
prefixIcon: icon != null ? Icon(icon, color: Colors.green) : null,
hintText: hint,
filled: true,
fillColor: Colors.white,
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
suffixIcon: obscure
? IconButton(
icon: Icon(
isConfirm
? (_obscureConfirm ? Icons.visibility_off : Icons.visibility)
: (_obscurePassword ? Icons.visibility_off : Icons.visibility),
color: Colors.grey,
),
onPressed: () {
setState(() {
if (isConfirm) {
_obscureConfirm = !_obscureConfirm;
} else {
_obscurePassword = !_obscurePassword;
}
});
},
)
: null,
),
);
}
}
