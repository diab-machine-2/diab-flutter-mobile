import 'package:dio/dio.dart';
import 'package:medical/src/model/response/diabetes_status_response.dart';
import 'package:medical/src/model/response/latest_hba1c_input_response.dart';
import 'package:retrofit/http.dart';
import 'package:retrofit/retrofit.dart';

import 'response/blood_sugar_template_category_response.dart';
import 'response/blood_sugar_template_detail_response.dart';
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

  @GET("/App/BloodSugarTemplate/GetListByCategory")
  Future<BloodSugarTemplateCategoryResponse> getListTemplateByCategory(
    @Query("category") String category,
  );

  @GET("/App/BloodSugarTemplate/{id}")
  Future<BloodSugarTemplateDetailResponse> getTemplateDetail(
    @Path("id") String id,
  );

  @GET("/App/DiabetesStatus/GetOwnDiabetesStatus")
  Future<DiabetesStatusResponse> getDiabetesStatus();

  @GET("/App/HbA1C/LatestHbA1CInput")
  Future<LatestHba1cInputResponse> getLatestHbA1CInput();
}
