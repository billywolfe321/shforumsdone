import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'OpenForum.dart';
import 'AddForum.dart';
import 'ReportPage.dart';
import 'OpenDrawer.dart';

class Forums extends StatefulWidget {
  @override
  _ForumsState createState() => _ForumsState();
}

class _ForumsState extends State<Forums> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> allForums = [];
  List<Map<String, dynamic>> userForums = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchForums();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void fetchForums() {
    _databaseReference.child('Forums').onValue.listen((event) {
      final forumsData = event.snapshot.value as Map<dynamic, dynamic>?;
      final currentUser = _auth.currentUser?.uid;

      if (forumsData != null) {
        List<Map<String, dynamic>> loadedAllForums = [];
        List<Map<String, dynamic>> loadedUserForums = [];

        forumsData.forEach((key, value) {
          final forum = Map<String, dynamic>.from(value);
          forum['forumId'] = key;
          loadedAllForums.add(forum);

          if (forum['authorID'] == currentUser) {
            loadedUserForums.add(forum);
          }
        });

        setState(() {
          allForums = loadedAllForums;
          userForums = loadedUserForums;
        });
      }
    });
  }

  void deleteForum(String forumId) async {
    await _databaseReference.child('Forums/$forumId').remove();
    fetchForums();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      drawer: OpenDrawer(), // Using the custom drawer
      appBar: AppBar(
        backgroundColor: Color(0xffad32fe),
        title: Text("Forums"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddForum())),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: "Current Forums"),
                Tab(text: "Your Forums"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                buildForumList(allForums, false),
                buildForumList(userForums, true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildForumList(List<Map<String, dynamic>> forums, bool showDeleteButton) {
    return ListView.builder(
      itemCount: forums.length,
      itemBuilder: (context, index) {
        final forum = forums[index];
        return ListTile(
          title: Text(forum["title"] ?? 'No Title'),
          subtitle: Text(forum["content"] ?? 'No Content'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OpenForum(forumId: forum['forumId'])),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.flag, color: Colors.red),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReportPage(forumId: forum['forumId'])),
                ),
              ),
              if (showDeleteButton) IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => confirmDelete(context, forum['forumId']),
              ),
            ],
          ),
        );
      },
    );
  }

  void confirmDelete(BuildContext context, String forumId) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Confirm Delete"),
            content: Text("Are you sure you want to delete this forum?"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Cancel")
              ),
              TextButton(
                  onPressed: () {
                    deleteForum(forumId);
                    Navigator.of(context). pop();
                  },
                  child: Text("Delete")
              ),
            ],
          );
        }
    );
  }
}
