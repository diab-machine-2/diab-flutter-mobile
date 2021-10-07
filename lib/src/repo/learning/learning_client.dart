import 'package:dio/dio.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/learning/learning_post_model.dart';
import 'package:medical/src/widget/helper/http_helper.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:easy_localization/easy_localization.dart';

class LearningClient extends FetchClient {
  Future<List<LearningPostModel>> fetchLearningPost(int position) async {
    try {
      final Response response = await super.fetchData(
          url: '/App/LearningPost',
          params: {
            'page': '1',
            'size': '1000',
            'position': position.toString()
          });
      if (response.statusCode == 200) {
        return LearningPostModel.toList(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error
          ? e
          : R.string.error_can_not_connect_to_server.tr();
    }
  }
}
