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
              final requestData =
                  requests[index].data() as Map<String, dynamic>;

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
