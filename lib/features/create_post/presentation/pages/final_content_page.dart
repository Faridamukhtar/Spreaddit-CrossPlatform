import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:spreadit_crossplatform/features/generic_widgets/validations.dart';
import '../widgets/create_post_header.dart';
import '../widgets/title.dart';
import '../widgets/content.dart';
import '../widgets/create_post_footer.dart';
import '../widgets/create_post_secondary_footer.dart';
import '../widgets/showDiscardBottomSheet.dart';
import '../pages/add_tags.dart';
import '../widgets/rendered_tag.dart';
import '../widgets/image_picker.dart';
import '../widgets/video_picker.dart';


class FinalCreatePost extends StatefulWidget {
  const FinalCreatePost({Key? key}) : super(key: key);

  @override
  State<FinalCreatePost> createState() => _FinalCreatePostState();
}

class _FinalCreatePostState extends State<FinalCreatePost> {

  final GlobalKey<FormState> _finalTitleForm = GlobalKey<FormState>();
  final GlobalKey<FormState> _finalContentForm = GlobalKey<FormState>();

  String title = '';
  String content ='';

  bool isPrimaryFooterVisible = true;
  bool isButtonEnabled = false;

  File? image;
  File? video;
  
   void updateTitle(String value) {
    title = value;
    _finalTitleForm.currentState!.save();
    updateButtonState();
  }

  void updateContent(String value) {
    content = value;
    _finalContentForm.currentState!.save();
      
  }

  void updateButtonState() {
    setState(() {
      isButtonEnabled = title.isNotEmpty && !RegExp(r'^[\W_]+$').hasMatch(title);
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

  void navigateToPostToCommunity() {
    Navigator.of(context).pushNamed('/post-to-community');
  }

  void navigateToAddTags(){
    Navigator.of(context).pushNamed('/add-tags');
  }

  void navigateToRules() {
    Navigator.of(context).pushNamed('/rules');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            child: CreatePostHeader(
              buttonText: "Post",
              onPressed: navigateToPostToCommunity,
              isEnabled: isButtonEnabled,
              onIconPress : () { showDiscardButtomSheet(context);},
            ),
          ),
          Container(
           margin: EdgeInsets.all(10),
           child:Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: CircleAvatar(
                  radius: 10,
                ),
              ),
              Text(
                'r/AskReddit',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              InkWell(
                onTap: navigateToRules, 
                child: Container(
                padding: EdgeInsets.all(5), 
                child: Icon(Icons.keyboard_arrow_down),
                ),
              ),
              Spacer(),
              Container(
                margin: EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: navigateToRules,
                  child: Text(
                    'Rules',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                  ),
                ),
               ),
              ),
            ],
            ), 
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              height: 20,
              width:150,
              margin: EdgeInsets.fromLTRB(15, 0, 10, 5),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 219, 219, 219),
                  foregroundColor: Colors.grey,
                ),
                onPressed: navigateToAddTags,
                child: Text('Add tags'),
              ),
             ),
          ),          
          PostTitle(
            formKey: _finalTitleForm,
            onChanged: updateTitle,
          ),
          PostContent(
            formKey: _finalContentForm,
            onChanged:  updateContent,
            hintText: 'body text (optional)',
            initialBody: ''
          ),
          Container(
            child: CreatePostHeader(
              buttonText: "Post",
              onPressed: navigateToPostToCommunity,
              isEnabled: isButtonEnabled,
              onIconPress : () { showDiscardButtomSheet(context);},
            ),
          ),
          isPrimaryFooterVisible? PostFooter(
            toggleFooter: toggleFooter,
            showAttachmentIcon: true,
            showPhotoIcon: true,
            showVideoIcon: true,
            showPollIcon: true,
            pickImage: pickImage,
            pickVideo: () {},
            ) : SecondaryPostFooter(
              onLinkPress: () {},
              onImagePress: pickImage,
              onVideoPress: pickVideo,
              onPollPress: () {},
            ),
        ],)
    );
  }
}

/* TODOs 
1) a3mel en law ekhtart tag , yeshil el zorar bta3 add tags da w y7ot el tag makano
3) asayyev kol haga f variable w akhod el haga ml pages elli ablaha 
---> a-make sure law ana aslan 3amla post men gowwa community mafish haga hakhodha men pages ablaha 
4) navigations
5) mock service 
6) unit testing 
 */