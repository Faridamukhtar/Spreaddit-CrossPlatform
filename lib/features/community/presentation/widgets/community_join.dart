import 'package:flutter/material.dart';
import 'package:spreadit_crossplatform/features/community/data/api_subscription_info.dart';
import 'package:spreadit_crossplatform/features/generic_widgets/button.dart';
import 'package:spreadit_crossplatform/features/generic_widgets/fail_to_fetch.dart';
import 'package:spreadit_crossplatform/features/generic_widgets/snackbar.dart';
import 'package:spreadit_crossplatform/features/generic_widgets/validations.dart';
import 'package:spreadit_crossplatform/features/user.dart';
import 'package:spreadit_crossplatform/user_info.dart';

/// A button widget that allows the user to join or leave a community.
class JoinCommunityBtn extends StatefulWidget {
  JoinCommunityBtn({
    Key? key,
    required this.communityName,
    this.shouldJoinButtonRender,
  }) : super(key: key);

  /// The name of the community.
  final String communityName;
  final void Function()? shouldJoinButtonRender;

  @override
  State<JoinCommunityBtn> createState() => _JoinCommunityBtnState();
}

class _JoinCommunityBtnState extends State<JoinCommunityBtn> {
  late Future<Map<String, dynamic>> subscriptionDataFuture;
  late Map<String, dynamic> subscriptionData;
  bool isJoined = false;
  bool isNotApprovedForJoin = false;

  @override
  void initState() {
    super.initState();
    checkIfCanJoin();
    fetchData();
  }

  /// [checkIfCanJoin] : a function used to check if users aren't approved for joining the community

  void checkIfCanJoin() async {
    await checkIfBannedOrPrivate(
            widget.communityName, UserSingleton().user!.username)
        .then((value) {
      isNotApprovedForJoin = value;
    });
    if (mounted) {
      setState(() {
        //TODO: check if this causes exception
        isNotApprovedForJoin = isNotApprovedForJoin;
      });
    }
  }

  /// Fetches the subscription data for the community.
  Future<void> fetchData() async {
    subscriptionDataFuture =
        getCommunitySubStatus(widget.communityName).then((value) {
      subscriptionData = value;
      if (subscriptionData["isSubscribed"] == -1) {
        CustomSnackbar(content: "Failed to retrieve subscription data")
            .show(context);
      } else {
        isJoined = subscriptionData["isSubscribed"];

        if (widget.shouldJoinButtonRender != null) {
          widget.shouldJoinButtonRender!();
        }
      }
      return value;
    });
  }

  /// Handles the button press event.
  void handleBtnPress() {
    if (isNotApprovedForJoin && !isJoined) {
      CustomSnackbar(content: "You are not approved to join this community")
          .show(context);
      return;
    }
    if (!isJoined) {
      subscribe();
    } else {
      showDialog(
        context: context,
        builder: (context) => SimpleDialog(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 15),
              child: Text(
                "Are you sure you want to leave the r/${widget.communityName} community",
                softWrap: true,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Button(
                    onPressed: () => Navigator.pop(context),
                    text: 'Cancel',
                    backgroundColor: const Color.fromARGB(255, 214, 214, 215),
                    foregroundColor: Colors.grey,
                  ),
                ),
                Expanded(
                  child: Button(
                    onPressed: () {
                      unsubscribe();
                      Navigator.of(context).pop();
                    },
                    text: 'Leave',
                    backgroundColor: const Color.fromARGB(255, 255, 85, 0),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  /// Subscribes the user to the community.
  void subscribe() async {
    User? currentUser = UserSingleton().getUser();
    String? userId = currentUser?.id;
    var postRequestInfo = {"name": widget.communityName, "userId": userId};
    var response = await postSubscribeRequest(postRequestInfo: postRequestInfo);
    if (response == 200) {
      setState(() {
        isJoined = true;
      });
      CustomSnackbar(content: "Successfully Joined").show(context);
    } else {
      CustomSnackbar(content: "Failed to Join").show(context);
    }
  }

  /// Unsubscribes the user from the community.
  void unsubscribe() async {
    var postRequestInfo = {
      "communityName": widget.communityName,
    };
    var response =
        await postUnsubscribeRequest(postRequestInfo: postRequestInfo);
    if (response == 200) {
      setState(() {
        isJoined = false;
      });
      CustomSnackbar(content: "Successfully Left").show(context);
    } else {
      print(response);
      setState(() {
        CustomSnackbar(content: "Failed to leave").show(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: subscriptionDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.deepOrangeAccent,
            ),
          );
        } else if (snapshot.hasError) {
          return FailToFetchWidget(text: Text('Error fetching data 😔'));
        } else if (snapshot.hasData) {
          return _buildJoinButton();
        } else {
          return FailToFetchWidget(text: Text('Unknown Error 🤔'));
        }
      },
    );
  }

  Widget _buildJoinButton() {
    return TextButton(
      onPressed: () {
        handleBtnPress();
      },
      style: ButtonStyle(
        side: MaterialStateProperty.all(BorderSide(color: Colors.black)),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        backgroundColor: isJoined
            ? MaterialStateProperty.all(Colors.white)
            : MaterialStateProperty.all(Colors.blueAccent),
      ),
      child: Text(
        isJoined ? 'Joined' : 'Join',
        style: isJoined
            ? TextStyle(color: Colors.black)
            : TextStyle(color: Colors.white),
      ),
    );
  }
}
