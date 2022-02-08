import 'package:dio/dio.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/request/make_comment_request.dart';
import 'package:medical/src/model/request/make_question_request.dart';
import 'package:medical/src/widget/helper/http_helper.dart';
import 'package:medical/src/modal/error/error_model.dart';

class QuestionAnswerClient extends FetchClient {
  Future<dynamic> makeQuestion(MakeQuestionRequest request) async {
    try {
      final Response response = await super.postData(
          url: '/App/Question/Input',
          params: FormData.fromMap({
            'body': request.body!,
            'lessonModuleId': request.lessonModuleId!,
            'accountId': request.accountId!,
          }));
      if (response.statusCode == 200) {
        return true;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      return e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  // Future<dynamic> makeComment(MakeCommentRequest request) async {
  //   try {
  //     final Response response = await super.postData(
  //         url: '/App/Question/CreateAnswer',
  //         params: FormData.fromMap({
  //           'body': request.body!,
  //           'questionId': request.questionId!,
  //           'accountId': request.accountId!,
  //           'isComment': true,
  //         }));
  //     if (response.statusCode == 200) {
  //       return true;
  //     } else {
  //       final error = Error.fromJson(response);
  //       throw error;
  //     }
  //   } catch (e) {
  //     return e is Error ? e : R.string.error_can_not_connect_to_server.tr();
  //   }
  // }

  // Future<dynamic> deleteComment(String id) async {
  //   try {
  //     final Response response = await super.delete(url: '/App/Question/DeleteAnswer', params: {'id': id});
  //     if (response.statusCode == 200) {
  //       return true;
  //     } else {
  //       final error = Error.fromJson(response);
  //       throw error;
  //     }
  //   } catch (e) {
  //     return e is Error ? e : R.string.error_can_not_connect_to_server.tr();
  //   }
  // }
}
