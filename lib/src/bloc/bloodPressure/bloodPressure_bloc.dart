import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/blood_pressure/blood_pressure.dart';
import 'package:medical/src/modal/blood_pressure/blood_pressure_distribution.dart';
import 'package:medical/src/modal/blood_pressure/blood_pressure_heart_rate.dart';
import 'package:medical/src/modal/blood_pressure/blood_pressure_trend.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/modal/glucose/glucose_timeFrame.dart';
import 'package:medical/src/repo/blood_pressure/bloodPressure_client.dart';
import 'package:medical/src/widget/home/fliter_enum.dart';
import 'package:meta/meta.dart';

import '../../app_setting/app_setting.dart';

part 'bloodPressure_bloc_event.dart';
part 'bloodPressure_bloc_state.dart';

class BloodPressureBloc extends Bloc<BloodPressureEvent, BloodPressureState> {
  BloodPressureBloc() : super(BloodPressureInitial());

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
      // final client = BloodPressureClient();
      yield BloodPressureLoading();
      // yield BloodPressureLoaded(await client.fetchFlucoseTimeFrame());
    } catch (e, _) {
      if (e is Error) {
        yield BloodPressureError(message: e.message);
      } else {
        yield BloodPressureError(
            message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<BloodPressureState> fetchInputPressureGlucose(String? currentDateTime,
      String? periodFilterType, String? bloodPressureType, int? page) async* {
    try {
      String finalPeriodFilterType =  periodFilterType ??
          await AppSettings.getPeriodByScreen(ScreenList.BLOOD_PRESSURE.index);
      final client = BloodPressureClient();
      final BloodPressureState currenState = state;
      var model = await client.fetchBloodPressureInput(
          currentDateTime, finalPeriodFilterType, bloodPressureType, page);

      if (currenState is BloodPressureDataLoaded) {
        if (page != 1) {
          model.inputs.insertAll(0, currenState.bloodPressureModel);
        }
      }
      yield BloodPressureDataLoaded(
        bloodPressureModel: model.inputs,
        hasMore: model.hasMore ?? false,
        page: (page ?? 1) + 1,
      );
    } catch (e, _) {
      if (e is Error) {
        yield BloodPressureError(message: e.message);
      } else {
        yield BloodPressureError(
            message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<BloodPressureState> fetchHeartRateBloodPressure(
    String? currentDateTime,
    String? periodFilterType,
  ) async* {
    try {
      String finalPeriodFilterType =  periodFilterType ??
          await AppSettings.getPeriodByScreen(ScreenList.BLOOD_PRESSURE.index);
      final client = BloodPressureClient();
      yield BloodPressureLoading();
      yield BloodPressureDataHeartRateLoaded(
          bloodPressureHeartRateModel: await client.fetchBloodPressureHeartRate(
              currentDateTime, finalPeriodFilterType),
          lastestSummaryModel: await client.fetchBloodPressureLatest());
    } catch (e, _) {
      if (e is Error) {
        yield BloodPressureError(message: e.message);
      } else {
        yield BloodPressureError(
            message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<BloodPressureState> fetchDistributionBloodPressure(
    String? currentDateTime,
    String? periodFilterType,
  ) async* {
    try {
      String finalPeriodFilterType =  periodFilterType ??
          await AppSettings.getPeriodByScreen(ScreenList.BLOOD_PRESSURE.index);
      final client = BloodPressureClient();
      yield BloodPressureLoading();
      final model = await client.fetchBloodDistribution(
          currentDateTime, finalPeriodFilterType);
      final lowHigh = await client.fetchBloodPressureHeartRate(
          currentDateTime, finalPeriodFilterType);
      model.lowestId = lowHigh.diastolicLowestId;
      model.lowestSystolic = lowHigh.systolicLowest;
      model.lowestDiastolic = lowHigh.diastolicLowest;
      model.highestId = lowHigh.diastolicHighestId;
      model.highestSystolic = lowHigh.systolicHighest;
      model.highestDiastolic = lowHigh.diastolicHighest;
      yield BloodPressureDistributionLoaded(listDistribution: model);
    } catch (e, _) {
      if (e is Error) {
        yield BloodPressureError(message: e.message);
      } else {
        yield BloodPressureError(
            message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<BloodPressureState> fetchBloodPressureTrend(
    int? currentDateTime,
    int? periodFilterType,
  ) async* {
    try {
      int finalPeriodFilterType = periodFilterType ??
          int.parse(await AppSettings.getPeriodByScreen(ScreenList.BLOOD_PRESSURE.index));
      final client = BloodPressureClient();
      yield BloodPressureLoading();
      var model = await client.fetchBloodPressureTrend(
          currentDateTime, finalPeriodFilterType);
      yield BloodPressureTrendLoaded(model: model);
    } catch (e, _) {
      if (e is Error) {
        yield BloodPressureError(message: e.message);
      } else {
        yield BloodPressureError(
            message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<BloodPressureState> fetchPulseRateTrend(
    int? currentDateTime,
    int? periodFilterType,
  ) async* {
    try {
      periodFilterType = int.parse(
          await AppSettings.getPeriodByScreen(ScreenList.BLOOD_PRESSURE.index));
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
            message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }
}
