
import 'package:medical/src/model/response/detail_package_response.dart';
import 'package:medical/src/model/response/list_package_response.dart';
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
}
