import 'package:dio/dio.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
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
import 'package:medical/src/modal/user/user_model.dart';
import 'package:medical/src/widget/helper/http_helper.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:easy_localization/easy_localization.dart';

class UserClient extends FetchClient {
  Future<UserModel?> fetchUser() async {
    try {
      final Response response =
          await super.fetchData(url: '/App/Patient/CurrentToken');
      if (response.statusCode == 200) {
        if (response.data['data'] == null) {
          return null;
        } else {
          final user = UserModel.fromJson(response.data['data']);
          AppSettings.userInfo = user;
          //await fetchUserInfo(user.patientId);
          Observable.instance.notifyObservers([], notifyName : "user_info_change");
          // DartNotificationCenter.post(channel: 'user_info_change');
          return user;
        }
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error
          ? e
          : R.string.error_can_not_connect_to_server.tr();
    }
  }

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
      final Response response = await super.fetchData(
          url: '/App/Profile/Instruction', params: {'takeAll': 'true'});
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
      throw e is Error
          ? e
          : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<SecureModel?> fetchInfoSecure() async {
    try {
      final Response response =
          await super.fetchData(url: '/App/Profile/Information');
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
      throw e is Error
          ? e
          : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<GoalInfoModel?> fetchGoalInfo() async {
    try {
      final Response response =
          await super.fetchData(url: '/App/Patient/Target');
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
      throw e is Error
          ? e
          : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> updateGoalInfo(GoalInfoModel model) async {
    try {
      final Response response =
          await super.putData(url: '/App/Patient/Target', params: {
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
      throw e is Error
          ? e
          : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> updateAvatar(
    String? patientId,
    String path,
  ) async {
    try {
      Map<String, String?> params = {
        'patientId': patientId,
      };
      final response = await super.putHttp(
          path: '/App/Patient/Avatar',
          params: params,
          files: [path],
          fileName: 'image');
      if (response.statusCode == 200) {
        return true;
      } else {
        final error = (await response.stream.bytesToString());
        throw Error.fromString(error);
      }
    } catch (e) {
      throw e is Error
          ? e
          : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> updateUserInfo(String? patientId, UserModel userInfo) async {
    try {
      Map<String, String> params = {
        'patientId': patientId ?? '',
        'fullName': userInfo.fullName ?? '',
        'dateOfBirth': userInfo.dateOfBirth.toString(),
        'gender': userInfo.genderType == null || userInfo.genderType == 0
            ? '1'
            : userInfo.genderType.toString(),
        'provinceId': userInfo.province == null ? '' : userInfo.province!.id ?? '',
        'districtId': userInfo.district == null ? '' : userInfo.district!.id ?? '',
        'wardId': userInfo.ward == null ? '' : userInfo.ward!.id ?? '',
        'address': userInfo.address ?? '',
        'diabetesStatus': userInfo.diabetesStatus == null
            ? ''
            : userInfo.diabetesStatus.toString(),
        'diabetesDate': userInfo.diabetesDate == null
            ? '0'
            : userInfo.diabetesDate.toString(),
        'height': userInfo.height == null ? '' : userInfo.height.toString(),
        'weight': userInfo.weight == null ? '' : userInfo.weight.toString(),
        'email': userInfo.email ?? '',
        'secondPhoneNumber': userInfo.secondPhoneNumber ?? ''
      };
      final response = await super.putHttp(
          path: '/App/Patient/Input', params: params, files: [], fileName: '');
      if (response.statusCode == 200) {
        return true;
      } else {
        final error = (await response.stream.bytesToString());
        throw Error.fromString(error);
      }
    } catch (e) {
      throw e is Error
          ? e
          : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<List<dynamic>?> fetchDiabeteStates() async {
    try {
      final Response response =
          await super.fetchData(url: '/App/Patient/DiabeteStates');
      if (response.statusCode == 200) {
        final List<dynamic>? result = response.data['data'];
        return result;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error
          ? e
          : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<List<ProvinceModel>?> fetchProvinces() async {
    try {
      final Response response = await super.fetchData(
          url: '/App/Division/Provinces',
          params: {'page': '1', 'size': '1000'});
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
      throw e is Error
          ? e
          : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<List<ProvinceModel>?> fetchDictricts(String provinceId) async {
    try {
      final Response response = await super.fetchData(
          url: '/App/Division/Dictricts',
          params: {'provinceId': provinceId, 'page': '1', 'size': '1000'});
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
      throw e is Error
          ? e
          : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<List<ProvinceModel>?> fetchWards(String districtId) async {
    try {
      final Response response = await super.fetchData(
          url: '/App/Division/Wards',
          params: {'districtId': districtId, 'page': '1', 'size': '1000'});
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
      throw e is Error
          ? e
          : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<List<PatientTimeFrameModel>?> fetchPatientTimeFrame() async {
    try {
      final Response response =
          await super.fetchData(url: '/App/Patient/PatientTimeFrame');
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
      throw e is Error
          ? e
          : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> updatePatientTimeFrame(
      List<PatientTimeFrameModel> timeFramePatients) async {
    try {
      List<Map<String, dynamic>> data = [];
      timeFramePatients.forEach((element) {
        data.add({'timeFrameId': element.timeFrameId, 'time': element.time});
      });

      Map<String, dynamic> params = {'timeFramePatients': data};

      final response = await super
          .putData(url: '/App/Patient/PatientTimeFrame', params: params);
      if (response.statusCode == 200) {
        return true;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error
          ? e
          : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<MotivationDataModel> fetchMotivationDiary(int page) async {
    try {
      final Response response = await super.fetchData(
          url: '/App/Profile/MotivationDiary',
          params: {'page': page.toString(), 'size': '10'});
      if (response.statusCode == 200) {
        return MotivationDataModel(
            models: MotivationModel.toList(response.data['data']),
            hasMore: response.data['meta']['canNext']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error
          ? e
          : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> inputMotivationDiary(String? content) async {
    try {
      final Response response = await super.postUri(
          baseOption: true,
          url: '/App/Profile/MotivationDiary/Input',
          params: {'content': content});
      if (response.statusCode == 200) {
        return true;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error
          ? e
          : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> editMotivationDiary(String? id, String? content) async {
    try {
      final Response response = await super.putData(
          url: '/App/Profile/MotivationDiary/Input',
          params: {'id': id, 'content': content});
      if (response.statusCode == 200) {
        return true;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error
          ? e
          : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<ScheduleReminderDataModel> fetchScheduleReminders(int page) async {
    try {
      final Response response = await super.fetchData(
          url: '/App/Patient/PatientRemind',
          params: {'page': page.toString(), 'size': '20'});
      if (response.statusCode == 200) {
        return ScheduleReminderDataModel(
            models: ScheduleReminderModel.toList(response.data['data']),
            hasMore: false); //response.data['meta']['canNext']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error
          ? e
          : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<ScheduleReminderModel> fetchScheduleReminderDetail(String? id) async {
    try {
      final Response response =
          await super.fetchData(url: '/App/Patient/PatientRemind/$id');
      if (response.statusCode == 200) {
        return ScheduleReminderModel.fromJson(
            response.data['data']); //response.data['meta']['canNext']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error
          ? e
          : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> inputScheduleReminder(ScheduleReminderModel model) async {
    try {
      final Response response = await super.postUri(
          baseOption: true,
          url: '/App/Patient/PatientRemind/Input',
          params: model.toJson());
      if (response.statusCode == 200) {
        return true;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error
          ? e
          : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> editScheduleReminder(ScheduleReminderModel model) async {
    try {
      final Response response =
          await super.putData(url: '/App/Patient/PatientRemind/Input', params: model.toJson());
      if (response.statusCode == 200) {
        return true;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error
          ? e
          : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> deleteScheduleReminder(String? id) async {
    try {
      final Response response =
          await super.delete(url: '/App/Patient/PatientRemind/Input/$id');
      print(response);
      if (response.statusCode == 200) {
        print('delete success');
        return true;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error
          ? e
          : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<ScheduleGlucoseModel> fetchScheduleGlucose() async {
    try {
      final Response response =
          await super.fetchData(url: '/App/Patient/PatientGlucoseRemind/Day');
      if (response.statusCode == 200) {
        return ScheduleGlucoseModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error
          ? e
          : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<ScheduleGlucoseTimeModel> fetchScheduleGlucoseSetting() async {
    try {
      final Response response =
          await super.fetchData(url: '/App/Patient/PatientGlucoseRemind/Time');
      if (response.statusCode == 200) {
        return ScheduleGlucoseTimeModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error
          ? e
          : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> updateScheduleGlucoseSetting(
      ScheduleGlucoseTimeModel model) async {
    try {
      final response = await super.postUri(
          baseOption: true,
          url: '/App/Patient/PatientGlucoseRemind/InputTime',
          params: {
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
      throw e is Error
          ? e
          : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> updateScheduleGlucose(ScheduleGlucoseModel model) async {
    try {
      final response = await super.postUri(
          baseOption: true,
          url: '/App/Patient/PatientGlucoseRemind/InputDay',
          params: model.toJson());
      if (response.statusCode == 200) {
        return true;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error
          ? e
          : R.string.error_can_not_connect_to_server.tr();
    }
  }
}
