import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:robotic_admin/screens/add/add_staff_screen.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  Future<void> _deleteStaff(String staffId) async {
    try {
      await FirebaseFirestore.instance
          .collection('staff')
          .doc(staffId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Staff member deleted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error deleting staff: $e")));
    }
  }

  void _showDeleteDialog(String staffId, String staffName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Staff Member"),
        content: Text("Are you sure you want to delete $staffName?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(context);
              _deleteStaff(staffId);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('staff')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person, size: 50, color: Colors.grey),
                  const SizedBox(height: 10),
                  const Text(
                    "No staff member added",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final staffList = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: staffList.length,
            itemBuilder: (context, index) {
              final staff = staffList[index];
              final staffId = staff['id']; // UUID field
              final name = staff['name'] ?? 'No Name';
              final email = staff['email'] ?? 'No Email';
              final profileImage = staff['profileImage'] ?? '';

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: profileImage.isNotEmpty
                        ? NetworkImage(profileImage)
                        : const AssetImage('assets/user.png') as ImageProvider,
                  ),
                  title: Text(name),
                  subtitle: Text(email),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteDialog(staffId, name),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (builder) => const AddStaffScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
