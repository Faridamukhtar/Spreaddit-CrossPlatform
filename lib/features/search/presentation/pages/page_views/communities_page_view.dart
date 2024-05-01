import 'package:flutter/material.dart';
import 'package:spreadit_crossplatform/features/search/data/get_search_results.dart';
import 'package:spreadit_crossplatform/features/search/presentation/widgets/page_views_elemets/community_element.dart';

class CommunitiesPageView extends StatefulWidget {
  final String searchItem;

  const CommunitiesPageView({Key? key, required this.searchItem}) : super(key: key);

  @override
  State<CommunitiesPageView> createState() => _CommunitiesPageViewState();
}

class _CommunitiesPageViewState extends State<CommunitiesPageView> {

  Map<String,dynamic> communities = {};
  List<Map<String, dynamic>> mappedCommunities = [];
  
  @override
  void initState() {
    super.initState();
    getCommunitiesResults();
  }

  void getCommunitiesResults() async {
    communities = await getSearchResults(widget.searchItem, 'communities','relevance');
    mappedCommunities = communities != {} ? extractCommunityDetails(communities) : [];
    setState(() {});
  }

  List<Map<String, dynamic>> extractCommunityDetails(Map<String, dynamic> data) {
    List<dynamic> results = data['results'];
    List<Map<String, dynamic>> mappedCommunities = [];
    for (var community in results) {
      mappedCommunities.add({
        'communityId' : community['communityId'],
        'communityName': community['communityName'],
        'communityProfilePic': community['communityProfilePic'],
        'membersCount': community['membersCount'],
        'communityInfo': community['communityInfo'],
        'isFollowing': community['isFollowing'],
      });
    }
    return mappedCommunities;
  }

  @override
  Widget build(BuildContext context) {
    if (mappedCommunities.isEmpty) {
      return Image.asset('./assets/images/Empty_Toast.png');
    }
    else {
      return SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              padding: EdgeInsets.only(top:3),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: mappedCommunities.length,
              itemBuilder: (context, index) {
                return CommunityElement(
                  communityName: mappedCommunities[index]['communityName'],
                  communityDescription: mappedCommunities[index]['communityInfo'],
                  communityIcon: mappedCommunities[index]['communityProfilePic'],
                  membersCount: mappedCommunities[index]['membersCount'] < 1000 ?
                        mappedCommunities[index]['membersCount'].toString() 
                        : '${(mappedCommunities[index]['membersCount']/100).truncateToDouble() /10.0}k',
                  isFollowing: mappedCommunities[index]['isFollowing'],      
                  );
              }
            ),
          ],
        ), 
      );
    }
  }
}
