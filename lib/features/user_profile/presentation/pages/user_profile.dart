import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spreadit_crossplatform/features/loader/loader_widget.dart';
import 'package:spreadit_crossplatform/features/post_and_comments_card/data/comment_model_class.dart';
import 'package:spreadit_crossplatform/features/post_and_comments_card/data/get_post_comments.dart';
import 'package:spreadit_crossplatform/features/user_profile/data/get_moderator_community.dart';
import 'package:spreadit_crossplatform/features/user_profile/presentation/widgets/comments_shimmering.dart';
import 'package:spreadit_crossplatform/user_info.dart';
import '../../../discover_communities/data/community.dart';
import '../../../generic_widgets/snackbar.dart';
import '../../../homepage/data/get_feed_posts.dart';
import '../../../homepage/presentation/widgets/post_feed.dart';
import '../../data/date_conversion.dart';
import '../../data/follow_unfollow_api.dart';
import '../widgets/about.dart';
import '../widgets/active_community.dart';
import '../widgets/comments.dart';
import '../../../generic_widgets/custom_bar.dart';
import '../widgets/profile_header.dart';
import '../../data/get_user_info.dart';
import '../../data/class_models/user_info_class_model.dart';
import '../../data/get_follow_status.dart';

/// `UserProfile` is a StatefulWidget responsible for displaying the user's profile information,
/// including their background, profile picture, karma, about section, and active communities.
///
/// This widget fetches user data asynchronously and updates its state accordingly. It provides
/// functionality to toggle follow status, view user comments, and navigate to edit profile.
class UserProfile extends StatefulWidget {
  final String? username;

  const UserProfile({Key? key, this.username}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

/// The state class for `UserProfile`. Handles state management and UI rendering.
class _UserProfileState extends State<UserProfile> {
  int _selectedIndex = 0;
  late bool myProfile = true;
  String backgroundImage = '';
  String profilePicture = '';
  String formattedDate = '';
  UserInfo? userInfoFuture;
  String userinfo = '';
  String about = '';
  String background = '';
  bool? followStatus = false;
  bool isActive = false;
  String displayName = '';
  String postKarmaNo = '';
  String commentKarmaNo = '';
  List<Comment> commentsList = [];
  List<Community> communitiesList = [];
  List<Map<String, dynamic>> socialMediaLinks = [];
  File? backgroundImageFile;
  File? profileImageFile;
  Uint8List? imageBackgroundWeb;
  ScrollController _scrollController = ScrollController();
  Uint8List? imageProfileWeb;
  late String username;
  List<Community> moderatorCommunities = [];
  bool isCommentsLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    username = args?['username'] ?? widget.username ?? '';
    username = username == '' ? UserSingleton().user!.username : username;
    myProfile = username == UserSingleton().user!.username;
    fetchUserInfoAsync();
    fetchComments();
    checkFollowStatus();
  }

  @override
  void initState() {
    super.initState();
  }

  /// Checks the follow status of the current user.
  void checkFollowStatus() async {
    try {
      followStatus = await isFollowed(username);
    } catch (e) {
      CustomSnackbar(content: "An error ocuured please try again later").show(context);
    }
  }

  /// Fetches user information asynchronously.
  void fetchUserInfoAsync() async {
    try {
      userInfoFuture = await fetchUserInfo(username);
      List<Community> moderatorCommunitiess =
          await GetUserModeratorCommunity().getCommunities();
      setState(() {
        formattedDate = formatDate(userInfoFuture!.dateOfJoining);
        userinfo =
            'u/${userInfoFuture!.username} • ${userInfoFuture!.numberOfKarmas} Karma • $formattedDate';
        about = userInfoFuture!.about;
        background = userInfoFuture!.background;
        postKarmaNo = userInfoFuture!.postKarmaNo;
        commentKarmaNo = userInfoFuture!.commentKarmaNo;
        profilePicture = userInfoFuture!.avatar;
        displayName = userInfoFuture!.displayname;
        isActive = userInfoFuture!.isActive;
        moderatorCommunities = moderatorCommunitiess;
        socialMediaLinks = userInfoFuture!.socialMedia
            .map((socialMedia) => {
                  'platform': socialMedia.platform,
                  'url': socialMedia.url,
                  'displayName': socialMedia.displayname,
                })
            .toList();
        communitiesList = userInfoFuture!.subscribedCommunities;
      });
    } catch (e) {
      print('Error fetching user info: $e');
    }
  }

  /// Toggles follow status.
  Future<void> unfollowOrFollow() async {
    try {
      var response =
          await toggleFollow(isFollowing: followStatus!, username: username);
      if (response == 200) {
        setState(() {
          followStatus = !followStatus!;
        });
      } else if (response == 400) {
        CustomSnackbar(content: 'Username is required').show(context);
      } else if (response == 404) {
        CustomSnackbar(content: 'User not found').show(context);
      } else if (response == 500) {
        CustomSnackbar(content: "an error ocuured try again later")
            .show(context);
      }
    } catch (e) {
      print('Error toggling follow status: $e');
    }
  }

  /// Fetches comments made by the user.
  Future<void> fetchComments() async {
    try {
      var data = await fetchCommentsData(username, 'user', '1');
      setState(() {
        commentsList = data;
        isCommentsLoaded = true;
      });
    } catch (e) {
      print('Error fetching comments: $e');
    }
  }

  /// Callback for changing the selected page/tab.
  void _onIndexChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  ///navigate to edit profile and send and recieve the data back
  void navigateToEditProfile(BuildContext context) async {
    final returnedData = await Navigator.of(context).pushNamed(
      '/edit-profile',
      arguments: {
        'backgroundImageUrl': background,
        'backgroundImageFile': backgroundImageFile,
        'backgroundImageWeb': imageBackgroundWeb,
        'profileImageWeb': imageProfileWeb,
        'profileImageUrl': profilePicture,
        'profileImageFile': profileImageFile,
        'about': about,
        'displayname': displayName,
        'socialMediaLinks': socialMediaLinks,
        'isActive': isActive,
      },
    );
    if (returnedData != null && returnedData is Map<String, dynamic>) {
      setState(() {
        backgroundImage = returnedData['backgroundImage'] ?? '';
        profilePicture = returnedData['profilePicImage'] ?? '';
        backgroundImageFile = returnedData['backgroundImageFile'];
        profileImageFile = returnedData['profileImageFile'];
        imageBackgroundWeb = returnedData['backgroundImageWeb'];
        imageProfileWeb = returnedData['profileImageWeb'];
        socialMediaLinks = returnedData['socialMedia'] ?? [];
        about = returnedData['about'] ?? '';
        displayName = returnedData['displayname'] ?? '';
        isActive = returnedData['isActive'];
      });
    }
  }

  /// Builds the selected page based on the current index.
  Widget _buildSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (communitiesList.isNotEmpty && isActive)
                Container(
                  width: double.infinity, // Take the full width of the screen
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 15.0),
                        child: Text(
                          'Active Communities',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      SizedBox(
                        height: kIsWeb
                            ? MediaQuery.of(context).size.height * 0.25
                            : MediaQuery.of(context).size.height * 0.21,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: communitiesList.map((communities) {
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5.0, vertical: 10.0),
                                child: ActiveCommunity(
                                  community: communities,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              PostFeed(
                scrollController: _scrollController,
                postCategory: PostCategories.user,
                username: username,
              ),
            ],
          ),
        );

      case 1:
        return isCommentsLoaded
            ? SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final comment = commentsList[index];
                    return CommentWidget(comment: comment);
                  },
                  childCount: commentsList.length,
                ),
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return CommentShimmerWidget(
                      saved: false,
                    );
                  },
                  childCount: 10,
                ),
              );

      case 2:
        return SliverToBoxAdapter(
          child: AboutWidget(
            postKarmaNo: postKarmaNo,
            commentKarmaNo: commentKarmaNo,
            aboutText: about,
            onSendMessagePressed: () {},
            onStartChatPressed: () {},
            myProfile: myProfile,
          ),
        );
      default:
        return SliverToBoxAdapter(
          child: Text('User not found'),
        );
    }
  }

  /// Builds the user profile widget.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scrollbar(
        child: CustomScrollView(
          physics: ScrollPhysics(),
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: userInfoFuture == null
                  ? Container(
                      alignment: Alignment.center,
                      constraints: BoxConstraints(
                        maxWidth: 50.0,
                        maxHeight: 200.0,
                      ),
                      child: Center(
                        child: LoaderWidget(dotSize: 10, logoSize: 0.0),
                      ))
                  : ProfileHeader(
                      backgroundImage: background,
                      profilePicture: profilePicture,
                      backgroundImageFile: backgroundImageFile,
                      profileImageWeb: imageProfileWeb,
                      backgroundImageWeb: imageBackgroundWeb,
                      profileImageFile: profileImageFile,
                      username: username,
                      displayName: displayName,
                      userinfo: userinfo,
                      about: about,
                      myProfile: myProfile,
                      followed: followStatus!,
                      follow: unfollowOrFollow,
                      onStartChatPressed: () => {},
                      editprofile: () => navigateToEditProfile(context),
                      socialMediaLinks: socialMediaLinks,
                      moderatorCommunities: moderatorCommunities,
                    ),
            ),
            SliverToBoxAdapter(
              child: CustomBar(
                tabs: ['Posts', 'Comments', 'About'],
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
