import 'dart:math';

import 'package:flutter/material.dart';
import 'package:spreadit_crossplatform/features/dynamic_navigations/navigate_to_community.dart';
import 'package:spreadit_crossplatform/features/user_profile/presentation/pages/user_profile.dart';
import '../../../generic_widgets/communities_search_card.dart';

class SearchDisplayList extends StatefulWidget {

   final List displayList;
   final String type;

   const SearchDisplayList({
    required this.displayList,
    required this.type,
  });

  @override
  State<SearchDisplayList> createState() => _SearchDisplayListState();
}

class _SearchDisplayListState extends State<SearchDisplayList> {

  void navigateToTappedItem(String searchItem , String type) {
    if(type == 'user') {
      Navigator.of(context).push(
                MaterialPageRoute(
                  settings: RouteSettings(
                    name: '/user-profile/$searchItem',
                  ),
                  builder: (context) => UserProfile(
                    username: searchItem,
                  ),
                ),
              );
    } 
    else {
      navigateToCommunity(context, searchItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        padding: EdgeInsets.only(top:3),
        shrinkWrap: true,
        itemCount: min(widget.displayList.length, 5),
        itemBuilder: (context, index) {
          String searchItem = widget.type == 'user'? widget.displayList[index]['username'] : widget.displayList[index]['communityName'];
          return InkWell(
            onTap: () => navigateToTappedItem(searchItem,widget.type) ,  
            child: CommunitiesCard(
              communityName: widget.type == 'user'? 
                  widget.displayList[index]['username'] 
                  : widget.displayList[index]['communityName'],
              communityIcon: widget.type == 'user'? 
                  widget.displayList[index]['avatar'] 
                  : widget.displayList[index]['communityProfilePic'],
              boxSize: 7,
              iconRadius: 13, 
              fontSize: 17,
              extraInfo: 
                widget.type == 'community' ? 
                  '${widget.displayList[index]['membersCount']} members' 
                   : '' ,
            ),
          );
        }
      ),     
    );
  }
}
