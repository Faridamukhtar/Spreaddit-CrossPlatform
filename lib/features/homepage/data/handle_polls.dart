import 'package:dio/dio.dart';
import 'package:spreadit_crossplatform/api.dart';
import 'package:spreadit_crossplatform/features/homepage/data/post_class_model.dart';
import 'package:spreadit_crossplatform/user_info.dart';

Future<bool> handlePolls({
  required PollOptions pollOption,
  required String postId,
}) async {
  try {
    String requestURL = "$apiUrl/posts/$postId/poll/vote";
    String? accessToken = UserSingleton().getAccessToken();

    print("post vote endpoint: $requestURL");
    final response = await Dio().post(
      requestURL,
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      ),
      data: {
        'selectedOptions': pollOption.option,
      },
    );
    if (response.statusCode == 200) {
      print("${response.statusMessage}");
      return true;
    } else if (response.statusCode == 404) {
      print("Conflict: ${response.statusMessage}");
      return false;
    } else {
      print("Conflict: ${response.statusMessage}");
      return false;
    }
  } on DioException catch (e) {
    if (e.response != null) {
      if (e.response!.statusCode == 200) {
        print("${e.response!.statusMessage}");
        return true;
      } else if (e.response!.statusCode == 404) {
        print("Conflict: ${e.response!.statusMessage}");
        return false;
      } else {
        print("Conflict: ${e.response!.statusMessage}");
        return false;
      }
    }
    rethrow;
  } catch (e) {
    //TO DO: show error message to user
    print("Error occurred: $e");
    return false;
  }
}
