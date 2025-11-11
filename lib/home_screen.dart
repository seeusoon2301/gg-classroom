import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'signin.dart';
import 'profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String userName = "User";
  String userEmail = "";
  String userPhoto = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String name = user.displayName ?? "User";
      String email = user.email ?? "";
      String photo = user.photoURL ?? "";

      final uid = user.uid;
      final dbRef = FirebaseDatabase.instance.ref().child("users").child(uid);
      final snapshot = await dbRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        name = data["name"] ?? name;
        email = data["email"] ?? email;
        photo = data["photoURL"] ?? photo;
      }

      setState(() {
        userName = name;
        userEmail = email;
        userPhoto = photo;
      });
    }
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() async {
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
    final List<Widget> _screens = [
      _buildHomeBody(), // Home
      const Center(child: Text('Classes Tab')),
      const Center(child: Text('Assignments Tab')),
      ProfileTab(
        name: userName,
        email: userEmail,
        photoURL: userPhoto,
      ), // Profile Tab
    ];

    return Scaffold(
      drawer: _buildDrawer(),
      body: _screens[_selectedIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userName),
            accountEmail: Text(userEmail),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.green[300],
              backgroundImage:
                  userPhoto.isNotEmpty ? NetworkImage(userPhoto) : null,
              child: userPhoto.isEmpty
                  ? Text(
                      userName.isNotEmpty ? userName[0] : "U",
                      style:
                          const TextStyle(fontSize: 24, color: Colors.white),
                    )
                  : null,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF4285F4),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.class_, color: Color(0xFF4285F4)),
            title: const Text('Your class'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading:
                const Icon(Icons.calendar_today, color: Color(0xFF4285F4)),
            title: const Text('Calendar'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.assignment, color: Color(0xFF4285F4)),
            title: const Text('Homework'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Color(0xFF4285F4)),
            title: const Text('Log out'),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildHomeBody() {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF8BC34A), Colors.white],
                stops: [0.0, 0.8],
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.25,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4E1A7E), Color(0xFFC09ADF)],
              ),
              boxShadow: [
                BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 15,
                    offset: Offset(0, 5))
              ],
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(20.0)),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Builder(
                  builder: (context) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.menu,
                                color: Colors.white, size: 30),
                            onPressed: () =>
                                Scaffold.of(context).openDrawer(),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 15.0),
                            child: Text(
                              'School Time',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(1, 1),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications,
                                color: Colors.white, size: 30),
                            onPressed: () =>
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Notifications clicked!'))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              Text(
                                userEmail,
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white70),
                              ),
                            ],
                          ),
                          const Spacer(),
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.blue[300],
                            backgroundImage: userPhoto.isNotEmpty
                                ? NetworkImage(userPhoto)
                                : null,
                            child: userPhoto.isEmpty
                                ? Text(
                                    userName.isNotEmpty ? userName[0] : "U",
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  )
                                : null,
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
        Positioned(
          top: MediaQuery.of(context).size.height * 0.15,
          left: MediaQuery.of(context).size.width * 0.05,
          right: MediaQuery.of(context).size.width * 0.05,
          bottom: MediaQuery.of(context).size.height * 0.075,
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildInfoCard(Icons.book, 'What’s next',
                            'Geometric weekly test', Colors.orange, '2 days to go'),
                        _buildInfoCard(Icons.play_circle_fill, 'Next Class',
                            'Geometric Video Class', Colors.blue, 'in 20-59 min'),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          children: [
                            _buildGridTile('Syllabus', 'What to learn',
                                Colors.blue[300]!, Icons.book),
                            _buildGridTile('Calendar', 'View schedule',
                                Colors.purple[300]!, Icons.calendar_today),
                            _buildGridTile(
                                'Tests',
                                'What to learn',
                                Colors.orange[300]!,
                                Icons.quiz),
                            _buildGridTile('Insights', 'Performance',
                                Colors.pink[300]!, Icons.analytics),
                            _buildGridTile('Faculty', 'List of teachers',
                                Colors.green[300]!, Icons.school),
                            _buildGridTile('Messages', 'All conversations',
                                Colors.teal[300]!, Icons.message),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ✅ Giữ nguyên các hàm gốc
  Widget _buildInfoCard(IconData icon, String title, String subtitle,
      Color color, String time) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          const BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                Text(subtitle,
                    style:
                        const TextStyle(fontSize: 14, color: Colors.black54)),
                Text(time,
                    style: TextStyle(
                        fontSize: 14,
                        color: color,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridTile(
      String title, String subtitle, Color color, IconData icon) {
    return InkWell(
      onTap: () => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Opening $title'))),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            Text(subtitle,
                style:
                    const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(25.0)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4E1A7E), Color(0xFFC09ADF)],
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, -2))
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.class_), label: 'Classes'),
            BottomNavigationBarItem(
                icon: Icon(Icons.assignment), label: 'Assignments'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person), label: 'Profile'),
          ],
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          elevation: 0,
        ),
      ),
    );
  }
}
