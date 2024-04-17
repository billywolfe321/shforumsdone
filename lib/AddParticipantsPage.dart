import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddParticipantsPage extends StatefulWidget {
  final String groupId;

  AddParticipantsPage({required this.groupId});

  @override
  _AddParticipantsPageState createState() => _AddParticipantsPageState();
}

class _AddParticipantsPageState extends State<AddParticipantsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];

  void _performSearch(String query) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref('Users');
    DatabaseEvent event = await ref.once();

    List<Map<String, dynamic>> results = [];
    if (event.snapshot.exists) {
      event.snapshot.children.forEach((child) {
        if (child.key == FirebaseAuth.instance.currentUser!.uid) {
          return;
        }

        Map<String, dynamic> userData = Map<String, dynamic>.from(child.value as Map);
        String username = userData['username'] ?? '';

        if (username.toLowerCase().contains(query.toLowerCase())) {
          results.add({
            'username': username,
            'uid': child.key,
          });
        }
      });
    }

    setState(() {
      _searchResults = results.isEmpty ? [{'username': 'No results', 'uid': ''}] : results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Participants'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search Users',
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: () => _performSearch(_searchController.text),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final user = _searchResults[index];
                return ListTile(
                  title: Text(user['username']),
                  trailing: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      FirebaseDatabase.instance.ref('GroupChats/${widget.groupId}/memberIDs').child(user['uid']).set(true);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

