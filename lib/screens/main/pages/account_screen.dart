import 'package:flutter/material.dart';
import 'package:robotic_admin/screens/auth/login_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: Image.asset('assets/logo.png', height: 200)),
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Color(0xff00843D)),
            title: Text("Logout"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (builder) => LoginScreen()),
              );
              // Navigate to profile screen
            },
          ),
        ],
      ),
    );
  }
}
