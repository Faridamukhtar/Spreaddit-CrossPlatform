import 'package:dio/dio.dart';
import 'package:spreadit_crossplatform/api.dart';

enum InteractWithUsersActions { follow, unfollow, block, report }

String interactionType(InteractWithUsersActions action) {
  switch (action) {
    case InteractWithUsersActions.follow:
      return "/users/follow/";
    case InteractWithUsersActions.unfollow:
      return "/users/unfollow/";
    case InteractWithUsersActions.block:
      return "/users/block/";
    case InteractWithUsersActions.report:
      return "/users/report/";
  }
}

void interactWithUser(
    {required String userId,
    required InteractWithUsersActions action,
    String? reportReason}) async {
  try {
    String requestURL = apiUrl + interactionType(action);
    var data = {'userId': userId, 'reason': reportReason};
    final response = await Dio().post(requestURL, data: data);
    if (response.statusCode == 200) {
      //TO DO: implement logic needed to re-render UI
      print(response.statusMessage);
    } else if (response.statusCode == 404) {
      print("Not Found: ${response.statusMessage}");
    } else if (response.statusCode == 400) {
      print("Bad request: ${response.statusMessage}");
    } else {
      print("Internal Server Error: ${response.statusCode}");
    }
  } on DioException catch (e) {
    if (e.response != null) {
      if (e.response!.statusCode == 400) {
        print("Bad request: ${e.response!.statusMessage}");
      } else if (e.response!.statusCode == 404) {
        print("Not Found: ${e.response!.statusMessage}");
      } else {
        print("Internal Server Error: ${e.response!.statusMessage}");
      }
    }
    rethrow;
  } catch (e) {
    //TO DO: show error message to user
    print("Error occurred: $e");
  }
}
