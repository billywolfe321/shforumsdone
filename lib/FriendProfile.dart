import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_and_registration/CustomAppBar.dart';
import 'UserProfile.dart';

class FriendProfile extends StatefulWidget {
  final String friendId;

  FriendProfile({required this.friendId});

  @override
  _FriendProfileState createState() => _FriendProfileState();
}

class _FriendProfileState extends State<FriendProfile> {
  final databaseReference = FirebaseDatabase.instance.ref();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  String firstName = '';
  String lastName = '';
  String username = '';
  String bio = '';
  String university = '';
  String course = '';
  int friendCount = 0;

  @override
  void initState() {
    super.initState();
    fetchFriendData();
  }

  Future<void> fetchFriendData() async {
    final friendSnapshot = await databaseReference.child(
        'Users/${widget.friendId}').get();
    if (friendSnapshot.exists) {
      final friendData = friendSnapshot.value as Map<dynamic, dynamic>;
      setState(() {
        firstName = friendData['firstName'] ?? '';
        lastName = friendData['lastName'] ?? '';
        username = friendData['username'] ?? '';
        bio = friendData['bio'] ?? '';
        university = friendData['university'] ?? '';
        course = friendData['course'] ?? '';
        friendCount = friendData['friends'] != null
            ? (friendData['friends'] as Map).length
            : 0;
      });
    }
  }

  void removeFriend() async {
    await databaseReference.child(
        'Users/$currentUserId/friends/${widget.friendId}').remove();
    await databaseReference.child(
        'Users/${widget.friendId}/friends/$currentUserId').remove();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            CircleAvatar(radius: 60,
                backgroundImage: AssetImage("assets/profilePicture1.png")),
            SizedBox(height: 10),
            Text("$firstName $lastName",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Text(username, style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ProfileInfoBox(title: course, subtitle: "Subject"),
                ProfileInfoBox(title: "$friendCount Friends", subtitle: ""),
                ProfileInfoBox(title: university, subtitle: "University"),
              ],
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Bio", style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 10),
                  Text(bio),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: removeFriend,
              child: Text("Remove Friend"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}