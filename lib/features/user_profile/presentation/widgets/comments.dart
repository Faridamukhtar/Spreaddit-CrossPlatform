import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spreadit_crossplatform/features/generic_widgets/comment_footer.dart';
import '../../../../user_info.dart';
import '../../../generic_widgets/bottom_model_sheet.dart';
import '../../../homepage/presentation/widgets/date_to_duration.dart';
import '../../../saved/data/unsave.dart';
import '../../data/class_models/comments_class_model.dart';

class CommentWidget extends StatelessWidget {
  final Comment comment;
  final bool saved;

  CommentWidget({
    required this.comment,
    this.saved = false,
  });

  void unsaveComment() async {
    //String accessToken = UserSingleton().accessToken!; 
    String accessToken ='AYHAGANOWc';   //easier for working now
    print(accessToken);
    int statusCode = await unsavePost(id: comment.id, accessToken: accessToken);
    if (statusCode == 200) {
      // Handle success, maybe update UI accordingly
      print('Post unsaved successfully.');
    } else {
      // Handle error, display error message or retry logic
      print('Error occurred while unsaving post.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final date = dateToDuration(comment.createdAt);

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.0),
            margin: EdgeInsets.symmetric(vertical: 5.0),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: saved ? Colors.grey[200]! : Colors.grey,
                  width: saved ? screenHeight * 0.01 : screenHeight * 0.001,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.postTitle,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  children: [
                    if (saved)
                      Text(
                        '${comment.userName} • ',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey,
                        ),
                      ),
                    Text(
                      'r/${comment.subredditName} • $date ',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                    ),
                    if (!saved)
                      Row(
                        children: [
                          Text(
                            '• ${comment.likesCount} ',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                          ),
                          Image.asset(
                            "assets/images/upvoteicon.png",
                            height: screenHeight * 0.015,
                            color: Colors.grey,
                          ),
                        ],
                      )
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  comment.content,
                  style: TextStyle(
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          ),
          if (saved)
            CommentFooter(
              onMorePressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return CustomBottomSheet(
                      icons: [
                        Icons.share,
                        Icons.bookmarks_outlined,
                        CupertinoIcons.bell_solid
                      ],
                      text: [
                        'Share',
                        'Unsave',
                        'Get reply notifications'
                      ],
                      onPressedList: [
                        () => {},
                        () => unsaveComment(), 
                        () => {}
                      ],
                    );
                  },
                );
              },
              onReplyPressed: () {},
              number: comment.likesCount,
              upvoted: false,
              downvoted: false,
            ),
        ],
      ),
    );
  }
}
