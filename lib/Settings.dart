import 'package:flutter/material.dart';
import 'index.dart';
import 'Privacy.dart';
import 'AccountSettings.dart';
import 'ReportBug.dart';
import 'CustomAppBar.dart';

class Setting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(),
      drawer: OpenDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSettingItem(context, "Account", Icons.person, () => navigateToPage(context, AccountSettings())),
            buildSettingItem(context, "Privacy", Icons.lock, () => navigateToPage(context, PrivacySettings())),
            buildSettingItem(context, "Report Bug", Icons.bug_report, () => navigateToPage(context, ReportBug())),
            SizedBox(height: 100),
            ElevatedButton(
              onPressed: () => navigateToPage(context, Login()),
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFEF2828)),
              child: Text("Log Out", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void navigateToPage(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  Widget buildSettingItem(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Color(0xff3a57e8), size: 24),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16, color: Colors.black)),
      trailing: Icon(Icons.arrow_forward_ios, color: Color(0xff808080), size: 18),
    );
  }
}
