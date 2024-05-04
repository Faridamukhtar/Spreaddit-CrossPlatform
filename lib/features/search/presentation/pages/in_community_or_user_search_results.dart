import 'package:flutter/material.dart';
import 'package:spreadit_crossplatform/features/search/presentation/pages/page_views/comments_page_view.dart';
import 'package:spreadit_crossplatform/features/search/presentation/pages/page_views/media_page_view.dart';
import 'package:spreadit_crossplatform/features/search/presentation/pages/page_views/posts_page_view.dart';
import 'package:spreadit_crossplatform/features/search/presentation/widgets/custom_search_bar.dart';
import 'package:spreadit_crossplatform/features/search/presentation/widgets/page_view.dart';
import 'package:spreadit_crossplatform/features/search/presentation/widgets/search_result_header.dart';

class InCommunityOrUserSearchResults extends StatefulWidget {

  final String? searchItem;
  final String communityOrUserName;
  final String communityOrUserIcon;
  final String? sortFilter;
  final String? timeFilter;
  final bool fromUserProfile;
  final bool fromCommunityPage;

  const InCommunityOrUserSearchResults({
    Key? key,
    this.searchItem,
    required this.communityOrUserName,
    required this.communityOrUserIcon,
    this.sortFilter,
    this.timeFilter,
    required this.fromUserProfile,
    required this.fromCommunityPage,
  }) : super(key: key);

  @override
  State<InCommunityOrUserSearchResults> createState() => _InCommunityOrUserSearchResultsState();
}

class _InCommunityOrUserSearchResultsState extends State<InCommunityOrUserSearchResults> {
  final GlobalKey<FormState> searchForm = GlobalKey<FormState>();
  String searchItem = '' ;
  String? initalSortFilter ;
  String? initialTimeFilter;
  List labelsList = ['Posts','Comments', 'Media'];
  int selectedIndex = 0;
  List<Widget> pages = [];
  PageController _pageController = PageController(initialPage: 0); 
  bool? fromUserProfile ;
  bool? fromCommunityPage; 


  @override
  void initState() {
    super.initState();
    if (widget.searchItem != null){
      searchItem = widget.searchItem!;
    }
    initalSortFilter = widget.sortFilter;
    initialTimeFilter = widget.timeFilter;
    fromUserProfile = widget.fromUserProfile;
    fromCommunityPage = widget.fromCommunityPage;
    pages.add(PostsPageView(
      searchItem: searchItem,
      initialSortFilter: initalSortFilter,
      initialTimeFilter: initialTimeFilter,
      fromUserProfile: fromUserProfile,
      fromCommunityPage: widget.fromCommunityPage,
      communityOrUserName: widget.communityOrUserName,
      ));
    pages.add(CommentsPageView(
      searchItem: searchItem,
      initialSortFilter: initalSortFilter,
      fromUserProfile: fromUserProfile,
      fromCommunityPage: widget.fromCommunityPage,
      communityOrUserName: widget.communityOrUserName,
      ));
    pages.add(MediaPageView(
      searchItem: searchItem,
      initialSortFilter: initalSortFilter,
      initialTimeFilter: initialTimeFilter,
      fromUserProfile: fromUserProfile,
      fromCommunityPage: widget.fromCommunityPage,
      communityOrUserName: widget.communityOrUserName,
      ));
  }

  void updateSearchItem(String value) {
    searchItem = value;
    searchForm.currentState!.save();
  }

  void onTabSelected(int index) {
    setState(() {
      selectedIndex = index;
      _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 500),
      curve: Curves.ease,
      );
    });
  }

  void navigateToSearchInCommunityOrUserResults (String searchItem) {
    Navigator.of(context).pushNamed('/community-or-user-search-results', arguments :{
      'searchItem': searchItem,
    });
  }

  void navigateToInCommunityOrUserSearch () {
    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back),
              ),
              CustomSearchBar(
                formKey: searchForm,
                hintText: '',
                navigateToSearchResult: navigateToSearchInCommunityOrUserResults,
                updateSearchItem: updateSearchItem,
                navigateToSuggestedResults: navigateToInCommunityOrUserSearch,
                initialBody: searchItem,
                communityOrUserName: widget.communityOrUserName,
                communityOrUserIcon: widget.communityOrUserIcon,
                isContained: true,
              ),
            ],
          ),
          SizedBox(height: 8),
          SearchResultHeader(
            labels: labelsList,
            onTabSelected: onTabSelected,
          ),
          Expanded(
            child: CustomPageView(
              pages: pages,
              currentIndex: selectedIndex,
              pageController: _pageController,
            ),
          ),
        ],
      ),
    );
  }
}