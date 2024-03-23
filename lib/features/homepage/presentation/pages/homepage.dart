import 'package:flutter/material.dart';
import 'package:spreadit_crossplatform/features/homepage/data/get_feed_posts.dart';
import 'package:spreadit_crossplatform/features/homepage/presentation/widgets/home_page_drawer.dart';
import 'package:spreadit_crossplatform/features/homepage/presentation/widgets/post_feed.dart';
import 'package:spreadit_crossplatform/features/homepage/presentation/widgets/top_bar.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(),
      body: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Container(
          color: Colors.white,
          child: Column(children: [
            Container(
              margin: EdgeInsets.all(10),
              child: Divider(
                height: 0.5,
              ),
            ),
            PostFeed(
              postCategory: PostCategories.best,
            ),
          ]),
        ),
      ),
      endDrawer: HomePageDrawer(),
    );
  }
}
