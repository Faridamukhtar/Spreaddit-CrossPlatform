import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:spreadit_crossplatform/features/user_profile/images/image_picker.dart';
import '../../../Account_Settings/presentation/widgets/switch_type_1.dart';
import '../../../generic_widgets/custom_input.dart';
import '../../data/update_user_info.dart';
import '../widgets/social_link_bottom_sheet_model.dart';
import '../widgets/social_media_selection_bottom_sheet.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final GlobalKey<FormState> _usernameForm = GlobalKey<FormState>();
  final GlobalKey<FormState> _aboutForm = GlobalKey<FormState>();
  var _about = '';
  var _username = '';
  var _change = false;
  bool _switchValue1 = false;
  bool _switchValue2 = false;
  String? backgroundImageURl =
      'https://www.shutterstock.com/blog/wp-content/uploads/sites/5/2020/02/Usign-Gradients-Featured-Image.jpg';
  String? profileImageURl =
      'https://www.shutterstock.com/blog/wp-content/uploads/sites/5/2020/02/Usign-Gradients-Featured-Image.jpg';
  File? backgroundImageFile;
  File? profileImageFile;

  void updateUsername(String username, bool validation) {
    _username = username;
    _usernameForm.currentState?.save();
    setState(() {
      _change = true;
    });
  }

  void updateAbout(String about, bool validation) {
    _about = about;
    _aboutForm.currentState?.save();
    setState(() {
      _change = true;
    });
  }

  void _showSocialMediaSelectionBottomSheet(BuildContext context) async {
    final selectedPlatform = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      builder: (context) => SocialMediaSelectionBottomSheet(),
    );

    if (selectedPlatform != null) {
      showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        builder: ((context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SocialMediaBottomSheet(
              platformName: selectedPlatform['platformName'],
              icon: selectedPlatform['icon'],
              color: selectedPlatform['color'],
            ),
          );
        }),
      );
    }
  }

  Future<void> pickBackGroundImage() async {
    final image = await pickImageFromFilePicker();
    setState(() {
      if (image != null) {
        backgroundImageURl = null;
        backgroundImageFile = image;
        print(backgroundImageFile);
      }
    });
  }

  Future<void> pickProfileImage() async {
    final image = await pickImageFromFilePicker();
    setState(() {
      if (image != null) {
        profileImageURl = null;
        profileImageFile = image;
      }
    });
  }

  ImageProvider SelectImage() {
    if (profileImageFile != null) {
      return FileImage(profileImageFile!);
    } else if (profileImageURl != null && profileImageURl!.isNotEmpty) {
      return NetworkImage(profileImageURl!); // Use profileImageURl
    } else {
      return NetworkImage('https://addlogo.imageonline.co/image.jpg');
    }
  }

  Future<void> saveProfile() async {
    try {
      // Call updateUserApi function to update user information
      int statusCode = await updateUserApi(
        accessToken: "your_access_token_here",
        username: _username,
        aboutUs: _about,
        backgroundImage: backgroundImageFile != null ? backgroundImageFile! : backgroundImageURl!,
        profilePicImage: profileImageFile != null ? profileImageFile! : profileImageURl!,
        socialMedia: [],
        contentVisibility: _switchValue1,
        showActiveComments: _switchValue2,
      );

      if (statusCode == 200) {
        print("User information updated successfully.");
      } else if (statusCode == 500) {
        print("Server error occurred while updating user information.");
      } else {
        print("Unexpected error occurred.");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Edit Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          ElevatedButton(
            onPressed: saveProfile, // Call saveProfile function here
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              height: MediaQuery.of(context).size.height,
              child: FractionallySizedBox(
                alignment: Alignment.topCenter,
                heightFactor: kIsWeb ? 0.35 : 0.25,
                child: Container(
                  decoration: BoxDecoration(
                    image: backgroundImageFile != null
                        ? DecorationImage(
                            image: FileImage(backgroundImageFile!),
                            fit: BoxFit.cover,
                          )
                        : (backgroundImageURl != null &&
                                backgroundImageURl!.isNotEmpty)
                            ? DecorationImage(
                                image: NetworkImage(backgroundImageURl!),
                                fit: BoxFit.cover,
                              )
                            : DecorationImage(
                                image: NetworkImage(
                                    'https://addlogo.imageonline.co/image.jpg'),
                                fit: BoxFit.cover,
                              ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: kIsWeb ? screenHeight * 0.15 : screenHeight * 0.1,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: pickBackGroundImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: Text(
                      'Change Background',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: kIsWeb
                      ? screenHeight * 0.35 - 40
                      : screenHeight * 0.25 - 40),
              child: Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: SelectImage(),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 40,
                            height:
                                40, // Adjust the height to match the width for a circular shape
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            alignment:
                                Alignment.center, // Adjust the alignment here
                            child: IconButton(
                              icon: Icon(Icons.add),
                              color: Colors.white,
                              onPressed: () {
                                pickProfileImage();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        CustomInput(
                          formKey: _usernameForm,
                          onChanged: updateUsername,
                          label: 'Display name - optional',
                          placeholder: 'Display name - optional',
                          wordLimit: 30,
                          tertiaryText:
                              "This will be displayed to viewers of your profile page and does not change your username",
                        ),
                        SizedBox(height: 20),
                        CustomInput(
                          formKey: _aboutForm,
                          onChanged: updateAbout,
                          label: 'About you - optional',
                          placeholder: 'About you - optional',
                          height: screenHeight * 0.25,
                          wordLimit: 200,
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _showSocialMediaSelectionBottomSheet(context);
                            },
                            icon: Icon(Icons.add),
                            label: Text('Add Social Media'),
                          ),
                        ),
                        SizedBox(height: 20),
                        SwitchBtn1(
                          currentLightVal: _switchValue1,
                          mainText: "Content Visibility",
                          onPressed: () {
                            setState(() {
                              _switchValue1 = !_switchValue1;
                            });
                          },
                          tertiaryText:
                              "All posts to this profile will appear in r/all and your profile can be discovered in /users",
                        ),
                        SwitchBtn1(
                          currentLightVal: _switchValue2,
                          mainText: "Show active communities",
                          onPressed: () {
                            setState(() {
                              _switchValue2 = !_switchValue2;
                            });
                          },
                          tertiaryText:
                              "Decide whether to show the communities you are active in on your profile",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
