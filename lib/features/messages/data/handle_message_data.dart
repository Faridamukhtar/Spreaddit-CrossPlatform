import 'package:dio/dio.dart';
import 'package:spreadit_crossplatform/api.dart';
import 'package:spreadit_crossplatform/features/messages/data/message_model.dart';
import 'package:spreadit_crossplatform/user_info.dart';

/// and fetches its respective [Message] List
Future<List<Message>> getMessages() async {
  try {
    String? accessToken = UserSingleton().getAccessToken();

    String requestURL = '$apiUrl/message/messages';
    final response = await Dio().get(
      requestURL,
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      ),
    );
    if (response.statusCode == 200) {
      print(response.data);
      
      List<Message> messages =
          (response.data as List).map((x) => Message.fromJson(x)).toList();

      return (messages);
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

// /// Takes [messageId] as a paremeter
// /// and fetches its respective [Post] List
// Future<Post?> getPostById({
//   required String postId,
// }) async {
//   try {
//     String? accessToken = UserSingleton().getAccessToken();

//     String requestURL = "$apiUrl/posts/$postId/";

//     final response = await Dio().get(
//       requestURL,
//       options: Options(
//         headers: {
//           'Authorization': 'Bearer $accessToken',
//         },
//       ),
//     );
//     if (response.statusCode == 200) {
//       return Post.fromJson(response.data);
//     } else if (response.statusCode == 409) {
//       print("Conflict: ${response.statusMessage}");
//     } else if (response.statusCode == 400) {
//       print("Bad request: ${response.statusMessage}");
//     } else {
//       print("Internal Server Error: ${response.statusCode}");
//     }
//     return null;
//   } on DioException catch (e) {
//     if (e.response != null) {
//       if (e.response!.statusCode == 400) {
//         print("Bad request: ${e.response!.statusMessage}");
//       } else if (e.response!.statusCode == 409) {
//         print("Conflict: ${e.response!.statusMessage}");
//       } else {
//         print("Internal Server Error: ${e.response!.statusMessage}");
//       }
//       return null;
//     }
//     rethrow;
//   } catch (e) {
//     //TO DO: show error message to user
//     print("Error occurred: $e");
//     return null;
//   }
// }
