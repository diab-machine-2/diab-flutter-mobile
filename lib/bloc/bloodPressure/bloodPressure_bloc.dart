import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:medical/modal/blood_pressure/blood_pressure.dart';
import 'package:medical/modal/blood_pressure/blood_pressure_distribution.dart';
import 'package:medical/modal/blood_pressure/blood_pressure_heart_rate.dart';
import 'package:medical/modal/blood_pressure/blood_pressure_trend.dart';
import 'package:medical/modal/glucose/glucose_timeFrame.dart';
import 'package:medical/repo/blood_pressure/bloodPressure_client.dart';
import 'package:meta/meta.dart';
import 'package:medical/modal/error/error_model.dart';

part 'bloodPressure_bloc_event.dart';
part 'bloodPressure_bloc_state.dart';

class BloodPressureBloc extends Bloc<BloodPressureEvent, BloodPressureState> {
  @override
  BloodPressureState get initialState => BloodPressureInitial();

  @override
  Stream<BloodPressureState> mapEventToState(BloodPressureEvent event) async* {
    if (event is FetchBloodPressureTimeFrame) {
      yield* fetchFlucoseTimeFrame();
    }
    if (event is FetchInputBloodPressure) {
      yield* fetchInputPressureGlucose(event.currentDateTime,
          event.periodFilterType, event.bloodPressureType, event.page);
    }
    if (event is FetchHeartRateBloodPressure) {
      yield* fetchHeartRateBloodPressure(
          event.currentDateTime, event.periodFilterType);
    }
    if (event is FetchDistributionBloodPressure) {
      yield* fetchDistributionBloodPressure(
          event.currentDateTime, event.periodFilterType);
    }
    if (event is FetchBloodPressureTrend) {
      yield* fetchBloodPressureTrend(
          event.currentDateTime, event.periodFilterType);
    }
    if (event is FetchPulseRateTrend) {
      yield* fetchPulseRateTrend(event.currentDateTime, event.periodFilterType);
    }
  }

  Stream<BloodPressureState> fetchFlucoseTimeFrame() async* {
    try {
      final client = BloodPressureClient();
      yield BloodPressureLoading();
      // yield BloodPressureLoaded(await client.fetchFlucoseTimeFrame());
    } catch (e, _) {
      if (e is Error) {
        yield BloodPressureError(message: e.message);
      } else {
        yield BloodPressureError(
            message:
                'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi');
      }
    }
  }

  Stream<BloodPressureState> fetchInputPressureGlucose(String currentDateTime,
      String periodFilterType, String bloodPressureType, int page) async* {
    try {
      final client = BloodPressureClient();
      final currenState = state;
      var model = await client.fetchBloodPressureInput(
          currentDateTime, periodFilterType, bloodPressureType, page);

      if (currenState is BloodPressureDataLoaded) {
        if (currenState.bloodPressureModel != null && page != 1) {
          model.inputs.insertAll(0, currenState.bloodPressureModel);
        }
      }
      yield BloodPressureDataLoaded(
          bloodPressureModel: model.inputs, hasMore: model.hasMore);
    } catch (e, _) {
      if (e is Error) {
        yield BloodPressureError(message: e.message);
      } else {
        yield BloodPressureError(
            message:
                'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi');
      }
    }
  }

  Stream<BloodPressureState> fetchHeartRateBloodPressure(
    String currentDateTime,
    String periodFilterType,
  ) async* {
    try {
      final client = BloodPressureClient();
      yield BloodPressureLoading();
      yield BloodPressureDataHeartRateLoaded(
          bloodPressureHeartRateModel: await client.fetchBloodPressureHeartRate(
              currentDateTime, periodFilterType),
          lastestSummaryModel: await client.fetchBloodPressureLatest());
    } catch (e, _) {
      if (e is Error) {
        yield BloodPressureError(message: e.message);
      } else {
        yield BloodPressureError(
            message:
                'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi');
      }
    }
  }

  Stream<BloodPressureState> fetchDistributionBloodPressure(
    String currentDateTime,
    String periodFilterType,
  ) async* {
    try {
      final client = BloodPressureClient();
      yield BloodPressureLoading();
      var model = await client.fetchBloodDistribution(
          currentDateTime, periodFilterType);
      yield BloodPressureDistributionLoaded(listDistribution: model);
    } catch (e, _) {
      if (e is Error) {
        yield BloodPressureError(message: e.message);
      } else {
        yield BloodPressureError(
            message:
                'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi');
      }
    }
  }

  Stream<BloodPressureState> fetchBloodPressureTrend(
    int currentDateTime,
    int periodFilterType,
  ) async* {
    try {
      final client = BloodPressureClient();
      yield BloodPressureLoading();
      var model = await client.fetchBloodPressureTrend(
          currentDateTime, periodFilterType);
      yield BloodPressureTrendLoaded(model: model);
    } catch (e, _) {
      if (e is Error) {
        yield BloodPressureError(message: e.message);
      } else {
        yield BloodPressureError(
            message:
                'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi');
      }
    }
  }

  Stream<BloodPressureState> fetchPulseRateTrend(
    int currentDateTime,
    int periodFilterType,
  ) async* {
    try {
      final client = BloodPressureClient();
      yield BloodPressureLoading();
      var model =
          await client.fetchPulseRateTrend(currentDateTime, periodFilterType);
      yield BloodPulseRateTrendLoaded(model: model);
    } catch (e, _) {
      if (e is Error) {
        yield BloodPressureError(message: e.message);
      } else {
        yield BloodPressureError(
            message:
                'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi');
      }
    }
  }
}
