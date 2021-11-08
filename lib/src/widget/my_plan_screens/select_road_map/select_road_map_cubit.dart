import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/list_roadmap_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';

import 'select_road_map.dart';

const int size = 5;

class SelectRoadMapCubit extends Cubit<SelectRoadMapState> {
  SelectRoadMapCubit(this.repository) : super(const SelectRoadMapInitial());

  final AppRepository repository;

  int currentPage = 1;
  int total = 0;

  List<ListRoadmapResponseDataItems?> roadMapList = [];

  bool get hasMore => currentPage * size < total;

  Future<bool> getRoadAppRoadMap({
    bool isLoadMore = false,
  }) async {
    currentPage = isLoadMore ? (currentPage + 1) : 1;
    await Future.delayed(Duration.zero);
    if (!isLoadMore) {
      emit(const SelectRoadMapLoading());
    }
    final ApiResult<ListRoadmapResponse> apiResult =
        await repository.getRoadMap(page: currentPage, size: size);
    apiResult.when(success: (ListRoadmapResponse response) {
      roadMapList.addAll(response.data?.items ?? []);
      total = response.data?.total ?? 0;
      emit(const SelectRoadMapSuccess());
      return true;
    }, failure: (NetworkExceptions error) {
      emit(SelectRoadMapFailure(NetworkExceptions.getErrorMessage(error)));
      return false;
    });
    emit(const SelectRoadMapInitial());
    return true;
  }

  Future<void> changeRoadMap() async {
    emit(const SelectRoadMapLoading());
    await Future.delayed(const Duration(seconds: 1));
    emit (const SelectRoadMapChanged());
    emit(const SelectRoadMapInitial());
  }
}
