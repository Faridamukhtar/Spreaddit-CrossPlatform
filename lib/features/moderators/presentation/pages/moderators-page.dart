import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ionicons/ionicons.dart';
import 'package:spreadit_crossplatform/features/generic_widgets/bottom_model_sheet.dart';
import 'package:spreadit_crossplatform/features/generic_widgets/custom_bar.dart';
import 'package:spreadit_crossplatform/features/moderators/data/delete_moderator.dart';
import 'package:spreadit_crossplatform/features/moderators/data/get_moderators.dart';
import 'package:spreadit_crossplatform/features/moderators/data/moderator_class_model.dart';
import 'package:spreadit_crossplatform/features/moderators/presentation/pages/edit_moderators_permissions.dart';
import 'package:spreadit_crossplatform/features/moderators/presentation/pages/invite_moderator_page.dart';
import 'package:spreadit_crossplatform/features/user_profile/presentation/pages/user_profile.dart';
import 'package:spreadit_crossplatform/user_info.dart';
import '../../../homepage/presentation/widgets/date_to_duration.dart';
import 'package:spreadit_crossplatform/features/moderators/presentation/widgets/invitation_to_moderate.dart';

class ModeratorsPage extends StatefulWidget {
  final String communityName;
  const ModeratorsPage({required this.communityName});

  @override
  State<ModeratorsPage> createState() {
    return _ModeratorsPageState();
  }
}

class _ModeratorsPageState extends State<ModeratorsPage> {
  bool isModerator = true;
  int _selectedIndex = 0;
  List<Moderator> moderatorsList = [];
  List<Moderator> editableModeratorsList = [];
  @override
  void initState() {
    super.initState();
    fetchModerators();
    //ModeratorsList = fetchModeratorsData(widget.communityName, _selectedIndex);
  }

  void _onIndexChanged(int index) {
    setState(() {
      _selectedIndex = index;
      fetchModerators();
    });
  }

  void onPermissionsChanged(bool newManagePostAndComments, bool newManageUsers,
      bool newMnageSettings) {
    setState(() {});
  }

  Future<void> fetchModerators() async {
    try {
      var data =
          await fetchModeratorsData(widget.communityName, _selectedIndex);
      print(data);
      setState(() {
        if (_selectedIndex == 1) {
          editableModeratorsList = data;
        } else {
          moderatorsList = data;
        }
      });
    } catch (e) {
      print('Error fetching moderators: $e');
    }
  }

  void removeModeratorFromList(Moderator moderator) {
    setState(() {
      editableModeratorsList.remove(moderator);
      moderatorsList.remove(moderator);
      deleteModerator(widget.communityName, moderator.username);
    });
  }

  Widget _buildSelectedPage() {
    print('build');
    print("_selectedIndexxx: $_selectedIndex");
    switch (_selectedIndex) {
      case 0: //all moderators case
        return SliverToBoxAdapter(
          child: ListView(
              shrinkWrap: true,
              children: moderatorsList.map((e) {
                return ListTile(
                    leading:
                        CircleAvatar(foregroundImage: NetworkImage(e.avatar)),
                    title: Text(e.username,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold)),
                    subtitle: Row(children: [
                      Text(dateToDuration(e.moderationDate)),
                      e.managePostsAndComments &&
                              e.manageSettings &&
                              e.manageUsers
                          ? Text(
                              '   .Manage posts and comments, Manage settings, Manage users',
                              maxLines: 10,
                              overflow: TextOverflow.ellipsis,
                            )
                          : e.managePostsAndComments && e.manageSettings
                              ? Text(
                                  '   .Manage posts and comments, Manage settings',
                                  maxLines: 10,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : e.managePostsAndComments && e.manageUsers
                                  ? Text(
                                      '   .Manage posts and comments, Manage users',
                                      maxLines: 10,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : e.manageSettings && e.manageUsers
                                      ? Text(
                                          '   .Manage settings, Manage users',
                                          maxLines: 10,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      : e.managePostsAndComments
                                          ? Text(
                                              '   .Manage posts and comments',
                                              maxLines: 10,
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          : e.manageSettings
                                              ? Text(
                                                  '   .Manage settings',
                                                  maxLines: 10,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                )
                                              : e.manageUsers
                                                  ? Text(
                                                      '   .Manage users',
                                                      maxLines: 10,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )
                                                  : Text(""),
                    ]),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          settings: RouteSettings(
                            name: '/user-profile/${e.username}',
                          ),
                          builder: (context) => UserProfile(
                            username: e.username,
                          ),
                        ),
                      );
                    });
              }).toList()),
        );
      case 1: //editable moderators
        return SliverToBoxAdapter(
          child: ListView(
              shrinkWrap: true,
              children: editableModeratorsList.map((e) {
                void onPermissionsChanged(bool newManagePostAndComments,
                    bool newManageUsers, bool newManageSettings) {
                  setState(() {
                    e.managePostsAndComments = newManagePostAndComments;
                    e.manageUsers = newManageUsers;
                    e.manageSettings = newManageSettings;
                  });
                }

                return ListTile(
                    leading:
                        CircleAvatar(foregroundImage: NetworkImage(e.avatar)),
                    title: Text(e.username,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold)),
                    subtitle: Row(children: [
                      Text(dateToDuration(e.moderationDate)),
                      e.managePostsAndComments &&
                              e.manageSettings &&
                              e.manageUsers
                          ? Text(
                              '   .Manage posts and comments,    \n    Manage settings,  Manage users',
                              maxLines: 10,
                              overflow: TextOverflow.ellipsis,
                            )
                          : e.managePostsAndComments && e.manageSettings
                              ? Text(
                                  '   .Manage posts and comments, Manage settings',
                                  maxLines: 10,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : e.managePostsAndComments && e.manageUsers
                                  ? Text(
                                      '   .Manage posts and comments, Manage users',
                                      maxLines: 10,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : e.manageSettings && e.manageUsers
                                      ? Text(
                                          '   .Manage settings, Manage users',
                                          maxLines: 10,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      : e.managePostsAndComments
                                          ? Text(
                                              '   .Manage posts and comments',
                                              maxLines: 10,
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          : e.manageSettings
                                              ? Text(
                                                  '   .Manage settings',
                                                  maxLines: 10,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                )
                                              : e.manageUsers
                                                  ? Text(
                                                      '   .Manage users',
                                                      maxLines: 10,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )
                                                  : Text(""),
                    ]),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          settings: RouteSettings(
                            name: '/user-profile/${e.username}',
                          ),
                          builder: (context) => UserProfile(
                            username: e.username,
                          ),
                        ),
                      );
                    },
                    trailing: Flexible(
                      child: IconButton(
                        icon: Icon(Icons.more_vert_rounded),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return CustomBottomSheet(
                                icons: [
                                  if (e.username !=
                                      UserSingleton().user!.username)
                                    Icons.edit,
                                  Icons.person,
                                  Icons.block
                                ],
                                text: [
                                  if (e.username !=
                                      UserSingleton().user!.username)
                                    "Edit Permissions",
                                  "View profile",
                                  "Remove"
                                ],
                                onPressedList: [
                                  if (e.username !=
                                      UserSingleton().user!.username)
                                    () {
                                      //navigate to edit permissions page

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditPermissionsPage(
                                            communityName: widget.communityName,
                                            username: e.username,
                                            managePostsAndComments:
                                                e.managePostsAndComments,
                                            manageUsers: e.manageUsers,
                                            manageSettings: e.manageSettings,
                                            onPermissionsChanged:
                                                onPermissionsChanged,
                                          ),
                                        ),
                                      );
                                    },
                                  () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        settings: RouteSettings(
                                          name: '/user-profile/${e.username}',
                                        ),
                                        builder: (context) => UserProfile(
                                          username: e.username,
                                        ),
                                      ),
                                    );
                                  },
                                  () {
                                    removeModeratorFromList(e);
                                    Navigator.pop(context);
                                  }
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ));
              }).toList()),
        );
      default:
        return SliverToBoxAdapter(
          child: ListView(
              shrinkWrap: true,
              children: moderatorsList.map((e) {
                return ListTile(
                  leading:
                      CircleAvatar(foregroundImage: NetworkImage(e.avatar)),
                  title: Text(e.username,
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold)),
                  subtitle: Row(children: [
                    Text(dateToDuration(e.moderationDate)),
                    e.managePostsAndComments &&
                            e.manageSettings &&
                            e.manageUsers
                        ? Text(
                            '   .Manage posts and comments, Manage settings, Manage users',
                            maxLines: 10,
                            overflow: TextOverflow.ellipsis,
                          )
                        : e.managePostsAndComments && e.manageSettings
                            ? Text(
                                '   .Manage posts and comments, Manage settings',
                                maxLines: 10,
                                overflow: TextOverflow.ellipsis,
                              )
                            : e.managePostsAndComments && e.manageUsers
                                ? Text(
                                    '   .Manage posts and comments, Manage users',
                                    maxLines: 10,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : e.manageSettings && e.manageUsers
                                    ? Text(
                                        '   .Manage settings, Manage users',
                                        maxLines: 10,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : e.managePostsAndComments
                                        ? Text(
                                            '   .Manage posts and comments',
                                            maxLines: 10,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        : e.manageSettings
                                            ? Text(
                                                '   .Manage settings',
                                                maxLines: 10,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : e.manageUsers
                                                ? Text(
                                                    '   .Manage users',
                                                    maxLines: 10,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                : Text(""),
                  ]),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        settings: RouteSettings(
                          name: '/user-profile/${e.username}',
                        ),
                        builder: (context) => UserProfile(
                          username: e.username,
                        ),
                      ),
                    );
                  },
                );
              }).toList()),
        );
    }
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
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InviteModeratorPage(
                      communityName: widget.communityName,
                    ),
                  ),
                );
              }),
        ],
      ),
      body: Container(
        color: _selectedIndex == 1 ? Colors.transparent : Colors.transparent,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: CustomBar(
                tabs: ['All', 'Editable'],
                onIndexChanged: _onIndexChanged,
              ),
            ),
            _buildSelectedPage(),
          ],
        ),
      ),
    );
  }
}
