import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/SelectRoadmapRequest.dart';
import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/response/list_roadmap_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';

import 'select_road_map.dart';

class SelectRoadMapCubit extends Cubit<SelectRoadMapState> {
  SelectRoadMapCubit(this.repository) : super(const SelectRoadMapInitial());

  final AppRepository repository;

  List<ListRoadmapResponseData?> roadMapList = [];

  ListRoadmapResponseData? currentRoadMap;

  Future<bool> getRoadAppRoadMap({
    bool isLoadMore = false,
  }) async {
    await Future.delayed(Duration.zero);
    if (!isLoadMore) {
      emit(const SelectRoadMapLoading());
    }
    final ApiResult<ListRoadmapResponse> apiResult =
        await repository.getRoadMap();
    apiResult.when(success: (ListRoadmapResponse response) {
      roadMapList = response.data ?? [];
      currentRoadMap = response.currentRoadMap;
      emit(const SelectRoadMapSuccess());
      return true;
    }, failure: (NetworkExceptions error) {
      emit(SelectRoadMapFailure(NetworkExceptions.getErrorMessage(error)));
      return false;
    });
    emit(const SelectRoadMapInitial());
    return true;
  }

  Future<void> changeRoadMap(ListRoadmapResponseData? itemData) async {
    emit(const SelectRoadMapLoading());
    DateTime dateTime0 = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0, 0);
    int startDate = (dateTime0.millisecondsSinceEpoch ~/ 1000).toInt();

    SelectRoadmapRequest request = SelectRoadmapRequest(roadmapId: itemData?.id, startDate: startDate);

    final ApiResult<CommonResponse> apiResult =
        await repository.selectRoadmap(request);
    apiResult.when(success: (CommonResponse response) {
      emit(SelectRoadMapChanged(itemData));
    }, failure: (NetworkExceptions error) {
      emit(SelectRoadMapFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const SelectRoadMapInitial());
  }
}
