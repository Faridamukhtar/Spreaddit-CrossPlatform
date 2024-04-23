import 'dart:math';
import 'package:flutter/material.dart';
import 'package:spreadit_crossplatform/features/moderation/muted_users/data/get_muted_users.dart';
import 'package:spreadit_crossplatform/features/moderation/muted_users/data/muted_user_class_model.dart';
import 'package:spreadit_crossplatform/features/moderation/muted_users/presentation/widgets/muted_user_tile.dart';
import 'package:shimmer/shimmer.dart';

class MutedUsersPage extends StatefulWidget {
  @override
  _MutedUsersPageState createState() => _MutedUsersPageState();
}

class _MutedUsersPageState extends State<MutedUsersPage> {
  List<MutedUser> mutedUsers = [];
  var communityName = "ayhaga";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMutedUsers();
  }

  Future<void> fetchMutedUsers() async {
    try {
      var data = await getMutedUsers(communityName);
      setState(() {
        mutedUsers = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching comments: $e');
    }
  }

  void removeMutedUser(MutedUser user) {
    setState(() {
      mutedUsers.remove(user);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Center(
          child: Text('Muted Users'),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/edit-muted-user',
                arguments: {
                  'isFirstFieldEditable': true,
                  'initialUsername': '',
                  'initialModNotes': '',
                  'communityName': communityName,
                },
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? _buildShimmerLoading()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: mutedUsers.length,
                    itemBuilder: (context, index) {
                      return MutedUserTile(
                        mutedUser: mutedUsers[index],
                        communityName: communityName,
                        onUnmute: () => removeMutedUser(mutedUsers[index]),
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/user-profile',
                            arguments: {
                              'username': mutedUsers[index].username,
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: Duration(milliseconds: 1000),
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(),
            title: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: 10.0,
              color: Colors.white,
            ),
            subtitle: Container(
              width: double.infinity,
              height: 10.0,
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }
}
