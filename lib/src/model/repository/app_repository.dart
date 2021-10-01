import 'package:medical/src/model/request/send_interest_request.dart';
import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/response/blood_sugar_template_category_response.dart';
import 'package:medical/src/model/response/blood_sugar_template_detail_response.dart';
import 'package:medical/src/model/response/detail_package_response.dart';
import 'package:medical/src/model/response/diabetes_status_response.dart';
import 'package:medical/src/model/response/latest_hba1c_input_response.dart';
import 'package:medical/src/model/response/list_package_response.dart';
import 'package:medical/src/model/response/list_transaction_response.dart';
import 'package:medical/src/model/response/menu_response.dart';
import 'package:medical/src/model/response/upgrade_account_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';

import '../service/app_client.dart';

class AppRepository {
  Future<ApiResult<ListPackageResponse>> getListPackage() async {
    try {
      ListPackageResponse response = await appClient.getListPackage();
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<DetailPackageResponse>> getDetailPackage(String type) async {
    try {
      DetailPackageResponse response = await appClient.getDetailPackage(type);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<UpgradeAccountResponse>> getUpgradeAccount() async {
    try {
      UpgradeAccountResponse response = await appClient.getUpgradeAccount();
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<CommonResponse>> sendInterestFeedback(
      SendInterestRequest request) async {
    try {
      CommonResponse response = await appClient.sendInterestFeedback(request);
      if (response.error == null)
        return ApiResult.success(data: response);
      else
        return ApiResult.failure(
            error:
                NetworkExceptions.defaultError(response.error!.message ?? ""));
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<BloodSugarTemplateCategoryResponse>>
      getListTemplateByCategory(
    int category,
  ) async {
    try {
      final BloodSugarTemplateCategoryResponse response =
          await appClient.getListTemplateByCategory(category);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<ListTransactionResponse>> getListTransaction(
      {bool? isExpired, int? page, int? size}) async {
    try {
      ListTransactionResponse response =
          await appClient.getListTransaction(isExpired, page, size);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<BloodSugarTemplateDetailResponse>> getListTemplateDetail(
    int type,
  ) async {
    try {
      final BloodSugarTemplateDetailResponse response =
          await appClient.getTemplateDetail(type);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<DiabetesStatusResponse>> getDiabetesStatus() async {
    try {
      final DiabetesStatusResponse response =
          await appClient.getDiabetesStatus();
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<LatestHba1cInputResponse>> getLatestHbA1CInput() async {
    try {
      final LatestHba1cInputResponse response =
          await appClient.getLatestHbA1CInput();
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<MenuResponse>> getGetUserFoodMenu() async {
    try {
      final MenuResponse response = await appClient.getGetUserFoodMenu();
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }
  
}
