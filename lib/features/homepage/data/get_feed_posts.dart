import 'package:dio/dio.dart';
import 'package:spreadit_crossplatform/api.dart';
import 'package:spreadit_crossplatform/features/homepage/data/post_class_model.dart';

/// describes the way reddit posts are categorized and/or sorted
enum PostCategories {
  best,
  hot,
  newposts,
  top,
  random,
  recent,
  views,
}

/// takes [PostCategories] as a parameter and
/// returns its respective endpoint
String postCategoryEndpoint({
  required PostCategories action,
  String? subspreaditName,
  String? timeSort = "",
}) {
  if (subspreaditName != null) {
    switch (action) {
      case PostCategories.best:
        return "/best/";
      case PostCategories.hot:
        return "/hot/";
      case PostCategories.newposts:
        return "/new/";
      case PostCategories.top:
        return "/top/";
      case PostCategories.recent:
        return "/best/recent-posts/";
      case PostCategories.views:
        return "/sort/views/";
      default:
        return "";
    }
  } else {
    switch (action) {
      case PostCategories.hot:
        return "/subspreadit/$subspreaditName/hot/";
      case PostCategories.newposts:
        return "/subspreadit/$subspreaditName/new/";
      case PostCategories.top:
        return "/subspreadit/$subspreaditName/top/$timeSort";
      case PostCategories.random:
        return "/subspreadit/$subspreaditName/random/";
      default:
        return "";
    }
  }
}

/// Takes [PostCategories] as a paremeter
/// and fetches its respective [Post] List
Future<List<Post>> getFeedPosts({
  required PostCategories category,
  String? subspreaditName,
  String? timeSort = "",
}) async {
  try {
    String requestURL = apiUrl +
        postCategoryEndpoint(
          action: category,
          subspreaditName: subspreaditName,
          timeSort: timeSort,
        );

    final response = await Dio().get(requestURL);
    if (response.statusCode == 200) {
      return (response.data as List).map((x) => Post.fromJson(x)).toList();
    } else if (response.statusCode == 409) {
      print("Conflict: ${response.statusMessage}");
    } else if (response.statusCode == 400) {
      print("Bad request: ${response.statusMessage}");
    } else {
      print("Internal Server Error: ${response.statusCode}");
    }
    return [];
  } on DioException catch (e) {
    if (e.response != null) {
      if (e.response!.statusCode == 400) {
        print("Bad request: ${e.response!.statusMessage}");
      } else if (e.response!.statusCode == 409) {
        print("Conflict: ${e.response!.statusMessage}");
      } else {
        print("Internal Server Error: ${e.response!.statusMessage}");
      }
      return [];
    }
    rethrow;
  } catch (e) {
    //TO DO: show error message to user
    print("Error occurred: $e");
    return [];
  }
}
