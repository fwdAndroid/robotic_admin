import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  String searchQuery = '';
  String sortBy = 'username';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Users"), centerTitle: true),
      body: Column(
        children: [
          _buildSearchAndSort(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .orderBy(sortBy)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No users found"));
                }

                var users = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String name =
                      data['username']?.toString().toLowerCase() ?? '';
                  String email = data['email']?.toString().toLowerCase() ?? '';
                  return name.contains(searchQuery.toLowerCase()) ||
                      email.contains(searchQuery.toLowerCase());
                }).toList();

                return LayoutBuilder(
                  builder: (context, constraints) {
                    bool isWide = constraints.maxWidth > 600;
                    return GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isWide ? 3 : 1,
                        childAspectRatio: isWide ? 3 : 2.8,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        var user = users[index].data() as Map<String, dynamic>;

                        String name = user['username'] ?? 'No Name';
                        String email = user['email'] ?? 'No Email';
                        String profilePic = user['profileImage'] ?? '';

                        return _buildUserCard(name, email, profilePic);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndSort() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search by name or email",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => searchQuery = value);
              },
            ),
          ),
          const SizedBox(width: 12),
          DropdownButton<String>(
            value: sortBy,
            items: const [
              DropdownMenuItem(value: 'username', child: Text("Sort by Name")),
              DropdownMenuItem(
                value: 'createdAt',
                child: Text("Sort by Join Date"),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => sortBy = value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(String name, String email, String profilePic) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: profilePic.isNotEmpty
                  ? NetworkImage(profilePic)
                  : null,
              child: profilePic.isEmpty
                  ? const Icon(Icons.person, size: 32)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    email,
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
