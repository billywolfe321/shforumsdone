import 'JoinGroupChat.dart';
import 'package:flutter/material.dart';
import 'index.dart';
import 'Friends.dart';

class OpenDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5, // 75% of screen will be occupied
      child: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: const Text('Home'),
              onTap: () {
                // Handle the profile tap action
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );// Close the drawer
              },
            ),
            ListTile(
              title: const Text('Forums'),
              onTap: () {
                // Handle the profile tap action
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Forums()),
                );// Close the drawer
              },
            ),
            ListTile(
              title: const Text('Group Chats'),
              onTap: () {
                // Handle the profile tap action
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => JoinGroupChat()),
                );// // Close the drawer
              },
            ),
            ListTile(
              title: const Text('Friends'),
              onTap: () {
                // Handle the profile tap action
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Friends()),
                );// // Close the drawer
              },
            ),
            ListTile(
              title: const Text('Profile'),
              onTap: () {
                // Handle the profile tap action
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserProfile()),
                );// // Close the drawer
              },
            ),
            ListTile(
              title: const Text('Settings'),
              onTap: () {
                // Handle the profile tap action
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Setting()),
                );// // Close the drawer
              },
            ),
          ],
        ),
      ),
    );
  }
}
