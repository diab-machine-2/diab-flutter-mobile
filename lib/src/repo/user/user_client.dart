import 'package:dio/dio.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/user/category_item_user_model.dart';
import 'package:medical/src/modal/user/category_user_model.dart';
import 'package:medical/src/modal/user/goal_info.dart';
import 'package:medical/src/modal/user/manual.dart';
import 'package:medical/src/modal/user/motivation_data_model.dart';
import 'package:medical/src/modal/user/motivation_model.dart';
import 'package:medical/src/modal/user/patient_time_frame.dart';
import 'package:medical/src/modal/user/schedule_glucose_model.dart';
import 'package:medical/src/modal/user/schedule_glucose_time.dart';
import 'package:medical/src/modal/user/schedule_reminder_data_model.dart';
import 'package:medical/src/modal/user/schedule_reminder_model.dart';
import 'package:medical/src/modal/user/secure.dart';
import 'package:medical/src/modal/user/update_profile_request.dart';
import 'package:medical/src/modal/user/user_model.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/helper/http_helper.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:easy_localization/easy_localization.dart';

enum CategoryType {
  JOB_TYPE,
  EDUCATION_LEVEL_TYPE,
  LEVEL_OF_DIABETES_TYPE,
  PERSONALITY_TYPE,
  INTERESTS_TYPE,
  CONSCIOUSNESS_PRATICE_TYPE,
  VEGETERIAN_TYPE,
  WORKING_HOURS_TYPE,

  LESSON_TAG_TYPE,
  RELIGION_TYPE,
  FAVORITE_SPORT_TYPE
}

class UserClient extends FetchClient {
  Future<UserModel?> fetchUser() async {
    try {
      final Response response = await super.fetchData(url: '/App/Patient/mobile/CurrentToken');
      if (response.statusCode == 200) {
        if (response.data['data'] == null) {
          return null;
        } else {
          final user = UserModel.fromJson(response.data['data']);
          AppSettings.userInfo = user;

          //await fetchUserInfo(user.patientId);
          Observable.instance.notifyObservers([], notifyName: "user_info_change");
          // DartNotificationCenter.post(channel: 'user_info_change');
          return user;
        }
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  // Future<CategoryUserModel?> fetchCategoryItems() async {
  //   try {
  //     final Response response =
  //         await super.fetchData(url: '/App/Admin/Account/portal/mobile/PrepareCreateUpdateFormItem');
  //     if (response.statusCode == 200) {
  //       if (response.data['data'] == null) {
  //         return null;
  //       } else {
  //         final categoryUser = CategoryUserModel.fromJson(response.data['data']);
  //         AppSettings.categoryUserModel = categoryUser;
  //         //   Observable.instance.notifyObservers([], notifyName: "user_info_change");
  //         return categoryUser;
  //       }
  //     } else {
  //       final error = Error.fromJson(response);
  //       throw error;
  //     }
  //   } catch (e) {
  //     throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
  //   }
  // }

  // Future<UserModel> fetchUserInfo(String id) async {
  //   try {
  //     final Response response = await super.fetchData(url: '/App/Patient/$id');
  //     if (response.statusCode == 200) {
  //       if (response.data['data'] == null) {
  //         return null;
  //       } else {
  //         final user = UserModel.fromJson(response.data['data']);
  //         AppSettings.userInfo = user;
  //         DartNotificationCenter.post(channel: 'user_info_change');
  //         return user;
  //       }
  //     } else {
  //       final error = Error.fromJson(response);
  //       throw error;
  //     }
  //   } catch (e) {
  //     throw R.string.error_can_not_connect_to_server.tr();
  //   }
  // }

  Future<List<ManualModel>?> fetchManuals() async {
    try {
      final Response response = await super.fetchData(url: '/App/Profile/Instruction', params: {'takeAll': 'true'});
      if (response.statusCode == 200) {
        if (response.data['data'] == null) {
          return null;
        } else {
          return ManualModel.toList(response.data['data']);
        }
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<SecureModel?> fetchInfoSecure() async {
    try {
      final Response response = await super.fetchData(url: '/App/Profile/Information');
      if (response.statusCode == 200) {
        if (response.data['data'] == null) {
          return null;
        } else {
          return SecureModel.fromJson(response.data['data']);
        }
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<GoalInfoModel?> fetchGoalInfo() async {
    try {
      final Response response = await super.fetchData(url: '/App/Patient/Target');
      if (response.statusCode == 200) {
        if (response.data['data'] == null) {
          return null;
        } else {
          return GoalInfoModel.fromJson(response.data['data']);
        }
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> updateGoalInfo(GoalInfoModel model) async {
    try {
      final Response response = await super.putData(url: '/App/Patient/Target', params: {
        'dailyWalkTargetDuration': model.dailyWalkTargetDuration,
        'dailyTargetDuration': model.dailyTargetDuration,
        'weeklyTargetDuration': model.weeklyTargetDuration,
        'dailyTargetBurnedCalorie': model.dailyTargetBurnedCalorie,
        'dailyEnergyGoal': model.dailyEnergyGoal,
        'goalWaist': model.goalWaist,
        'goalWeight': model.goalWeight
      });
      if (response.statusCode == 200) {
        return true;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> updateAvatar(
    String? patientId,
    String path,
  ) async {
    try {
      Map<String, String> params = {
        'patientId': patientId!,
      };
      final response =
          await super.putHttp(path: '/App/Patient/Avatar', params: params, files: [path], fileName: 'image');
      if (response.statusCode == 200) {
        return true;
      } else {
        final error = (await response.stream.bytesToString());
        throw Error.fromString(error);
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> updateUserInfo(String? patientId, UserModel userInfo, {bool isUpdateDiabetes = false}) async {
    try {
      Map<String, dynamic> params = {
        'patientId': patientId ?? '',
        'fullName': userInfo.fullName ?? '',
        'dateOfBirth': userInfo.dateOfBirth,
        'gender': userInfo.genderType == null || userInfo.genderType == 0 ? 1 : userInfo.genderType,
        'provinceId': userInfo.province == null ? '' : userInfo.province!.id ?? '',
        'districtId': userInfo.district == null ? '' : userInfo.district!.id ?? '',
        'wardId': userInfo.ward == null ? '' : userInfo.ward!.id ?? '',
        'address': userInfo.address ?? '',
        'diabetesStatus': userInfo.diabetesStatus == null ? 0 : userInfo.diabetesStatus! - 1,
        'diabetesDate': userInfo.diabetesDate == null ? 0 : userInfo.diabetesDate,
        'height': userInfo.height == null ? 0 : userInfo.height,
        'weight': userInfo.weight == null ? 0 : userInfo.weight,
        'email': userInfo.email ?? '',
        'secondPhoneNumber': userInfo.secondPhoneNumber ?? ''
      };

      AccountRule? accountRule;
      if (isUpdateDiabetes) {
        accountRule = userInfo.accountRule;
        if (accountRule != null) {
          AccountRuleTypeMapping? accountRuleTypeMapping;
          for (var item in accountRule.accountRuleTypeMappings!) {
            if (item.ruleType == 10) {
              accountRuleTypeMapping = item;
              accountRuleTypeMapping.modelStatus = 1;
            }
          }
          if (accountRuleTypeMapping != null) {
            accountRule.accountRuleTypeMappings = [accountRuleTypeMapping];
          }
          accountRule.accountRuleTagMappings = [];
          accountRule.fromAge = 0;
          accountRule.toAge = 0;
          accountRule.amount = 0;
          accountRule.modelStatus = 0;
          params['accountRule'] = accountRule.toJson();
        }
      }

      final Response response = await super.putData(url: '/App/Patient/mobile/Input', params: params);
      if (response.statusCode == 200) {
        return true;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> updateCategoryUser(
    String? patientId,
    UserModel userInfo,
    List<CategoryItemUserModel> selectedList,
    CategoryType categoryType,
    bool isMultiChoice,
  ) async {
    try {
      AccountRule accountRule = userInfo.accountRule!;
      accountRule.fromAge = 0;
      accountRule.toAge = 0;
      accountRule.amount = 0;
      accountRule.modelStatus = 0;

      if (categoryType == CategoryType.LESSON_TAG_TYPE ||
          categoryType == CategoryType.FAVORITE_SPORT_TYPE ||
          categoryType == CategoryType.RELIGION_TYPE) {
        if (accountRule.accountRuleTagMappings == null) accountRule.accountRuleTagMappings = [];
        if (accountRule.accountRuleTypeMappings == null) accountRule.accountRuleTypeMappings = [];
        List<CategoryItemUserModel> oldSelectedList = [];
        if (categoryType == CategoryType.LESSON_TAG_TYPE) {
          oldSelectedList = userInfo.lessonTagList == null
              ? []
              : userInfo.lessonTagList!.where((element) => element.selected ?? false).toList();
        } else if (categoryType == CategoryType.FAVORITE_SPORT_TYPE) {
          oldSelectedList = userInfo.favouriteSportRuleList == null
              ? []
              : userInfo.favouriteSportRuleList!.where((element) => element.selected ?? false).toList();
        } else if (categoryType == CategoryType.RELIGION_TYPE) {
          oldSelectedList = userInfo.religionRuleList == null
              ? []
              : userInfo.religionRuleList!.where((element) => element.selected ?? false).toList();
        }

        for (int i = 0; i < oldSelectedList.length; i++) {
          bool isExisted = false;
          int indexSelectedList = -1;
          for (int j = 0; j < selectedList.length; j++) {
            if (oldSelectedList[i].value == selectedList[j].value) {
              indexSelectedList = j;
              isExisted = true;
              break;
            }
          }
          if (isExisted) {
            oldSelectedList.removeAt(i);
            if (indexSelectedList >= 0) {
              selectedList.remove(indexSelectedList);
            }
            i--;
          }
        }

        List<AccountRuleTagMapping> accountRuleTagMappingList = [];
        accountRuleTagMappingList.addAll(oldSelectedList.map((e) => AccountRuleTagMapping(
              tagId: e.value,
              modelStatus: 2,
              accountRuleId: (accountRule.id != null && accountRule.id!.isNotEmpty)
                  ? accountRule.id
                  : "00000000-0000-0000-0000-000000000000",
              tag: null,
            )));
        accountRuleTagMappingList.addAll(selectedList.map((e) => AccountRuleTagMapping(
              tagId: e.value,
              modelStatus: 3,
              accountRuleId: (accountRule.id != null && accountRule.id!.isNotEmpty)
                  ? accountRule.id
                  : "00000000-0000-0000-0000-000000000000",
              tag: null,
            )));

        accountRule.accountRuleTagMappings = accountRuleTagMappingList;
        accountRule.accountRuleTypeMappings = [];
      } else {
        if (accountRule.accountRuleTypeMappings == null) accountRule.accountRuleTypeMappings = [];

        if (!isMultiChoice) {
          String id = "00000000-0000-0000-0000-000000000000";
          String? accountRuleId = (accountRule.id != null && accountRule.id!.isNotEmpty)
              ? accountRule.id
              : "00000000-0000-0000-0000-000000000000";
          int modelStatus = 3;

          for (int i = 0; i < accountRule.accountRuleTypeMappings!.length; i++) {
            if (accountRule.accountRuleTypeMappings![i].ruleType == getRuleType(categoryType)) {
              id = accountRule.accountRuleTypeMappings![i].id ?? '';
              modelStatus = 1;
              break;
            }
          }
          accountRule.accountRuleTypeMappings = selectedList
              .map((e) => AccountRuleTypeMapping(
                    id: id,
                    ruleType: getRuleType(categoryType),
                    value: Utils.parseStringToInt(e.value!),
                    accountRuleId: accountRuleId,
                    modelStatus: modelStatus,
                  ))
              .toList();
        } else {
          List<AccountRuleTypeMapping> newAccountRuleTypeMappingList = [];
          newAccountRuleTypeMappingList.addAll(selectedList.map((e) => AccountRuleTypeMapping(
                id: "00000000-0000-0000-0000-000000000000",
                ruleType: getRuleType(categoryType),
                value: Utils.parseStringToInt(e.value!),
                accountRuleId: (accountRule.id != null && accountRule.id!.isNotEmpty)
                    ? accountRule.id
                    : "00000000-0000-0000-0000-000000000000",
                modelStatus: 3,
              )));

          List<AccountRuleTypeMapping> oldAccountRuleTypeMappingList = accountRule.accountRuleTypeMappings!
              .where((element) => element.ruleType == getRuleType(categoryType))
              .toList();

          for (int i = 0; i < oldAccountRuleTypeMappingList.length; i++) {
            bool isExisted = false;
            int indexSelectedList = -1;
            for (int j = 0; j < newAccountRuleTypeMappingList.length; j++) {
              if (oldAccountRuleTypeMappingList[i].value == newAccountRuleTypeMappingList[j].value) {
                indexSelectedList = j;
                isExisted = true;
                break;
              }
            }
            if (isExisted) {
              oldAccountRuleTypeMappingList.removeAt(i);
              if (indexSelectedList >= 0) {
                newAccountRuleTypeMappingList.remove(indexSelectedList);
              }
              i--;
            }
          }

          List<AccountRuleTypeMapping> accountRuleTypeMappingList = [];
          for (var item in oldAccountRuleTypeMappingList) {
            item.modelStatus = 2;
          }
          accountRuleTypeMappingList.addAll(oldAccountRuleTypeMappingList);
          accountRuleTypeMappingList.addAll(newAccountRuleTypeMappingList);

          accountRule.accountRuleTypeMappings = accountRuleTypeMappingList;
        }
        accountRule.accountRuleTagMappings = [];
      }

      UpdateProfileRequest request = UpdateProfileRequest(patientId: patientId, accountRule: accountRule);
      final Response response = await super.putData(url: '/App/Patient/mobile/Input', params: request.toJson());
      if (response.statusCode == 200) {
        return true;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<List<dynamic>?> fetchDiabeteStates() async {
    try {
      final Response response = await super.fetchData(url: '/App/Patient/DiabeteStates');
      if (response.statusCode == 200) {
        final List<dynamic>? result = response.data['data'];
        return result;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<List<ProvinceModel>?> fetchProvinces() async {
    try {
      final Response response =
          await super.fetchData(url: '/App/Division/Provinces', params: {'page': '1', 'size': '1000'});
      if (response.statusCode == 200) {
        if (response.data['data'] == null) {
          return null;
        } else {
          return ProvinceModel.toList(response.data['data']);
        }
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<List<ProvinceModel>?> fetchDictricts(String provinceId) async {
    try {
      final Response response = await super
          .fetchData(url: '/App/Division/Dictricts', params: {'provinceId': provinceId, 'page': '1', 'size': '1000'});
      if (response.statusCode == 200) {
        if (response.data['data'] == null) {
          return null;
        } else {
          return ProvinceModel.toList(response.data['data']);
        }
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<List<ProvinceModel>?> fetchWards(String districtId) async {
    try {
      final Response response = await super
          .fetchData(url: '/App/Division/Wards', params: {'districtId': districtId, 'page': '1', 'size': '1000'});
      if (response.statusCode == 200) {
        if (response.data['data'] == null) {
          return null;
        } else {
          return ProvinceModel.toList(response.data['data']);
        }
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<List<PatientTimeFrameModel>?> fetchPatientTimeFrame() async {
    try {
      final Response response = await super.fetchData(url: '/App/Patient/PatientTimeFrame');
      if (response.statusCode == 200) {
        if (response.data['data'] == null) {
          return null;
        } else {
          return PatientTimeFrameModel.toList(response.data['data']);
        }
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> updatePatientTimeFrame(List<PatientTimeFrameModel> timeFramePatients) async {
    try {
      List<Map<String, dynamic>> data = [];
      timeFramePatients.forEach((element) {
        data.add({'timeFrameId': element.timeFrameId, 'time': element.time});
      });

      Map<String, dynamic> params = {'timeFramePatients': data};

      final response = await super.putData(url: '/App/Patient/PatientTimeFrame', params: params);
      if (response.statusCode == 200) {
        return true;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<MotivationDataModel> fetchMotivationDiary(int page) async {
    try {
      final Response response =
          await super.fetchData(url: '/App/Profile/MotivationDiary', params: {'page': page.toString(), 'size': '10'});
      if (response.statusCode == 200) {
        return MotivationDataModel(
            models: MotivationModel.toList(response.data['data']), hasMore: response.data['meta']['canNext']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> inputMotivationDiary(String? content) async {
    try {
      final Response response = await super
          .postUri(baseOption: true, url: '/App/Profile/MotivationDiary/Input', params: {'content': content});
      if (response.statusCode == 200) {
        return true;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> editMotivationDiary(String? id, String? content) async {
    try {
      final Response response =
          await super.putData(url: '/App/Profile/MotivationDiary/Input', params: {'id': id, 'content': content});
      if (response.statusCode == 200) {
        return true;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<ScheduleReminderDataModel> fetchScheduleReminders(int page) async {
    try {
      final Response response =
          await super.fetchData(url: '/App/Patient/PatientRemind', params: {'page': page.toString(), 'size': '20'});
      if (response.statusCode == 200) {
        return ScheduleReminderDataModel(
            models: ScheduleReminderModel.toList(response.data['data']),
            hasMore: false); //response.data['meta']['canNext']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<ScheduleReminderModel> fetchScheduleReminderDetail(String? id) async {
    try {
      final Response response = await super.fetchData(url: '/App/Patient/PatientRemind/$id');
      if (response.statusCode == 200) {
        return ScheduleReminderModel.fromJson(response.data['data']); //response.data['meta']['canNext']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> inputScheduleReminder(ScheduleReminderModel model) async {
    try {
      final Response response =
          await super.postUri(baseOption: true, url: '/App/Patient/PatientRemind/Input', params: model.toJson());
      if (response.statusCode == 200) {
        return true;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> editScheduleReminder(ScheduleReminderModel model) async {
    try {
      final Response response = await super.putData(url: '/App/Patient/PatientRemind/Input', params: model.toJson());
      if (response.statusCode == 200) {
        return true;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> deleteScheduleReminder(String? id) async {
    try {
      final Response response = await super.delete(url: '/App/Patient/PatientRemind/Input/$id');
      print(response);
      if (response.statusCode == 200) {
        print('delete success');
        return true;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<ScheduleGlucoseModel> fetchScheduleGlucose() async {
    try {
      final Response response = await super.fetchData(url: '/App/Patient/PatientGlucoseRemind/Day');
      if (response.statusCode == 200) {
        return ScheduleGlucoseModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<ScheduleGlucoseTimeModel> fetchScheduleGlucoseSetting() async {
    try {
      final Response response = await super.fetchData(url: '/App/Patient/PatientGlucoseRemind/Time');
      if (response.statusCode == 200) {
        return ScheduleGlucoseTimeModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> updateScheduleGlucoseSetting(ScheduleGlucoseTimeModel model) async {
    try {
      final response =
          await super.postUri(baseOption: true, url: '/App/Patient/PatientGlucoseRemind/InputTime', params: {
        "beforeEat": model.beforeEat,
        "afterEat": model.afterEat,
        "beforeSleeping": model.beforeSleeping,
        "glucoseUnit": model.glucoseUnit
      });
      if (response.statusCode == 200) {
        return true;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> updateScheduleGlucose(ScheduleGlucoseModel model) async {
    try {
      final response = await super
          .postUri(baseOption: true, url: '/App/Patient/PatientGlucoseRemind/InputDay', params: model.toJson());
      if (response.statusCode == 200) {
        return true;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  int getRuleType(CategoryType categoryType) {
    switch (categoryType) {
      case CategoryType.JOB_TYPE:
        return Const.JOB_TYPE;
      case CategoryType.EDUCATION_LEVEL_TYPE:
        return Const.EDUCATION_LEVEL_TYPE;
      case CategoryType.LEVEL_OF_DIABETES_TYPE:
        return Const.LEVEL_OF_DIABETES_TYPE;
      case CategoryType.PERSONALITY_TYPE:
        return Const.PERSONALITY_TYPE;
      case CategoryType.CONSCIOUSNESS_PRATICE_TYPE:
        return Const.CONSCIOUSNESS_PRATICE_TYPE;
      case CategoryType.VEGETERIAN_TYPE:
        return Const.VEGETERIAN_TYPE;
      case CategoryType.WORKING_HOURS_TYPE:
        return Const.WORKING_HOURS_TYPE;
      case CategoryType.INTERESTS_TYPE:
        return Const.INTERESTS_TYPE;
      case CategoryType.LESSON_TAG_TYPE:
        return Const.LESSON_TAG_TYPE;
      default:
        return 0;
    }
  }
}
