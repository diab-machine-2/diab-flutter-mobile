import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:medical/modal/HbA1C/HbA1C_Input.dart';
import 'package:medical/modal/HbA1C/HbA1C_lastestSumary.dart';
import 'package:medical/modal/HbA1C/HbA1C_trend.dart';
import 'package:medical/repo/HbA1C/HbA1C_client.dart';
import 'package:meta/meta.dart';
import 'package:medical/modal/error/error_model.dart';
part 'HbA1C_bloc_event.dart';
part 'HbA1C_bloc_state.dart';

class HbA1CBloc extends Bloc<HbA1CEvent, HbA1CState> {
  @override
  HbA1CState get initialState => HbA1CInitial();

  @override
  Stream<HbA1CState> mapEventToState(HbA1CEvent event) async* {
    if (event is FetchHbA1C) {
      yield* fetchLastestSumary(event.currentDateTime, event.periodFilterType);
    }
    if (event is FetchHbA1CTrend) {
      yield* fetchTrend(event.type);
    }
    if (event is FetchInputHbA1C) {
      yield* fetchInputHbA1C(
          event.currentDateTime, event.periodFilterType, event.page);
    }
  }

  Stream<HbA1CState> fetchLastestSumary(
      int currentDateTime, int periodFilterType) async* {
    try {
      final client = HbA1CClient();
      yield HbA1CLoading();
      yield HbA1CLoaded(
          lastestSummaryModel: await client.fetchLastestSumary(
              currentDateTime, periodFilterType));
    } catch (e, _) {
      if (e is Error) {
        yield HbA1CError(message: e.message);
      } else {
        yield HbA1CError(
            message:
                'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi');
      }
    }
  }

  Stream<HbA1CState> fetchTrend(int type) async* {
    try {
      final client = HbA1CClient();
      yield HbA1CLoading();
      yield HbA1CTrendLoaded(trendModel: await client.fetchTrend(type));
    } catch (e, _) {
      if (e is Error) {
        yield HbA1CError(message: e.message);
      } else {
        yield HbA1CError(
            message:
                'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi');
      }
    }
  }

  Stream<HbA1CState> fetchInputHbA1C(
      int currentDateTime, int periodFilterType, int page) async* {
    try {
      final client = HbA1CClient();
      final currenState = state;
      // yield HbA1CLoading();
      var model =
          await client.fetchInput(currentDateTime, periodFilterType, page);

      if (currenState is HbA1CDetailLoaded) {
        if (currenState.inputHbA1CModel != null && page != 1) {
          model.inputs.insertAll(0, currenState.inputHbA1CModel);
        }
      }
      yield HbA1CDetailLoaded(
          inputHbA1CModel: model.inputs, hasMore: model.hasMore);
    } catch (e, _) {
      if (e is Error) {
        yield HbA1CError(message: e.message);
      } else {
        yield HbA1CError(
            message:
                'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi');
      }
    }
  }
}
