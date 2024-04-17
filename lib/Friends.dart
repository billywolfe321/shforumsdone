import 'package:flutter/material.dart';
import 'CustomAppBar.dart';
import 'FriendProfile.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Friends extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Color(0xfff6f6f6),
        appBar: CustomAppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TabBar(
              tabs: [
                Tab(text: 'Friends'),
                Tab(text: 'Requests'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  FriendsList(),
                  RequestsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FriendsList extends StatefulWidget {
  @override
  _FriendsListState createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  List<Map<String, dynamic>> friendsDetails = [];
  final DatabaseReference ref = FirebaseDatabase.instance.ref();
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    fetchFriendIds();
  }

  void fetchFriendIds() {
    ref.child('Users/$userId/friends').onValue.listen((event) {
      final DataSnapshot snapshot = event.snapshot;
      final friendsData = Map<String, dynamic>.from(snapshot.value as Map);
      List<String> friendIds = friendsData.keys.toList();
      fetchFriendsDetails(friendIds);
    });
  }

  void fetchFriendsDetails(List<String> friendIds) {
    friendsDetails.clear();
    for (String id in friendIds) {
      ref.child('Users/$id').get().then((snapshot) {
        final DataSnapshot dataSnapshot = snapshot;
        if (dataSnapshot.exists) {
          final friendData = Map<String, dynamic>.from(dataSnapshot.value as Map);
          setState(() {
            friendsDetails.add({
              'id': id,
              'username': friendData['username'] ?? 'Unknown',
              'profilePicture': friendData['profilePicture'] ?? 'default_profile_picture.png',
            });
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search Friends...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: friendsDetails.length,
            itemBuilder: (context, index) {
              final friend = friendsDetails[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(friend['profilePicture']),
                ),
                title: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => FriendProfile(friendId: friend['id'])),
                  ),
                  child: Text(friend['username']),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
class RequestsList extends StatefulWidget {
  @override
  _RequestsListState createState() => _RequestsListState();
}

class _RequestsListState extends State<RequestsList> {
  final DatabaseReference ref = FirebaseDatabase.instance.ref();
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  List<Map<String, String>> requestDetails = [];

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  void fetchRequests() {
    ref.child('Users/$userId/friendRequestsReceived').onValue.listen((event) async {
      final DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists && snapshot.value != null) {
        final requestsData = Map<String, dynamic>.from(snapshot.value as Map);
        List<Map<String, String>> fetchedDetails = [];
        for (String requestId in requestsData.keys) {
          DataSnapshot usernameSnapshot = await ref.child('Users/$requestId/username').get();
          String username = usernameSnapshot.value as String? ?? 'Unknown';
          fetchedDetails.add({
            'id': requestId,
            'username': username,
          });
        }
        setState(() {
          requestDetails = fetchedDetails;
        });
      } else {
        setState(() {
          requestDetails.clear();
        });
      }
    });
  }

  void acceptRequest(String requestId) async {
    await ref.child('Users/$userId/friends/$requestId').set(true);
    await ref.child('Users/$requestId/friends/$userId').set(true);
    await ref.child('Users/$userId/friendRequestsReceived/$requestId').remove();
    await ref.child('Users/$requestId/friendRequestsSent/$userId').remove();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Friend request accepted.")));
  }

  void rejectRequest(String requestId) async {
    await ref.child('Users/$userId/friendRequestsReceived/$requestId').remove();
    await ref.child('Users/$requestId/friendRequestsSent/$userId').remove();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Friend request declined.")));
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: requestDetails.length,
      itemBuilder: (context, index) {
        final details = requestDetails[index];
        return ListTile(
          title: Text(details['username']!),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.check, color: Colors.green),
                onPressed: () => acceptRequest(details['id']!),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.red),
                onPressed: () => rejectRequest(details['id']!),
              ),
            ],
          ),
        );
      },
    );
  }
}