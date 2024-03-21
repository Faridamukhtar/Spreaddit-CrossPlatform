import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:spreadit_crossplatform/features/homepage/widgets/date_to_duration.dart';
import 'package:spreadit_crossplatform/features/homepage/widgets/interaction_button.dart';

//TODO: create options tab for post (shows join community options when pressed)

// class PostOptions extends StatefulWidget {
// bool isJoinCommunityVisible;
// }

class _PostHeader extends HookWidget {
  final String username;
  final String userId;
  final DateTime date;
  final String profilePic;
  //TODO:final PostOptions options;

  _PostHeader({
    required this.username,
    required this.userId,
    required this.date,
    required this.profilePic,
    //TODO:required this.options,
  });

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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ListTile(
          contentPadding: EdgeInsets.only(top: 20),
          title: Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text(
                username,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(dateFormatted.value),
            ],
          ),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(profilePic),
          ),
          trailing: Icon(Icons.more_horiz),
        ),
      ),
    );
  }
}

class _PostBody extends StatelessWidget {
  final String headline;
  final String? description;
  final String? imageUrl;

  _PostBody({
    required this.headline,
    this.description,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListTile(
        dense: true,
        title: Text(
          headline,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        subtitle: imageUrl != null
            ? Image(image: NetworkImage(imageUrl ?? ""))
            : Text(
                description ?? "",
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
      ),
    );
  }
}

class _PostInteractions extends HookWidget {
  final int votesCount;
  final int sharesCount;
  final int commentsCount;
  //TODO:final bool isJoinCommunityVisible;

  _PostInteractions({
    required this.votesCount,
    required this.sharesCount,
    required this.commentsCount,
    //TODO:required this.isJoinCommunityVisible,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
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
              initialSharesCount: sharesCount,
            ),
          ],
        ),
      ),
    );
  }
}

class Post extends StatelessWidget {
  final int postId;
  final String username;
  final String userId;
  final DateTime date;
  final String headline;
  final String? description;
  final String? imageUrl;
  final int votesCount;
  final int sharesCount;
  final int commentsCount;
  final String profilePic;
  //TODO: final bool isJoinCommunityVisible;

  Post({
    required this.postId,
    required this.username,
    required this.userId,
    required this.date,
    required this.headline,
    this.description,
    this.imageUrl,
    required this.votesCount,
    required this.sharesCount,
    required this.commentsCount,
    required this.profilePic,
    //TODO:required this.isJoinCommunityVisible,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PostHeader(
          username: username,
          userId: userId,
          date: date,
          profilePic: profilePic,
        ),
        _PostBody(
          headline: headline,
          description: description,
          imageUrl: imageUrl,
        ),
        _PostInteractions(
          votesCount: votesCount,
          sharesCount: sharesCount,
          commentsCount: commentsCount,
        )
      ],
    );
  }
}
