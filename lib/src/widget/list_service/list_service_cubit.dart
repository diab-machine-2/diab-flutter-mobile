import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/detail_package_data.dart';
import 'package:medical/src/model/response/list_package_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/utils/const.dart';

import 'list_service.dart';

class ListServiceCubit extends Cubit<ListServiceState> {

  final AppRepository appRepository;
  List<DetailPackageData>? listData;
  List<DetailPackageData> get listFilterData => (listData ?? []).where((element) => element.code != Const.BASIC).toList();

  ListServiceCubit(this.appRepository) : super(ListServiceInitial());

  void getListPackage() async {
    emit(ListServiceLoading());
    ApiResult<ListPackageResponse> apiResult = await appRepository.getListPackage();
    apiResult.when(success: (ListPackageResponse response) {
      listData = response.data ?? [];
      emit(ListServiceSuccess());
    }, failure: (NetworkExceptions error) {
      emit(ListServiceFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }
}
