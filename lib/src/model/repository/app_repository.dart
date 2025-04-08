import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/exercrises/exercises_intensity.dart';
import 'package:medical/src/model/docosan_api.dart';
import 'package:medical/src/model/request/booking_success_request.dart';
import 'package:medical/src/model/request/complete_exercise_request.dart';
import 'package:medical/src/model/request/complete_smart_goal_request.dart';
import 'package:medical/src/model/request/create_calendar_request.dart';
import 'package:medical/src/model/request/create_dsmes_booking_request.dart';
import 'package:medical/src/model/request/create_menu_request.dart';
import 'package:medical/src/model/request/create_smart_goal_request.dart';
import 'package:medical/src/model/request/delete_calendar_request.dart';
import 'package:medical/src/model/request/dsmes_cancel_booking_request.dart';
import 'package:medical/src/model/request/dsmes_reschedule_request.dart';
import 'package:medical/src/model/request/exercise_feedback_request.dart';
import 'package:medical/src/model/request/food_change_request.dart';
import 'package:medical/src/model/request/get_dsmes_appointment_request.dart';
import 'package:medical/src/model/request/ios_receipt_request.dart';
import 'package:medical/src/model/request/lesson_filter_request.dart';
import 'package:medical/src/model/request/make_comment_request.dart';
import 'package:medical/src/model/request/make_question_request.dart';
import 'package:medical/src/model/request/mark_completed_target_request.dart';
import 'package:medical/src/model/request/mark_share_request.dart';
import 'package:medical/src/model/request/post_survey_request.dart';
import 'package:medical/src/model/request/register_docosan_user_request.dart';
import 'package:medical/src/model/request/send_feedback_course_request.dart';
import 'package:medical/src/model/request/send_interest_request.dart';
import 'package:medical/src/model/request/sync_index_from_zalo_request.dart';
import 'package:medical/src/model/request/update_lesson_section_request.dart';
import 'package:medical/src/model/request/update_quiz_lesson_request.dart';
import 'package:medical/src/model/request/update_shared_profile_request.dart';
import 'package:medical/src/model/request/zoom_token_request.dart';
import 'package:medical/src/model/response/blood_sugar_template_response.dart';
import 'package:medical/src/model/response/branchio_generate_zoom_response.dart';
import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/response/create_calendar_response.dart';
import 'package:medical/src/model/response/create_dsmes_offline_booking_response.dart';
import 'package:medical/src/model/response/create_menu_response.dart';
import 'package:medical/src/model/response/create_smart_goal_response.dart';
import 'package:medical/src/model/response/delete_smart_goal_reponse.dart';
import 'package:medical/src/model/response/detail_package_response.dart';
import 'package:medical/src/model/response/detail_survey_response.dart';
import 'package:medical/src/model/response/diabetes_status_response.dart';
import 'package:medical/src/model/response/dsmes_clinic_detail_response.dart';
import 'package:medical/src/model/response/dsmes_clinic_list_response.dart';
import 'package:medical/src/model/response/dsmes_clinic_rating_response.dart';
import 'package:medical/src/model/response/exercise_movement_response.dart';
import 'package:medical/src/model/response/expert_comment_list_response.dart';
import 'package:medical/src/model/response/filter_data_response.dart';
import 'package:medical/src/model/response/food_suggest_response.dart';
import 'package:medical/src/model/response/get_customer_receives_user_response.dart';
import 'package:medical/src/model/response/get_diab_clinics_schedule_response.dart';
import 'package:medical/src/model/response/get_dsmes_appointment_detail_response.dart';
import 'package:medical/src/model/response/get_dsmes_appointment_response.dart';
import 'package:medical/src/model/response/is_exist_docosan_user_response.dart';
import 'package:medical/src/model/response/latest_hba1c_input_response.dart';
import 'package:medical/src/model/response/learning_post_response.dart';
import 'package:medical/src/model/response/lesson_module_response.dart';
import 'package:medical/src/model/response/lesson_section_list_response.dart';
import 'package:medical/src/model/response/list_activity_response.dart';
import 'package:medical/src/model/response/list_calendart_response.dart';
import 'package:medical/src/model/response/list_package_response.dart';
import 'package:medical/src/model/response/list_roadmap_response.dart';
import 'package:medical/src/model/response/list_transaction_response.dart';
import 'package:medical/src/model/response/menu_response.dart';
import 'package:medical/src/model/response/my_lesson_response.dart';
import 'package:medical/src/model/response/my_progress_response.dart';
import 'package:medical/src/model/response/patient_info_response.dart';
import 'package:medical/src/model/response/question_answer_response.dart';
import 'package:medical/src/model/response/register_docosan_user_response.dart';
import 'package:medical/src/model/response/report_response.dart';
import 'package:medical/src/model/response/save_survey_result_response.dart';
import 'package:medical/src/model/response/smart_goal_detail_response.dart';
import 'package:medical/src/model/response/smart_goal_list_reponse.dart';
import 'package:medical/src/model/response/smart_goal_statistic_response.dart';
import 'package:medical/src/model/response/survey_data.dart';
import 'package:medical/src/model/response/tdee_response.dart';
import 'package:medical/src/model/response/update_shared_profile_response.dart';
import 'package:medical/src/model/response/upgrade_account_response.dart';
import 'package:medical/src/model/response/user_info_referral_code_response.dart';
import 'package:medical/src/model/response/user_info_response.dart';
import 'package:medical/src/model/response/week_states_response.dart';
import 'package:medical/src/model/response/zoom_token_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/docosan_client.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/calendar/calendar_model.dart';

import '../app_api.dart';
import '../request/SelectRoadmapRequest.dart';
import '../request/complete_video_request.dart';
import '../response/app_version_response.dart';
import '../response/calendar_training_response.dart';
import '../response/content_welcome_response.dart';
import '../response/expert_comment_response.dart';
import '../service/app_client.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

late AppApi appClient;
late DocosanApi docosanClient;

class AppRepository {
  /// Package flow

  Future<ApiResult<ListPackageResponse>> getListPackage() async {
    try {
      final ListPackageResponse response = await appClient.getListPackage();
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<DetailPackageResponse>> getDetailPackage(String type) async {
    try {
      final DetailPackageResponse response =
          await appClient.getDetailPackage(type);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<UpgradeAccountResponse>> getUpgradeAccount() async {
    try {
      final UpgradeAccountResponse response =
          await appClient.getUpgradeAccount();
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<CommonResponse>> sendInterestFeedback(
      SendInterestRequest request) async {
    try {
      final CommonResponse response =
          await appClient.sendInterestFeedback(request);
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

  Future<ApiResult<ListTransactionResponse>> getListTransaction(
      {bool? isExpired, int? page, int? size}) async {
    try {
      final ListTransactionResponse response =
          await appClient.getListTransaction(isExpired, page, size);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<dynamic>> verifyReceipt({required String? receipt}) async {
    try {
      final IosReceiptRequest request = IosReceiptRequest(
        receipt: receipt,
      );
      final dynamic response = await appClient.verifyReceipt(request);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  /// Blood sugar

  Future<ApiResult<BloodSugarTemplateResponse>> getTemplateDetail(
      String code) async {
    try {
      final BloodSugarTemplateResponse response =
          await appClient.getTemplateDetail(code);
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

  Future<ApiResult<SaveSurveyResultResponse>> saveSurveyResult(
      String templateId) async {
    try {
      final SaveSurveyResultResponse response =
          await appClient.saveSurveyResult(templateId);
      //  if (response.statusCode == 200) {
      return ApiResult.success(data: response);
      //  } else {
      //    return const ApiResult.failure(error: NetworkExceptions.defaultError("Save schedule failed"));
      //  }
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  /// Sample menu

  Future<ApiResult<List<ExerciseIntensityModel>>> getListActivity() async {
    try {
      final ListActivityResponse response = await appClient.getListActivity();
      return ApiResult.success(data: response.data ?? []);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<TDEEResponse>> getTDEE(
      {int? weight,
      int? height,
      int? yearOfBirth,
      String? activityLevelId}) async {
    try {
      final TDEEResponse response =
          await appClient.getTDEE(activityLevelId, weight, height, yearOfBirth);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  /// Food Menu

  Future<ApiResult<MenuResponse>> getUserFoodMenu() async {
    try {
      final MenuResponse response = await appClient.getUserFoodMenu();
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<List<AppVersionResponse>>> getAppVersion() async {
    appClient = AppClient().appClient;
    docosanClient = DocosanClient().docosanClient;
    try {
      final List<AppVersionResponse> response = await appClient.getAppVersion();
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<FoodSuggestResponse>> getSuggestionFood({
    required String foodMenuCode,
    required String foodId,
    required String dateCode,
    required int timeCode,
    required bool isUseReplacedFood,
  }) async {
    try {
      final FoodSuggestResponse response = await appClient.getSuggestionFood(
        foodMenuCode: foodMenuCode,
        foodId: foodId,
        dateCode: dateCode,
        timeCode: timeCode,
        isUseReplacedFood: isUseReplacedFood,
      );
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<CommonResponse>> changeFood(
      FoodChangeRequest request) async {
    try {
      final CommonResponse response = await appClient.changeFood(request);
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

  Future<ApiResult<CreateMenuResponse>> createMenu(
      CreateMenuRequest request) async {
    try {
      final CreateMenuResponse response = await appClient.createMenu(request);
      if (response.statusCode == 200) {
        return ApiResult.success(data: response);
      } else
        return ApiResult.failure(
            error: NetworkExceptions.defaultError(response.message ?? ''));
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  /// Zoom
  // get zoom token
  Future<ApiResult<ZoomTokenResponse>> getZoomToken(
      {required String roomId, required String displayName}) async {
    try {
      ZoomTokenRequest request = ZoomTokenRequest(
        roomId: roomId,
        displayName: displayName,
      );
      final ZoomTokenResponse response = await appClient.getZoomToken(request);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  /// Quiz

  Future<ApiResult<LessonSectionListResponse?>> getListQuiz(
      String lessonId) async {
    try {
      final LessonSectionListResponse response =
          await appClient.getListQuiz(lessonId);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<CommonResponse>> sendFeedbackCourse(
      String lessonId, SendFeedbackCourseRequest request) async {
    try {
      final CommonResponse response =
          await appClient.sendFeedbackCourse(lessonId, request);
      if (response.meta?.success == true) {
        return ApiResult.success(data: response);
      } else
        return ApiResult.failure(
            error: NetworkExceptions.defaultError(response.message ?? ''));
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  /// Survey

  Future<ApiResult<SurveyData>> getDetailSurvey(String surveyId) async {
    try {
      final DetailSurveyResponse response =
          await appClient.getDetailSurvey(surveyId);
      if (response.data != null) {
        return ApiResult.success(data: response.data!);
      } else {
        return const ApiResult.failure(
            error: NetworkExceptions.defaultError("Survey data not found"));
      }
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<CommonResponse>> submitSurvey(
      PostSurveyRequest request) async {
    try {
      final CommonResponse response = await appClient.submitSurvey(request);
      if (response.meta?.success == true) {
        return ApiResult.success(data: response);
      } else
        return ApiResult.failure(
            error: NetworkExceptions.defaultError(response.message ?? ''));
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  /// Account

  Future<ApiResult<UserInfoResponse>> getCurrentUserInfo() async {
    try {
      final UserInfoResponse response = await appClient.getCurrentUserInfo();
      if (response.data != null) {
        return ApiResult.success(data: response);
      } else
        return const ApiResult.failure(
            error: NetworkExceptions.defaultError("Can't not get UserInfo"));
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  void syncIndexFromZaloToPhone(String accountPhone, String accountZalo) {
    try {
      appClient.syncIndexFromZaloToPhone(SyncIndexFromZaloToPhoneRequest(
          accountPhone: accountPhone, accountZalo: accountZalo));
    } catch (e) {
      print("SyncIndexFromZaloToPhone exception: $e");
    }
  }

  /// My Plan
  Future<ApiResult<MyLessonResponse>> getLessonsList(
      LessonFilterRequest request) async {
    appClient = AppClient().appClient;
    try {
      final MyLessonResponse response = await appClient.getLessonsList(request);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<FilterDataResponse>> getFilterData() async {
    try {
      final FilterDataResponse response = await appClient.getFilterData();
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<LessonSectionListResponse>> getListLessonSection(
      String lessonId) async {
    try {
      final LessonSectionListResponse response =
          await appClient.getListLessonSection(lessonId);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<CommonResponse>> setCompletedLessonAccount(
      UpdateLessonSectionRequest request) async {
    try {
      final CommonResponse response =
          await appClient.setCompletedLessonAccount(request);
      if (response.meta?.success == true) {
        return ApiResult.success(data: response);
      } else
        return ApiResult.failure(
            error: NetworkExceptions.defaultError(response.message ?? ''));
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<CommonResponse>> setCompletedLessonQuiz(
      UpdateQuizLessonRequest request) async {
    try {
      final CommonResponse response =
          await appClient.setCompletedLessonQuiz(request);
      if (response.meta?.success == true) {
        return ApiResult.success(data: response);
      } else
        return ApiResult.failure(
            error: NetworkExceptions.defaultError(response.message ?? ''));
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  //Exercise

  Future<ApiResult<ListRoadmapResponse>> getRoadMap() async {
    try {
      final ListRoadmapResponse response = await appClient.getRoadMap();
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<CommonResponse>> selectRoadmap(
      SelectRoadmapRequest request) async {
    try {
      final CommonResponse response = await appClient.selectRoadmap(request);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<ExerciseMovementResponse>> getExerciseMovement(
      {int? week}) async {
    try {
      final ExerciseMovementResponse response =
          await appClient.getExerciseMovement(week);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<ContentWelcomeResponse>> getContentWelcome(
      String accountId) async {
    try {
      final ContentWelcomeResponse response =
          await appClient.getContentWelcome(accountId);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<CommonResponse>> exerciseFeedback(
      ExerciseFeedbackRequest request) async {
    try {
      final CommonResponse response = await appClient.exerciseFeedback(request);
      if (response.meta?.success == true) {
        return ApiResult.success(data: response);
      } else {
        return ApiResult.failure(
            error: NetworkExceptions.defaultError(response.message ?? ''));
      }
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<CommonResponse>> completeExercise(
      CompleteExerciseRequest request) async {
    try {
      final CommonResponse response = await appClient.completeExercise(request);
      if (response.meta?.success == true) {
        return ApiResult.success(data: response);
      } else {
        return ApiResult.failure(
            error: NetworkExceptions.defaultError(response.message ?? ''));
      }
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<CommonResponse>> completeVideo(
      CompleteVideoRequest request) async {
    try {
      final CommonResponse response = await appClient.completeVideo(request);
      if (response.meta?.success == true) {
        return ApiResult.success(data: response);
      } else {
        return ApiResult.failure(
            error: NetworkExceptions.defaultError(response.message ?? ''));
      }
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<WeekStatesResponse>> getExerciseWeekStates() async {
    try {
      final WeekStatesResponse response =
          await appClient.getExerciseWeekStates();
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<WeekStatesResponse>> getLessonWeekStates() async {
    try {
      final WeekStatesResponse response = await appClient.getLessonWeekStates();
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<ReportListResponse>> getReports() async {
    try {
      final ReportListResponse response = await appClient.getReports();
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  //Activity
  Future<ApiResult<CreateSmartGoalResponse>> createSmartGoal(
      CreateSmartGoalRequest request) async {
    try {
      final CreateSmartGoalResponse response =
          await appClient.createSmartGoal(request);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<CommonResponse>> completeSmartGoal(
      CompleteSmartGoalRequest request) async {
    try {
      final CommonResponse response =
          await appClient.completeSmartGoal(request);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<CommonResponse>> markCompletedUpdateProfile(
      String id) async {
    try {
      final CommonResponse response =
          await appClient.markCompletedUpdateProfile(id);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<CommonResponse>> completeGoal(
      MarkCompletedTargetRequest request) async {
    try {
      final CommonResponse response = await appClient.completeGoal(request);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<CommonResponse>> markCompletedCalendar(String id) async {
    try {
      final CommonResponse response = await appClient.markCompletedCalendar(id);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<CommonResponse>> markIsShare(
      MarkShareRequest request) async {
    try {
      final CommonResponse response = await appClient.markIsShare(request);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<CommonResponse>> markDisplayedWelcome() async {
    try {
      final CommonResponse response = await appClient.markDisplayedWelcome();
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<CommonResponse>> makeQuestion(
      MakeQuestionRequest request) async {
    try {
      final CommonResponse response = await appClient.makeQuestion(request);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<CommonResponse>> makeComment(
      MakeCommentRequest request) async {
    try {
      final CommonResponse response = await appClient.makeComment(request);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<CommonResponse>> deleteQuestion(String id) async {
    try {
      final CommonResponse response = await appClient.deleteQuestion(id);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<CommonResponse>> deleteComment(String id) async {
    try {
      final CommonResponse response = await appClient.deleteComment(id);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<SmartGoalListReponse>> getListSmartGoal({
    int? week,
    int? day,
  }) async {
    try {
      appClient = AppClient().appClient;
      final SmartGoalListReponse response =
          await appClient.getListSmartGoal(week: week, day: day);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<QuestionAnswerResponse>> getListQuestion(
      {int page = 1,
      int size = 20,
      List<String>? lessonModuleIds,
      List<String>? accountIds}) async {
    try {
      final QuestionAnswerResponse response = await appClient.getListQuestion(
          page, size, lessonModuleIds, accountIds);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<QuestionResponse>> getQuestionById(String id) async {
    try {
      final QuestionResponse response = await appClient.getQuestionById(id);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<LessonModuleResponse>> getListLessonModule() async {
    try {
      final LessonModuleResponse response =
          await appClient.getListLessonModule(1, 300);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<SmartGoalDetailResponse>> getSmartGoalDetail(
      {required String id}) async {
    try {
      final SmartGoalDetailResponse response =
          await appClient.getSmartGoalDetail(id);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<SmartGoalStatisticResponse>> getSmartGoalStatistics(
      {int? day, int? week}) async {
    try {
      final SmartGoalStatisticResponse response =
          await appClient.getSmartGoalStatistics(day: day, week: week);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<DeleteSmartGoalReponse>> deleteSmartGoal(String id) async {
    try {
      final DeleteSmartGoalReponse response =
          await appClient.deleteSmartGoal(id);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  // My Progress
  Future<ApiResult<MyProgressResponse>> getMyProgress({int? type}) async {
    try {
      final MyProgressResponse response =
          await appClient.getMyProgress(type: type);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<ExpertCommentListResponse>> getCommentProfessorByAccountId(
      String accountId) async {
    try {
      final ExpertCommentListResponse response =
          await appClient.getCommentProfessorByAccountId(accountId);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<ExpertCommentResponse>> getCommentById(String id) async {
    try {
      final ExpertCommentResponse response = await appClient.getCommentById(id);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<CalendarTrainingListResponse>> getCalendarTraining(
      String calendarId) async {
    try {
      final CalendarTrainingListResponse response =
          await appClient.getCalendarTraining(calendarId);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  //Referral, Share Profile
  Future<ApiResult<PatientInfoResponse>> getSharedProfile() async {
    try {
      final PatientInfoResponse response = await appClient.getSharedProfile();
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<UpdateSharedProfileResponse>> updateSharedProfile(
      UpdateSharedProfileRequest request) async {
    try {
      final UpdateSharedProfileResponse response =
          await appClient.updateSharedProfile(request);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<UpdateSharedProfileResponse>> hasSharedProfile(
      String code) async {
    try {
      final UpdateSharedProfileResponse response =
          await appClient.hasSharedProfile(code);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<UserInfoReferralCodeResponse>> getUserFromReferralCode(
      String referalCode) async {
    try {
      final UserInfoReferralCodeResponse response =
          await appClient.getUserFromReferralCode(referalCode);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  // Calendar
  Future<ApiResult<CreateCalendarResponse>> createCalendar(
      CreateCalendarRequest request) async {
    try {
      final CreateCalendarResponse response =
          await appClient.createCalendar(request);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<CommonResponse>> deleteCalendar(
      String id, DeleteCalendarRequest request) async {
    try {
      final response = await appClient.deleteCalendar(id, request);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<List<CreateCalendarResponse>>> getMyCalendar(
      CalendarFilter request) async {
    try {
      final fromDate = request.fromDate.millisecondsSinceEpoch ~/ 1000;
      final toDate = request.toDate.millisecondsSinceEpoch ~/ 1000;
      final CalendarListResponse response = await appClient.getMyCalendar(
        accountPatientId: request.accountPatientId,
        fromDate: fromDate,
        toDate: toDate,
        courseId: request.courseId,
        calendarType: request.calendarType,
      );
      return ApiResult.success(data: response.data ?? []);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<CommonResponse>> notifyBookingSuccess(
      BookingSuccessRequest request) async {
    try {
      await appClient.notifyBookingSuccess(request);
      return ApiResult.success(data: CommonResponse(statusCode: 200));
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<BranchioGenerateZoomResponse>> branchioGenerateZoom(
      {String? email, String? topic, String? date}) async {
    try {
      final BranchioGenerateZoomResponse response =
          await appClient.branchioGenerateZoom(email, topic, date);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<LearningPostListResponse>> getBanners(
      {int position = 9}) async {
    try {
      final LearningPostListResponse response =
          await appClient.getBanners(position: position);

      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  // Customer Receives

  Future<ApiResult<CommonResponse>> updateDoneInterview(String id) async {
    try {
      await appClient.updateDoneInterview(id);
      return ApiResult.success(data: CommonResponse(statusCode: 200));
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  // Dsmes booking center
  Future<ApiResult<GetDsmesAppointmentResponse>> getDsmesAppointmentList(
      {int page = 1}) async {
    try {
      final response = await docosanClient.getListDsmesAppointment(page);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<GetDsmesAppointmentDetailResponse>>
      getDsmesAppointmentDetail({required int appointmentId}) async {
    try {
      final response =
          await docosanClient.getDsmesAppointmentDetail(appointmentId);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<DsmesClinicDetailResponse>> getClinicDetail(
      {required int id}) async {
    try {
      final response = await docosanClient.getClinicDetail(id);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<DsmesClinicListResponse>> getClinicList({String? type}) async {
    try {
      final response = await docosanClient.getClinicList(type);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<bool> isExistDocosanUser({String? phoneNumber}) async {
    if (phoneNumber == null) {
      return false;
    }
    http.Response response = await http.get(
      Uri.parse(
        "${Utils.getHostDocosanUrl()}api/is-exist-user?phone_number=$phoneNumber",
      ),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'User-Agent': 'Mobile',
        'x-api-key': Const.ORGANIZATION_API_KEY_VALUE,
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> dataJson = json.decode(response.body);
      final data = IsExistDocosanUserResponse.fromJson(dataJson['data']);
      return data.isExists;
    }
    return false;
  }

  Future<RegisterDocosanUserResponse?> registerDocosanUser(
      {required RegisterDocosanUserRequest request}) async {
    http.Response response = await http.post(
      Uri.parse(
        "${Utils.getHostDocosanUrl()}api/register-internal",
      ),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'User-Agent': 'Mobile',
        'x-api-key': Const.ORGANIZATION_API_KEY_VALUE,
      },
      body: request.toJson(),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> dataJson = json.decode(response.body);
      final resp = RegisterDocosanUserResponse.fromJson(dataJson);
      await AppSettings.saveDocosanToken(resp.data.accessToken);
      docosanClient = DocosanClient().docosanClient;
      return resp;
    }
    return null;
  }

  Future<ApiResult<CreateDsmesOfflineBookingResponse>>
      createDsmesOfflineBooking(
          {required CreateDsmesBookingRequest request}) async {
    try {
      final response = await docosanClient.createDsmesOfflineBooking(request);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<CreateDsmesOfflineBookingResponse>> createDsmesOnlineBooking(
      {required CreateDsmesBookingRequest request}) async {
    try {
      final response = await docosanClient.createDsmesOnlineBooking(request);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<CommonResponse>> cancelDsmesBooking(
      {required DsmesCancelBookingRequest request}) async {
    try {
      final response = await docosanClient.cancelDsmesAppointment(request);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<CreateDsmesOfflineBookingResponse>> rescheduleDsmesBooking(
      {required RescheduleDsmesBookingRequest request}) async {
    try {
      final response = await docosanClient.rescheduleDsmesAppointment(request);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<DsmesClinicRatingResponse>> getClinicRate(
      {required int id}) async {
    try {
      final response = await docosanClient.getClinicRate(id);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<GetDiabClinicsScheduleResponse>>
      getDiabClinicsSchedule() async {
    try {
      final response = await docosanClient.getDiabClinicsSchedule();
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<GetCustomerReceivesUserResponse>> getCustomerReceivesUser(
      String phoneNumber) async {
    try {
      final GetCustomerReceivesUserResponse response =
          await appClient.getCustomerReceivesUser(phoneNumber);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }
}
