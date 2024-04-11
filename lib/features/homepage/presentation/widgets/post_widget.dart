import 'dart:async';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_polls/flutter_polls.dart';
import 'package:spreadit_crossplatform/features/generic_widgets/bottom_model_sheet.dart';
import 'package:spreadit_crossplatform/features/generic_widgets/snackbar.dart';
import 'package:spreadit_crossplatform/features/homepage/data/handle_polls.dart';
import 'package:spreadit_crossplatform/features/homepage/data/post_class_model.dart';
import 'package:spreadit_crossplatform/features/homepage/presentation/widgets/date_to_duration.dart';
import 'package:spreadit_crossplatform/features/homepage/presentation/widgets/interaction_button.dart';
import 'package:spreadit_crossplatform/features/post_and_comments_card/presentation/widgets/on_more_functios.dart';
import 'package:video_player/video_player.dart';
import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

class _PostHeader extends StatefulWidget {
  Post post;
  final bool isUserProfile;
  final void Function(String) onContentChanged;

  _PostHeader({
    required this.post,
    required this.onContentChanged,
    required this.isUserProfile,
  });

  State<_PostHeader> createState() => _PostHeaderState();
}

class _PostHeaderState extends State<_PostHeader> {
  void onShowMenu() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return CustomBottomSheet(icons: [
          Icons.notifications_on_rounded,
          Icons.save,
          Icons.copy,
          Icons.flag,
          Icons.block,
          Icons.hide_source_rounded,
          if (widget.isUserProfile) Icons.new_releases_rounded,
          Icons.warning_rounded,
          Icons.delete,
        ], text: [
          "Subscribe to post",
          "Save",
          "Copy text",
          "Report",
          "Block account",
          "Hide",
          if (widget.isUserProfile)
            isSpoiler ? "Unmark Spoiler" : "Mark Spoiler",
          isNSFW ? "Unmark NSFW" : "Mark NSFW",
          "Delete post",
        ], onPressedList: [
          subscribeToPost,
          save,
          copyText,
          report,
          blockAccount,
          hide,
          if (widget.isUserProfile)
            widget.post.isSpoiler
                ? () => widget.post.unmarkSpoiler(context, widget.post.postId)
                : () => widget.post.markSpoiler(context, widget.post.postId),
          widget.post.isNsfw
              ? () => widget.post.unmarkNSFW(context, widget.post.postId)
              : () => widget.post.markNSFW(context, widget.post.postId),
          () => widget.post.deletePost(context, widget.post.postId),
        ]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sec30PassedToggler =
        useState(false); //used for changing time without constant re-render
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
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ListTile(
          contentPadding: EdgeInsets.only(top: -10),
          title: Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text(
                "r/$community",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(dateFormatted.value),
            ],
          ),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(profilePic),
          ),
          trailing: Icon(Icons.more_vert), //TODO: render menu here
        ),
      ),
    );
  }
}

/// This widget is responsible for displaying post body:
/// headline, description (optional) and an image (optional)
class _PostBody extends StatelessWidget {
  final String title;
  final String postType;
  final String? content;
  final List<Attachment>? attachments;
  final String? link;
  final bool isFullView;
  final List<PollOptions>? pollOption;
  final String? pollVotingLength;
  final bool? isPollEnabled;
  final int postId;
  final bool isSpoiler;
  final bool isNsfw;

  _PostBody({
    required this.title,
    required this.postType,
    this.content,
    this.attachments,
    this.link,
    required this.isFullView,
    this.isPollEnabled,
    this.pollOption,
    this.pollVotingLength,
    required this.postId,
    this.isNsfw = false,
    this.isSpoiler = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: ListTile(
        dense: true,
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Opacity(
              opacity: 0.6,
              child: Row(
                children: [
                  isNsfw
                      ? Flex(
                          direction: Axis.horizontal,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.eighteen_up_rating_rounded,
                              color: Colors.purple,
                              size: 16,
                            ),
                            Text(
                              " Nswf",
                              style: TextStyle(
                                fontSize: 12,
                                letterSpacing: -0.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        )
                      : Text(""),
                  SizedBox(
                    width: isNsfw ? 10 : 0,
                  ),
                  isSpoiler
                      ? Flex(
                          direction: Axis.horizontal,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.explicit,
                              size: 16,
                            ),
                            Text(
                              " Spoiler",
                              style: TextStyle(
                                fontSize: 12,
                                letterSpacing: -0.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Text(""),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            _PostContent(
              postType: postType,
              content: content,
              attachments: attachments,
              link: link,
              isFullView: isFullView,
              pollOption: pollOption,
              isPollEnabled: isPollEnabled ?? true,
              pollVotingLength: pollVotingLength,
              postId: postId,
              isNsfw: isNsfw,
              isSpoiler: isSpoiler,
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageCaruosel extends StatefulWidget {
  final List<Attachment> attachments;
  _ImageCaruosel({
    required this.attachments,
  });

  @override
  State<_ImageCaruosel> createState() => _ImageCaruoselState();
}

class _ImageCaruoselState extends State<_ImageCaruosel> {
  int _currentImageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: MediaQuery.of(context).size.width / (16 / 9),
            aspectRatio: 16 / 9,
            viewportFraction: 1,
            enableInfiniteScroll: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentImageIndex = index;
              });
            },
          ),
          items: widget.attachments.map((i) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                        10.0), // Adjust the border radius as needed
                    child: Image(
                      image: NetworkImage(i.link),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.attachments.asMap().entries.map((entry) {
            return Container(
              width: 20.0,
              height: 5.0,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: entry.key == _currentImageIndex
                    ? Color.fromARGB(255, 255, 68, 0)
                    : Colors.grey,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _PostContent extends StatelessWidget {
  final String postType;
  final String? content;
  final List<PollOptions>? pollOption;
  final String? pollVotingLength;
  final bool isPollEnabled;
  final List<Attachment>? attachments;
  final String? link;
  final bool isFullView;
  final int postId;
  final bool isSpoiler;
  final bool isNsfw;

  _PostContent({
    required this.postType,
    required this.isFullView,
    this.content,
    this.attachments,
    this.link,
    this.isPollEnabled = true,
    this.pollOption,
    this.pollVotingLength,
    required this.postId,
    this.isNsfw = false,
    this.isSpoiler = false,
  });

  @override
  Widget build(BuildContext context) {
    if (postType == "post") {
      if ((isNsfw || isSpoiler) && !isFullView) return Text("");

      return Text(
        content ?? "",
        overflow: TextOverflow.ellipsis,
        maxLines: !isFullView ? 5 : null,
      );
    } else if (postType == "attachment") {
      if ((isNsfw || isSpoiler) && !isFullView) return Text("");

      if (attachments!.isNotEmpty) {
        if (attachments![0].type == "image") {
          return _ImageCaruosel(attachments: attachments!);
        } else {
          return VideoPlayerScreen(videoURL: attachments![0].link);
        }
      } else {
        CustomSnackbar(content: "No Attachments Found").show(context);
        print("Error fetching attachments from back");
        return Text("Unable to load attachments");
      }
    } else if (postType == "link") {
      if ((isNsfw || isSpoiler) && !isFullView) return Text("");

      return AnyLinkPreview(
        link: link ?? "",
        displayDirection: UIDirection.uiDirectionHorizontal,
        bodyMaxLines: 5,
        bodyTextOverflow: TextOverflow.ellipsis,
        titleStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      );
    } else {
      if ((isNsfw || isSpoiler) && !isFullView) return Text("");
      return FlutterPolls(
        pollTitle: Text(""),
        pollId: Uuid().v1(),
        onVoted: (chosenPollOption, newTotalVotes) {
          return handlePolls(
              postId: postId,
              pollOption: PollOptions(
                option:
                    pollOption![int.parse(chosenPollOption.id ?? "0")].option,
                votes: newTotalVotes,
              ));
        },
        pollOptionsSplashColor: Colors.white,
        pollEnded: !isPollEnabled,
        votedProgressColor: Colors.grey,
        votedBackgroundColor: Colors.grey.withOpacity(0.2),
        leadingVotedProgessColor: Color.fromARGB(230, 255, 68, 0),
        pollOptions: pollOption!.mapIndexed(
          (index, option) {
            return PollOption(
              id: index.toString(),
              title: Text(
                option.option,
              ),
              votes: option.votes,
            );
          },
        ).toList(),
      );
    }
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoURL;

  const VideoPlayerScreen({
    Key? key,
    required this.videoURL,
  }) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late FlickManager flickManager;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoURL),
    );
    flickManager = FlickManager(videoPlayerController: _controller);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: FlickVideoPlayer(
        flickManager: flickManager,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

/// This widget is responsible for displaying post interactions bottom bar
/// count of shares, upvotes and comments is displayed here.
class _PostInteractions extends HookWidget {
  final int votesCount;
  final int sharesCount;
  final int commentsCount;

  _PostInteractions({
    required this.votesCount,
    required this.sharesCount,
    required this.commentsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        child: Wrap(
          alignment: WrapAlignment.spaceAround,
          children: [
            VoteButton(
              initialVotesCount: votesCount,
            ),
            CommentButton(
              initialCommensCount: commentsCount,
            ),
            ShareButton(
                initialSharesCount: sharesCount, message: "LINK///////"),
          ],
        ),
      ),
    );
  }
}

/// This widget takes an instance of [Post] as a paremeter
/// and returns a postcard with its relevant info
class PostWidget extends StatefulWidget {
  final Post post;
  final bool isFullView;
  final bool isUserProfile;

  PostWidget({
    required this.post,
    this.isFullView = false,
    required this.isUserProfile,
  });

  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  late List<String> content;
  @override
  void initState() {
    super.initState();
    setState(() {
      content = widget.post.type == "post" ? widget.post.content : [];
    });
  }

  void onContentChanged(String newContent) {
    setState(() {
      content.add(newContent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PostHeader(
          post: widget.post,
          onContentChanged: onContentChanged,
          isUserProfile: widget.isUserProfile,
        ),
        _PostBody(
          title: widget.post.title,
          content: content.isNotEmpty ? content[content.length - 1] : "",
          attachments: widget.post.attachments,
          link: widget.post.link,
          postType: widget.post.type,
          isFullView: widget.isFullView,
          pollOption: widget.post.pollOptions,
          isPollEnabled: widget.post.isPollEnabled,
          pollVotingLength: widget.post.pollVotingLength,
          postId: widget.post.postId,
          isNsfw: widget.post.isNsfw,
          isSpoiler: widget.post.isSpoiler,
        ),
        _PostInteractions(
          votesCount: widget.post.votesUpCount - widget.post.votesDownCount,
          sharesCount: widget.post.sharesCount,
          commentsCount: widget.post.commentsCount,
        )
      ],
    );
  }
}
