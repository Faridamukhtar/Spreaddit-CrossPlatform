import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:spreadit_crossplatform/features/homepage/presentation/widgets/post_widget.dart';
import 'package:video_player/video_player.dart';

/// This is the customized widget for displaying the media search result.
/// Parameters :
/// 1) [username] : the username of the post creator.
/// 2) [userIcon] : the avatar of the post creator .
/// 3) [postTitle] : the title of the created post.
/// 4) [media] : attached image or video.
/// 5) [mediaType] : image or video.

class MediaElement extends StatefulWidget {

  final String username;
  final String userIcon;
  final String postTitle;
  final String media;
  final String mediaType;

  const MediaElement({
    required this.username,
    required this.userIcon,
    required this.postTitle,
    required this.media,
    required this.mediaType,
  });

  @override
  State<MediaElement> createState() => _MediaElementState();
}

class _MediaElementState extends State<MediaElement> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          if (widget.mediaType == 'image')
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image(
                image: NetworkImage(widget.media),
                height: 200,
                width: 170,
                fit: BoxFit.fill,
              ),
            ),
          if (widget.mediaType == 'video') 
            ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: VideoPlayerScreen(videoURL: widget.media),
              ),
          Row(
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(10, 5, 5, 2),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(widget.userIcon),
                  radius: 10,
                ),
              ),
              Text(
                widget.username,
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Text(
            widget.postTitle,
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}