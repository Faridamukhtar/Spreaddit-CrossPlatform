import 'package:flutter/material.dart';

class HomePageDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          ListTile(
            title: Text('u/Basem1166', style: TextStyle(fontSize: 24.0)),
          ),
          ...[
            {
              'icon': Icons.account_circle_outlined,
              'text': 'My profile',
              'route': '/home'
            },
            {
              'icon': Icons.group,
              'text': 'Create a community',
              'route': '/create_a_community'
            },
            {
              'icon': Icons.bookmarks_outlined,
              'text': 'Saved',
              'route': '/home'
            },
            {
              'icon': Icons.watch_later_outlined,
              'text': 'History',
              'route': '/history'
            },
            {
              'icon': Icons.settings_outlined,
              'text': 'Settings',
              'route': '/settings'
            }
          ].map((Map<String, dynamic> item) {
            return ListTile(
              leading: Icon(item['icon']),
              title: Text(item['text'], style: TextStyle(fontSize: 18.0)),
              onTap: () {
                Navigator.pushNamed(context, item['route']);
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}
