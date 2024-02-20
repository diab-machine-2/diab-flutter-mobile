import 'package:easy_localization/src/public_ext.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/request/make_question_request.dart';
import 'package:medical/src/widget/helper/http_helper.dart';
import 'package:medical/src/modal/error/error_model.dart';

class QuestionAnswerClient extends FetchClient {
  Future<dynamic> makeQuestion(MakeQuestionRequest request) async {
    try {
      final response = await super.postHttp(
          path: '/App/Question/Input',
          params: {
            'body': request.body!,
            'accountId': request.accountId!,
          },
          files: request.pictures);
      if (response.statusCode == 200) {
        return true;
      } else {
        final error = (await response.stream.bytesToString());
        throw Error.fromString(error);
      }
    } catch (e) {
      return e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<dynamic> ratingComment({
    required String commentId,
    required String rate,
  }) async {
    // try {
    final response = await super.postHttp(
        path: '/App/Question/Mobile/RateAnwser',
        params: {'rate': rate, 'answerId': commentId});

    if (response.statusCode == 200) {
      return true;
    } else {
      final error = (await response.stream.bytesToString());
      throw Error.fromString(error);
    }
    // } catch (e) {
    //   return e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    // }
  }
}
