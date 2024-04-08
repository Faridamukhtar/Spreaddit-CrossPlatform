import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spreadit_crossplatform/features/community/presentation/pages/community_about_page.dart';
import 'package:spreadit_crossplatform/features/homepage/data/get_feed_posts.dart';
import 'package:spreadit_crossplatform/features/community/data/api_community_info.dart';
import 'package:spreadit_crossplatform/features/community/presentation/widgets/community_join.dart';
import 'package:spreadit_crossplatform/features/homepage/presentation/widgets/post_feed.dart';

class CommunityInfoSection extends StatefulWidget {
  const CommunityInfoSection({Key? key, required this.communityName})
      : super(key: key);

  final String communityName;

  @override
  State<CommunityInfoSection> createState() => _CommunityInfoSectionState();
}

class _CommunityInfoSectionState extends State<CommunityInfoSection> {
  late Map<String, dynamic> communityData;
  String membersCount = "0";
  String communityDescription = "";
  String communityImageLink = "";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    communityData = await getCommunityInfo(widget.communityName);
    setState(() {
      membersCount = formatNumber(communityData["memberscount"]);
      communityImageLink = communityData["image"];
      communityDescription = communityData["description"];
    });
  }

  formatNumber(dynamic myNumber) {
    myNumber.toString();
    NumberFormat numberFormat =
        NumberFormat.compact(locale: "en_US", explicitSign: false);
    return numberFormat.format(myNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 15, top: 15, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: [
                    CircleAvatar(
                      foregroundImage: (communityImageLink != "")
                          ? NetworkImage(communityImageLink)
                          : NetworkImage(
                              "https://cdn-icons-png.flaticon.com/512/5968/5968908.png"),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "r/${widget.communityName}",
                          softWrap: true,
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 17),
                        ),
                        Text(
                          "$membersCount members",
                          style: TextStyle(
                            color: const Color.fromARGB(255, 25, 25, 25),
                            fontSize: 17,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                JoinCommunityBtn(
                  communityName: widget.communityName,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15),
            child: Text(
              communityDescription,
              softWrap: true,
              style: TextStyle(
                  fontSize: 15, color: const Color.fromARGB(255, 96, 95, 95)),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 7),
            child: TextButton(
              style: ButtonStyle(
                overlayColor:
                    MaterialStateProperty.all(Colors.grey.withOpacity(0.5)),
              ),
              child: Text(
                'See more',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 4, 66, 117),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CommunityAboutPage(
                      communityName: widget.communityName,
                    ),
                  ),
                );
              },
            ),
          ),
          PostFeed(
            postCategory: PostCategories.best,
          ),
        ],
      ),
    );
  }
}
