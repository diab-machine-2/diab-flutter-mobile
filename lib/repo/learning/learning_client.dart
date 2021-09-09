import 'package:dio/dio.dart';
import 'package:medical/modal/learning/learning_post_model.dart';
import 'package:medical/widget/helper/http_helper.dart';
import 'package:medical/modal/error/error_model.dart';

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
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
  }
}
