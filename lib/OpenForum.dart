import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'ReportPage.dart';
import 'OpenDrawer.dart';

enum CommentFilter { mostLiked, mostRecent, oldest }

class OpenForum extends StatefulWidget {
  final String forumId;

  OpenForum({required this.forumId});

  @override
  _OpenForumState createState() => _OpenForumState();
}

class _OpenForumState extends State<OpenForum> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = true;
  Map<String, dynamic>? forumData;
  List<Map<String, dynamic>> comments = [];
  TextEditingController commentController = TextEditingController();
  CommentFilter currentFilter = CommentFilter.mostRecent;

  @override
  void initState() {
    super.initState();
    fetchForumData();
  }

  void fetchForumData() async {
    setState(() => isLoading = true);
    final forumSnapshot = await _databaseReference.child('Forums/${widget.forumId}').get();
    if (forumSnapshot.exists && forumSnapshot.value != null) {
      Map<dynamic, dynamic> responses = forumSnapshot.child('responses').value as Map<dynamic, dynamic>? ?? {};
      List<Map<String, dynamic>> fetchedComments = responses.entries.map((e) {
        return {
          'id': e.key,
          'content': e.value['content'],
          'thumbsUp': e.value['thumbsUp'] ?? 0,
          'thumbsDown': e.value['thumbsDown'] ?? 0,
          'timestamp': e.value['timestamp'] ?? 0,
        };
      }).toList();
      sortComments(fetchedComments);
    } else {
      setState(() => isLoading = false);
    }
  }

  void sortComments(List<Map<String, dynamic>> commentsList) {
    commentsList.sort((a, b) => (b['timestamp'] ?? 0).compareTo(a['timestamp'] ?? 0));
    setState(() {
      comments = commentsList;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(forumData?['title'] ?? 'Forum'),
        backgroundColor: Color(0xffad32fe),
      ),
      drawer: OpenDrawer(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(forumData?['title'] ?? 'No Title', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text(forumData?['content'] ?? 'No Content', style: TextStyle(fontSize: 18)),
              Divider(),
              Text('Comments:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...comments.map((comment) => ListTile(
                title: Text(comment['content']),
                trailing: Text('Likes: ${comment['thumbsUp']}, Dislikes: ${comment['thumbsDown']}'),
              )),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  labelText: 'Write a comment...',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () async {
                      if (commentController.text.trim().isNotEmpty) {
                        await postComment();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> postComment() async {
    final String userId = _auth.currentUser!.uid;
    final String comment = commentController.text.trim();
    if (comment.isNotEmpty) {
      await _databaseReference.child('Forums/${widget.forumId}/responses').push().set({
        'content': comment,
        'authorID': userId,
        'thumbsUp': 0,
        'thumbsDown': 0,
        'timestamp': ServerValue.timestamp,
      });
      commentController.clear();
      fetchForumData();
    }
  }
}
