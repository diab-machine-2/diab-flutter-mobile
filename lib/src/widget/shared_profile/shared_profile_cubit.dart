import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/update_shared_profile_request.dart';
import 'package:medical/src/model/response/patient_info_response.dart';
import 'package:medical/src/model/response/update_shared_profile_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';

import 'shared_profile.dart';

class SharedProfileCubit extends Cubit<SharedProfileState> {
  SharedProfileCubit(this.repository) : super(const SharedProfileInitial());

  final AppRepository repository;

  List<PatientInfoResponseData?> sharedList = [];

  Future<List<PatientInfoResponseData?>?> getSharedProfile() async {
    await Future.delayed(Duration.zero);
    emit(const SharedProfileLoading());
    final ApiResult<PatientInfoResponse> apiResult =
        await repository.getSharedProfile();
    apiResult.when(success: (PatientInfoResponse response) {
      sharedList = response.data ?? [];
      emit(const SharedProfileSuccess());
    }, failure: (NetworkExceptions error) {
      emit(SharedProfileFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const SharedProfileInitial());
    return null;
  }

  Future<void> stopSharing({required String code}) async {
    emit(const SharedProfileLoading());
    final UpdateSharedProfileRequest request = UpdateSharedProfileRequest(
      referalCode: code,
      referalCodeType: 2,
    );
    final ApiResult<UpdateSharedProfileResponse> apiResult =
        await repository.updateSharedProfile(request);
    apiResult.when(success: (UpdateSharedProfileResponse response) {
      emit(const SharedProfileSuccess());
    }, failure: (NetworkExceptions error) {
      emit(SharedProfileFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const SharedProfileInitial());
  }
}
