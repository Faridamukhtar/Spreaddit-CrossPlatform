import 'package:flutter/material.dart';
import 'package:spreadit_crossplatform/features/homepage/presentation/widgets/post_widget.dart';
import 'package:spreadit_crossplatform/features/search/data/get_in_community_search_result.dart';
import 'package:spreadit_crossplatform/features/search/data/get_in_user_search_result.dart';
import 'package:spreadit_crossplatform/features/search/data/get_search_results.dart';
import 'package:spreadit_crossplatform/features/search/presentation/widgets/filter_button.dart';
import 'package:spreadit_crossplatform/features/search/presentation/widgets/page_views_elemets/media_element.dart';
import 'package:spreadit_crossplatform/features/search/presentation/widgets/radio_button_bottom_sheet.dart';
import 'package:spreadit_crossplatform/features/search/presentation/widgets/time_sort.dart';

/// Responsible for displaying the search results for posts which contain media as images an videos.
/// The class displays 2 filter buttons : Sort and Time.
/// The class also displays a list of [MediaElement] widgets, which is a Custom widget to display the posts with media.
/// The class handles the filtering logic upon filter button press , it also handles the logic of tapping a post search result, which is navigating to the corresponding post card.
/// The class also checks if the user comes from the home page or from a community page or user profile, to call the correct api accordingly  

class MediaPageView extends StatefulWidget {
  final String searchItem;
  final String? initialSortFilter;
  final String? initialTimeFilter;
  final bool? fromUserProfile;
  final bool? fromCommunityPage;
  final String? communityOrUserName;

  const MediaPageView({
    Key? key,
    required this.searchItem,
    this.initialSortFilter,
    this.initialTimeFilter,
    this.fromUserProfile,
    this.fromCommunityPage,
    this.communityOrUserName,
    }) : super(key: key);

  @override
  State<MediaPageView> createState() => _MediaPageViewState();
}

class _MediaPageViewState extends State<MediaPageView> {

  Map<String,dynamic> media = {};
  List<Map<String, dynamic>> mappedMedia = [];
  List<Map<String,dynamic>> orgMappedMedia = [];
  String sort = 'relevance';
  String sortText = 'Sort';
  String timeText = 'Time';
  List sortList = [ 'Most relevant','Hot', 'Top', 'New', 'Comment count'];
  List timeList = ['All time', 'Past hour', 'Today', 'Past week', 'Past month', 'Past year'];
  bool showTimeFilter = true;
  bool? fromUserProfile;
  bool? fromCommunityPage;
  String communityOrUserName = '';
  
  @override
  void initState() {
    super.initState(); 
    if (widget.fromUserProfile != null) {
      fromUserProfile = widget.fromUserProfile!;
    }
    if (widget.fromCommunityPage != null) {
      fromCommunityPage = widget.fromCommunityPage!;
    }
    if(widget.communityOrUserName != null) {
      communityOrUserName = widget.communityOrUserName!;
    }
    if (widget.initialSortFilter != null) {
      sort = widget.initialSortFilter!.toLowerCase();
      sortText = widget.initialSortFilter!; 
      if(widget.initialSortFilter == 'New') {
        showTimeFilter = false;
      }
    }
    if(widget.initialTimeFilter != null) {
      timeText = widget.initialTimeFilter!;
    }
    getPostsResults();
  }

  void getPostsResults() async {
    if (fromUserProfile != null && fromUserProfile == true) {
      media = await getUserSearchResults(widget.searchItem, 'posts', sort, communityOrUserName);
    }
    else if (fromCommunityPage != null && fromCommunityPage == true) {
      media = await getCommunitySearchResults(widget.searchItem, 'posts', sort, communityOrUserName);
    }
    else {
      media = await getSearchResults(widget.searchItem, 'posts', sort);
    }
    mappedMedia = extractMediaDetails(media);
    orgMappedMedia = mappedMedia;
    setState(() {});
  }

  List<Map<String, dynamic>> extractMediaDetails(Map<String, dynamic> data) {
    List<dynamic> results = data['results'];
    List<Map<String, dynamic>> mappedMedia = [];
    try {
      for (var post in results) {
        if (post['attachments'].isNotEmpty)
        {
          mappedMedia.add({
          'postId': post['postId'] ?? (throw Exception('null')),
          'title': post['title'] ?? (throw Exception('null')),
          'isNsfw': post['isnsfw'] ?? (throw Exception('null')),
          'isSpoiler': post['isSpoiler'] ?? (throw Exception('null')),
          'votesCount': post['votesCount'] ?? (throw Exception('null')),
          'commentCount': post['commentsCount'] ?? (throw Exception('null')),
          'createdAt': post['date'] ?? (throw Exception('null')),
          'username': post['username'] ?? (throw Exception('null')),
          'userProfilePic': post['userProfilePic'] ?? (throw Exception('null')),
          'communityName': post['communityname'] ?? (throw Exception('null')),
          'communityProfilePic': post['communityProfilePic'] ?? (throw Exception('null')),
          'image': post['attachments'][0]['link'],
          });
        }
      }
      return mappedMedia;
    }
    catch(e) {
      return [];
    }
  }

  void removeFilter() {
    setState(() {
      sortText = 'Sort';
      showTimeFilter;
      timeText = 'Time';
    });
  }

  void updateSortFilter(int value) {
    switch (value) {
      case (0):
        sort = 'relevance';
        sortText = sortList[0];
        showTimeFilter = true;
        break;
      case(1):
        sort = 'hot';
        sortText = sortList[1];
        showTimeFilter = false;
        break;
      case(2):
        sort = 'top';
        sortText = sortList[2];
        showTimeFilter = true;
        break;
      case(3):
        sort = 'new';
        sortText = sortList[3];
        showTimeFilter = false;
        break;
      case(4):
        sort = 'comment';
        sortText = sortList[4];
        showTimeFilter = true;
        break;     
    }
    getPostsResults(); 
  }

  void updateTimeFilter(int value) {
    switch (value) {
      case (0):
        timeText = timeList[0];
        break;
      case(1):
        timeText = timeList[1];
        break;
      case(2):
        timeText = timeList[2];
        break;
      case(3):
        timeText = timeList[3];
        break;
      case(4):
        timeText = timeList[4];
        break;     
    }
    final filteredPosts = sortByTime(orgMappedMedia, timeText);
    mappedMedia = filteredPosts;
    setState((){}); 
  }



  @override
  Widget build(BuildContext context) {
    int totalItemCount = mappedMedia.length;
    int firstColumnCount = totalItemCount % 2 == 0 ? totalItemCount ~/ 2 : (totalItemCount ~/ 2) + 1;
    int secondColumnCount = totalItemCount - firstColumnCount;
    if (media.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4500),
          ),
        ),
      );
    }
    if (mappedMedia.isEmpty) {
      return Image.asset('./assets/images/Empty_Toast.png');
    }
    else {
      return SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                if(sortText != 'Sort')
                  IconButton(
                    onPressed: removeFilter,
                    icon: Icon(Icons.cancel),
                  ),
                FilterButton(
                  openBottomSheet: () {
                    openBottomSheet(
                      sortText,
                      sortList,
                      updateSortFilter,
                      context,
                    );
                  },
                  text: sortText,
                ),
                if (showTimeFilter)
                  FilterButton(
                    openBottomSheet: () { 
                      openBottomSheet(
                        timeText,
                        timeList,
                        updateTimeFilter,
                        context,
                      );  
                    },
                    text: timeText,
                  ),
              ],
            ),
            Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  Container(
                    width: MediaQuery.of(context).size.width/ 2,
                    child: ListView.builder(
                      padding: EdgeInsets.only(top:3),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: firstColumnCount,
                      itemBuilder: (context, index) {
                        int actualIndex = index * 2 ;
                        return InkWell(
                          onTap: () => navigateToPostCardPage(context, mappedMedia[actualIndex]['postId'] , true),
                          child: MediaElement(
                            username: mappedMedia[actualIndex]['username'],
                            userIcon: mappedMedia[actualIndex]['userProfilePic'],
                            postTitle: mappedMedia[actualIndex]['title'],
                            media: mappedMedia[actualIndex]['image'] != null ?
                                mappedMedia[actualIndex]['image'] 
                                : mappedMedia[actualIndex]['video'],
                            mediaType: mappedMedia[actualIndex]['image'] != null ? 'image': 'video',
                          ),
                        );
                      }
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width /2,
                    child: ListView.builder(
                      padding: EdgeInsets.only(top:3),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: secondColumnCount,
                      itemBuilder: (context, index) {
                        int actualIndex = index * 2 + 1;
                        return InkWell(
                          onTap: () => navigateToPostCardPage(context, mappedMedia[actualIndex]['postId'] , true),
                          child: MediaElement(
                            username: mappedMedia[actualIndex]['username'],
                            userIcon: mappedMedia[actualIndex]['userProfilePic'],
                            postTitle: mappedMedia[actualIndex]['title'],
                            media: mappedMedia[actualIndex]['image'] != null ?
                               mappedMedia[actualIndex]['image']
                               :mappedMedia[actualIndex]['video'],
                            mediaType: mappedMedia[actualIndex]['image'] != null ? 'image': 'video',   
                          ),
                        );
                      }
                    ),
                  ),
              ],
            ),
          ],
        ), 
      );
    }
  }
}

