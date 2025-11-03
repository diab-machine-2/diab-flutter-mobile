import 'package:dio/dio.dart';
import 'package:medical/src/model/request/SelectRoadmapRequest.dart';
import 'package:medical/src/model/request/add_exercise_request.dart';
import 'package:medical/src/model/request/booking_success_request.dart';
import 'package:medical/src/model/request/create_calendar_request.dart';
import 'package:medical/src/model/request/delete_calendar_request.dart';
import 'package:medical/src/model/request/make_comment_request.dart';
import 'package:medical/src/model/request/make_question_request.dart';
import 'package:medical/src/model/request/mark_completed_target_request.dart';
import 'package:medical/src/model/request/notify_subscription_request.dart';
import 'package:medical/src/model/request/save_vnpay_transaction_request.dart';
import 'package:medical/src/model/request/sync_index_from_zalo_request.dart';
import 'package:medical/src/model/request/update_exercise_request.dart';
import 'package:medical/src/model/response/app_version_response.dart';
import 'package:medical/src/model/response/bmi_get_analyze_weight_index_response.dart';
import 'package:medical/src/model/response/bmi_get_analyze_weight_trend_response.dart';
import 'package:medical/src/model/response/bmi_get_weight_detail_response.dart';
import 'package:medical/src/model/response/bmi_get_weight_lessons_response.dart';
import 'package:medical/src/model/response/bmi_get_weight_list_response.dart';
import 'package:medical/src/model/response/bmi_statistical_response.dart';
import 'package:medical/src/model/response/bmi_waist_statistical_response.dart';
import 'package:medical/src/model/response/bmi_weight_statistical_response.dart';
import 'package:medical/src/model/response/branchio_generate_zoom_response.dart';
import 'package:medical/src/model/response/calculate_bmi_response.dart';
import 'package:medical/src/model/response/calendar_training_response.dart';
import 'package:medical/src/model/response/chat_supabase_response.dart';
import 'package:medical/src/model/response/content_welcome_response.dart';
import 'package:medical/src/model/response/create_calendar_response.dart';
import 'package:medical/src/model/response/delete_weight_record_response.dart';
import 'package:medical/src/model/response/exercise_analysis_response.dart';
import 'package:medical/src/model/response/exercise_category_response.dart';
import 'package:medical/src/model/response/exercise_health_trend_response.dart';
import 'package:medical/src/model/response/exercise_intensity_response.dart';
import 'package:medical/src/model/response/exercise_lesson_response.dart';
import 'package:medical/src/model/response/exercise_summary_response.dart';
import 'package:medical/src/model/response/expert_comment_list_response.dart';
import 'package:medical/src/model/response/get_customer_receives_user_response.dart';
import 'package:medical/src/model/response/get_subscription_banners_response.dart';
import 'package:medical/src/model/response/get_weight_threshold_response.dart';
import 'package:medical/src/model/response/get_vnpay_transaction_info_response.dart';
import 'package:medical/src/model/response/learning_post_response.dart';
import 'package:medical/src/model/response/lesson_module_response.dart';
import 'package:medical/src/model/response/list_calendart_response.dart';
import 'package:medical/src/model/response/question_answer_response.dart';
import 'package:medical/src/model/response/report_response.dart';
import 'package:medical/src/model/response/submit_weight_record_response.dart';
import 'package:retrofit/http.dart';
import 'package:retrofit/retrofit.dart';

import 'request/complete_exercise_request.dart';
import 'request/complete_smart_goal_request.dart';
import 'request/complete_video_request.dart';
import 'request/create_menu_request.dart';
import 'request/create_smart_goal_request.dart';
import 'request/exercise_feedback_request.dart';
import 'request/food_change_request.dart';
import 'request/ios_receipt_request.dart';
import 'request/lesson_filter_request.dart';
import 'request/mark_share_request.dart';
import 'request/post_survey_request.dart';
import 'request/send_feedback_course_request.dart';
import 'request/send_interest_request.dart';
import 'request/update_lesson_section_request.dart';
import 'request/update_quiz_lesson_request.dart';
import 'request/update_shared_profile_request.dart';
import 'request/zoom_token_request.dart';
import 'response/blood_sugar_template_response.dart';
import 'response/common_response.dart';
import 'response/create_menu_response.dart';
import 'response/create_smart_goal_response.dart';
import 'response/delete_smart_goal_reponse.dart';
import 'response/detail_package_response.dart';
import 'response/detail_survey_response.dart';
import 'response/diabetes_status_response.dart';
import 'response/exercise_movement_response.dart';
import 'response/expert_comment_response.dart';
import 'response/filter_data_response.dart';
import 'response/food_suggest_response.dart';
import 'response/latest_hba1c_input_response.dart';
import 'response/lesson_section_list_response.dart';
import 'response/list_activity_response.dart';
import 'response/list_package_response.dart';
import 'response/list_roadmap_response.dart';
import 'response/list_transaction_response.dart';
import 'response/menu_response.dart';
import 'response/my_lesson_response.dart';
import 'response/my_progress_response.dart';
import 'response/patient_info_response.dart';
import 'response/save_survey_result_response.dart';
import 'response/smart_goal_detail_response.dart';
import 'response/smart_goal_list_reponse.dart';
import 'response/smart_goal_statistic_response.dart';
import 'response/tdee_response.dart';
import 'response/update_shared_profile_response.dart';
import 'response/upgrade_account_response.dart';
import 'response/user_info_referral_code_response.dart';
import 'response/user_info_response.dart';
import 'response/week_states_response.dart';
import 'response/zoom_token_response.dart';

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

  @GET("App/Version")
  Future<List<AppVersionResponse>> getAppVersion();

  @GET("App/PatientFoodMenu/SuggestionFood")
  Future<FoodSuggestResponse> getSuggestionFood({
    @Query("foodMenuCode") String? foodMenuCode,
    @Query("foodId") String? foodId,
    @Query("dateCode") String? dateCode,
    @Query("timeCode") int? timeCode,
    @Query("isUseReplacedFood") bool? isUseReplacedFood,
  });

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

  //Acount
  @GET("App/Account/SyncData")
  Future<void> syncIndexFromZaloToPhone(
      @Body() SyncIndexFromZaloToPhoneRequest request);

  //My Plan
  @POST("App/Lesson/MyLessonsOptimizedRemoveWeek")
  Future<MyLessonResponse> getLessonsList(
    @Body() LessonFilterRequest request,
  );

  @GET("App/Lesson/PrepareSearchFormItem")
  Future<FilterDataResponse> getFilterData();

  @GET("/App/Lesson/{lessonId}/ListLessonSection")
  Future<LessonSectionListResponse> getListLessonSection(
    @Path("lessonId") String lessonId,
  );

  @POST("App/LessonSection/SetCompletedLessonAccount")
  Future<CommonResponse> setCompletedLessonAccount(
    @Body() UpdateLessonSectionRequest request,
  );

  @POST("/App/Lesson/SetCompletedLessonQuiz")
  Future<CommonResponse> setCompletedLessonQuiz(
    @Body() UpdateQuizLessonRequest request,
  );

  //Exercise

  @GET("App/Agenda/MyRoadmap")
  Future<ListRoadmapResponse> getRoadMap();

  @POST("App/Patient/Roadmap")
  Future<CommonResponse> selectRoadmap(
    @Body() SelectRoadmapRequest request,
  );

  @GET("App/ExerciseMovement/All")
  Future<ExerciseMovementResponse> getExerciseMovement(
    @Query('week') int? week,
  );

  @GET("App/PackageAccountTransaction/GetContentWelcome")
  Future<ContentWelcomeResponse> getContentWelcome(
    @Query('accountId') String? accountId,
  );

  @POST("App/ExerciseMovementReview")
  Future<CommonResponse> exerciseFeedback(
    @Body() ExerciseFeedbackRequest request,
  );

  @POST("App/ExerciseMovementAccount")
  Future<CommonResponse> completeExercise(
    @Body() CompleteExerciseRequest request,
  );

  @POST("App/ExerciseMovementAccount/Input")
  Future<CommonResponse> completeVideo(
    @Body() CompleteVideoRequest request,
  );

  @GET("App/Agenda/GetWeekStates")
  Future<WeekStatesResponse> getExerciseWeekStates();

  @GET("App/Lesson/GetWeekStates")
  Future<WeekStatesResponse> getLessonWeekStates();

  //Activity
  @POST("/App/Target")
  Future<CreateSmartGoalResponse> createSmartGoal(
    @Body() CreateSmartGoalRequest request,
  );

  @POST("App/Target/MarkCompletedTarget")
  Future<CommonResponse> completeSmartGoal(
    @Body() CompleteSmartGoalRequest request,
  );

  @POST("App/Target/MarkCompletedUpdateProfile")
  Future<CommonResponse> markCompletedUpdateProfile(
    @Query("id") String id,
  );

  @POST("App/Target/MarkCompletedTarget")
  Future<CommonResponse> completeGoal(
    @Body() MarkCompletedTargetRequest request,
  );

  @POST("App/Calendar/MarkCompletedCalendar")
  Future<CommonResponse> markCompletedCalendar(
    @Query("id") String id,
  );

  @POST("App/Patient/ChangeIsShare")
  Future<CommonResponse> markIsShare(
    @Body() MarkShareRequest request,
  );

  @POST("App/Home/MarkDisplayedWelcome")
  Future<CommonResponse> markDisplayedWelcome();

  @GET("App/CustomerReceives/user")
  Future<GetCustomerReceivesUserResponse> getCustomerReceivesUser(
      @Query('PhoneNumber') String phoneNumber);

  @GET("App/MyProgress/Reports")
  Future<ReportListResponse> getReports();

  @GET("App/Target")
  Future<SmartGoalListReponse> getListSmartGoal({
    @Query('week') int? week,
    @Query('day') int? day,
  });

  @GET("App/Question/GetAllMobile")
  Future<QuestionAnswerResponse> getListQuestion(
      @Query('page') int page,
      @Query('size') int size,
      @Query("lessonModuleIds") List<String>? lessonModuleIds,
      @Query("accountIds") List<String>? accountIds);

  @GET("App/Question/{id}")
  Future<QuestionResponse> getQuestionById(@Path('id') String id);

  @GET("App/LessonModule")
  Future<LessonModuleResponse> getListLessonModule(
      @Query('page') int page, @Query('size') int size);

  @POST("App/Question/Input")
  Future<CommonResponse> makeQuestion(
    @Body() MakeQuestionRequest request,
  );

  @POST("App/Question/CreateAnswer")
  Future<CommonResponse> makeComment(
    @Body() MakeCommentRequest request,
  );

  @DELETE("App/Question/Input/{id}")
  Future<CommonResponse> deleteQuestion(
    @Path('id') String id,
  );

  @DELETE("App/Question/DeleteAnswer/{id}")
  Future<CommonResponse> deleteComment(
    @Path('id') String id,
  );

  @GET("App/Target/GetTargetWeekStatistics")
  Future<SmartGoalStatisticResponse> getSmartGoalStatistics({
    @Query('day') int? day,
    @Query('week') int? week,
  });

  @GET("App/Target/{id}")
  Future<SmartGoalDetailResponse> getSmartGoalDetail(
    @Path("id") String id,
  );

  @DELETE("App/Target/{id}")
  Future<DeleteSmartGoalReponse> deleteSmartGoal(
    @Path('id') String id,
  );

  // Zoom Token
  @POST("App/Zoom/sdk-key")
  Future<ZoomTokenResponse> getZoomToken(
    @Body() ZoomTokenRequest request,
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

  // My Progress
  @GET("App/MyProgress")
  Future<MyProgressResponse> getMyProgress({@Query('type') int? type});

  @GET("App/UserDashboard/Calendar-Training-Comment")
  Future<ExpertCommentListResponse> getCommentProfessorByAccountId(
      @Query('patientId') String? accountId);

  @GET("App/UserDashboard/Calendar-Training-Comment/{id}")
  Future<ExpertCommentResponse> getCommentById(@Path('id') String id);

  @GET("App/CalendarTraining")
  Future<CalendarTrainingListResponse> getCalendarTraining(
      @Query('calendarId') String calendarId);

  //Referral, Share Profile
  @GET("App/Patient/GetAccountInfoWithReferalOfCurrentPatient")
  Future<PatientInfoResponse> getSharedProfile();

  @PUT("App/Patient/UpdateReferalCodeFromPatient")
  Future<UpdateSharedProfileResponse> updateSharedProfile(
    @Body() UpdateSharedProfileRequest? request,
  );

  @GET("App/Patient/CheckHasShareProfile/{referalCode}")
  Future<UpdateSharedProfileResponse> hasSharedProfile(
    @Path('referalCode') String referalCode,
  );

  @GET("App/Patient/CheckDuplicateReferalAccount/{referalCode}")
  Future<UserInfoReferralCodeResponse> getUserFromReferralCode(
    @Path('referalCode') String referalCode,
  );

  //  Calendar
  @POST("/App/Calendar/mobile/v1/booking")
  Future<CreateCalendarResponse> createCalendar(
      @Body() CreateCalendarRequest request);

  @DELETE("/App/Calendar/mobile/booking/v1/{id}")
  Future<CommonResponse> deleteCalendar(
    @Path('id') String id,
    @Body() DeleteCalendarRequest request,
  );

  @GET("/App/Calendar/v1")
  Future<CalendarListResponse> getMyCalendar({
    @Query("accountPatientId") String? accountPatientId,
    @Query("fromDate") int? fromDate,
    @Query("toDate") int? toDate,
    @Query("courseId") String? courseId,
    @Query("calendarType") int? calendarType,
    @Query("type") int? type,
  });

  @POST("/App/Calendar/booking-success")
  Future<void> notifyBookingSuccess(@Body() BookingSuccessRequest request);

  @POST("/App/Zoom/BranchioGenerateZoom")
  Future<BranchioGenerateZoomResponse> branchioGenerateZoom(
    @Query("email") String? email,
    @Query("topic") String? topic,
    @Query("date") String? date,
  );

  @GET("App/LearningPost")
  Future<LearningPostListResponse> getBanners(
      {@Query('Position') int? position});

  // Customer Receives
  @PUT("/App/CustomerReceives/interview/{courseId}")
  Future<void> updateDoneInterview(String courseId);

  @GET("/App/Image/Banner/Subscription")
  Future<GetSubscriptionBannersResponse> getSubscriptionBanners();

  @POST("/App/Notification/Subscription")
  Future<CommonResponse> notifySubscription(
      @Query('phoneNumberInput') String? phoneNumberInput,
      @Body() NotifySubscriptionRequest request);

  // ## 1. Lấy Cấu hình Supabase
  @GET('/App/Chat/config/supabase')
  Future<SupabaseConfigResponse> getSupabaseConfig();
  // ## 2. Gửi Câu Hỏi Cho AI
  @GET('/App/Chat/conversations/{conversationId}/messages/{messageId}')
  Future<MessageResponse> sendMessageById(
    @Path('conversationId') String conversationId,
    @Path('messageId') String messageId,
  );
  // ## 3. Tạo Lại Câu Trả Lời AI
  @PUT('/App/Chat/conversations/{conversationId}/messages/regenerate')
  Future<MessageResponse> regenerateMessage(
      @Path('conversationId') String conversationId);
  // Create
  @POST('/App/Chat/conversations')
  Future<CreateConversationResponse> createConversation(
    @Body() CreateConversationRequest request,
  );
  @DELETE('/App/Chat/conversations/{conversationId}')
  Future<CommonResponse> deleteConversation(
    @Path('conversationId') String conversationId,
  );
  //GET {{url}}/app/chat/conversations/me
  @GET('/App/Chat/conversations/me')
  Future<ConversationListResponse> getMyConversation();

  @GET("App/PaymentMethodVnpay")
  Future<GetVnpayTransactionInfoResponse> getPaymentVnpayTransactionInfo(
      {@Query('refCode') String? txnRef});

  // Exercise Endpoints
  @POST("App/Exercise/Input")
  Future<CommonResponse> addExercise(@Body() AddExerciseRequest request);

  @PUT("App/Exercise/Input/{id}")
  Future<CommonResponse> updateExercise(
      @Body() UpdateExerciseRequest request, @Path("id") String id);

  @GET("App/Exercise/Intensity")
  Future<ExerciseIntensityResponse> getExerciseIntensities(
      {@Query("shortname") int shortname = 1});
  @GET("App/Exercise/Category")
  Future<ExerciseCategoryResponse> getExerciseCategories();

  @GET("App/Exercise/Analysis/Index")
  Future<ExerciseAnalysisResponse> getExerciseAnalysis(
      @Query("id") String exerciseId);

  @GET("App/Exercise/Summary")
  Future<ExerciseSummaryResponse> getExerciseSummary(
      @Query("currentDateTime") String currentDateTime);

  @GET('/App/Lesson/Support/Exercise')
  Future<ExerciseLessonResponse> getSupportExercises();

  @GET('/App/Exercise/Analysis/HealthTrend')
  Future<ExerciseHealthTrendResponse> getExerciseHealthTrend(
    @Query('CurrentDateTime') String currentDateTime,
    @Query('PeriodFilterType') int periodFilterType,
  );

  @POST('/App/PackageAccountTransaction/SubscriptionActivePackage')
  Future<CommonResponse> subscriptionActivePackage({
    @Query("accountId") required String accountId,
    @Query("packageId") required String packageId,
  });

  // region weight

  @GET("/App/Weight/GetWeightThreshold")
  Future<GetWeightThresholdResponse> getWeightThreshold({
    @Query("thresholdType") int? thresholdType,
    @Query("date") int? date,
    @Query("height") double? height,
    @Query("weight") double? weight,
    @Query("waist") double? waist,
  });

  @GET("/App/Weight/Analysis/Index")
  Future<BmiGetAnalyzeWeightIndexResponse> analyzeWeightIndex(
    @Query("id") String id,
  );

  @GET("/App/Weight/Analysis/Trend")
  Future<BmiGetAnalyzeWeightTrendResponse> analyzeWeightTrend({
    @Query('currentDateTime') required int currentTime,
    @Query('periodFilterType') required int periodFilterType,
    @Query('page') int? page,
    @Query('size') int? size,
  });

  @GET("/App/Bmi/Calculate-Bmi")
  Future<CalculateBmiResponse> calculateBmi({
    @Query('weight') required double weight,
    @Query('height') required int height,
  });

  @MultiPart()
  @POST("/App/Weight/Input")
  Future<SubmitWeightRecordResponse> submitWeightRecord({
    // @Body() SubmitWeightRecordRequest request,
    @Part(name: "images") List<MultipartFile>? images,
    @Part(name: "date") required int date,
    @Part(name: "weight") required double weight,
    @Part(name: "waist") double? waist,
    @Part(name: "height") required double height,
    @Part(name: "note") String? note,
    @Part(name: "timeFrameValue") int? timeFrameValue,
    @Part(name: "timeFrameId") String? timeFrameId,
    @Part(name: "thresholdType") int? thresholdType,
  });

  @MultiPart()
  @PUT("/App/Weight/Input")
  Future<SubmitWeightRecordResponse> reviseWeightRecord({
    @Part(name: "id") required String id,
    @Part(name: "images") List<MultipartFile>? images,
    @Part(name: "date") required int date,
    @Part(name: "weight") required double weight,
    @Part(name: "waist") double? waist,
    @Part(name: "height") double? height,
    @Part(name: "note") String? note,
    @Part(name: "timeFrameValue") int? timeFrameValue,
    @Part(name: "timeFrameId") String? timeFrameId,
    @Part(name: "thresholdType") int? thresholdType,
    @Part(name: "removalImageIds") List<String>? removalImageIds,
  });

  @DELETE("/App/Weight/Input/{id}")
  Future<DeleteWeightRecordResponse> deleteWeightRecord({
    @Path('id') required String id,
  });

  @GET("/App/Weight/Input")
  Future<BmiGetWeightListResponse> getWeightIndexList({
    @Query('currentDateTime') required int currentTime,
    @Query('periodFilterType') required int periodFilterType,
    @Query('page') int? page,
    @Query('size') int? size,
  });

  @GET("/App/Weight/Input/{id}")
  Future<BmiGetWeightDetailResponse> getWeightDetail(
    @Path("id") String id,
  );

  //

  //

  @GET("/App/Weight/Lessons")
  Future<BmiGetWeightLessonsResponse> getWeightLessons();

  @GET("/App/Lesson/LessonSupport")
  Future<BmiGetWeightLessonsResponse> getWeightLessonsSupport();

  @GET("/App/Weight/Statistic/Bmi")
  Future<BmiStatisticalResponse> getBmiStatisticalData({
    @Query('currentDateTime') required int currentTime,
    @Query('periodFilterType') required int periodFilterType,
    @Query('page') int? page,
    @Query('size') int? size,
    @Query('reverseItems') bool? reverseItems,
    @Query('thresholdType') int? thresholdType,
    @Query('patientId') String? patientId,
    @Query('takeAll') bool? takeAll,
  });

  @GET("/App/Weight/Statistic/Waist")
  Future<BmiWaistStatisticalResponse> getWaistStatisticalData({
    @Query('currentDateTime') required int currentTime,
    @Query('periodFilterType') required int periodFilterType,
    @Query('page') int? page,
    @Query('size') int? size,
    @Query('reverseItems') bool? reverseItems,
    @Query('thresholdType') int? thresholdType,
    @Query('patientId') String? patientId,
    @Query('takeAll') bool? takeAll,
  });

  @GET("/App/Weight/Statistic/Weight")
  Future<BmiWeightStatisticalResponse> getWeightStatisticalData({
    @Query('currentDateTime') required int currentTime,
    @Query('periodFilterType') required int periodFilterType,
    @Query('page') int? page,
    @Query('size') int? size,
    @Query('reverseItems') bool? reverseItems,
    @Query('thresholdType') int? thresholdType,
    @Query('patientId') String? patientId,
    @Query('takeAll') bool? takeAll,
  });

  // end region weight
}
