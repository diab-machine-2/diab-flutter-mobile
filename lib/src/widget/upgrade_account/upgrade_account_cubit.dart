import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/upgrade_account_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';

import 'upgrade_account.dart';

class UpgradeAccountCubit extends Cubit<UpgradeAccountState> {

  final AppRepository appRepository;

  List<UpgradeAccountData>? listData;

  UpgradeAccountCubit(this.appRepository) : super(UpgradeAccountInitial());

  void getUpgradeAccount() async {
    emit(UpgradeAccountLoading());
    ApiResult<UpgradeAccountResponse> apiResult = await appRepository.getUpgradeAccount();
    apiResult.when(success: (UpgradeAccountResponse response) {
      listData = response.data ?? [];
      emit(UpgradeAccountSuccess());
    }, failure: (NetworkExceptions error) {
      emit(UpgradeAccountFailure(NetworkExceptions.getErrorMessage(error)));
    });
  } 

}
