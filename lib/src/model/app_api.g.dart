// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_api.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _AppApi implements AppApi {
  _AppApi(this._dio, {this.baseUrl});

  final Dio _dio;

  String? baseUrl;

  @override
  Future<ListPackageResponse> getListPackage() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<ListPackageResponse>(
            Options(method: 'GET', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options, 'App/Package',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = ListPackageResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<DetailPackageResponse> getDetailPackage(code) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<DetailPackageResponse>(
            Options(method: 'GET', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options, 'App/Package/$code',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = DetailPackageResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<UpgradeAccountResponse> getUpgradeAccount() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<UpgradeAccountResponse>(
            Options(method: 'GET', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options, 'App/Feature/GetPackageComparison',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = UpgradeAccountResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<CommonResponse> sendInterestFeedback(request) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<CommonResponse>(
            Options(method: 'POST', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options, 'App/PackageInterest/Input',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = CommonResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<ListTransactionResponse> getListTransaction(
      isExpired, page, size) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'isExpired': isExpired,
      r'page': page,
      r'size': size
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<ListTransactionResponse>(
            Options(method: 'GET', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options, 'App/PackageTransaction',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = ListTransactionResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<dynamic> verifyReceipt(request) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _result = await _dio.fetch(_setStreamType<dynamic>(
        Options(method: 'POST', headers: <String, dynamic>{}, extra: _extra)
            .compose(_dio.options, 'App/Payment/VerifyApplePayment',
                queryParameters: queryParameters, data: _data)
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    return value;
  }

  @override
  Future<DiabetesStatusResponse> getDiabetesStatus() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<DiabetesStatusResponse>(
            Options(method: 'GET', headers: <String, dynamic>{}, extra: _extra)
                .compose(
                    _dio.options, '/App/DiabetesStatus/GetOwnDiabetesStatus',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = DiabetesStatusResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<LatestHba1cInputResponse> getLatestHbA1CInput() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<LatestHba1cInputResponse>(
            Options(method: 'GET', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options, '/App/HbA1C/LatestHbA1CInput',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = LatestHba1cInputResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<BloodSugarTemplateResponse> getTemplateDetail(code) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<BloodSugarTemplateResponse>(
            Options(method: 'GET', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options, '/App/BloodSugarTemplate/$code',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = BloodSugarTemplateResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<SaveSurveyResultResponse> saveSurveyResult(templateId) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<SaveSurveyResultResponse>(Options(
                method: 'PUT', headers: <String, dynamic>{}, extra: _extra)
            .compose(
                _dio.options, 'App/Patient/SaveBloodSugarTemplate/$templateId',
                queryParameters: queryParameters, data: _data)
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = SaveSurveyResultResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<ListActivityResponse> getListActivity() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<ListActivityResponse>(
            Options(method: 'GET', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options, 'App/ActivityLevel',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = ListActivityResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<TDEEResponse> getTDEE(
      activityLevelId, weight, height, yearOfBirth) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'activityLevelId': activityLevelId,
      r'weight': weight,
      r'height': height,
      r'yearOfBirth': yearOfBirth
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<TDEEResponse>(
            Options(method: 'GET', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options, 'App/Diet/TDEE',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = TDEEResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<MenuResponse> getUserFoodMenu() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<MenuResponse>(
            Options(method: 'GET', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options, 'App/PatientFoodMenu/GetUserFoodMenu',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = MenuResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<FoodSuggestResponse> getSuggestionFood(id) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<FoodSuggestResponse>(
            Options(method: 'GET', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options, 'App/PatientFoodMenu/SuggestionFood/$id',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = FoodSuggestResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<CommonResponse> changeFood(request) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<CommonResponse>(
            Options(method: 'PUT', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options, 'App/PatientFoodMenu/Input',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = CommonResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<CreateMenuResponse> createMenu(request) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<CreateMenuResponse>(
            Options(method: 'POST', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options, 'App/PatientFoodMenu/Input',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = CreateMenuResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<DetailSurveyResponse> getDetailSurvey(surveyId) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<DetailSurveyResponse>(
            Options(method: 'GET', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options, 'App/Survey/$surveyId',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = DetailSurveyResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<CommonResponse> submitSurvey(request) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<CommonResponse>(
            Options(method: 'POST', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options, 'App/SurveyResult',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = CommonResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<UserInfoResponse> getCurrentUserInfo() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<UserInfoResponse>(
            Options(method: 'GET', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options, 'App/Account/GetCurrentUserInfo',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = UserInfoResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<MyLessonResponse> getLessonsList(type) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'type': type};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<MyLessonResponse>(
            Options(method: 'GET', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options, 'App/Lesson/MyLessons',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = MyLessonResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<LessonSectionListResponse> getListLessonSection(lessonId) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<LessonSectionListResponse>(
            Options(method: 'GET', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options, 'App/Lesson/$lessonId',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = LessonSectionListResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<CommonResponse> setCompletedLessonAccount(request) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<CommonResponse>(
            Options(method: 'POST', headers: <String, dynamic>{}, extra: _extra)
                .compose(
                    _dio.options, 'App/LessonSection/SetCompletedLessonAccount',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = CommonResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<ListRoadmapResponse> getRoadMap(page, size) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'page': page, r'size': size};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<ListRoadmapResponse>(
            Options(method: 'GET', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options, 'App/Roadmap',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = ListRoadmapResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<ExerciseMovementResponse> getExerciseMovement() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<ExerciseMovementResponse>(
            Options(method: 'GET', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options, 'App/ExerciseMovement/All',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = ExerciseMovementResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<CommonResponse> exerciseFeedback(request) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<CommonResponse>(
            Options(method: 'POST', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options, 'App/ExerciseMovementReview',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = CommonResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<CommonResponse> sendFeedbackCourse(lessonId, request) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<CommonResponse>(
            Options(method: 'POST', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options, 'App/Lesson/$lessonId/Review',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = CommonResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<LessonSectionListResponse> getListQuiz(lessonId) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    // final _result = await _dio.fetch<Map<String, dynamic>>(
    //     _setStreamType<LessonSectionListResponse>(
    //         Options(method: 'GET', headers: <String, dynamic>{}, extra: _extra)
    //             .compose(_dio.options, 'App/Lesson/$lessonId/LessonQuizDetail',
    //                 queryParameters: queryParameters, data: _data)
    //             .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
                final data = {
  "meta": {
    "success": true
  },
  "data": {
    "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "code": "string",
    "name": "string",
    "description": "string",
    "status": 0,
    "type": 1,
    "order": 0,
    "isEnabledRating": true,
    "minCompletePercent": 0,
    "coverId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "lessonModuleId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "lessonLevelId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "lessonModule": {
      "id": "string",
      "code": "string",
      "name": "string",
      "updateDate": "string",
      "updaterName": "string",
      "updaterUsername": "string",
      "updaterCode": "string",
      "updaterImage": {
        "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "url": "string"
      }
    },
    "lessonLevel": {
      "id": "string",
      "code": "string",
      "name": "string",
      "order": 0,
      "updateDate": "string",
      "updaterName": "string",
      "updaterUsername": "string",
      "updaterCode": "string",
      "updaterImage": {
        "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "url": "string"
      }
    },
    "quizLessons": [
      {
        "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "code": "string",
        "quizId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "lessonId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "quiz": {
          "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
          "code": "string",
          "name": "string",
          "status": 0,
          "type": 0,
          "lessonLevel": "string",
          "lesson": "string",
          "quizAnswers": [
            {
              "name": "string",
              "isCorrect": true,
              "order": 0,
              "quizId": "3fa85f64-5717-4562-b3fc-2c963f66afa6"
            }
          ]
        }
      }
    ],
    "lessonTagMappings": [
      {
        "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "lessonId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "lessonTagId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "tag": {
          "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
          "name": "string",
          "type": 1
        }
      }
    ],
    "lessonSections": [
      {
        "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "code": "string",
        "lessonId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "name": "string",
        "type": 1,
        "status": 0,
        "firstContent": "string",
        "secondContent": "string",
        "imageId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "videoAddressLink": "string",
        "videoDescription": "string",
        "audioAddressLink": "string",
        "audioDescription": "string",
        "order": 0,
        "quizLessonSections": [
          {
            "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
            "quizId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
            "lessonSectionId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
            "quiz": {
              "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
              "code": "string",
              "name": "string",
              "status": 0,
              "type": 0,
              "lessonLevel": "string",
              "lesson": "string",
              "quizAnswers": [
                {
                  "name": "answer 1",
                  "isCorrect": true,
                  "order": 0,
                  "quizId": "3fa85f64-5717-4562-b3fc-2c963f66afa6"
                },
                {
                  "name": "answer 2",
                  "isCorrect": false,
                  "order": 1,
                  "quizId": "3fa85f64-5717-4562-b3fc-2c963f66afa6"
                },
                {
                  "name": "answer 3",
                  "isCorrect": true,
                  "order": 3,
                  "quizId": "3fa85f64-5717-4562-b3fc-2c963f66afa6"
                },
                {
                  "name": "answer 4",
                  "isCorrect": false,
                  "order": 2,
                  "quizId": "3fa85f64-5717-4562-b3fc-2c963f66afa6"
                }
              ]
            }
          },
          {
            "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
            "quizId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
            "lessonSectionId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
            "quiz": {
              "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
              "code": "string",
              "name": "string",
              "status": 0,
              "type": 1,
              "lessonLevel": "string",
              "lesson": "string",
              "quizAnswers": [
                {
                  "name": "Answer 1",
                  "isCorrect": true,
                  "order": 0,
                  "quizId": "3fa85f64-5717-4562-b3fc-2c963f66afa6"
                },
                {
                  "name": "Answer 2",
                  "isCorrect": false,
                  "order": 1,
                  "quizId": "3fa85f64-5717-4562-b3fc-2c963f66afa7"
                },
                {
                  "name": "Answer 3",
                  "isCorrect": false,
                  "order": 7,
                  "quizId": "3fa85f64-5717-4562-b3fc-2c963f66afa8"
                },
                {
                  "name": "Answer 4",
                  "isCorrect": false,
                  "order": 2,
                  "quizId": "3fa85f64-5717-4562-b3fc-2c963f66afa9"
                }
              ]
            }
          },
          {
            "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
            "quizId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
            "lessonSectionId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
            "quiz": {
              "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
              "code": "string",
              "name": "string",
              "status": 0,
              "type": 0,
              "lessonLevel": "string",
              "lesson": "string",
              "quizAnswers": [
                {
                  "name": "string",
                  "isCorrect": true,
                  "order": 0,
                  "quizId": "3fa85f64-5717-4562-b3fc-2c963f66afa6"
                }
              ]
            }
          },
          {
            "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
            "quizId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
            "lessonSectionId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
            "quiz": {
              "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
              "code": "string",
              "name": "string",
              "status": 0,
              "type": 0,
              "lessonLevel": "string",
              "lesson": "string",
              "quizAnswers": [
                {
                  "name": "string",
                  "isCorrect": true,
                  "order": 0,
                  "quizId": "3fa85f64-5717-4562-b3fc-2c963f66afa6"
                }
              ]
            }
          },
          {
            "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
            "quizId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
            "lessonSectionId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
            "quiz": {
              "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
              "code": "string",
              "name": "string",
              "status": 0,
              "type": 0,
              "lessonLevel": "string",
              "lesson": "string",
              "quizAnswers": [
                {
                  "name": "string",
                  "isCorrect": true,
                  "order": 0,
                  "quizId": "3fa85f64-5717-4562-b3fc-2c963f66afa6"
                }
              ]
            }
          }
        ],
        "lessonSectionLinks": [
          {
            "id": "string",
            "type": 1,
            "url": "string"
          }
        ],
        "lessonAccounts": [
          {
            "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
            "code": "string",
            "accountId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
            "lessonId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
            "lessonType": 1,
            "lessonSectionId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
            "isComplete": true
          }
        ],
        "isComplete": true,
        "lessonSectionStates": [
          {
            "disabled": true,
            "group": {
              "disabled": true,
              "name": "string"
            },
            "selected": true,
            "text": "string",
            "value": "string"
          }
        ],
        "lessonSectionTypes": [
          {
            "disabled": true,
            "group": {
              "disabled": true,
              "name": "string"
            },
            "selected": true,
            "text": "string",
            "value": "string"
          }
        ],
        "image": {
          "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
          "url": "string"
        }
      }
    ],
    "lessonReviews": [
      {
        "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "lessonId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "accountId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "rating": 1,
        "note": "string"
      }
    ],
    "lessonStates": [
      {
        "disabled": true,
        "group": {
          "disabled": true,
          "name": "string"
        },
        "selected": true,
        "text": "string",
        "value": "string"
      }
    ],
    "lessonModules": [
      {
        "disabled": true,
        "group": {
          "disabled": true,
          "name": "string"
        },
        "selected": true,
        "text": "string",
        "value": "string"
      }
    ],
    "lessonTypes": [
      {
        "disabled": true,
        "group": {
          "disabled": true,
          "name": "string"
        },
        "selected": true,
        "text": "string",
        "value": "string"
      }
    ],
    "lessonLevels": [
      {
        "disabled": true,
        "group": {
          "disabled": true,
          "name": "string"
        },
        "selected": true,
        "text": "string",
        "value": "string"
      }
    ],
    "lessonTags": [
      {
        "disabled": true,
        "group": {
          "disabled": true,
          "name": "string"
        },
        "selected": true,
        "text": "string",
        "value": "string"
      }
    ],
    "image": {
      "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "url": "string"
    }
  }
};
    final value = LessonSectionListResponse.fromJson(data);
    return value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }
}
