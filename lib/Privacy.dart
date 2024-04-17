import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PrivacySettings extends StatefulWidget {
  @override
  _PrivacySettingsState createState() => _PrivacySettingsState();
}

class _PrivacySettingsState extends State<PrivacySettings> {
  final dbRef = FirebaseDatabase.instance.ref('users/${FirebaseAuth.instance.currentUser!.uid}/privacySettings');
  bool profileVisible = true;
  bool searchable = true;
  bool receiveNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadPrivacySettings();
  }

  _loadPrivacySettings() async {
    DataSnapshot snapshot = await dbRef.get();
    if (snapshot.exists) {
      Map privacySettings = snapshot.value as Map;
      setState(() {
        profileVisible = privacySettings['profileVisible'] ?? true;
        searchable = privacySettings['searchable'] ?? true;
        receiveNotifications = privacySettings['receiveNotifications'] ?? true;
      });
    }
  }

  _updatePrivacySetting(String key, bool value) async {
    await dbRef.update({key: value});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Privacy setting updated.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Settings'),
        backgroundColor: Color(0xffad32fe),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Profile Visible'),
            value: profileVisible,
            onChanged: (bool value) {
              setState(() => profileVisible = value);
              _updatePrivacySetting('profileVisible', value);
            },
          ),
          SwitchListTile(
            title: Text('Searchable'),
            value: searchable,
            onChanged: (bool value) {
              setState(() => searchable = value);
              _updatePrivacySetting('searchable', value);
            },
          ),
          SwitchListTile(
            title: Text('Receive Notifications'),
            value: receiveNotifications,
            onChanged: (bool value) {
              setState(() => receiveNotifications = value);
              _updatePrivacySetting('receiveNotifications', value);
            },
          ),
        ],
      ),
    );
  }
}
