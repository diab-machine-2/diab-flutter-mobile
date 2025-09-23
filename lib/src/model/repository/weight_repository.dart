import 'package:http/http.dart' as http;

import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/submit_weight_record_request.dart';
import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';

class WeightRepository {
  WeightRepository._();

  static final WeightRepository _instance = WeightRepository._();

  static WeightRepository get instance => _instance;

  Future<ApiResult<CommonResponse>> submitWeightRecord(
      SubmitWeightRecordRequest request) async {
    try {
      final CommonResponse response =
          await appClient.submitWeightRecord(request);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }
}
