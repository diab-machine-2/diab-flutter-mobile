import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:medical/modal/bmi/bmi_trend.dart';
import 'package:medical/modal/bmi/weight_input.dart';
import 'package:medical/modal/bmi/weight_trend.dart';
import 'package:medical/repo/weight/weight_client.dart';
import 'package:meta/meta.dart';
import 'package:medical/modal/error/error_model.dart';

part 'weight_bloc_event.dart';
part 'weight_bloc_state.dart';

class WeightBloc extends Bloc<WeightEvent, WeightState> {
  @override
  WeightState get initialState => WeightInitial();

  @override
  Stream<WeightState> mapEventToState(WeightEvent event) async* {
    // if (event is FetchInputWeight) {
    //   yield* fetchInputWeight(
    //       event.startDateTime, event.endDateTime, event.page);
    // }
    if (event is FetchTrendWeight) {
      yield* fetchTrendWeight(
          event.currentDateTime, event.periodFilterType, event.page);
    }
    if (event is FetchTrendHip) {
      yield* fetchTrendHip(
          event.currentDateTime, event.periodFilterType, event.page);
    }
    if (event is FetchInputWeight) {
      yield* fetchInputWeight(
          event.currentDateTime, event.periodFilterType, event.page);
    }
    if (event is FetchTrendBMI) {
      yield* fetchTrendBMI(event.currentDateTime, event.periodFilterType);
    }
  }

  // Stream<WeightState> fetchInputWeight(
  //   String startDateTime,
  //   String endDateTime,
  //   int page,
  // ) async* {
  //   try {
  //     final client = WeightClient();
  //     final currenState = state;
  //     var model = await client.fetchInput(startDateTime, endDateTime, page);

  //     if (currenState is WeightInputLoaded) {
  //       if (currenState.inputbmiModel != null && page != 1) {
  //         model.inputs.insertAll(0, currenState.inputbmiModel);
  //       }
  //     }
  //     yield WeightInputLoaded(
  //         inputbmiModel: model.inputs, hasMore: model.hasMore);
  //   } catch (e, _) {
  //     if (e is Error) {
  //       yield WeightError(message: e.message);
  //     } else {
  //       yield WeightError(message: 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi');
  //     }
  //   }
  // }

  Stream<WeightState> fetchTrendWeight(
      String currentDateTime, String periodFilterType, String page) async* {
    try {
      final client = WeightClient();
      yield WeightLoading();
      var model = await client.fetchWeightTrend(
          currentDateTime, periodFilterType, page);
      yield WeightTrendLoaded(trend: model);
    } catch (e, _) {
      if (e is Error) {
        yield WeightError(message: e.message);
      } else {
        yield WeightError(
            message:
                'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi');
      }
    }
  }

  Stream<WeightState> fetchTrendHip(
      String currentDateTime, String periodFilterType, String page) async* {
    try {
      final client = WeightClient();
      yield WeightLoading();
      var model =
          await client.fetchHipTrend(currentDateTime, periodFilterType, page);
      yield WeightTrendLoaded(trend: model);
    } catch (e, _) {
      if (e is Error) {
        yield WeightError(message: e.message);
      } else {
        yield WeightError(
            message:
                'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi');
      }
    }
  }

  Stream<WeightState> fetchInputWeight(
    String currentDateTime,
    String periodFilterType,
    int page,
  ) async* {
    try {
      final client = WeightClient();
      final currenState = state;
      var model =
          await client.fetchInput(currentDateTime, periodFilterType, page);

      if (currenState is WeightAllLoaded) {
        if (currenState.inputWeightModel != null && page != 1) {
          model.inputs.insertAll(0, currenState.inputWeightModel);
        }
      }
      yield WeightAllLoaded(
          inputWeightModel: model.inputs, hasMore: model.hasMore);
    } catch (e, _) {
      if (e is Error) {
        yield WeightError(message: e.message);
      } else {
        yield WeightError(
            message:
                'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi');
      }
    }
  }

  Stream<WeightState> fetchTrendBMI(
      String currentDateTime, String periodFilterType) async* {
    try {
      final client = WeightClient();
      yield WeightLoading();
      var model = await client.fetchTrendBMI(currentDateTime, periodFilterType);
      yield WeightTrendBMILoaded(trendBMI: model);
    } catch (e, _) {
      if (e is Error) {
        yield WeightError(message: e.message);
      } else {
        yield WeightError(
            message:
                'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi');
      }
    }
  }
}
