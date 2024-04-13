import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:spreadit_crossplatform/features/generic_widgets/bottom_model_sheet.dart';
import 'package:spreadit_crossplatform/features/generic_widgets/comment_footer.dart';
import 'package:spreadit_crossplatform/features/generic_widgets/share.dart';
import 'package:spreadit_crossplatform/features/homepage/presentation/widgets/date_to_duration.dart';
import 'package:spreadit_crossplatform/features/post_and_comments_card/data/comment_model_class.dart';
import 'package:spreadit_crossplatform/features/post_and_comments_card/data/update_comments_list.dart';
import 'package:spreadit_crossplatform/features/post_and_comments_card/presentation/widgets/on_more_functios.dart';
import 'package:spreadit_crossplatform/features/post_and_comments_card/data/get_replies.dart';
import 'package:spreadit_crossplatform/user_info.dart';

class Media {
  final String type;
  final String link;

  Media({
    required this.type,
    required this.link,
  });
}

class _CommentHeader extends HookWidget {
  final String username;
  final String userId;
  final String postId;
  final DateTime date;
  final String profilePic;

  _CommentHeader({
    required this.username,
    required this.userId,
    required this.postId,
    required this.date,
    required this.profilePic,
  });

  @override
  Widget build(BuildContext context) {
    final sec30PassedToggler = useState(false);
    final dateFormatted = useState(dateToDuration(date));

    useEffect(() {
      dateFormatted.value = dateToDuration(date);
      print(dateFormatted.value);
      return;
    }, [sec30PassedToggler.value]);

    useEffect(() {
      final timer = Timer.periodic(Duration(seconds: 30), (timer) {
        sec30PassedToggler.value = !sec30PassedToggler.value;
      });

      return timer.cancel;
    }, []);

    return Material(
      color: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ListTile(
          contentPadding: EdgeInsets.only(top: 20),
          title: Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text(
                username,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(dateFormatted.value),
            ],
          ),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(profilePic),
          ),
        ),
      ),
    );
  }
}

class CommentCard extends StatefulWidget {
  final Comment comment;
  final String community;
  // bool collapseThreadFlag = false;

  CommentCard({
    required this.comment,
    required this.community,
  });

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  bool _repliesFetched = false;
  late bool isUserProfile;

  Future<void> fetchReplies() async {
    if (!_repliesFetched) {
      try {
        var data = await getCommentReplies(widget.comment.id);
        setState(() {
          widget.comment.replies = data;
          _repliesFetched = true;
        });
      } catch (e) {
        print('Error fetching comments: $e');
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isUserProfile = UserSingleton().user != null &&
        widget.comment.username == UserSingleton().user!.username;
    fetchReplies();
  }

  @override
  Widget build(BuildContext context) {
    return _buildCommentWidget(widget.comment);
  }

  Widget _buildCommentWidget(Comment comment) {
    return Padding(
      padding: EdgeInsets.only(left: 15.0, top: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CommentHeader(
                      username: comment.username!,
                      userId: comment.userId!,
                      postId: comment.postId!,
                      date: comment.createdAt,
                      profilePic: comment.profilePic!,
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          comment.isCollapsed = !comment.isCollapsed!;
                        });
                      },
                      child: Text(
                        comment.content,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                    CommentFooter(
                      onMorePressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return CustomBottomSheet(
                              icons: [
                                Icons.share,
                                Icons.notifications_on_rounded,
                                Icons.save,
                                Icons.copy,
                                Icons.block,
                                Icons.flag
                              ],
                              text: [
                                "Share",
                                "Get Reply notifications",
                                "Save",
                                "Copy text",
                                "Block account",
                                "Report"
                              ],
                              onPressedList: [
                                () {
                                  sharePressed(comment.content);
                                },
                                getReplyNotifications,
                                save,
                                ()=>copyText(context, widget.comment.content),
                                ()=>blockAccount(widget.comment.username!),
                                () => report(
                                      context,
                                      widget.community,
                                      widget.comment.postId!,
                                      widget.comment.id,
                                      widget.comment.username!,
                                      false,
                                    ),
                              ],
                            );
                          },
                        );
                      },
                      onReplyPressed: () {
                        TextEditingController replyController =
                            TextEditingController();

                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (BuildContext context) {
                            return SingleChildScrollView(
                              child: Container(
                                padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom,
                                  top: 20,
                                  right: 20,
                                  left: 20,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: replyController,
                                      decoration: InputDecoration(
                                        labelText: 'Your reply...',
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () async {
                                        if (replyController.text != "") {
                                          print('add reply');
                                          Navigator.pop(context);
                                          String newReply =
                                              replyController.text;
                                          print(newReply);
                                          Comment? nReply =
                                              await updateComments(
                                            id: widget.comment.id,
                                            content: newReply,
                                            type: 'reply',
                                          );
                                          setState(() {
                                            widget.comment.replies!
                                                .add(nReply!);
                                            print(
                                                'newComment${nReply!.content}');
                                          });
                                        }
                                      },
                                      child: Text('Reply'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ).whenComplete(() {
                          replyController.dispose();
                        });
                      },
                      number: comment.likesCount,
                      upvoted: false,
                      downvoted: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!comment.isCollapsed && comment.replies != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: comment.replies!.map((reply) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: Colors.grey, width: 1),
                        ),
                      ),
                      margin: EdgeInsets.only(left: 8.0),
                      child: CommentCard(
                        comment: reply,
                        community: widget.community,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
