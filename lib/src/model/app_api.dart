import 'package:dio/dio.dart';

import 'package:retrofit/http.dart';
import 'package:retrofit/retrofit.dart';

import 'response/detail_package_response.dart';
import 'response/list_package_response.dart';
import 'response/upgrade_account_response.dart';


part 'app_api.g.dart';

@RestApi()
abstract class AppApi {
  factory AppApi(Dio dio, {String baseUrl}) = _AppApi;

  @GET("App/Package")
  Future<ListPackageResponse> getListPackage();

  @GET("App/Package/{code}")
  Future<DetailPackageResponse> getDetailPackage(@Path("code") String code,);

  @GET("App/Feature/GetPackageComparison")
  Future<UpgradeAccountResponse> getUpgradeAccount();
}
