import 'package:flutter/material.dart';
import 'package:spreadit_crossplatform/features/generic_widgets/snackbar.dart';
import 'package:spreadit_crossplatform/features/report_feature/data/api_report.dart';
import 'package:spreadit_crossplatform/features/report_feature/data/violation_and_sub_violations.dart';
import 'package:spreadit_crossplatform/features/report_feature/presentation/widgets/block_reported_user.dart';
import 'package:spreadit_crossplatform/features/report_feature/presentation/widgets/main_report_option.dart';
import 'package:spreadit_crossplatform/features/report_feature/presentation/widgets/main_report_section.dart';
import 'package:spreadit_crossplatform/features/report_feature/presentation/widgets/modal_bottom_bar.dart';
import 'package:spreadit_crossplatform/features/report_feature/presentation/widgets/sub_report_section.dart';
import 'package:spreadit_crossplatform/features/user_interactions/data/user_interactions/user_to_user/interact.dart';

class ReportModal {
  /// A modal for reporting posts, comments, or users.
  ///
  /// The [ReportModal] class provides a bottom sheet interface for reporting posts, comments, or users on Reddit. It allows users to specify various reasons for reporting, including standard violations and additional context.
  ///
  /// ## Parameters
  ///
  /// - [buildContext] : The build context where the modal will be displayed.
  /// - [communityName] : The name of the community where the report is being made.
  /// - [postId] : The ID of the post being reported.
  /// - [commentId] : The ID of the comment being reported.
  /// - [isReportingPost] : A boolean indicating whether the report is for a post or comment.
  /// - [isReportingUser] : A boolean indicating whether the report is for a user or posts and comments.
  /// - [reportedUserName] : The username of the user being reported (if applicable).
  ReportModal(
      this.buildContext,
      this.communityName,
      this.postId,
      this.commentId,
      this.isReportingPost,
      this.isReportingUser,
      this.reportedUserName) {
    /// List of main violations for reporting.
    mainViolations.addAll([
      "Breaks r/$communityName rules",
      "Harassment",
      "Threatening Violence",
      "Hate",
      "Minor abuse or sexualization",
      "Sharing personal information",
      "Non-consensual intimate media",
      "Prohibited transaction",
      "Impersonation",
      "Copyright Violation",
      "Trademark Violation",
      "Self-harm or suicide",
      "Spam"
    ]);

    /// List of extra text providing additional context for reporting.
    extraText.addAll([
      'Posts, comments, or behavior that breaks r/$communityName rules',
      'Harassing, bullying, intimidationg, or abusing an individual or group of people with the result of discouraging them from participating.',
      'Encouraging, glorifying or inciting violence or physical harm againts individuals or groups of people, places, or animals.',
      'Promoting hate or inciting violence based on identity or vulnerability.',
      'Sharing or soliciting content involving abuse, neglect, or sexualization of minors or any predatory or inappropriate behavior towards minors.',
      'Sharing or threatening to share private, personal, or confidential information about someone.',
      'Sharing, threatening to share, or soliciting intimate or sexually-explicit content of someone without their consent (including fake or "lookalike" pornography).',
      'Soliciting or facilitating transactions or gifts of illegal or prohibited goods and services.',
      'Impersonating an individual or entity in a misleading or deceptive way. This includes deepfakes, manipulated content, or false attributions.',
      'Content posted to Reddit that infringes a copyright you own or control. (Note: Only the copyright owner or an authorized representative can submit a report.)',
      'Content posted to Reddit that infringes a trademark you own or control. (Note: Only the trademark owner or an authorized representative can submit a report.)',
      'Behavior or comments that make you think someone may be considering suicide or seriously hurting themselves.',
      'Repeated, unwanted, or unsolicited manual or automated actions that negatively affect redditors, communities, and the Reddit platform.',
    ]);

    /// List indicating whether sub-reasons are enabled for each main violation.
    hasSubReasons = List.generate(
      mainViolations.length,
      (int index) => (index == 3 || index == 7 || index == 11) ? false : true,
      growable: false,
    );

    if (isReportingUser) {
      showReportUserPage(buildContext);
    } else {
      showMainPage(buildContext);
    }
  }

  /// The build context where the modal will be displayed.
  BuildContext buildContext;

  /// The name of the community where the report is being made.
  String communityName;

  /// The username of the reported user (if applicable).
  final String reportedUserName;

  /// The ID of the post being reported.
  String postId;

  /// The ID of the comment being reported.
  String commentId;

  /// A boolean indicating whether the report is for a post.
  bool isReportingPost;

  /// A boolean indicating whether the report is for a user.
  bool isReportingUser;

  /// The index of the selected report reason for the user.
  var selectedUserReportIndex = -1;

  /// The index of the selected main report reason.
  var selectedMainIndex = -1;

  /// The index of the selected sub report reason.
  var selectedSubIndex = -1;

  /// A boolean indicating whether the 'block' option is checked.
  var blockIsChecked = false;

  /// List of violations reported on the user's profile.
  List<String> userProfileViolations = [];

  /// List of main violations for reporting.
  final List<String> mainViolations = [];

  /// List of extra text providing additional context for reporting.
  final List<String> extraText = [];

  /// List of main report options generated based on main violations.
  List<MainReportOption> mainReportOptions = [];

  /// List indicating whether sub-reasons are enabled for each main violation.
  List<bool> hasSubReasons = [];

  /// Generates main report options for the report modal.
  /// Creates a list of main report options based on the predefined main violations. Each option is represented by a [MainReportOption] object, containing information such as the community name, option text, index, and whether it has an associated image.
  /// - [setModalState] : A function to state setter of the bottom sheet.
  /// The function does not return a value but updates the [mainReportOptions] list.
  void generateMainReports(StateSetter setModalState) {
    mainReportOptions = List.generate(
      mainViolations.length,
      (int index) => MainReportOption(
        communityName: communityName,
        optionText: mainViolations[index],
        index: index,
        onSelect: () {
          setModalState(() {
            selectedMainIndex = index;
          });
        },
        selectedContainerIndex: selectedMainIndex,
        optionHasImage: (index == 0) ? true : false,
      ),
      growable: false,
    );
  }

  /// Displays the report user page.
  void showReportUserPage(BuildContext context) {
    showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.white,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(10),
          ),
        ),
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
            return FractionallySizedBox(
              heightFactor: 0.9,
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AppBar(
                      title: Text("Report profile"),
                    ),
                    SubReportSection(
                      isReportingUser: true,
                      communityName: communityName,
                      selectedIndex: 0,
                      onIndexChange: (int newSubVal) {
                        setModalState(() {
                          selectedUserReportIndex = newSubVal;
                        });
                      },
                    ),
                    ModalBottomBar(
                      buttonText: "Next",
                      onPressed: (selectedUserReportIndex == -1)
                          ? null
                          : () {
                              showMainPage(context);
                            },
                    )
                  ],
                ),
              ),
            );
          });
        });
  }

  /// Displays the main reporting page.
  void showMainPage(BuildContext context) {
    showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.white,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(10),
          ),
        ),
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
            generateMainReports(setModalState);
            return FractionallySizedBox(
              heightFactor: 0.9,
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AppBar(
                      title: Text("Submit a Report"),
                    ),
                    MainReportSection(mainReportOptions: mainReportOptions),
                    ModalBottomBar(
                      extraTextTitle: (selectedMainIndex != -1)
                          ? mainViolations[selectedMainIndex]
                          : '',
                      extraText: (selectedMainIndex != -1)
                          ? extraText[selectedMainIndex]
                          : '',
                      buttonText: (selectedMainIndex == -1 ||
                              hasSubReasons[selectedMainIndex])
                          ? 'Next'
                          : 'Submit Report',
                      onPressed: (selectedMainIndex == -1)
                          ? null
                          : () {
                              if (hasSubReasons[selectedMainIndex]) {
                                showSecondPage(context);
                              } else {
                                report(context);
                              }
                            },
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  /// Displays the second reporting page.
  void showSecondPage(BuildContext context) {
    selectedSubIndex = -1;
    showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.white,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(10),
          ),
        ),
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
            return FractionallySizedBox(
              heightFactor: 0.9,
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AppBar(
                      title: Text("Submit a Report"),
                    ),
                    SubReportSection(
                      communityName: communityName,
                      selectedIndex: selectedMainIndex,
                      onIndexChange: (int newSubVal) {
                        setModalState(() {
                          selectedSubIndex = newSubVal;
                        });
                      },
                    ),
                    ModalBottomBar(
                      buttonText: "Submit Report",
                      onPressed: () {
                        report(context);
                      },
                    )
                  ],
                ),
              ),
            );
          });
        });
  }

  /// Displays the 'done' page after submitting a report, with the option of blocking the reported user.
  void showDonePage(BuildContext context) {
    blockIsChecked = false;
    showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.white,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(10),
          ),
        ),
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
            return FractionallySizedBox(
              heightFactor: 0.9,
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.blueAccent,
                        size: 45,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Thanks for your report",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 25,
                        ),
                        softWrap: true,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Thanks again for your report and for looking out for yourself and your fellow redditors.\nYour reporting helps make Reddit a better, safer and more welcoming place for everyone; and it means a lot to us.",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                        softWrap: true,
                      ),
                    ),
                    Spacer(),
                    BlockReportedUser(
                        reportedUserName: reportedUserName,
                        onValChanged: (bool newVal) {
                          setModalState(() {
                            blockIsChecked = newVal;
                          });
                        },
                        blockIsChecked: blockIsChecked),
                    ModalBottomBar(
                      buttonText: "Done",
                      onPressed: () {
                        blockReportedUser(context);
                      },
                    )
                  ],
                ),
              ),
            );
          });
        });
  }

  /// Reports a post or comment.
  void reportPostOrComment(BuildContext context) async {
    int response;
    var postRequestInfo = {
      "reason": mainViolations[selectedMainIndex],
      "sureason": (hasSubReasons[selectedMainIndex] && selectedSubIndex != -1)
          ? subViolationsList[selectedMainIndex]["subViolations"]
              [selectedSubIndex]
          : ""
    };
    if (isReportingPost) {
      response =
          await reportPostRequest(postId, postRequestInfo: postRequestInfo);
    } else {
      response = await reportCommentRequest(postId, commentId,
          postRequestInfo: postRequestInfo);
    }
    bool reportSuccessful = (response == 201);
    if (reportSuccessful) {
      Navigator.pop(context);
      if (hasSubReasons[selectedMainIndex]) {
        Navigator.pop(context);
      }
      showDonePage(context);
    } else {
      CustomSnackbar(content: "Failed to report").show(context);
    }
    print("RESPONSE OF REPORT : $response");
  }

  void reportUser(BuildContext context) async {
    //TODO HANDLE REPORTING USER
    Navigator.pop(context);
    Navigator.pop(context);
    if (hasSubReasons[selectedMainIndex]) {
      Navigator.pop(context);
    }
    showDonePage(context);
  }

  /// Reports a post, comment, or user.
  void report(BuildContext context) async {
    if (isReportingUser) {
      reportUser(context);
    } else {
      reportPostOrComment(context);
    }
  }

  /// Blocks the reported user.
  void blockReportedUser(BuildContext context) {
    print(blockIsChecked);
    if (blockIsChecked) {
      // TODO ASK IF REQUEST RESPONSE STATUS SHOULD BE RETURNED HERE
      interactWithUser(
          userId: reportedUserName, action: InteractWithUsersActions.report);
    }
    Navigator.pop(context);
  }
}
