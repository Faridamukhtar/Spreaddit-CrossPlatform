import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../widgets/header_and_footer_widgets/create_post_header.dart';
import '../widgets/title.dart';
import '../widgets/content.dart';
import '../widgets/header_and_footer_widgets/create_post_footer.dart';
import '../widgets/header_and_footer_widgets/create_post_secondary_footer.dart';
import '../../../generic_widgets/validations.dart';
import '../widgets/show_discard_bottomsheet.dart';
import '../widgets/photo_and_video_pickers/image_picker.dart';
import '../widgets/photo_and_video_pickers/video_picker.dart';
import '../widgets/poll_widgets/poll.dart';

class CreatePost extends StatefulWidget {  
  const CreatePost({Key? key}) : super(key: key);

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {

  final GlobalKey<FormState> _primaryTitleForm = GlobalKey<FormState>();
  final GlobalKey<FormState> _primaryContentForm = GlobalKey<FormState>();

  String title = '';
  String content = '';

  bool isPrimaryFooterVisible = true;
  bool isButtonEnabled = false;
  bool isPollOptionValid = false;
  bool createPoll = false;

  File? image;
  File? video;
  IconData? lastPressedIcon;

  void updateTitle(String value) {
    title = value;
    _primaryTitleForm.currentState!.save();
    updateButtonState();
  }

  void updateContent(String value) {
    content = value;
    WidgetsBinding.instance!.addPostFrameCallback((_) {
    if (_primaryContentForm.currentState != null) {
      _primaryContentForm.currentState!.save();
    }
    });
  }

  void updateButtonState() {
    setState(() {
      isButtonEnabled = validatePostTitle(title);
    });
  }

  void setLastPressedIcon(IconData? passedIcon) {
    setState(() {
      lastPressedIcon = passedIcon;
    });
  }

  void toggleFooter() {
    setState(() {
      isPrimaryFooterVisible = !isPrimaryFooterVisible;
    });
  }

  Future<void> pickImage() async {
    final image = await pickImageFromFilePicker();
    setState(() {
      this.image = image;
    });
  }

  Future<void> pickVideo() async {
    final video = await pickVideoFromFilePicker();
    setState(() {
      this.video = video;
    });
  }

  void openPollWidow() {
    setState(() {
      createPoll = !createPoll;
    });
  }

  void navigateToPostToCommunity() {
      Navigator.of(context).pushNamed('/post-to-community');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                CreatePostHeader(
                  buttonText: "Next",
                  onPressed: navigateToPostToCommunity,
                  isEnabled: isButtonEnabled,
                  onIconPress: validatePostTitle(title) ? () {}: () {showDiscardButtomSheet(context);},
                ),
                PostTitle(
                  formKey: _primaryTitleForm,
                  onChanged:updateTitle,
                ),
                if (image != null)
                   Container(
                    alignment: Alignment.center,
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(image!),
                          fit:BoxFit.cover,
                        ),
                    ),
                  ),
                if (video != null)
                   Container(
                    alignment: Alignment.center,
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(video!),
                          fit:BoxFit.cover,
                        ),
                    ),
                  ),    
                PostContent(
                  formKey: _primaryContentForm,
                  onChanged:updateContent,
                  hintText: 'body text (optional)',
                  initialBody: '',
                ),
                if (createPoll)
                  Poll(
                    onPollCancel: openPollWidow,
                    setLastPressedIcon: setLastPressedIcon,
                  ),
              ],
            ),     
          ), 
          isPrimaryFooterVisible? PostFooter(
            toggleFooter: toggleFooter,
            showAttachmentIcon: true,
            showPhotoIcon: true,
            showVideoIcon: true,
            showPollIcon: true,
            onImagePress: pickImage,
            onVideoPress: pickVideo,
            onPollPress: openPollWidow,
            lastPressedIcon: lastPressedIcon, 
            setLastPressedIcon: setLastPressedIcon,
            ) : SecondaryPostFooter(
              onLinkPress: () {},
              onImagePress: pickImage,
              onVideoPress: pickVideo,
              onPollPress: openPollWidow,
              lastPressedIcon: lastPressedIcon, 
              setLastPressedIcon: setLastPressedIcon,
            ),
        ],
      ),
    );
  }
}

/* TODOs 
1) a7ot soura 3al vm to test
3) ab3at el haga di kollaha lel final content page 
4) navigations (almost done)
5) unit testing 
 */