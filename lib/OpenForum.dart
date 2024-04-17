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
      List<Map<String, dynamic>> fetchedComments = [];
      Map<dynamic, dynamic> responses = forumSnapshot.child('responses').value as Map<dynamic, dynamic>? ?? {};
      for (var entry in responses.entries) {
        Map<dynamic, dynamic> response = entry.value as Map<dynamic, dynamic>? ?? {};
        String userId = response['authorID'] ?? '';
        DataSnapshot userSnapshot = await _databaseReference.child('Users/$userId').get();
        Map<dynamic, dynamic> userData = userSnapshot.value as Map<dynamic, dynamic>? ?? {};
        String profilePicture = getProfilePicturePath(userData['profilePic']);
        Map<String, dynamic> commentData = {
          'id': entry.key,
          'content': response['content'],
          'thumbsUp': response['thumbsUp'] ?? 0,
          'thumbsDown': response['thumbsDown'] ?? 0,
          'username': userData['username'] ?? 'Unknown',
          'profilePicture': profilePicture,
        };
        fetchedComments.add(commentData);
      }
      setState(() {
        forumData = Map<String, dynamic>.from(forumSnapshot.value as Map<dynamic, dynamic>);
        comments = fetchedComments;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  String getProfilePicturePath(int? profilePicIndex) {
    switch (profilePicIndex) {
      case 1: return "assets/purple.png";
      case 2: return "assets/blue.png";
      case 3: return "assets/blue-purple.png";
      case 4: return "assets/orange.png";
      case 5: return "assets/pink.png";
      case 6: return "assets/turquoise.png";
      default: return "assets/default_profile_picture.png";
    }
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

  void sortComments(List<Map<String, dynamic>> commentsList) {
    switch (currentFilter) {
      case CommentFilter.mostLiked:
        commentsList.sort((a, b) => (b['thumbsUp'] ?? 0).compareTo(a['thumbsUp'] ?? 0));
        break;
      case CommentFilter.mostRecent:
        commentsList.sort((a, b) => (b['timestamp'] ?? 0).compareTo(a['timestamp'] ?? 0));
        break;
      case CommentFilter.oldest:
        commentsList.sort((a, b) => (a['timestamp'] ?? 0).compareTo(b['timestamp'] ?? 0));
        break;
    }
    comments = commentsList;
  }

  void navigateToReportPage(String commentId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReportPage(forumId: widget.forumId, commentId: commentId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(forumData?['title'] ?? 'Forum'),
        backgroundColor: Color(0xffad32fe),
        actions: [
          PopupMenuButton<CommentFilter>(
            onSelected: (CommentFilter result) {
              setState(() {
                currentFilter = result;
                sortComments(comments);
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<CommentFilter>>[
              const PopupMenuItem<CommentFilter>(
                value: CommentFilter.mostLiked,
                child: Text('Most Liked'),
              ),
              const PopupMenuItem<CommentFilter>(
                value: CommentFilter.mostRecent,
                child: Text('Most Recent'),
              ),
              const PopupMenuItem<CommentFilter>(
                value: CommentFilter.oldest,
                child: Text('Oldest'),
              ),
            ],
          ),
        ],
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
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(comment['profilePicture']),
                ),
                title: Text(comment['content']),
                subtitle: Text('Sent by: ${comment['username']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.thumb_up),
                      onPressed: () => incrementThumbsUp(comment['id']),
                    ),
                    Text('${comment['thumbsUp'] ?? 0}'),
                    IconButton(
                      icon: Icon(Icons.thumb_down),
                      onPressed: () => incrementThumbsDown(comment['id']),
                    ),
                    Text('${comment['thumbsDown'] ?? 0}'),
                    IconButton(
                      icon: Icon(Icons.report),
                      onPressed: () => navigateToReportPage(comment['id']),
                    ),
                  ],
                ),
              )),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  labelText: 'Write a comment...',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: postComment,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> incrementThumbsUp(String commentId) async {
    DatabaseReference thumbsUpRef = _databaseReference.child('Forums/${widget.forumId}/responses/$commentId/thumbsUp');
    DataSnapshot snapshot = await thumbsUpRef.get();
    int currentLikes = (snapshot.value ?? 0) as int;
    await thumbsUpRef.set(currentLikes + 1);
    fetchForumData();
  }

  Future<void> incrementThumbsDown(String commentId) async {
    DatabaseReference thumbsDownRef = _databaseReference.child('Forums/${widget.forumId}/responses/$commentId/thumbsDown');
    DataSnapshot snapshot = await thumbsDownRef.get();
    int currentDislikes = (snapshot.value ?? 0) as int;
    await thumbsDownRef.set(currentDislikes + 1);
    fetchForumData();
  }
}
