import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'AddParticipantsPage.dart';

class AddGroupChat extends StatefulWidget {
  @override
  _AddGroupChatState createState() => _AddGroupChatState();
}

class _AddGroupChatState extends State<AddGroupChat> {
  final TextEditingController _titleController = TextEditingController();
  bool isPrivate = false;
  List<Map<String, dynamic>> memberUsers = [];
  late String groupId;

  @override
  void initState() {
    super.initState();
    groupId = FirebaseDatabase.instance.ref().child('GroupChats').push().key!;
  }

  void createGroupChat() async {
    Map<String, bool> members = {for (var user in memberUsers) user['id']: true};

    await FirebaseDatabase.instance.ref().child('GroupChats/$groupId').set({
      'title': _titleController.text,
      'isPrivate': isPrivate,
      'adminID': FirebaseAuth.instance.currentUser!.uid,
      'memberIDs': members,
    });

    Navigator.pop(context);
  }

  void navigateToAddParticipants() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AddParticipantsPage(groupId: groupId),
    ));
  }

  void addUser(Map<String, dynamic> user) {
    if (!memberUsers.any((element) => element['id'] == user['id'])) {
      setState(() {
        memberUsers.add(user);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Group Chat'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Group Chat Title',
                border: OutlineInputBorder(),
              ),
            ),
            SwitchListTile(
              title: Text('Private Group'),
              value: isPrivate,
              onChanged: (bool value) {
                setState(() {
                  isPrivate = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: navigateToAddParticipants,
              child: Text('Search and Add Users'),
            ),
            Wrap(
              spacing: 8.0,
              children: memberUsers.map((user) => Chip(
                label: Text(user['username']),
                onDeleted: () {
                  setState(() {
                    memberUsers.removeWhere((element) => element['id'] == user['id']);
                  });
                },
              )).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: createGroupChat,
              child: Text('Create Group Chat'),
            ),
          ],
        ),
      ),
    );
  }
}
