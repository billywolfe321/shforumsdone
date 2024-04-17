import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class GroupChatPage extends StatefulWidget {
  final String chatId;
  final bool isAdmin;

  GroupChatPage({required this.chatId, required this.isAdmin});

  @override
  _GroupChatPageState createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  Map<String, String> userIdToUsername = {};
  String chatTitle = "";
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    fetchChatDetails();
    listenToMessages();
  }

  void fetchChatDetails() async {
    DataSnapshot chatSnapshot = await _databaseRef.child('GroupChats/${widget.chatId}').get();
    if (chatSnapshot.exists && chatSnapshot.value != null) {
      Map<dynamic, dynamic> chatData = chatSnapshot.value as Map<dynamic, dynamic>? ?? {};
      setState(() {
        chatTitle = chatData['title'] ?? 'Group Chat';
      });
    }

    DataSnapshot usersSnapshot = await _databaseRef.child('Users').get();
    if (usersSnapshot.exists && usersSnapshot.value != null) {
      Map<dynamic, dynamic> users = usersSnapshot.value as Map<dynamic, dynamic>? ?? {};
      Map<String, String> usernames = {};
      users.forEach((uid, userData) {
        Map<dynamic, dynamic> userDataMap = userData as Map<dynamic, dynamic>? ?? {};
        usernames[uid] = userDataMap['username'] ?? 'Unknown';
      });
      setState(() {
        userIdToUsername = usernames;
      });
    }
  }

  void listenToMessages() {
    _databaseRef.child('GroupChats/${widget.chatId}/messages').onValue.listen((event) {
      var fetchedMessages = <Map<String, dynamic>>[];
      event.snapshot.children.forEach((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          Map<String, dynamic> message = Map<String, dynamic>.from(snapshot.value as Map);
          message['key'] = snapshot.key;
          fetchedMessages.add(message);
        }
      });
      setState(() {
        messages = fetchedMessages;
      });
    });
  }


  void sendMessage() {
    if (_messageController.text.isNotEmpty) {
      _databaseRef.child('GroupChats/${widget.chatId}/messages').push().set({
        'text': _messageController.text,
        'senderId': FirebaseAuth.instance.currentUser?.uid,
        'timestamp': ServerValue.timestamp,
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(chatTitle),
        actions: widget.isAdmin ? [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatSettingsPage(chatId: widget.chatId)),
              );
            },
          ),
        ] : [],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                String senderUsername = userIdToUsername[msg['senderId']] ?? 'Unknown User';
                return ListTile(
                  title: Text(msg['text']),
                  subtitle: Text('Sent by: $senderUsername'),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Type a message',
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatSettingsPage extends StatelessWidget {
  final String chatId;

  ChatSettingsPage({required this.chatId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat Settings")),
      body: Center(child: Text("Settings for the chat")),
    );
  }
}
