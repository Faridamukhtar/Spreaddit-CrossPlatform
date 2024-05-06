import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spreadit_crossplatform/features/search/data/post_search_log.dart';

class CustomSearchBar extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final String hintText;
  final Function(String) updateSearchItem;
  final Function(String) navigateToSearchResult;
  final VoidCallback navigateToSuggestedResults;
  final String? initialBody;
  final String? communityOrUserName;
  final String? communityOrUserIcon;
  final bool? isContained;
  final bool? inCommunityPage;
  final bool? inUserProfile;

  const CustomSearchBar({
    required this.formKey,
    required this.hintText,
    required this.updateSearchItem,
    required this.navigateToSearchResult,
    required this.navigateToSuggestedResults,
    this.initialBody,
    this.communityOrUserName,
    this.communityOrUserIcon,
    this.isContained,
    this.inCommunityPage,
    this.inUserProfile,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialBody);
     _controller.addListener(() {
      widget.updateSearchItem(_controller.text); 
    });
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void saveSearchLog (String query) async {
    if (widget.inCommunityPage != null && widget.inCommunityPage == true) {
      await postSearchLog(query,'community', widget.communityOrUserName!, null,false);
      print('community query log submitted');
    }
    else if (widget.inUserProfile != null && widget.inUserProfile == true) {
      await postSearchLog(query,'user', null, widget.communityOrUserName!,true);
      print('user query log submitted');
    }
    else {
      int response =await postSearchLog(query,'normal', null, null , false);
    }

  } 

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      height: 50,
      width: 330,
      decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        children: [
          Form(
            key: widget.formKey,
            child: Row(
              children: [
                if (widget.isContained != null && widget.isContained == true && widget.communityOrUserName != null)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[300],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10), 
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(widget.communityOrUserIcon!),
                          radius: 10,
                        ),
                        SizedBox(width:4),
                        Text(
                          widget.communityOrUserName!,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: FocusScope(
                    child: TextFormField(
                      onTap: widget.navigateToSuggestedResults,
                      onFieldSubmitted: (text) {
                        if (text.trim().isNotEmpty) {
                          widget.navigateToSearchResult(text);
                          saveSearchLog(text);
                        } else {
                          FocusScope.of(context).unfocus();
                        }
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                        hintText: widget.hintText,
                        prefixIcon: widget.communityOrUserIcon != null
                            ? null
                            : Icon(Icons.search), 
                      ),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      controller: _controller,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


         
