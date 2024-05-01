import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:spreadit_crossplatform/features/community/data/api_community_info.dart';
import 'package:spreadit_crossplatform/features/community/presentation/widgets/community_app_bar.dart';
import 'package:spreadit_crossplatform/features/community/presentation/widgets/community_info_sect.dart';
import 'package:spreadit_crossplatform/features/homepage/data/get_feed_posts.dart';
import 'package:spreadit_crossplatform/features/homepage/presentation/widgets/post_feed.dart';
import 'package:spreadit_crossplatform/features/loader/loader_widget.dart';
import 'package:spreadit_crossplatform/features/modtools/data/api_approved_users.dart';
import 'package:spreadit_crossplatform/features/modtools/data/api_banned_users.dart';
import 'package:spreadit_crossplatform/user_info.dart';

/// A page that displays the community page, info, and posts.
class CommunityPage extends StatefulWidget {
  /// The name of the community.
  final String communityName;

  /// Creates a [CommunityPage] with the given [communityName].
  CommunityPage({Key? key, required this.communityName}) : super(key: key);

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  bool isInitialized = false;
  late Map<String, dynamic> data;
  String communityBannerLink = "";
  ScrollController _scrollController = ScrollController();
  late Future<Map<String, dynamic>> communityDataFuture;
  late Future<Map<String, dynamic>> isApprovedDataFuture;
  late Future<Map<String, dynamic>> isBannedDataFuture;
  int communityDataIdx = 0;
  int isApprovedDataIdx = 1;
  int isBannedDataIdx = 2;
  Map<String, dynamic> communityData = {};
  Map<String, dynamic> isApprovedData = {};
  Map<String, dynamic> isBannedData = {};
  List<List<String>> alertTexts = [
    [
      "You are banned from this community 🔨",
      "You are banned from this community and cannot view its content 🛑."
    ],
    ["You are not an approved user 🔐", "This is a private community 🫣"]
  ];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  /// Fetches the community information.
  Future<void> fetchData() async {
    communityDataFuture = getCommunityInfo(widget.communityName)
        .then((value) => communityData = value);
    isApprovedDataFuture = checkIfApprovedRequest(
      communityName: widget.communityName,
      username: (UserSingleton().user != null)
          ? UserSingleton().user!.username
          : "ss",
    ).then((value) => isApprovedData = value);
    isBannedDataFuture = checkIfBannedRequest(
      communityName: widget.communityName,
      username: (UserSingleton().user != null)
          ? UserSingleton().user!.username
          : "ss",
    ).then((value) => isBannedData = value);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait(
          [communityDataFuture, isApprovedDataFuture, isBannedDataFuture]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: LoaderWidget(
              dotSize: 10,
              logoSize: 100,
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text("Error while fetching data 😔"),
          );
        } else if (snapshot.hasData) {
          if (!isInitialized) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              String title = "";
              String content = "";
              if (isBannedData["isBanned"] == true) {
                title = alertTexts[0][0];
                content = alertTexts[0][1];
                _showHaltingAlert(title: title, content: content);
              } else if (communityData["communityType"] == "Private" &&
                  isApprovedData["isContributor"] == false) {
                title = alertTexts[1][0];
                content = alertTexts[1][1];
                _showHaltingAlert(title: title, content: content);
              }
            });
            isInitialized = true;
          }
          return Scaffold(
            backgroundColor: Color.fromARGB(237, 236, 236, 234),
            appBar: CommunityAppBar(
              bannerImageLink: communityData["communityBanner"],
              communityName: widget.communityName,
            ),
            body: _buildNormalBody(),
          );
        } else {
          return Center(child: Text("Unknown error fetching data 🤔"));
        }
      },
    );
  }

  Widget _buildNormalBody() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Container(
        color: Color.fromARGB(255, 228, 227, 227),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CommunityInfoSection(
              communityName: widget.communityName,
              communityData: communityData,
            ),
            // PostFeed(
            //   postCategory: PostCategories.hot,
            //   subspreaditName: widget.communityName,
            //   startSortIndex: 1,
            //   endSortIndex: 3,
            //   showSortTypeChange: true,
            //   scrollController: _scrollController,
            // ),
          ],
        ),
      ),
    );
  }

  void _showHaltingAlert({required String title, required String content}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return NonSkippableAlertDialog(
          title: title,
          content: content,
        );
      },
    );
  }
}

class NonSkippableAlertDialog extends StatelessWidget {
  final String title;
  final String content;

  NonSkippableAlertDialog({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        // Ensure dialog is not dismissed when tapped outside
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  content,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: ElevatedButton(
                    onPressed: () {
                      int count = 2;
                      Navigator.of(context).popUntil((route) => count-- <= 0);
                    },
                    child: Text('OK'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
