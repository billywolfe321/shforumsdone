import 'package:flutter/material.dart';
import 'SearchScreen.dart'; // Ensure this is imported if you're using SearchScreen for navigation

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 4,
      centerTitle: false,
      backgroundColor: Color(0xffad32fe),
      title: GestureDetector(
        onTap: () => Navigator.of(context).pushReplacementNamed('/home'), // Navigate to the home screen when the title is tapped
        child: Row(
          children: [
            Image.asset('assets/logo.png', width: 24), // Ensure you have this asset or replace it with your logo
            SizedBox(width: 8),
            Text("Study Hive", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: Colors.white)),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchScreen()), // Navigate to the SearchScreen
            );
          },
        ),
        // Include any other action icons here if needed
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); // AppBar's preferred height
}
