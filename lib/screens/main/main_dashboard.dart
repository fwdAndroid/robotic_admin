import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:robotic_admin/screens/main/pages/account_screen.dart';
import 'package:robotic_admin/screens/main/pages/staff_request_screen.dart';
import 'package:robotic_admin/screens/main/pages/staff_screen.dart';
import 'package:robotic_admin/screens/main/pages/user_screen.dart';

class MainDashboard extends StatefulWidget {
  final int initialPageIndex; // new

  const MainDashboard({super.key, this.initialPageIndex = 0});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    StaffScreen(), // Replace with your screen widgets
    StaffRequestScreen(), // Assuming this is a valid screen
    UserScreen(),
    AccountScreen(),
  ];
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialPageIndex;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await _showExitDialog(context);
        return shouldPop ?? false;
      },
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.blue,
          selectedItemColor: Colors.white,
          selectedLabelStyle: TextStyle(color: Colors.white),
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.person_2, size: 25, color: Color(0xff0A5EFE)),
              label: "Staff",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.request_page,
                size: 25,
                color: Color(0xff0A5EFE),
              ),
              label: "Staff Request",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 25, color: Color(0xff0A5EFE)),
              label: "Users",
            ),

            BottomNavigationBarItem(
              label: "Account",
              icon: Icon(Icons.settings, size: 25, color: Color(0xff0A5EFE)),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exit App'),
        content: Text('Do you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              if (Platform.isAndroid) {
                SystemNavigator.pop(); // For Android
              } else if (Platform.isIOS) {
                exit(0); // For iOS
              }
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }
}
