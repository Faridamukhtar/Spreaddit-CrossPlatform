import 'package:flutter/material.dart';
import 'package:spreadit_crossplatform/features/Account_Settings/presentation/widgets/settings_app_bar.dart';
import 'package:spreadit_crossplatform/features/blocked_accounts/pages/blocked_accounts/data/get_blocked_accounts.dart';
import 'package:spreadit_crossplatform/features/blocked_accounts/pages/blocked_accounts/data/put_blocked_accounts.dart';
import 'package:spreadit_crossplatform/features/moderators/data/update_moderator_permmissions.dart';

class EditPermissionsPage extends StatefulWidget {
  String communityName;
  String username;
  bool managePostsAndComments;
  bool manageUsers;
  bool manageSettings;
  final void Function(bool newManagePostsAndCommnets, bool newManageUsers,
      bool newManageSettings) onPermissionsChanged;

  EditPermissionsPage({
    required this.communityName,
    required this.username,
    required this.managePostsAndComments,
    required this.manageSettings,
    required this.manageUsers,
    required this.onPermissionsChanged,
  });

  @override
  State<EditPermissionsPage> createState() {
    return _EditPermissionsPageState();
  }
}

class _EditPermissionsPageState extends State<EditPermissionsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Moderators'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
          actions: [
            TextButton(
                onPressed: () {
                  widget.onPermissionsChanged(widget.managePostsAndComments,
                      widget.manageUsers, widget.manageSettings);
                  updatePermissions(
                      communityName: widget.communityName,
                      username: widget.username,
                      managePostsAndComments: widget.managePostsAndComments,
                      manageUsers: widget.manageUsers,
                      manageSettings: widget.manageSettings);
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text('Save'))
          ]),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Text(
              "Edit Permissions for r/${widget.username}",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600], // Faint color
              ),
            ),
          ),
          CheckboxListTile(
            title: Text("Manage Posts and Comments"),
            value: widget.managePostsAndComments,
            onChanged: (newValue) {
              setState(() {
                widget.managePostsAndComments = newValue!;
              });
            },
          ),
          CheckboxListTile(
            title: Text("Manage Users"),
            value: widget.manageUsers,
            onChanged: (newValue) {
              setState(() {
                widget.manageUsers = newValue!;
              });
            },
          ),
          CheckboxListTile(
            title: Text("Manage Settings"),
            value: widget.manageSettings,
            onChanged: (newValue) {
              setState(() {
                widget.manageSettings = newValue!;
              });
            },
          ),
        ],
      ),
    );
  }
}
