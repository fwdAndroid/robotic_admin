import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StaffRequestScreen extends StatefulWidget {
  const StaffRequestScreen({super.key});

  @override
  State<StaffRequestScreen> createState() => _StaffRequestScreenState();
}

class _StaffRequestScreenState extends State<StaffRequestScreen> {
  // Function to get staff name by staffId
  Future<String> _getStaffName(String? staffId) async {
    if (staffId == null) return 'Unknown';

    final doc = await FirebaseFirestore.instance
        .collection('staff')
        .doc(staffId)
        .get();

    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      return data['name'] ?? 'Unknown';
    }
    return 'Unknown';
  }

  // Function to show dialog for new password input
  Future<void> _changePassword(String staffId, String requestId) async {
    final TextEditingController passwordController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: TextField(
            controller: passwordController,
            decoration: const InputDecoration(labelText: 'Enter new password'),
            obscureText: true,
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context, null),
            ),
            ElevatedButton(
              child: const Text('Update'),
              onPressed: () {
                Navigator.pop(context, passwordController.text.trim());
              },
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      try {
        // 1️⃣ Update staff password
        await FirebaseFirestore.instance
            .collection('staff')
            .doc(staffId)
            .update({'password': result});

        // 2️⃣ Update request status
        await FirebaseFirestore.instance
            .collection('password_requests')
            .doc(requestId)
            .update({'status': 'done'});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password updated successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Reset Requests'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('password_requests')
            .where("status", isEqualTo: "pending")
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No password requests found.'));
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final requestDoc = requests[index];
              final requestData = requestDoc.data() as Map<String, dynamic>;

              final staffId = requestData['staffId'] as String?;
              final email = requestData['email'] ?? 'No Email';
              final status = requestData['status'] ?? 'pending';

              return FutureBuilder<String>(
                future: _getStaffName(staffId),
                builder: (context, staffSnapshot) {
                  String staffName = 'Loading...';
                  if (staffSnapshot.connectionState == ConnectionState.done) {
                    staffName = staffSnapshot.data ?? 'Unknown';
                  }
                  return ListTile(
                    leading: const Icon(Icons.lock_reset),
                    title: Text('Email: $email'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Staff Name: $staffName'),
                        Text('Status: $status'),
                        if (status == 'pending')
                          TextButton(
                            onPressed: () {
                              if (staffId != null) {
                                _changePassword(staffId, requestDoc.id);
                              }
                            },
                            child: const Text("Change Password"),
                          ),
                      ],
                    ),
                    isThreeLine: true,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
