import 'package:flutter/material.dart';
import 'package:robotic_admin/screens/main/main_dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: Image.asset('assets/logo.png', height: 200)),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Password"),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      loginAdmin();
                    },
                    child: Text("Login", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),

                      backgroundColor: Color(0xff0A5EFE),
                      fixedSize: Size(285, 54),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
  //Functions

  Future<void> loginAdmin() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('admin')
          .where('email', isEqualTo: email)
          .where(
            'password',
            isEqualTo: password,
          ) // ⚠️ For security, hash this in real apps
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Success
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Login successful")));
        // Navigate to admin dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainDashboard()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Invalid credentials")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => isLoading = false);
  }
}
