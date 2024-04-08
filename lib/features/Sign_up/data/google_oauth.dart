import 'package:dio/dio.dart';
import 'package:spreadit_crossplatform/api.dart';

import '../../../user_info.dart';
import '../../user.dart';

/// Base URL for the API.
String apibase = apiUrl;

/// takes [googleToken] as a parameter and
/// returns its the user info and the new access token
Future<int> googleOAuthApi({
  required String googleToken,
}) async {
  try {
    print('here');
    var apiroute = "/google/oauth";
    String apiUrl = apibase + apiroute;
    var data = {
      "Authorization": googleToken,
      "remember_me": true,
    };
    final response = await Dio().post(
      apiUrl,
      data: data,
      options: Options(
        headers: {
          'Authorization': 'Bearer $googleToken',
        },
      ),
    );
    if (response.statusCode == 200) {
      User user = User.fromJson(response.data['user']);
      UserSingleton().setUser(user);
      UserSingleton().setAccessToken(response.data['access_token'],
          DateTime.parse(response.data['token_expiration_date']));

      print(response.statusMessage);
      return 200;
    } else if (response.statusCode == 409) {
      print("Conflict: ${response.statusMessage}");
      return 409;
    } else if (response.statusCode == 400) {
      print("Bad request: ${response.statusMessage}");
      return 400;
    } else if (response.statusCode == 500) {
      print("Server error: ${response.statusMessage}");
      return 500;
    } else {
      print("Unexpected status code: ${response.statusCode}");
      return 404;
    }
  } on DioException catch (e) {
    if (e.response != null) {
      if (e.response!.statusCode == 400) {
        print("Bad request: ${e.response!.statusMessage}");
        return 400;
      } else if (e.response!.statusCode == 409) {
        print("Conflict: ${e.response!.statusMessage}");
        return 409;
      } else if (e.response!.statusCode == 500) {
        print("Conflict: ${e.response!.statusMessage}");
        return 500;
      }
    }
    print("Dio error occurred: $e");
    rethrow;
  } catch (e) {
    print("Error occurred: $e");
    return 404;
  }
}
