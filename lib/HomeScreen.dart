import 'package:flutter/material.dart';
import 'index.dart';
import 'CustomAppBar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();

}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> appForums = [];
  List<dynamic> forYouForums = [];
  List<dynamic> friendsForums = [];
  List userFriends = [];
  String course = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final databaseReference = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    getForums();
  }

  Future<void> getForums() async {
    User? user = _auth.currentUser;
    if (user != null) {
      final userSnapshot = await databaseReference.child('Users/${user.uid}')
          .get();
      if (userSnapshot.exists) {
        setState(() {
          final userData = userSnapshot.value as Map<dynamic, dynamic>;
          Map<dynamic, dynamic>? friendsMap = userData['friends'];
          course = userData['course'] ?? '';
          if (friendsMap != null) {
            // Extracting friend IDs from the friendsMap
            userFriends = friendsMap.keys.map((key) => key.toString()).toList();
          }
        });
      }
    }
    final DatabaseReference forumsRef = FirebaseDatabase.instance.ref();
    Query forumsQuery = forumsRef.child('Forums');
    final forumSnapshot = await forumsQuery.get();

    if (forumSnapshot.exists) {
      final dynamic snapshotValue = forumSnapshot.value;
      snapshotValue.forEach((key, value) {
        final forum = Map<String, dynamic>.from(value);
        setState(() {
          appForums.add(forum);
        });
      });
    }

    for (int i = appForums.length - 1; i >= 0; i--) {
      Map<String, dynamic> currentForum = appForums[i];
      if (currentForum.containsKey("subject")) {
        String subject = currentForum["subject"];
        if (subject == course) {
          forYouForums.add(currentForum);
        }
      }
    }
    for (int i = appForums.length - 1; i >= 0; i--) {
      Map<String, dynamic> currentForum = appForums[i];
      if (currentForum.containsKey("authorID")) {
        String author = currentForum["authorID"];
        if (userFriends.contains(author)) {
          friendsForums.add(currentForum);
        }
      }
    }
  }
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.white,
        drawer: OpenDrawer(),
        appBar: CustomAppBar(),

        body: Padding(
          padding: EdgeInsets.all(2.0),
          child: Column(
            children: [
              const Text(
                "Top Forums for You",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 17,
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: forYouForums.length == 0 ? 1 : forYouForums.length,
                  itemBuilder: (context, index) {
                    if (forYouForums.isEmpty) {
                      return ListTile(
                        title: Text(
                          'No forums available',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      );
                    } else {
                      final item = forYouForums[index];
                      return ListTile(
                        tileColor: Color(0x1f000000),
                        title: Text(
                          item["title"] ?? 'No Title',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Text(item["content"] ?? 'No Content'),
                        leading: Icon(Icons.article, color: Color(0xff212435),
                            size: 24),
                        trailing: Icon(Icons.arrow_forward, color: Color(
                            0xff212435), size: 24),
                      );
                    }
                  },
                ),
              ),
              const Text(
                "Recent Posts from Friends",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 17,
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: friendsForums.length == 0 ? 1 : friendsForums
                      .length,
                  itemBuilder: (context, index) {
                    if (friendsForums.isEmpty) {
                      return ListTile(
                        title: Text(
                          'You have no friends, check out groupchats to find some',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      );

                    } else {
                      final item = friendsForums[index];
                      return ListTile(
                        tileColor: Color(0x1f000000),
                        title: Text(
                          item["title"] ?? 'No Title',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Text(item["content"] ?? 'No Content'),
                        leading: Icon(Icons.article, color: Color(0xff212435),
                            size: 24),
                        trailing: Icon(Icons.arrow_forward, color: Color(
                            0xff212435), size: 24),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),

      );
    }
  }
