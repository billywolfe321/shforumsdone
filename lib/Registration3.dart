import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'HomeScreen.dart';

class Registration3 extends StatefulWidget {
  @override
  _Registration3State createState() => _Registration3State();
}

class _Registration3State extends State<Registration3> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final databaseReference = FirebaseDatabase.instance.ref();
  TextEditingController bioController = TextEditingController();
  int profilePic = 0;

  Future<void> saveBio() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await databaseReference.child('Users/${user.uid}/bio').set(bioController.text);
      await databaseReference.child('Users/${user.uid}/profilePic').set(profilePic);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Complete Registration"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    profilePic = 1;
                  },
                  child: Image.asset(
                    'assets/purple.png',
                    width: 60,
                    height: 60,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    profilePic = 2;
                  },
                  child: Image.asset(
                    'assets/blue.png',
                    width: 60,
                    height: 60,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    profilePic = 3;
                  },
                  child: Image.asset(
                    'assets/blue-purple.png',
                    width: 60,
                    height: 60,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    profilePic = 4;
                  },
                  child: Image.asset(
                    'assets/orange.png',
                    width: 60,
                    height: 60,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    profilePic = 5;
                  },
                  child: Image.asset(
                    'assets/pink.png',
                    width: 60,
                    height: 60,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    profilePic = 6;
                  },
                  child: Image.asset(
                    'assets/turquoise.png',
                    width: 60,
                    height: 60,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: bioController,
              decoration: InputDecoration(
                labelText: 'Bio',
                counterText: '${bioController.text.length}/255',
              ),
              maxLines: 3,
              maxLength: 255,
              onChanged: (text) {
                setState(() {});
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveBio,
              child: Text('Finish Registration'),
            ),
          ],
        ),
      ),
    );
  }
}
