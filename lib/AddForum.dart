import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:login_and_registration/OpenDrawer.dart';

class AddForum extends StatefulWidget {
  @override
  _AddForumState createState() => _AddForumState();
}

class _AddForumState extends State<AddForum> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  List<String> subjects = [];
  String? selectedSubject;

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }

  void fetchSubjects() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref('Subjects');
    DatabaseEvent event = await ref.once();
    if (event.snapshot.exists) {
      List<String> loadedSubjects = [];
      event.snapshot.children.forEach((DataSnapshot snapshot) {
        loadedSubjects.add(snapshot.value.toString());
      });
      setState(() {
        subjects = loadedSubjects;
        if (subjects.isNotEmpty) selectedSubject = subjects[0];
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submitForum() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Title and content cannot be empty')),
      );
      return;
    }

    String userId = _auth.currentUser?.uid ?? '';
    Map<String, dynamic> forum = {
      'title': _titleController.text.trim(),
      'content': _contentController.text.trim(),
      'subject': selectedSubject,
      'authorID': userId,
      'timestamp': ServerValue.timestamp,
      'responses': {},
    };

    await _databaseReference.child('Forums').push().set(forum);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Forum'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () { Scaffold.of(context).openDrawer(); },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
      ),
      drawer: OpenDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Forum Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _contentController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Content',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            DropdownButton<String>(
              value: selectedSubject,
              isExpanded: true,
              onChanged: (String? newValue) {
                setState(() {
                  selectedSubject = newValue!;
                });
              },
              items: subjects.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForum,
              child: Text('Submit Forum'),
            ),
          ],
        ),
      ),
    );
  }
}
