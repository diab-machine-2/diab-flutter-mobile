import 'package:medical/src/modal/exercrises/exercises_intensity.dart';
import 'package:medical/src/model/request/complete_exercise_request.dart';
import 'package:medical/src/model/request/create_menu_request.dart';
import 'package:medical/src/model/request/exercise_feedback_request.dart';
import 'package:medical/src/model/request/food_change_request.dart';
import 'package:medical/src/model/request/ios_receipt_request.dart';
import 'package:medical/src/model/request/lesson_filter_request.dart';
import 'package:medical/src/model/request/post_survey_request.dart';
import 'package:medical/src/model/request/send_feedback_course_request.dart';
import 'package:medical/src/model/request/send_interest_request.dart';
import 'package:medical/src/model/request/update_lesson_section_request.dart';
import 'package:medical/src/model/response/blood_sugar_template_response.dart';
import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/response/create_menu_response.dart';
import 'package:medical/src/model/response/detail_package_response.dart';
import 'package:medical/src/model/response/detail_survey_response.dart';
import 'package:medical/src/model/response/diabetes_status_response.dart';
import 'package:medical/src/model/response/exercise_movement_response.dart';
import 'package:medical/src/model/response/filter_data_response.dart';
import 'package:medical/src/model/response/food_suggest_response.dart';
import 'package:medical/src/model/response/latest_hba1c_input_response.dart';
import 'package:medical/src/model/response/lesson_section_list_response.dart';
import 'package:medical/src/model/response/list_activity_response.dart';
import 'package:medical/src/model/response/list_package_response.dart';
import 'package:medical/src/model/response/list_roadmap_response.dart';
import 'package:medical/src/model/response/list_transaction_response.dart';
import 'package:medical/src/model/response/menu_response.dart';
import 'package:medical/src/model/response/my_lesson_response.dart';
import 'package:medical/src/model/response/save_survey_result_response.dart';
import 'package:medical/src/model/response/survey_data.dart';
import 'package:medical/src/model/response/tdee_response.dart';
import 'package:medical/src/model/response/upgrade_account_response.dart';
import 'package:medical/src/model/response/user_info_response.dart';
import 'package:medical/src/model/response/week_states_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';

import '../service/app_client.dart';

class AppRepository {
  /**
   * Package flow
   */

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

  /**
   * Blood sugar
   */

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
      if (response.statusCode == 200) {
        return ApiResult.success(data: response);
      } else {
        return const ApiResult.failure(
            error: NetworkExceptions.defaultError("Save schedule failed"));
      }
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  /**
   * Sample menu
   */

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

  /**
   * Food Menu
   */

  Future<ApiResult<MenuResponse>> getUserFoodMenu() async {
    try {
      final MenuResponse response = await appClient.getUserFoodMenu();
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<FoodSuggestResponse>> getSuggestionFood(String id) async {
    try {
      final FoodSuggestResponse response =
          await appClient.getSuggestionFood(id);
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

  /**
   * Quiz
   */

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

  /**
   * Survey
   */

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

  /**
   * Account
   */

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

  /**
   * My Plan
   */
  Future<ApiResult<MyLessonResponse>> getLessonsList(
      LessonFilterRequest request) async {
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

  Future<ApiResult<ListRoadmapResponse>> getRoadMap(
      {required int page, required int size}) async {
    try {
      final ListRoadmapResponse response =
          await appClient.getRoadMap(page, size);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<CommonResponse>> selectRoadmap(String roadmapId) async {
    try {
      final CommonResponse response =
          await appClient.selectRoadmap('"$roadmapId"');
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<ExerciseMovementResponse>> getExerciseMovement(
      {required String roadmapId, required int week}) async {
    try {
      final ExerciseMovementResponse response =
          await appClient.getExerciseMovement(roadmapId: roadmapId, week: week);
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

  Future<ApiResult<WeekStatesResponse>> getExerciseWeekStates(
      {required String roadmapId}) async {
    try {
      final WeekStatesResponse response =
          await appClient.getExerciseWeekStates(roadmapId);
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
}
