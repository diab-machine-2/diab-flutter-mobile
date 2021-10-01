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
  Future<BloodSugarTemplateCategoryResponse> getListTemplateByCategory(
      category) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'category': category};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<BloodSugarTemplateCategoryResponse>(
            Options(method: 'GET', headers: <String, dynamic>{}, extra: _extra)
                .compose(
                    _dio.options, '/App/BloodSugarTemplate/GetListByCategory',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = BloodSugarTemplateCategoryResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<BloodSugarTemplateDetailResponse> getTemplateDetail(type) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'type': type};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<BloodSugarTemplateDetailResponse>(
            Options(method: 'GET', headers: <String, dynamic>{}, extra: _extra)
                .compose(
                    _dio.options, '/App/BloodSugarTemplate/GetByTemplateType',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = BloodSugarTemplateDetailResponse.fromJson(_result.data!);
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
  Future<MenuResponse> getGetUserFoodMenu() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<MenuResponse>(
            Options(method: 'GET', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options, 'App/PatientFoodMenu/GetUserFoodMenu',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final data = {
  "totalKcal": 905.4,
  "listdayfood": [
    {
      "dateCode": "T2",
      "totalKcal": 905.4000000000001,
      "timeGroups": [
        {
          "timeCode": 1,
          "timeName": "Bữa Sáng",
          "totalKcal": 603.6,
          "defaultFood": [
            {
              "id": "5b525d8a-61f7-4f17-2e50-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T2",
              "timeCode": 1,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T2 food",
              "foodSubstitute": [
                {
                  "id": "0c8467de-08cb-42d1-2e51-08d981116b4e",
                  "foodMenuCode": "TD19",
                  "dateCode": "T2",
                  "timeCode": 1,
                  "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
                  "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
                  "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
                  "foodUnitName": "Phần",
                  "foodName": "Ức gà nướng ớt chuông",
                  "portion": 2,
                  "calorie": 150.9,
                  "glucose": 2.6,
                  "lipid": 4.6,
                  "protein": 23.2,
                  "fibre": 0.8,
                  "note": "T2 food",
                  "foodSubstitute": null
                }
              ]
            },
            {
              "id": "6a3bd873-13a9-4152-2e56-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T2",
              "timeCode": 1,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T2 food",
              "foodSubstitute": []
            },
            {
              "id": "a0e4b448-ac0b-413c-2e55-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T2",
              "timeCode": 1,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T2 food",
              "foodSubstitute": []
            },
            {
              "id": "fd7d88a7-5ee3-49f4-2e53-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T2",
              "timeCode": 1,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T2 food",
              "foodSubstitute": []
            }
          ]
        },
        {
          "timeCode": 2,
          "timeName": "Bữa trưa",
          "totalKcal": 0,
          "defaultFood": []
        },
        {
          "timeCode": 3,
          "timeName": "Bữa tối",
          "totalKcal": 0,
          "defaultFood": []
        },
        {
          "timeCode": 4,
          "timeName": "Bữa phụ 1",
          "totalKcal": 301.8,
          "defaultFood": [
            {
              "id": "492524af-80a3-4251-2e52-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T2",
              "timeCode": 4,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T2 food",
              "foodSubstitute": []
            },
            {
              "id": "829cd980-6bbc-4035-2e54-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T2",
              "timeCode": 4,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T2 food",
              "foodSubstitute": []
            }
          ]
        },
        {
          "timeCode": 5,
          "timeName": "Bữa phụ 2",
          "totalKcal": 0,
          "defaultFood": []
        }
      ]
    },
    {
      "dateCode": "T3",
      "totalKcal": 905.4000000000001,
      "timeGroups": [
        {
          "timeCode": 1,
          "timeName": "Bữa Sáng",
          "totalKcal": 603.6,
          "defaultFood": [
            {
              "id": "5b525d8a-61f7-4f17-2e50-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T3",
              "timeCode": 1,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T3 food",
              "foodSubstitute": [
                {
                  "id": "0c8467de-08cb-42d1-2e51-08d981116b4e",
                  "foodMenuCode": "TD19",
                  "dateCode": "T3",
                  "timeCode": 1,
                  "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
                  "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
                  "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
                  "foodUnitName": "Phần",
                  "foodName": "Ức gà nướng ớt chuông",
                  "portion": 2,
                  "calorie": 150.9,
                  "glucose": 2.6,
                  "lipid": 4.6,
                  "protein": 23.2,
                  "fibre": 0.8,
                  "note": "T3 food",
                  "foodSubstitute": null
                }
              ]
            },
            {
              "id": "6a3bd873-13a9-4152-2e56-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T3",
              "timeCode": 1,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T3 food",
              "foodSubstitute": []
            },
            {
              "id": "a0e4b448-ac0b-413c-2e55-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T3",
              "timeCode": 1,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T3 food",
              "foodSubstitute": []
            },
            {
              "id": "fd7d88a7-5ee3-49f4-2e53-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T3",
              "timeCode": 1,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T3 food",
              "foodSubstitute": []
            }
          ]
        },
        {
          "timeCode": 2,
          "timeName": "Bữa trưa",
          "totalKcal": 0,
          "defaultFood": []
        },
        {
          "timeCode": 3,
          "timeName": "Bữa tối",
          "totalKcal": 0,
          "defaultFood": []
        },
        {
          "timeCode": 4,
          "timeName": "Bữa phụ 1",
          "totalKcal": 301.8,
          "defaultFood": [
            {
              "id": "492524af-80a3-4251-2e52-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T3",
              "timeCode": 4,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T3 food",
              "foodSubstitute": []
            },
            {
              "id": "829cd980-6bbc-4035-2e54-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T3",
              "timeCode": 4,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T3 food",
              "foodSubstitute": []
            }
          ]
        },
        {
          "timeCode": 5,
          "timeName": "Bữa phụ 2",
          "totalKcal": 0,
          "defaultFood": []
        }
      ]
    },
    {
      "dateCode": "T4",
      "totalKcal": 905.4000000000001,
      "timeGroups": [
        {
          "timeCode": 1,
          "timeName": "Bữa Sáng",
          "totalKcal": 603.6,
          "defaultFood": [
            {
              "id": "5b525d8a-61f7-4f17-2e50-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T4",
              "timeCode": 1,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T4 food",
              "foodSubstitute": [
                {
                  "id": "0c8467de-08cb-42d1-2e51-08d981116b4e",
                  "foodMenuCode": "TD19",
                  "dateCode": "T4",
                  "timeCode": 1,
                  "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
                  "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
                  "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
                  "foodUnitName": "Phần",
                  "foodName": "Ức gà nướng ớt chuông",
                  "portion": 2,
                  "calorie": 150.9,
                  "glucose": 2.6,
                  "lipid": 4.6,
                  "protein": 23.2,
                  "fibre": 0.8,
                  "note": "T4 food",
                  "foodSubstitute": null
                }
              ]
            },
            {
              "id": "6a3bd873-13a9-4152-2e56-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T4",
              "timeCode": 1,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T4 food",
              "foodSubstitute": []
            },
            {
              "id": "a0e4b448-ac0b-413c-2e55-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T4",
              "timeCode": 1,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T4 food",
              "foodSubstitute": []
            },
            {
              "id": "fd7d88a7-5ee3-49f4-2e53-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T4",
              "timeCode": 1,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T4 food",
              "foodSubstitute": []
            }
          ]
        },
        {
          "timeCode": 2,
          "timeName": "Bữa trưa",
          "totalKcal": 0,
          "defaultFood": []
        },
        {
          "timeCode": 3,
          "timeName": "Bữa tối",
          "totalKcal": 0,
          "defaultFood": []
        },
        {
          "timeCode": 4,
          "timeName": "Bữa phụ 1",
          "totalKcal": 301.8,
          "defaultFood": [
            {
              "id": "492524af-80a3-4251-2e52-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T4",
              "timeCode": 4,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T4 food",
              "foodSubstitute": []
            },
            {
              "id": "829cd980-6bbc-4035-2e54-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T4",
              "timeCode": 4,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T4 food",
              "foodSubstitute": []
            }
          ]
        },
        {
          "timeCode": 5,
          "timeName": "Bữa phụ 2",
          "totalKcal": 0,
          "defaultFood": []
        }
      ]
    },
    {
      "dateCode": "T5",
      "totalKcal": 905.4000000000001,
      "timeGroups": [
        {
          "timeCode": 1,
          "timeName": "Bữa Sáng",
          "totalKcal": 603.6,
          "defaultFood": [
            {
              "id": "5b525d8a-61f7-4f17-2e50-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T5",
              "timeCode": 1,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T5 food",
              "foodSubstitute": [
                {
                  "id": "0c8467de-08cb-42d1-2e51-08d981116b4e",
                  "foodMenuCode": "TD19",
                  "dateCode": "T5",
                  "timeCode": 1,
                  "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
                  "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
                  "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
                  "foodUnitName": "Phần",
                  "foodName": "Ức gà nướng ớt chuông",
                  "portion": 2,
                  "calorie": 150.9,
                  "glucose": 2.6,
                  "lipid": 4.6,
                  "protein": 23.2,
                  "fibre": 0.8,
                  "note": "T5 food",
                  "foodSubstitute": null
                }
              ]
            },
            {
              "id": "6a3bd873-13a9-4152-2e56-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T5",
              "timeCode": 1,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T5 food",
              "foodSubstitute": []
            },
            {
              "id": "a0e4b448-ac0b-413c-2e55-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T5",
              "timeCode": 1,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T5 food",
              "foodSubstitute": []
            },
            {
              "id": "fd7d88a7-5ee3-49f4-2e53-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T5",
              "timeCode": 1,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T5 food",
              "foodSubstitute": []
            }
          ]
        },
        {
          "timeCode": 2,
          "timeName": "Bữa trưa",
          "totalKcal": 0,
          "defaultFood": []
        },
        {
          "timeCode": 3,
          "timeName": "Bữa tối",
          "totalKcal": 0,
          "defaultFood": []
        },
        {
          "timeCode": 4,
          "timeName": "Bữa phụ 1",
          "totalKcal": 301.8,
          "defaultFood": [
            {
              "id": "492524af-80a3-4251-2e52-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T5",
              "timeCode": 4,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T5 food",
              "foodSubstitute": []
            },
            {
              "id": "829cd980-6bbc-4035-2e54-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T5",
              "timeCode": 4,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T5 food",
              "foodSubstitute": []
            }
          ]
        },
        {
          "timeCode": 5,
          "timeName": "Bữa phụ 2",
          "totalKcal": 0,
          "defaultFood": []
        }
      ]
    },{
      "dateCode": "T6",
      "totalKcal": 905.4000000000001,
      "timeGroups": [
        {
          "timeCode": 1,
          "timeName": "Bữa Sáng",
          "totalKcal": 603.6,
          "defaultFood": [
            {
              "id": "5b525d8a-61f7-4f17-2e50-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T6",
              "timeCode": 1,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T6 food",
              "foodSubstitute": [
                {
                  "id": "0c8467de-08cb-42d1-2e51-08d981116b4e",
                  "foodMenuCode": "TD19",
                  "dateCode": "T6",
                  "timeCode": 1,
                  "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
                  "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
                  "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
                  "foodUnitName": "Phần",
                  "foodName": "Ức gà nướng ớt chuông",
                  "portion": 2,
                  "calorie": 150.9,
                  "glucose": 2.6,
                  "lipid": 4.6,
                  "protein": 23.2,
                  "fibre": 0.8,
                  "note": "T6 food",
                  "foodSubstitute": null
                }
              ]
            },
            {
              "id": "6a3bd873-13a9-4152-2e56-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T6",
              "timeCode": 1,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T6 food",
              "foodSubstitute": []
            },
            {
              "id": "a0e4b448-ac0b-413c-2e55-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T6",
              "timeCode": 1,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T6 food",
              "foodSubstitute": []
            },
            {
              "id": "fd7d88a7-5ee3-49f4-2e53-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T6",
              "timeCode": 1,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T6 food",
              "foodSubstitute": []
            }
          ]
        },
        {
          "timeCode": 2,
          "timeName": "Bữa trưa",
          "totalKcal": 0,
          "defaultFood": []
        },
        {
          "timeCode": 3,
          "timeName": "Bữa tối",
          "totalKcal": 0,
          "defaultFood": []
        },
        {
          "timeCode": 4,
          "timeName": "Bữa phụ 1",
          "totalKcal": 301.8,
          "defaultFood": [
            {
              "id": "492524af-80a3-4251-2e52-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T6",
              "timeCode": 4,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T6 food",
              "foodSubstitute": []
            },
            {
              "id": "829cd980-6bbc-4035-2e54-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T6",
              "timeCode": 4,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T6 food",
              "foodSubstitute": []
            }
          ]
        },
        {
          "timeCode": 5,
          "timeName": "Bữa phụ 2",
          "totalKcal": 0,
          "defaultFood": []
        }
      ]
    },
    {
      "dateCode": "T7",
      "totalKcal": 905.4000000000001,
      "timeGroups": [
        {
          "timeCode": 1,
          "timeName": "Bữa Sáng",
          "totalKcal": 603.6,
          "defaultFood": [
            {
              "id": "5b525d8a-61f7-4f17-2e50-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T7",
              "timeCode": 1,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T7 food",
              "foodSubstitute": [
                {
                  "id": "0c8467de-08cb-42d1-2e51-08d981116b4e",
                  "foodMenuCode": "TD19",
                  "dateCode": "T7",
                  "timeCode": 1,
                  "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
                  "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
                  "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
                  "foodUnitName": "Phần",
                  "foodName": "Ức gà nướng ớt chuông",
                  "portion": 2,
                  "calorie": 150.9,
                  "glucose": 2.6,
                  "lipid": 4.6,
                  "protein": 23.2,
                  "fibre": 0.8,
                  "note": "T7 food",
                  "foodSubstitute": null
                }
              ]
            },
            {
              "id": "6a3bd873-13a9-4152-2e56-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T7",
              "timeCode": 1,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T7 food",
              "foodSubstitute": []
            },
            {
              "id": "a0e4b448-ac0b-413c-2e55-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T7",
              "timeCode": 1,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T7 food",
              "foodSubstitute": []
            },
            {
              "id": "fd7d88a7-5ee3-49f4-2e53-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T7",
              "timeCode": 1,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T7 food",
              "foodSubstitute": []
            }
          ]
        },
        {
          "timeCode": 2,
          "timeName": "Bữa trưa",
          "totalKcal": 0,
          "defaultFood": []
        },
        {
          "timeCode": 3,
          "timeName": "Bữa tối",
          "totalKcal": 0,
          "defaultFood": []
        },
        {
          "timeCode": 4,
          "timeName": "Bữa phụ 1",
          "totalKcal": 301.8,
          "defaultFood": [
            {
              "id": "492524af-80a3-4251-2e52-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T7",
              "timeCode": 4,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T7 food",
              "foodSubstitute": []
            },
            {
              "id": "829cd980-6bbc-4035-2e54-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T7",
              "timeCode": 4,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T7 food",
              "foodSubstitute": []
            }
          ]
        },
        {
          "timeCode": 5,
          "timeName": "Bữa phụ 2",
          "totalKcal": 0,
          "defaultFood": []
        }
      ]
    },
    {
      "dateCode": "T8",
      "totalKcal": 905.4000000000001,
      "timeGroups": [
        {
          "timeCode": 1,
          "timeName": "Bữa Sáng",
          "totalKcal": 603.6,
          "defaultFood": [
            {
              "id": "5b525d8a-61f7-4f17-2e50-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T8",
              "timeCode": 1,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T8 food",
              "foodSubstitute": [
                {
                  "id": "0c8467de-08cb-42d1-2e51-08d981116b4e",
                  "foodMenuCode": "TD19",
                  "dateCode": "T8",
                  "timeCode": 1,
                  "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
                  "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
                  "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
                  "foodUnitName": "Phần",
                  "foodName": "Ức gà nướng ớt chuông",
                  "portion": 2,
                  "calorie": 150.9,
                  "glucose": 2.6,
                  "lipid": 4.6,
                  "protein": 23.2,
                  "fibre": 0.8,
                  "note": "T8 food",
                  "foodSubstitute": null
                }
              ]
            },
            {
              "id": "6a3bd873-13a9-4152-2e56-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T8",
              "timeCode": 1,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T8 food",
              "foodSubstitute": []
            },
            {
              "id": "a0e4b448-ac0b-413c-2e55-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T8",
              "timeCode": 1,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T8 food",
              "foodSubstitute": []
            },
            {
              "id": "fd7d88a7-5ee3-49f4-2e53-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T8",
              "timeCode": 1,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T8 food",
              "foodSubstitute": []
            }
          ]
        },
        {
          "timeCode": 2,
          "timeName": "Bữa trưa",
          "totalKcal": 0,
          "defaultFood": []
        },
        {
          "timeCode": 3,
          "timeName": "Bữa tối",
          "totalKcal": 0,
          "defaultFood": []
        },
        {
          "timeCode": 4,
          "timeName": "Bữa phụ 1",
          "totalKcal": 301.8,
          "defaultFood": [
            {
              "id": "492524af-80a3-4251-2e52-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T8",
              "timeCode": 4,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T8 food",
              "foodSubstitute": []
            },
            {
              "id": "829cd980-6bbc-4035-2e54-08d981116b4e",
              "foodMenuCode": "TD17",
              "dateCode": "T8",
              "timeCode": 4,
              "foodId": "02821a58-50cb-4290-7797-08d945b50f3d",
              "foodCategoryId": "8eff87be-cecd-43e2-300d-08d945b3544f",
              "foodUnitId": "4fd993d2-ebf1-4b5b-ad89-5e0058ab5896",
              "foodUnitName": "Phần",
              "foodName": "Ức gà nướng ớt chuông",
              "portion": 2,
              "calorie": 150.9,
              "glucose": 2.6,
              "lipid": 4.6,
              "protein": 23.2,
              "fibre": 0.8,
              "note": "T8 food",
              "foodSubstitute": []
            }
          ]
        },
        {
          "timeCode": 5,
          "timeName": "Bữa phụ 2",
          "totalKcal": 0,
          "defaultFood": []
        }
      ]
    }
  ],
  "message": null
};
    final value = MenuResponse.fromJson(data);
    print(value);
    // final value = MenuResponse.fromJson(_result.data!);
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
