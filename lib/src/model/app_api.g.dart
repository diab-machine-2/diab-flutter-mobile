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
  Future<CommonResponse> sendFeedbackCourse(request) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<CommonResponse>(
            Options(method: 'POST', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options, 'App/Lesson/InsertLessonReview',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = CommonResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<ListQuizLessonResponse> getListQuiz(lessonId) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<ListQuizLessonResponse>(
            Options(method: 'GET', headers: <String, dynamic>{}, extra: _extra)
                .compose(
                    _dio.options, 'App/Lesson/GetLessonQuizDetail/$lessonId',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = ListQuizLessonResponse.fromJson(_result.data!);
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
                .compose(
                    _dio.options, 'App/Lesson/GetListLessonSection/$lessonId',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
                final data = {
"meta": {
    "success": true
  },
  "data": {
"review": {
    "rating": 1,
    "note": "string"
  },
  "sections" : [
    {
      "id": "189c0f00-6a05-44e0-cc49-08d98d956006",
      "name": "Khóa h?c dinh du?ng",
      "type": 1,
      "content": """
      Người bệnh tiểu đường cần biết mình nên bổ sung thực phẩm như thế nào cho phù hợp, nên ăn gì và không nên ăn gì. Theo đó, những thực phẩm người bệnh tiểu đường nên ăn bao gồm:

Nhóm đường bột: Ngũ cốc nguyên hạt, đậu đỗ, gạo còn vỏ cám, rau củ... được chế biến bằng cách hấp, luộc, nướng, hạn chế tối đa rán, xào... Các loại củ như khoai sắn cũng cung cấp khá nhiều tinh bột, nên nếu người bệnh tiểu đường ăn các loại này thì cần phải giảm hoặc cắt cơm.""",
      "quizzes": [],
      "links": [
        {
          "id": "21623041-88f2-4a5f-ab28-08d98d5a695e",
          "type": 1,
          "url": "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
        },
        {
          "id": "66133f40-0d7e-45f2-ab29-08d98d5a695e",
          "type": 1,
          "url": "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4"
        }
      ],
      "isComplete": true
    },
    {
      "id": "1bb86ddb-22cd-4a70-b510-08d98f899372",
      "name": "H?c ph?n abc",
      "type": 2,
      "content": "Mô t? test",
      "quizzes": [],
      "links": [
        {
          "id": "21623041-88f2-4a5f-ab28-08d98d5a695e",
          "type": 1,
          "url": "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"
        },
        {
          "id": "66133f40-0d7e-45f2-ab29-08d98d5a695e",
          "type": 1,
          "url": "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4"
        }
      ],
      "isComplete": true
    },
    {
      "id": "fb3e093b-96e8-4bfd-cc4a-08d98d956006",
      "name": "Khóa h?c dinh du?ng",
      "type": 3,
      "content": "Mô t? test",
      "quizzes": [
        {
          "name": "tên quiz ediited",
          "type": 1,
          "explain": "Gi?i thích edited",
          "answers": [
            {
              "id": "00f2200c-60ef-4cdf-01b4-08d98d6c681f",
              "name": "câu tr? l?i s?a - 2",
              "order": 0,
              "isCorrect": false
            },
            {
              "id": "6ce36123-06d2-4c89-01b5-08d98d6c681f",
              "name": "câu tr? l?i s?a - 3",
              "order": 0,
              "isCorrect": false
            },
            {
              "id": "c4c22a56-aff8-4205-01b3-08d98d6c681f",
              "name": "câu tr? l?i s?a - 1",
              "order": 0,
              "isCorrect": true
            },
            {
              "id": "f9cc61ea-514e-47ca-01b6-08d98d6c681f",
              "name": "câu tr? l?i s?a - 4",
              "order": 0,
              "isCorrect": false
            }
          ]
        },
        {
          "name": "tên quiz",
          "type": 1,
          "explain": "Gi?i thích",
          "answers": [
            {
              "id": "2466c88f-af34-4621-42f5-08d98d62b317",
              "name": "câu tr? l?i 2",
              "order": 0,
              "isCorrect": false
            },
            {
              "id": "4930a419-fe18-4d8b-42f7-08d98d62b317",
              "name": "câu tr? l?i 4",
              "order": 0,
              "isCorrect": false
            },
            {
              "id": "60920b57-3596-44a0-42f4-08d98d62b317",
              "name": "câu tr? l?i 1",
              "order": 0,
              "isCorrect": true
            },
            {
              "id": "837dd703-45ea-4ccb-42f6-08d98d62b317",
              "name": "câu tr? l?i 3",
              "order": 0,
              "isCorrect": false
            }
          ]
        }
      ],
      "links": [],
      "isComplete": true
    },
    {
      "id": "189c0f00-6a05-44e0-cc49-08d98d956006",
      "name": "Khóa h?c dinh du?ng",
      "type": 1,
      "content": """
      Người bệnh tiểu đường cần biết mình nên bổ sung thực phẩm như thế nào cho phù hợp, nên ăn gì và không nên ăn gì. Theo đó, những thực phẩm người bệnh tiểu đường nên ăn bao gồm:

Nhóm đường bột: Ngũ cốc nguyên hạt, đậu đỗ, gạo còn vỏ cám, rau củ... được chế biến bằng cách hấp, luộc, nướng, hạn chế tối đa rán, xào... Các loại củ như khoai sắn cũng cung cấp khá nhiều tinh bột, nên nếu người bệnh tiểu đường ăn các loại này thì cần phải giảm hoặc cắt cơm.""",
      "quizzes": [],
      "links": [
        {
          "id": "21623041-88f2-4a5f-ab28-08d98d5a695e",
          "type": 1,
          "url": "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4"
        },
        {
          "id": "66133f40-0d7e-45f2-ab29-08d98d5a695e",
          "type": 1,
          "url": "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4"
        },
        {
          "id": "66133f40-0d7e-45f2-ab29-08d98d5a695e",
          "type": 1,
          "url": "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4"
        },
        {
          "id": "66133f40-0d7e-45f2-ab29-08d98d5a695e",
          "type": 1,
          "url": "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4"
        }
      ],
      "isComplete": true
    }
  ]
}
};
    final value = LessonSectionListResponse.fromJson(data);
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
