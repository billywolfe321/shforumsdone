import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Settings'),
        backgroundColor: Color(0xffad32fe),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Change Password'),
            onTap: () => _showChangePasswordDialog(context),
          ),
          ListTile(
            title: Text('Change Email'),
            onTap: () => _showChangeEmailDialog(context),
          ),
          ListTile(
            title: Text('Delete Account'),
            onTap: () => _showDeleteAccountDialog(context),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    TextEditingController newPasswordController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Password'),
          content: TextField(
            controller: newPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'New Password',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Change'),
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                final newPassword = newPasswordController.text.trim();

                try {
                  await user!.updatePassword(newPassword);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password changed successfully')));
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to change password. Please try again.')));
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showChangeEmailDialog(BuildContext context) {
    //todo email dialog
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Account'),
          content: Text('Are you sure you want to delete your account? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                try {
                  await user!.delete();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Account deleted successfully')));
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete account. Please try again.')));
                }
              },
            ),
          ],
        );
      },
    );
  }
}
