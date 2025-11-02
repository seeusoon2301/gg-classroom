// lib/profile_tab.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signin.dart';
import 'change_password.dart';

class ProfileTab extends StatelessWidget {
  final String name;
  final String email;
  final String photoURL;
  
  const ProfileTab({
    super.key,
    required this.name,
    required this.email,
    required this.photoURL,
  });
  
  // void _logout(BuildContext context) async {
  //   await FirebaseAuth.instance.signOut();
  //   Navigator.pushReplacementNamed(context, '/login');
  // }

  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignIn()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    
    String avatarLetter =
        name.isNotEmpty ? name[0].toUpperCase() : 'U'; // chữ cái đầu

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8BC34A), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          )
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),
      
            // Avatar + Tên + Email
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue[300],
              backgroundImage:
                  photoURL.isNotEmpty ? NetworkImage(photoURL) : null,
              child: photoURL.isEmpty
                  ? Text(
                      avatarLetter,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              name.isNotEmpty ? name : "Đang tải...",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
      
            const SizedBox(height: 30),
      
            Container(
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                          _buildMenuItem(Icons.lock_reset, 'Change your password', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
            );
          }),
      
                  _divider(),
                  _buildMenuItem(Icons.settings, 'Settings', () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('New functions are coming soon')),
                    );
                  }),
                  _divider(),
                  _buildMenuItem(
                    Icons.logout,
                    'Log out',
                    () => _logout(context),
                    isLogout: true,
                  ),
                ],
              ),
            ),
      
            const SizedBox(height: 50),
            const Text(
              "© 2025 SchoolTime. All rights reserved.",
              style: TextStyle(color: Colors.black, fontSize: 13,fontWeight: FontWeight.bold,),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 15, endIndent: 15);

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap,
      {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : Colors.black),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.red : Colors.black,
          fontSize: 16,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
