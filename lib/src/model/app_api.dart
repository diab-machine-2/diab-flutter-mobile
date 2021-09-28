import 'package:dio/dio.dart';
import 'package:medical/src/model/request/send_interest_request.dart';
import 'package:medical/src/model/response/list_transaction_response.dart';

import 'package:retrofit/http.dart';
import 'package:retrofit/retrofit.dart';

import 'response/common_response.dart';
import 'response/detail_package_response.dart';
import 'response/list_package_response.dart';
import 'response/upgrade_account_response.dart';

part 'app_api.g.dart';

@RestApi()
abstract class AppApi {
  factory AppApi(Dio dio, {String baseUrl}) = _AppApi;

  // Package

  @GET("App/Package")
  Future<ListPackageResponse> getListPackage();

  @GET("App/Package/{code}")
  Future<DetailPackageResponse> getDetailPackage(
    @Path("code") String code,
  );

  @GET("App/Feature/GetPackageComparison")
  Future<UpgradeAccountResponse> getUpgradeAccount();

  @POST("App/PackageInterest/Input")
  Future<CommonResponse> sendInterestFeedback(@Body() SendInterestRequest request);

  // Transaction

  @GET("App/PackageTransaction")
  Future<ListTransactionResponse> getListTransaction(
    @Query("isExpired") bool? isExpired,
    @Query("page") int? page,
    @Query("size") int? size,
  );
}
