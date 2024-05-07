import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../widgets/header_and_footer_widgets/create_post_header.dart';
import '../widgets/title.dart';
import '../widgets/header_and_footer_widgets/create_post_footer.dart';
import '../widgets/header_and_footer_widgets/create_post_secondary_footer.dart';
import '../../../generic_widgets/validations.dart';
import '../widgets/show_discard_bottomsheet.dart';
import '../../../generic_widgets/photo_and_video_pickers/image_picker.dart';
import '../../../generic_widgets/photo_and_video_pickers/video_picker.dart';
import '../widgets/image_and_video_widgets.dart';

/// [CreatePost] class renders the create post page , which allows the user to create a post by adding a [title], [content], [link]
/// [image], [video] or [poll].
/// it serves as the first draft for the user to write his post

class CreatePost extends StatefulWidget {
  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final GlobalKey<FormState> _primaryTitleForm = GlobalKey<FormState>();
  final GlobalKey<FormState> _primaryContentForm = GlobalKey<FormState>();
  final GlobalKey<FormState> _primaryLinkForm = GlobalKey<FormState>();
  List<GlobalKey<FormState>> formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  String title = '';
  String content = '';
  List<String> pollOptions = ['', ''];
  List<String> initialBody = ['', ''];
  int selectedDay = 1;

  bool isPrimaryFooterVisible = true;
  bool isButtonEnabled = false;
  bool isPollOptionValid = false;
  bool createPoll = false;
  bool isLinkAdded = false;

  File? image;
  Uint8List? imageWeb;
  File? video;
  Uint8List? videoWeb;
  String? link;
  IconData? lastPressedIcon;

  /// [updateTitle] : a function which updates the title whenever the user writes in the title text field
  void updateTitle(String value) {
    title = value;
    _primaryTitleForm.currentState!.save();
    updateButtonState();
  }

  /// [updateContent] : a function which updates the content whenever the user writes in the content text field
  void updateContent(String value) {
    content = value;
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (_primaryContentForm.currentState != null) {
        _primaryContentForm.currentState!.save();
      }
    });
  }

  /// [updateLink] : a function which updates the link whenever the user writes in the link text field
  void updateLink(String value) {
    link = value;
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (_primaryLinkForm.currentState != null) {
        _primaryLinkForm.currentState!.save();
        updateButtonState();
      }
    });
  }

  /// [updateButtonState] : a function which controls the enablement of the 'Next' button
  void updateButtonState() {
    if (link == null) {
      setState(() {
        isButtonEnabled = validatePostTitle(title);
      });
    } else {
      isButtonEnabled = validatePostTitle(title) && validatePostTitle(link!);
    }
  }

  /// [setLastPreddedIcon] : a function which sets the last pressed icon variable to the last pressed icon by the user to disable the rest
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

  /// [addLink] : a function which renders the link text field
  void addLink() {
    setState(() {
      isLinkAdded = !isLinkAdded;
    });
    if (isLinkAdded) {
      setLastPressedIcon(Icons.link);
    } else {
      setLastPressedIcon(null);
    }
  }

  /// [cancelImageOrVideo] : removes the uploaded image or video
  void cancelImageOrVideo() {
    setState(() {
      imageWeb = null;
      videoWeb = null;
      image = null;
      video = null;
    });
    setLastPressedIcon(null);
  }

  Future<void> pickImage() async {
    if (kIsWeb) {
      final image = await pickImageFromFilePickerWeb();
      setState(() {
        imageWeb = image;
      });
    } else {
      final image = await pickImageFromFilePicker();
      setState(() {
        this.image = image;
      });
    }
  }

  Future<void> pickVideo() async {
    if(kIsWeb) {
      final video = await pickVideoFromFilePickerWeb();
      setState(() {
        videoWeb = video;
      });
    }
    else {
      final video = await pickVideoFromFilePicker();
      setState(() {
        this.video = video;
      });
    }
  }

  /// [openPollWindow] : renders the poll
  void openPollWidow() {
    setState(() {
      createPoll = !createPoll;
    });
    print('create poll from primary: $createPoll');
  }

  void updatePollOption(int optionNumber, String value) {
    setState(() {
      pollOptions[optionNumber - 1] = value;
    });
    formKeys[optionNumber - 1].currentState!.save();
  }

  void updateSelectedDay(int selectedDay) {
    setState(() {
      this.selectedDay = selectedDay;
    });
  }

  void removePollOption(int index) {
    setState(() {
      pollOptions.removeAt(index);
      formKeys.removeAt(index);
    });
  }

  void navigateToPostToCommunity() {
    Navigator.of(context).pushNamed('/post-to-community', arguments: {
      'title': title,
      'content': content,
      'link': link,
      'image': image,
      'imageWeb': imageWeb,
      'video': video,
      'videoWeb': videoWeb,
      'pollOptions': pollOptions,
      'selectedDay': selectedDay,
      'createPoll': createPoll,
      'isLinkAdded': isLinkAdded,
    });
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
                  allowScheduling: false,
                  onPressed: navigateToPostToCommunity,
                  isEnabled: isButtonEnabled,
                  onIconPress: validatePostTitle(title)
                      ? () {}
                      : () {
                          showDiscardButtomSheet(context);
                        }, // if invalid , pop to home page
                ),
                PostTitle(
                  formKey: _primaryTitleForm,
                  onChanged: updateTitle,
                  initialBody: '',
                ),
                if (image != null || imageWeb != null)
                  ImageOrVideoWidget(
                    imageOrVideo: image,
                    imageOrVideoWeb: imageWeb,
                    onIconPress: cancelImageOrVideo,
                  ),
                if (video != null || videoWeb != null)
                   VideoWidget(
                    video: video,
                    videoWeb: videoWeb,
                    onIconPress: cancelImageOrVideo,
                  ),
                if (isLinkAdded)
                  LinkTextField(
                    formKey: _primaryLinkForm,
                    onChanged: updateLink,
                    hintText: 'URL',
                    initialBody: '',
                    onIconPress: addLink,
                  ),
                if (isLinkAdded && link != null && !validateLink(link!))
                  Container(
                    margin: EdgeInsets.fromLTRB(15, 5, 15, 5),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                    ),
                    child: Text(
                        'Oops, this link isn\'t valid. Double-check, and try again.'),
                  ),
                PostContent(
                  formKey: _primaryContentForm,
                  onChanged: updateContent,
                  hintText: 'body text (optional)',
                  initialBody: '',
                ),
                if (createPoll)
                  Poll(
                    onPollCancel: openPollWidow,
                    setLastPressedIcon: setLastPressedIcon,
                    formkeys: formKeys,
                    pollOptions: pollOptions,
                    selectedDay: selectedDay,
                    updatePollOption: updatePollOption,
                    removePollOption: removePollOption,
                    updateSelectedDay: updateSelectedDay,
                    initialBody: initialBody,
                  ),
              ],
            ),
          ),
          isPrimaryFooterVisible
              ? PostFooter(
                  toggleFooter: toggleFooter,
                  showAttachmentIcon: true,
                  showPhotoIcon: true,
                  showVideoIcon: true,
                  showPollIcon: true,
                  onLinkPress: addLink,
                  onImagePress: pickImage,
                  onVideoPress: pickVideo,
                  onPollPress: openPollWidow,
                  lastPressedIcon: lastPressedIcon,
                  setLastPressedIcon: setLastPressedIcon,
                )
              : SecondaryPostFooter(
                  onLinkPress: addLink,
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
 unit testing 
 */
