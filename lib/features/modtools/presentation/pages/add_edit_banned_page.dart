import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spreadit_crossplatform/features/generic_widgets/snackbar.dart';
import 'package:spreadit_crossplatform/features/modtools/data/api_banned_users.dart';
import 'package:spreadit_crossplatform/features/modtools/presentation/widgets/add_data_appbar.dart';
import 'package:spreadit_crossplatform/user_info.dart';

/// A page for adding or editing banned users in a community.
class AddOrEditBannedPage extends StatefulWidget {
  /// Constructs a new instance of AddOrEditBannedPage.
  ///
  /// [key] is an optional key to identify this widget.
  /// [communityName] is the name of the community.
  /// [isAdding] is true if adding a new banned user, false if editing an existing one.
  /// [onRequestCompleted] is a callback function to be called when the request is completed.
  /// [username] is the username of the banned user.
  /// [violation] is the reason for the ban.
  /// [banReason] is a note for moderators regarding the ban.
  /// [days] is the duration of the ban.
  /// [messageToUser] is a note to be included in the ban message sent to the user.
  const AddOrEditBannedPage({
    Key? key,
    required this.communityName,
    required this.isAdding,
    required this.onRequestCompleted,
    this.username = '',
    this.violation = '',
    this.banReason = '',
    this.days = -1,
    this.messageToUser = '',
  }) : super(key: key);

  /// The name of the community.
  final String communityName;

  /// True if adding a new banned user, false if editing an existing one.
  final bool isAdding;

  /// Callback function to be called when the request is completed.
  final Function onRequestCompleted;

  /// The username of the banned user.
  final String username;

  /// The reason for the ban.
  final String violation;

  /// A note for moderators regarding the ban.
  final String banReason;

  /// The duration of the ban.
  final int days;

  /// A note to be included in the ban message sent to the user.
  final String messageToUser;

  @override
  State<AddOrEditBannedPage> createState() => _AddOrEditBannedPageState();
}

class _AddOrEditBannedPageState extends State<AddOrEditBannedPage> {
  bool isInitialized = false;
  bool isAdding = false;
  int? days = -1;
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _violationController = TextEditingController();
  TextEditingController _banReasonController = TextEditingController();
  TextEditingController _daysController = TextEditingController();
  TextEditingController _messageToUserController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isAdding = widget.isAdding;
    if (!isAdding) {
      _usernameController.text = widget.username;
      _violationController.text = widget.violation;
      _banReasonController.text = widget.banReason;
      _daysController.text = (widget.days != -1) ? widget.days.toString() : '';
      _messageToUserController.text = widget.messageToUser;
      days = widget.days;
      return;
    }
    days = -1;
  }

  void addBannedUser() async {
    if (_usernameController.text == UserSingleton().user!.username) {
      CustomSnackbar(content: "You can't ban yourself 😐").show(context);
      return;
    }
    if(_messageToUserController.text.isEmpty){
      CustomSnackbar(content: "Please add a message to the user").show(context);
      return;
    }
    if (days != null && days == 0) {
      CustomSnackbar(content: "Please give a valid ban length").show(context);
      return;
    }
    int response = await banUserRequest(
        communityName: widget.communityName,
        username: _usernameController.text,
        violation: _violationController.text,
        days: days ?? 1,
        modNote: _banReasonController.text,
        messageToUser: _messageToUserController.text,);
    if (response == 200) {
      CustomSnackbar(content: "u/${_usernameController.text} was banned!").show(context);
      Navigator.pop(context);
      widget.onRequestCompleted();
      
    } else {
      CustomSnackbar(content: "Error banning user").show(context);
    }
  }

  void editBannedUser() async {
    if(_messageToUserController.text.isEmpty){
      CustomSnackbar(content: "Please add a message to the user").show(context);
      return;
    }
    if (days != null && days == 0) {
      CustomSnackbar(content: "Please give a valid ban length").show(context);
      return;
    }
    int response = await editBannedUserRequest(
        communityName: widget.communityName,
        username: _usernameController.text,
        violation: _violationController.text,
        days: days ?? 1,
        messageToUser: _messageToUserController.text);
    if (response == 200) {
      Navigator.pop(context);
      widget.onRequestCompleted();
      CustomSnackbar(content: "u/${widget.username} ban edited!").show(context);
    } else {
      CustomSnackbar(content: "Error editing ban").show(context);
    }
  }

  InputDecoration getReasonForBanDecoration() {
    if (_violationController.text.isEmpty) {
      return getTextFieldDecoration("Pick a reason", isBanReason: true);
    }
    return getTextFieldDecoration(_violationController.text, isBanReason: true);
  }

  InputDecoration getTextFieldDecoration(String? hintText,
      {bool isUsername = false, bool isBanReason = false}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(),
      hintText: hintText,
      prefixStyle: TextStyle(
        fontWeight: FontWeight.w800,
        color: Colors.black,
      ),
      prefixText: isUsername ? "u/" : null,
      suffixIcon: isBanReason ? Icon(Icons.expand_more_outlined) : null,
    );
  }

  showViolationsModal(context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Reason for ban',
                style: TextStyle(
                    fontWeight: FontWeight.w800, color: Colors.grey[600]),
              ),
            ),
            Divider(),
            ListTile(
              title: Text('Spam'),
              onTap: () {
                setState(() {
                  _violationController.text = 'Spam';
                });
                Navigator.pop(context);
              },
            ),
            Divider(),
            ListTile(
              title: Text('Personal and confidential information'),
              onTap: () {
                setState(() {
                  _violationController.text =
                      'Personal and confidential information';
                });
                Navigator.pop(context);
              },
            ),
            Divider(),
            ListTile(
              title: Text('Threatening, harassing, or inciting violence'),
              onTap: () {
                setState(() {
                  _violationController.text =
                      'Threatening, harassing, or inciting violence';
                });
                Navigator.pop(context);
              },
            ),
            Divider(),
            ListTile(
              title: Text('Other'),
              onTap: () {
                setState(() {
                  _violationController.text = 'Other';
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AddOrSaveDataAppBar(
        title: isAdding ? 'Add a banned user' : 'Edit banned user',
        actionText: isAdding ? 'Add' : 'Save',
        onButtonPressed: _usernameController.text.isNotEmpty &&
                _violationController.text.isNotEmpty &&
                days != null
            ? () {
                if (isAdding) {
                  addBannedUser();
                } else {
                  editBannedUser();
                }
              }
            : null,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Username'),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: _usernameController,
                    decoration:
                        getTextFieldDecoration("Username", isUsername: true),
                    readOnly: !isAdding,
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
              ),
              Text('Reason for ban'),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      showViolationsModal(context);
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        controller: _violationController,
                        readOnly: true,
                        decoration: getReasonForBanDecoration(),
                      ),
                    ),
                  ),
                ),
              ),
              Text('Mod note'),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: _banReasonController,
                    maxLength: 300,
                    readOnly: !isAdding,
                    decoration:
                        getTextFieldDecoration("Will be seen by mods only"),
                  ),
                ),
              ),
              Text('How Long?'),
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 100,
                    child: Padding(
                      padding:
                          EdgeInsets.only(top: 8.0, right: 8.0, bottom: 8.0),
                      child: TextField(
                        controller: _daysController,
                        decoration: getTextFieldDecoration(null),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          setState(() {
                            if (value == '') {
                              days = null;
                              return;
                            }
                            days = int.parse(_daysController.text);
                          });
                        },
                      ),
                    ),
                  ),
                  Text('Days'),
                  SizedBox(
                    width: 16,
                  ),
                  Checkbox(
                    value: days == -1,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          days = -1;
                          _daysController.text = '';
                        }
                      });
                    },
                  ),
                  Text('Permanent',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
              Text('Note to be included in ban message'),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: _messageToUserController,
                    maxLines: null,
                    minLines: 4,
                    maxLength: 5000,
                    decoration: getTextFieldDecoration(
                        "The user will receive this note in a message"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
