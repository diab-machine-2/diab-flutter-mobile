import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';
import 'package:retrofit/retrofit.dart';

import 'request/create_menu_request.dart';
import 'request/food_change_request.dart';
import 'request/ios_receipt_request.dart';
import 'request/post_survey_request.dart';
import 'request/send_feedback_course_request.dart';
import 'request/send_interest_request.dart';
import 'request/update_lesson_section_request.dart';
import 'response/blood_sugar_template_response.dart';
import 'response/common_response.dart';
import 'response/create_menu_response.dart';
import 'response/detail_package_response.dart';
import 'response/detail_survey_response.dart';
import 'response/diabetes_status_response.dart';
import 'response/food_suggest_response.dart';
import 'response/latest_hba1c_input_response.dart';
import 'response/lesson_section_list_response.dart';
import 'response/list_activity_response.dart';
import 'response/list_package_response.dart';
import 'response/list_roadmap_response.dart';
import 'response/list_transaction_response.dart';
import 'response/menu_response.dart';
import 'response/my_lesson_response.dart';
import 'response/save_survey_result_response.dart';
import 'response/tdee_response.dart';
import 'response/upgrade_account_response.dart';
import 'response/user_info_response.dart';

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
  Future<CommonResponse> sendInterestFeedback(
      @Body() SendInterestRequest request);

  // Transaction

  @GET("App/PackageTransaction")
  Future<ListTransactionResponse> getListTransaction(
    @Query("isExpired") bool? isExpired,
    @Query("page") int? page,
    @Query("size") int? size,
  );

  @POST("App/Payment/VerifyApplePayment")
  Future<dynamic> verifyReceipt(@Body() IosReceiptRequest request);

  // Blood sugar
  @GET("/App/DiabetesStatus/GetOwnDiabetesStatus")
  Future<DiabetesStatusResponse> getDiabetesStatus();

  @GET("/App/HbA1C/LatestHbA1CInput")
  Future<LatestHba1cInputResponse> getLatestHbA1CInput();

  @GET("/App/BloodSugarTemplate/{code}")
  Future<BloodSugarTemplateResponse> getTemplateDetail(
    @Path("code") String code,
  );

  @PUT("App/Patient/SaveBloodSugarTemplate/{templateId}")
  Future<SaveSurveyResultResponse> saveSurveyResult(
    @Path("templateId") String templateId,
  );

  // Sample menu

  @GET("App/ActivityLevel")
  Future<ListActivityResponse> getListActivity();

  @GET("App/Diet/TDEE")
  Future<TDEEResponse> getTDEE(
    @Query("activityLevelId") String? activityLevelId,
    @Query("weight") num? weight,
    @Query("height") num? height,
    @Query("yearOfBirth") num? yearOfBirth,
  );

  //Food Menu

  @GET("App/PatientFoodMenu/GetUserFoodMenu")
  Future<MenuResponse> getUserFoodMenu();

  @GET("App/PatientFoodMenu/SuggestionFood/{id}")
  Future<FoodSuggestResponse> getSuggestionFood(
    @Path("id") String id,
  );

  @PUT("App/PatientFoodMenu/Input")
  Future<CommonResponse> changeFood(
    @Body() FoodChangeRequest request,
  );

  @POST("App/PatientFoodMenu/Input")
  Future<CreateMenuResponse> createMenu(
    @Body() CreateMenuRequest request,
  );

  // Survey
  @GET("App/Survey/{surveyId}")
  Future<DetailSurveyResponse> getDetailSurvey(
    @Path("surveyId") String surveyId,
  );

  @POST("App/SurveyResult")
  Future<CommonResponse> submitSurvey(@Body() PostSurveyRequest request);

  //Acount
  @GET("App/Account/GetCurrentUserInfo")
  Future<UserInfoResponse> getCurrentUserInfo();

  //My Plan
  @GET("App/Lesson/MyLessons")
  Future<MyLessonResponse> getLessonsList(
    @Query("type") int type,
  );

  @GET("App/Lesson/{lessonId}/ListLessonSection")
  Future<LessonSectionListResponse> getListLessonSection(
    @Path("lessonId") String lessonId,
  );

  @POST("App/LessonSection/SetCompletedLessonAccount")
  Future<CommonResponse> setCompletedLessonAccount(
    @Body() UpdateLessonSectionRequest request,
  );
 
  @GET("App/Roadmap")
  Future<ListRoadmapResponse> getRoadMap(
    @Query('page') int page,
    @Query('size') int size,
  );

  // Quiz
  @POST("App/Lesson/{lessonId}/Review")
  Future<CommonResponse> sendFeedbackCourse(
    @Path("lessonId") String lessonId,
    @Body() SendFeedbackCourseRequest request,
  );

  @GET("App/Lesson/{lessonId}/LessonQuizDetail")
  Future<LessonSectionListResponse> getListQuiz(
      @Path("lessonId") String lessonId);
}
