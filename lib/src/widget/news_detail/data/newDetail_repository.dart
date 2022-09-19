import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/error/failures.dart';
import 'package:medical/src/modal/learning/learning_post_model.dart';
import 'package:medical/src/model/app_api.dart';
import 'package:medical/src/model/response/default_model_response.dart';
import 'package:medical/src/widget/helper/http_helper.dart';

late AppApi appClient;

class NewsDetailRepository extends FetchClient {
  Future<Either<Failure, LearningPostModel>> getNewsDetaill(
      String newsId) async {
    final Response response = await super.fetchData(
      url: '/App/LearningPost/$newsId',
    );
    try {
      DefaultModelResponse responseData =
          DefaultModelResponse.fromJson(response.data);
      if (response.statusCode == 200) {
        return Right(LearningPostModel.fromJson(responseData.data));
      } else {
        return Left(Failure(message: responseData.error.message));
      }
    } catch (e) {
      return Left(
        Failure(message: R.string.error_can_not_connect_to_server.tr()),
      );
    }
  }

  static final NewsDetailRepository _instance =
      NewsDetailRepository._internal();
  factory NewsDetailRepository() {
    return _instance;
  }
  NewsDetailRepository._internal();
}
