import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'OtherUserProfile.dart';
import 'FriendProfile.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  void _performSearch(String query) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref('Users');
    DatabaseEvent event = await ref.once();

    List<Map<String, dynamic>> results = [];
    if (event.snapshot.exists) {
      event.snapshot.children.forEach((child) {
        if (child.key == currentUserId) {
          return;
        }

        Map<String, dynamic> userData = Map<String, dynamic>.from(child.value as Map);
        String username = userData['username'] ?? '';

        if (username.toLowerCase().contains(query.toLowerCase())) {
          results.add({
            'username': username,
            'key': child.key,
          });
        }
      });
    }

    setState(() {
      _searchResults = results.isEmpty ? [{'username': 'No results', 'key': ''}] : results;
    });
  }

  void navigateToProfile(String userId) async {
    final DatabaseReference ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('Users/$currentUserId/friends/$userId').get();

    if (snapshot.exists) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => FriendProfile(friendId: userId)),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OtherUserProfile(userID: userId)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffad32fe),
        title: TextField(
          controller: _searchController,
          onChanged: (value) {
            if (value.isNotEmpty) {
              _performSearch(value);
            } else {
              setState(() => _searchResults.clear());
            }
          },
          decoration: InputDecoration(
            hintText: "Search...",
            hintStyle: TextStyle(color: Colors.white),
            border: InputBorder.none,
          ),
          style: TextStyle(color: Colors.white),
        ),
        leading: BackButton(color: Colors.white),
      ),
      body: ListView.separated(
        itemCount: _searchResults.length,
        separatorBuilder: (context, index) => Divider(height: 1),
        itemBuilder: (context, index) {
          var result = _searchResults[index];
          return ListTile(
            title: Text(result['username']),
            onTap: () {
              if (result.containsKey('key') && result['key'] != '') {
                navigateToProfile(result['key']);
              }
            },
          );
        },
      ),
    );
  }
}
