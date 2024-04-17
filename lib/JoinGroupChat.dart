import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'GroupChatPage.dart';
import 'OpenDrawer.dart';
import 'AddGroupChat.dart';

class JoinGroupChat extends StatefulWidget {
  @override
  _JoinGroupChatState createState() => _JoinGroupChatState();
}

class _JoinGroupChatState extends State<JoinGroupChat> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> myChats = [];
  List<Map<String, dynamic>> allChats = [];
  List<Map<String, dynamic>> privateChats = [];
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchGroupChats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void fetchGroupChats() {
    final currentUser = _auth.currentUser?.uid;
    _databaseReference.child('GroupChats').onValue.listen((event) {
      var loadedMyChats = <Map<String, dynamic>>[];
      var loadedAllChats = <Map<String, dynamic>>[];
      var loadedPrivateChats = <Map<String, dynamic>>[];

      event.snapshot.children.forEach((DataSnapshot snapshot) {
        Map<String, dynamic> chat = Map<String, dynamic>.from(snapshot.value as Map);
        chat['id'] = snapshot.key;
        bool isPrivate = chat['isPrivate'] ?? false;
        bool isAdmin = chat['adminID'] == currentUser;

        if (chat['memberIDs'] != null && chat['memberIDs'].containsKey(currentUser)) {
          loadedMyChats.add(chat);
        }

        if (!isPrivate) {
          loadedAllChats.add(chat);
        }

        if (isPrivate && (chat['memberIDs'].containsKey(currentUser) || isAdmin)) {
          loadedPrivateChats.add(chat);
        }
      });

      setState(() {
        myChats = loadedMyChats;
        allChats = loadedAllChats;
        privateChats = loadedPrivateChats;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: OpenDrawer(), // Custom drawer for navigation
      appBar: AppBar(
        title: Text("Join Group Chat"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "My Chats"),
            Tab(text: "All Chats"),
            Tab(text: "Private Chats"),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AddGroupChat()));
            },
          )
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildChatList(myChats),
          buildChatList(allChats),
          buildChatList(privateChats),
        ],
      ),
    );
  }

  Widget buildChatList(List<Map<String, dynamic>> chats) {
    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        bool joined = chat['memberIDs'] != null && chat['memberIDs'].containsKey(_auth.currentUser?.uid);
        return ListTile(
          title: Text(chat['title']),
          subtitle: Text('Admin: ${chat['adminID']}'),
          trailing: ElevatedButton(
            onPressed: () {
              if (joined) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => GroupChatPage(chatId: chat['id'], isAdmin: chat['adminID'] == _auth.currentUser?.uid)));
              } else {
                joinChat(chat['id'], chat['isPrivate']);
              }
            },
            child: Text(joined ? "Open Chat" : "Join"),
          ),
        );
      },
    );
  }

  void joinChat(String chatId, bool isPrivate) async {
    if (!isPrivate) {
      await _databaseReference.child('GroupChats/$chatId/memberIDs/${_auth.currentUser!.uid}').set(true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Joined the chat!")));
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Request sent to join private chat.")));
    }
  }
}
