import 'dart:io';
import 'package:flutter/material.dart';

import 'package:spreadit_crossplatform/features/generic_widgets/image_picker.dart';
import 'package:spreadit_crossplatform/features/generic_widgets/snackbar.dart';
import 'package:spreadit_crossplatform/features/generic_widgets/validations.dart';
import 'package:spreadit_crossplatform/features/homepage/data/get_feed_posts.dart';
import 'package:spreadit_crossplatform/features/homepage/data/post_class_model.dart';
import 'package:spreadit_crossplatform/features/homepage/presentation/widgets/post_widget.dart';
import 'package:spreadit_crossplatform/features/post_and_comments_card/data/comment_model_class.dart';
import 'package:spreadit_crossplatform/features/post_and_comments_card/data/get_post_comments.dart';
import 'package:spreadit_crossplatform/features/post_and_comments_card/presentation/comments.dart';
import 'package:spreadit_crossplatform/features/post_and_comments_card/data/update_comments_list.dart';
import 'package:spreadit_crossplatform/user_info.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;

/// Widget for adding a comment to a post.
class AddCommentWidget extends StatefulWidget {
  /// List of comments associated with the post.
  List<Comment> commentsList;

  /// ID of the post to which the comment is being added.
  String postId;

  /// Function to add a comment.
  final Function(Comment) addComment;

  /// Name of the community.
  final String communityName;
  final String type;
  final String labelText;
  final String buttonText;

  /// Constructs an [AddCommentWidget] with the specified [commentsList], [postId], and [addComment] function.
  AddCommentWidget(
      {required this.commentsList,
      required this.postId,
      required this.addComment,
      required this.communityName,
      required this.type,
      required this.labelText,
      required this.buttonText});

  @override
  State<AddCommentWidget> createState() {
    return _AddCommentWidgetState();
  }

  /// Retrieves the text of the comment.
  String getCommentText() {
    return _AddCommentWidgetState()._commentController.text;
  }
}

class _AddCommentWidgetState extends State<AddCommentWidget> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isNotApprovedForCommenting = false;
  File? uploadedImageFile;
  Uint8List? uploadedImageWeb;

  @override
  void initState() {
    super.initState();
    checkIfCanComment();
  }

  Future<void> pickImage() async {
    var image;
    if (!kIsWeb) {
      image = await pickImageFromFilePicker();
      setState(() {
        if (image != null) {
          uploadedImageFile = image;
        }
      });
    }
    if (kIsWeb) {
      image = await pickImageFromFilePickerWeb();
      setState(() {
        if (image != null) {
          uploadedImageWeb = image;
        }
      });
    }
  }

  /// [checkIfCanComment] : a function used to check if users aren't approved for commenting in the community

  void checkIfCanComment() async {
    if (widget.communityName == "") {
      return;
    }
    await checkIfNotApproved(
            widget.communityName, UserSingleton().user!.username)
        .then((value) {
      isNotApprovedForCommenting = value;
    });
    setState(() {
      if (!mounted) return;
      isNotApprovedForCommenting = isNotApprovedForCommenting;
    });
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _commentController,
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: 'Link name',
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _linkController,
                  decoration: InputDecoration(
                    labelText: 'https://',
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    String linkName = '[${_commentController.text}]';
                    String link = '(${_linkController.text})';
                    String finalLink = '$linkName $link';

                    _commentController.text = finalLink;

                    _linkController.clear();
                    Navigator.pop(context);
                  },
                  child: Text('Add link'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  if (uploadedImageFile != null || uploadedImageWeb != null)
                    Container(
                      height: 200, // Adjust the height as needed
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: selectImage(
                              uploadedImageFile, null, uploadedImageWeb),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  TextFormField(
                    controller: _commentController,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: widget.labelText,
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              _showBottomSheet(context);
                            },
                            icon: Icon(Icons.link),
                          ),
                          IconButton(
                            onPressed: () {
                              pickImage();
                            },
                            icon: Icon(Icons.image),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      trailing: OutlinedButton(
        onPressed: isNotApprovedForCommenting
            ? () {
                CustomSnackbar(
                  content:
                      "You are not approved for commenting in this community",
                ).show(context);
              }
            : () async {
                print("commenting: $isNotApprovedForCommenting");
                if (_commentController.text.isNotEmpty) {
                  print('add comment');
                  FocusScope.of(context).unfocus();
                  String newComment = _commentController.text;
                  _commentController.clear();
                  Comment? nComment = await updateComments(
                    id: widget.postId,
                    content: newComment,
                    type: widget.type,
                    imageFile: uploadedImageFile,
                    imageWeb: uploadedImageWeb,
                  );
                  setState(() {
                    if (!mounted) return;
                    widget.addComment(nComment!);
                    CustomSnackbar(
                            content:
                                "Your ${widget.type} has been posted successfully! ")
                        .show(context);
                    print('nComment${nComment.content}');
                    uploadedImageFile = null;
                    uploadedImageWeb = null;
                  });
                } else if (uploadedImageFile != null ||
                    uploadedImageWeb != null) {
                  setState(() {
                    if (!mounted) return;
                    uploadedImageFile = null;
                    uploadedImageWeb = null;
                    CustomSnackbar(
                            content: "Sorry you can't post an image only :(")
                        .show(context);
                  });
                } else {
                  CustomSnackbar(
                          content: "Sorry you can't post an empty comment :(")
                      .show(context);
                }
                if (widget.type == 'reply') {
                  Navigator.pop(context);
                }
              },
        child: Text(widget.buttonText),
      ),
    );
  }
}
