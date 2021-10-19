import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/exercrises/exercises_intensity.dart';
import 'package:medical/src/modal/user/user_model.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/tdee_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/repo/user/user_client.dart';

import 'body_parameter.dart';

class BodyParameterCubit extends Cubit<BodyParameterState> {
  final AppRepository repository;

  List<ExerciseIntensityModel> listData = [];
  ExerciseIntensityModel? intensity;
  num number = 0;
  int? selectedWeight;
  int? selectedHeight;
  int? selectedYear;
  double? activityLevelRate;

  BodyParameterCubit(this.repository) : super(InitialBodyParameterState());

  Future<void> getUserProfile() async {
    try {
      final UserModel? user = await UserClient().fetchUser();
      selectedWeight = user?.weight?.toInt();
      selectedHeight = user?.height?.toInt();
      if (user?.age != null) {
        selectedYear = DateTime.now().year - user!.age!;
      }
      activityLevelRate = user?.activityLevelRate;
      emit(BodyParameterSuccess());
    } catch (error) {
      emit(BodyParameterFailure(error.toString()));
    }
  }

  Future<void> getListActivity() async {
    emit(BodyParameterLoading());
    await getUserProfile();
    ApiResult<List<ExerciseIntensityModel>> apiResult =
        await repository.getListActivity();
    apiResult.when(success: (List<ExerciseIntensityModel> response) {
      listData = response;
      if (listData.isNotEmpty) {
        for (final data in listData) {
          if ((activityLevelRate ?? 0) <= (data.rate ?? 0)) {
            intensity = data;
            break;
          }
        }
      }
      emit(BodyParameterSuccess());
    }, failure: (NetworkExceptions error) {
      emit(BodyParameterFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(InitialBodyParameterState());
  }

  void getTDEE() async {
    emit(BodyParameterLoading());
    if (selectedWeight == null || selectedWeight == 0) {
      emit(BodyParameterFailure(R.string.ban_chua_nhap_can_nang.tr()));
      return;
    }
    if (selectedHeight == null || selectedHeight == 0) {
      emit(BodyParameterFailure(R.string.ban_chua_nhap_chieu_cao.tr()));
      return;
    }
    if (selectedYear == null || selectedYear == 0) {
      emit(BodyParameterFailure(R.string.ban_chua_nhap_nam_sinh.tr()));
      return;
    }
    if (intensity == null) {
      emit(
          BodyParameterFailure(R.string.ban_chua_chon_cuong_do_tap_luyen.tr()));
      return;
    }
    ApiResult<TDEEResponse> apiResult = await repository.getTDEE(
        weight: selectedWeight,
        height: selectedHeight,
        yearOfBirth: selectedYear,
        activityLevelId: intensity?.id);
    apiResult.when(success: (TDEEResponse response) {
      number = response.data ?? 0;
      emit(GetTDEESuccess());
    }, failure: (NetworkExceptions error) {
      emit(BodyParameterFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }

  void selectHeight(int? index) {
    emit(BodyParameterLoading());
    selectedHeight = index;
    emit(InitialBodyParameterState());
  }

  void selectWeight(int? index) {
    emit(BodyParameterLoading());
    selectedWeight = index;
    emit(InitialBodyParameterState());
  }

  void selectYear(int? index) {
    emit(BodyParameterLoading());
    selectedYear = index;
    emit(InitialBodyParameterState());
  }

  void selectIntensity(ExerciseIntensityModel? intensity) {
    emit(BodyParameterLoading());
    this.intensity = intensity;
    emit(InitialBodyParameterState());
  }
}
