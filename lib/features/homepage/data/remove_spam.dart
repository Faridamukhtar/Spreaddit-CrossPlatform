import 'package:dio/dio.dart';
import 'package:spreadit_crossplatform/api.dart';
import 'package:spreadit_crossplatform/features/generic_widgets/snackbar.dart';
import 'package:spreadit_crossplatform/user_info.dart';

String apibase = apiUrl;

/// Removes a post as spam.
///
/// This function sends a request to the server to remove a post as spam.
///
/// [communityName] is the name of the community where the post belongs.
///
/// [postId] is the ID of the post to be removed as spam.
///
/// Throws a DioException if the request fails.
Future<void> removeAsSpam(
    {required String communityName, required String postId}) async {
  try {
    String? accessToken = UserSingleton().accessToken;
    String reason = 'spam';
    var apiRoute = "/community/moderation/$communityName/$postId/remove-post";
    String apiUrl = apibase + apiRoute;

    final response = await Dio().post(
      apiUrl,
      options: Options(headers: {
        'Authorization': 'Bearer $accessToken',
      }),
      data: {
        "removalReason": reason,
      },
    );

    if (response.statusCode == 200) {
      print(response.statusCode);
      print(response.statusMessage);

      return;
    } else if (response.statusCode == 400) {
      print(response.statusMessage);
      print(response.statusCode);
      return;
    } else if (response.statusCode == 401) {
      print(response.statusMessage);
      print(response.statusCode);
      return;
    } else if (response.statusCode == 402) {
      print(response.statusMessage);
      print(response.statusCode);
      return;
    } else if (response.statusCode == 500) {
      print(response.statusMessage);
      print(response.statusCode);
      return;
    } else {
      print(response.statusMessage);
      print(response.statusCode);
      return;
    }
  } on DioException catch (e) {
    if (e.response != null) {
      if (e.response!.statusCode == 400) {
        print(e.response!.statusMessage);
        return;
      } else if (e.response!.statusCode == 500) {
        print("Conflict: ${e.response!.statusMessage}");
        return;
      }
    }
    rethrow;
  } catch (e) {
    print("Error occurred: $e");
    return;
  }
}
