import 'package:dio/dio.dart';
import 'package:medical/src/model/response/menu_response.dart';
import 'request/send_interest_request.dart';
import 'response/diabetes_status_response.dart';
import 'response/latest_hba1c_input_response.dart';
import 'response/list_transaction_response.dart';
import 'package:retrofit/http.dart';
import 'package:retrofit/retrofit.dart';
import 'response/common_response.dart';
import 'response/blood_sugar_template_category_response.dart';
import 'response/blood_sugar_template_detail_response.dart';
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

  @GET("/App/BloodSugarTemplate/GetListByCategory")
  Future<BloodSugarTemplateCategoryResponse> getListTemplateByCategory(
    @Query("category") int category,
  );

  @GET("/App/BloodSugarTemplate/GetByTemplateType")
  Future<BloodSugarTemplateDetailResponse> getTemplateDetail(
    @Query("type") int type,
  );

  @GET("/App/DiabetesStatus/GetOwnDiabetesStatus")
  Future<DiabetesStatusResponse> getDiabetesStatus();

  @GET("/App/HbA1C/LatestHbA1CInput")
  Future<LatestHba1cInputResponse> getLatestHbA1CInput();
  // Transaction

  @GET("App/PackageTransaction")
  Future<ListTransactionResponse> getListTransaction(
    @Query("isExpired") bool? isExpired,
    @Query("page") int? page,
    @Query("size") int? size,
  );

  @GET("App/PatientFoodMenu/GetUserFoodMenu")
  Future<MenuResponse> getGetUserFoodMenu();
}
