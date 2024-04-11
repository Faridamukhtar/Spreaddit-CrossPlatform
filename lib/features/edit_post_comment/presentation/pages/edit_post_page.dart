import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:spreadit_crossplatform/features/edit_post_comment/data/update_edited_post.dart';
import 'package:spreadit_crossplatform/features/edit_post_comment/presentation/widgets/generic_footer.dart';
import 'package:spreadit_crossplatform/features/edit_post_comment/presentation/widgets/generic_header.dart';
import 'package:spreadit_crossplatform/features/edit_post_comment/presentation/widgets/generic_body.dart';
import 'package:spreadit_crossplatform/features/generic_widgets/validations.dart';
import 'package:spreadit_crossplatform/features/homepage/data/post_class_model.dart';

class EditPost extends StatefulWidget {
  Post? post;
  EditPost({this.post});

  @override
  State<EditPost> createState() {
    return _EditPostState();
  }
}

class _EditPostState extends State<EditPost> {
  final GlobalKey<FormState> _finalTitleForm = GlobalKey<FormState>();
  final GlobalKey<FormState> _finalContentForm = GlobalKey<FormState>();

  String? content;
  bool isEnabled = true;
  void setContent(String? C) {
    content = widget.post!.description;
  }

  @override
  void initState() {
    setContent(content);
    super.initState();
  }

  bool validateContent(String value) {
    if (value.isNotEmpty && !RegExp(r'^[\W_]+$').hasMatch(value)) {
      return true;
    } else {
      return false;
    }
  }

  void updateContent(String value) {
    setState(() {
      content = value; // Update content when text changes
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        if (_finalContentForm.currentState != null) {
          _finalContentForm.currentState!.save();
        }
      });
      isEnabled = validateContent(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: GenericHeader(
            buttonText: "Save",
            onPressed: () async {
              print("pressed");
              widget.post!.description = content!;
              await updateEditedPost(
                  postId: "${widget.post!.postId}", content: content);
              print("this is the content${widget.post!.description}");
              print("content before fetching$content");
              //navigate to post card page with edited post
            },
            isEnabled: isEnabled,
            onIconPress: () {}, //navigate to pst card page
            showHeaderTitle: true,
          ),
        ),
        body: Column(
          children: [
            GenericContent(
                initialBody: widget.post!.description,
                bodyHint: "Add a post",
                formKey: _finalContentForm,
                onChanged: updateContent),
            GenericFooter(
              toggleFooter: null,
              showAttachmentIon: true,
              showPhotoIcon: false,
              showVideoIcon: false,
              showPollIcon: false,
            )
          ],
        ));
  }
}
