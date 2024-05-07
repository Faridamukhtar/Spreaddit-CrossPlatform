import 'package:spreadit_crossplatform/user_info.dart';
import 'package:spreadit_crossplatform/features/discover_communities/data/community.dart';
import 'package:dio/dio.dart';
import 'package:spreadit_crossplatform/api.dart';

class GetUserModeratorCommunity {
  Dio dio = Dio();
  String? accessToken = UserSingleton().accessToken;
  String username = UserSingleton().user!.username;

  /// This function sends a request to the server and retrieves a list of communities a user is moderator in.
  ///
  /// The function first sends a GET request to the server. The server's response is then checked.
  ///
  /// If the status code of the response is 200, the data from the response is mapped to a list of `Community` objects.
  /// Each item in the list is converted to a `Community` object using the `fromJson` factory method.
  ///
  /// If the status code of the response is 404, an exception is thrown with the message 'No communities found for the specified category'.
  ///
  /// If the status code of the response is 500, an exception is thrown with the message 'Internal server error'.
  ///
  /// If the status code of the response is anything else, an exception is thrown with the message 'Bad request, invalid request parameters'.
  ///
  /// If any error occurs during the execution of the function, an exception is thrown with the message 'Failed to load communities: $e', where `$e` is the error that occurred.
  ///
  /// The function returns a list of `Community` objects if the request is successful.
  Future<List<Community>> getCommunities() async {
    try {
      Response response;
      Options options = Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      response = await dio.get(
        "$apiUrl/community/moderation/user/$username",
        options: options,
      );
      if (response.statusCode == 200) {
        print(
          "reponse ${response.data}",
        );
        List<Community> communities =
            (response.data as List).map((i) => Community.fromJson(i)).toList();
        print(communities);
        return communities;
      } else if (response.statusCode == 404) {
        throw Exception('No communities found for the specified category');
      } else if (response.statusCode == 500) {
        throw Exception('Internal server error');
      } else {
        throw Exception('Bad request, invalid request paramters');
      }
    } catch (e) {
      throw Exception('Failed to load communities 4klna msh hn5ls: $e ');
    }
  }
}
