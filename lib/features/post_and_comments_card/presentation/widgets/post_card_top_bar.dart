import 'package:flutter/material.dart';

class PostCardTopBar extends AppBar {
  PostCardTopBar(BuildContext context, String image)
      : super(
          toolbarHeight: 60,
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.blue,
          title: Container(
              color: Colors.transparent,
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    // Search onPressed logic here
                  },
                  color: Colors.white,
                ),
                CircleAvatar(foregroundImage: NetworkImage(image)),
              ])),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushNamed('/home');
            },
            color: Colors.white,
          ),
        );
}
