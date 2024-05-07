import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:spreadit_crossplatform/features/create_post/presentation/widgets/tags_widgets/rendered_tag.dart';
import 'package:spreadit_crossplatform/features/homepage/presentation/widgets/post_widget.dart';

/// This is the customized widget for displaying the post search result.
/// Parameters :
/// 1) [communityIcon] : the icon of the community to which the post was made.
/// 2) [communityName] : the name of the community to which to post was made.
/// 3) [time] : when was the post created.
/// 4) [postTitle] : the title of the created post.
/// 5) [upvotes] : number of post upvotes.
/// 6) [comments] : number of post comments.
/// 7) [isNsfw] : render the tag of NSFW.
/// 8) [isSpoiler] : render tyhe tag of Spoiler.
/// 9) [image] : optional parameter if there is an image attached to the post.
/// 10) [video] : optional parameter if there is a video attached to the post.

class PostElement extends StatefulWidget {

  final String communityIcon;
  final String communityName;
  final String time;
  final String postTitle;
  final String upvotes;
  final String comments;
  final bool isNsfw;
  final bool isSpoiler;
  final String? image;
  final String? video;

  const PostElement({
    required this.communityIcon,
    required this.communityName,
    required this.time,
    required this.postTitle,
    required this.upvotes,
    required this.comments,
    required this.isNsfw,
    required this.isSpoiler,
    this.image,
    this.video,
  });

  @override
  State<PostElement> createState() => _PostElementState();
}

class _PostElementState extends State<PostElement> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: GestureDetector(
        child: Column(
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 5),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(widget.communityIcon),
                            radius: 15,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right:5),
                          child: Text(
                            widget.communityName,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Text(
                          widget.time,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height:5),
                    SizedBox(
                      width: widget.image != null || widget.video != null ? MediaQuery.of(context).size.width - 150 : MediaQuery.of(context).size.width - 25,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.isNsfw && !widget.isSpoiler)
                           RenderedTag(
                            icon: Icons.warning_rounded,
                            text: 'NSFW',
                            height: 15,
                            width: 40,
                            fontSize: 9,
                            iconSize: 12,
                            ),
                          if (widget.isSpoiler && !widget.isNsfw)
                           RenderedTag(
                            icon: Icons.new_releases_rounded,
                            text: 'Spoiler',
                            height: 15,
                            width: 40,
                            fontSize: 8,
                            iconSize: 12,
                            ),
                          if (widget.isSpoiler && widget.isNsfw)
                            Row (
                              children: [
                                RenderedTag(icon: Icons.new_releases_rounded, text: 'Spoiler', height: 15, width: 40, fontSize: 8,iconSize: 12),
                                RenderedTag(icon: Icons.warning_rounded, text: 'NSFW',height: 15, width: 40, fontSize: 9,iconSize: 12),
                              ],
                            ),    
                          Text(
                            widget.postTitle,
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height:5),
                    Row(
                      children: [
                        Text(
                          '${widget.upvotes} upvotes',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        SizedBox(width: 5),  
                        Text(
                          '${widget.comments} comments',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                if (widget.image != null && (widget.image!.isNotEmpty || widget.image != '') )...[
                  Spacer(),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image(
                      image: NetworkImage(widget.image!),
                      height: 70,
                      width: 80,
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
                if (widget.video != null && (widget.video!.isNotEmpty || widget.video != '') )...[
                  Spacer(),
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          height: 70,
                          width: 80,
                          child: VideoPlayerScreen(
                            videoURL: widget.video!,
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 5.0, 
                        left: 5.0, 
                        child: Icon(
                          Icons.play_circle_fill_rounded, 
                          size: 17, 
                        ),
                      ),
                    ],
                  ),
                ], 
              ],
            ),
            Divider(
              color: Colors.grey,
              thickness: 1,
            ), 
          ],
        ),
      ),
    );
  }
}


