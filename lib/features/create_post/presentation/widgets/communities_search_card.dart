import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CommunitiesCard extends StatefulWidget {

  final String communityName;
  final String online;
  final String communityIcon;

  const CommunitiesCard({
    required this.communityName,
    required this.online,
    required this.communityIcon,
  });

  @override
  State<CommunitiesCard> createState() => _CommunitiesCardState();
}

class _CommunitiesCardState extends State<CommunitiesCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin:EdgeInsets.all(15),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(widget.communityIcon),
              radius: 20,
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Text(widget.communityName,
                  style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  ),
                ),
            Text(widget.online),
              ],
            ),
          ],
        ),
      ),
    );
  }
}