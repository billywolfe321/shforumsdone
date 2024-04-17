import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class OtherUserProfile extends StatefulWidget {
  final String userID;

  OtherUserProfile({required this.userID});

  @override
  _OtherUserProfileState createState() => _OtherUserProfileState();
}

class _OtherUserProfileState extends State<OtherUserProfile> {
  final databaseReference = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String firstName = '';
  String lastName = '';
  String username = '';
  String bio = '';
  String university = '';
  String course = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final userSnapshot = await databaseReference.child('Users/${widget.userID}').get();
    if (userSnapshot.exists) {
      final userData = Map<String, dynamic>.from(userSnapshot.value as Map);
      setState(() {
        firstName = userData['firstName'] ?? '';
        lastName = userData['lastName'] ?? '';
        username = userData['username'] ?? '';
        bio = userData['bio'] ?? '';
        university = userData['university'] ?? '';
        course = userData['course'] ?? '';
      });
    }
  }

  void sendFriendRequest() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null && currentUser.uid != widget.userID) {
      await databaseReference.child('Users/${currentUser.uid}/friendRequestsSent/${widget.userID}').set('pending');
      await databaseReference.child('Users/${widget.userID}/friendRequestsReceived/${currentUser.uid}').set('pending');

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Friend request sent!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Other User Profile'),
        backgroundColor: Color(0xffad32fe),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CircleAvatar(radius: 60),
            Text("$firstName $lastName", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Text(username, style: TextStyle(fontSize: 18)),
            ElevatedButton(
              onPressed: sendFriendRequest,
              child: Text("Send Friend Request"),
            ),
          ],
        ),
      ),
    );
  }
}
