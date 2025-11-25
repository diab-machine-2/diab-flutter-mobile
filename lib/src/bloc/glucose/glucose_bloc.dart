import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/glucose/glucose_comparer.dart';
import 'package:medical/src/modal/glucose/glucose_data_trend.dart';
import 'package:medical/src/modal/glucose/glucose_distribution.dart';
import 'package:medical/src/modal/glucose/glucose_input.dart';
import 'package:medical/src/modal/glucose/glucose_timeFrame.dart';
import 'package:medical/src/repo/glucose/glucose_client.dart';
import 'package:medical/src/widget/BloodSugar/constant/bloodSugar_rangetype.dart';
import 'package:meta/meta.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:easy_localization/easy_localization.dart';

part 'glucose_bloc_event.dart';
part 'glucose_bloc_state.dart';

class GlucoseBloc extends Bloc<GlucoseEvent, GlucoseState> {
  GlucoseBloc() : super(GlucoseInitial());

  @override
  Stream<GlucoseState> mapEventToState(GlucoseEvent event) async* {
    if (event is FetchGlucoseTimeFrame) {
      yield* fetchFlucoseTimeFrame();
    }
    if (event is FetchGlucoseDistribution) {
      yield* fetchGlucoseDistribution(
          event.currentDateTime, event.periodFilterType, event.page);
    }
    if (event is FetchInputGlucose) {
      yield* fetchInputGlucose(
          event.currentDateTime,
          event.periodFilterType,
          event.page,
          event.timeFrameType,
          event.glucoseDistributionType,
          event.size);
    }
    if (event is FetchTrendGlucose) {
      yield* fetchTrendGlucose(event.trendType, event.currentDateTime,
          event.periodFilterType, event.page);
    }
    if (event is FetchComparerGlucose) {
      yield* fetchComparerGlucose(event.currentDateTime, event.periodFilterType,
          event.page, event.comparerType);
    }
  }

  Stream<GlucoseState> fetchFlucoseTimeFrame() async* {
    try {
      final client = GlucoseClient();
      yield GlucoseLoading();
      yield GlucoseLoaded(await client.fetchFlucoseTimeFrame());
    } catch (e, _) {
      if (e is Error) {
        yield GlucoseError(message: e.message);
      } else {
        yield GlucoseError(
            message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<GlucoseState> fetchGlucoseDistribution(
      String? currentDateTime, String? periodFilterType, String? page) async* {
    try {
      final client = GlucoseClient();
      yield GlucoseLoading();
      var model = await client.fetchFlucoseDistribution(
          currentDateTime, periodFilterType, page);
      yield GlucoseDistributionLoaded(listDistribution: model);
    } catch (e, _) {
      if (e is Error) {
        yield GlucoseError(message: e.message);
      } else {
        yield GlucoseError(
            message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<GlucoseState> fetchTrendGlucose(String? timeFrameId,
      String? currentDateTime, String? periodFilterType, String? page) async* {
    try {
      final client = GlucoseClient();
      yield GlucoseLoading();
      final result = await Future.wait([
        client.fetchGlucoseTrend(timeFrameId, currentDateTime, periodFilterType, page),
        client.fetchFlucoseDistribution(currentDateTime, periodFilterType, page),
      ]);
      if (result.length == 2) {
        final model = result[0] as TrendDataModel;
        final distribution = result[1] as DistributionModel;
        final total = distribution.veryHighCount! +
            distribution.highCount! +
            distribution.goodCount! +
            distribution.lowCount! +
            distribution.veryLowCount!;
        final listPercent = [
          distribution.veryHighCount! / total,
          distribution.highCount! / total,
          distribution.goodCount! / total,
          distribution.lowCount! / total,
          distribution.veryLowCount! / total,
        ];
        final listNames = [
          R.string.very_high.tr(),
          R.string.high.tr(),
          R.string.good.tr(),
          R.string.low.tr(),
          R.string.very_low.tr(),
        ];
        final listColors = [
          distribution.veryHighColor,
          distribution.highColor,
          distribution.goodColor,
          distribution.lowColor,
          distribution.veryLowColor,
        ];
        int maxIndex = 0;
        for (int i = 0; i < listPercent.length; i++) {
          if (i == 0 || listPercent[i] > listPercent[maxIndex]) {
            maxIndex = i;
          }
        }
        final mostAppearType = listNames[maxIndex];
        final mostAppearTypeColor = listColors[maxIndex];
        final rangeType = (maxIndex == 0 || maxIndex == 1)
            ? BloodSugarRangeType.very_high
            : (maxIndex == listNames.length - 1 || maxIndex == listNames.length - 2)
                ? BloodSugarRangeType.very_low
                : BloodSugarRangeType.normal;
        // yield GlucoseTrendLoaded(
        //   trend: model,
        //   mostAppearType: mostAppearType,
        //   mostAppearTypeColor: mostAppearTypeColor,
        //   rangeType: rangeType,
        // );
        final glucoseInputAIAnalysis =
            await client.fetchGlucoseAlltimeAnalysis(int.parse(periodFilterType!));
        yield GlucoseTrendLoaded(
          trend: model,
          glucoseInputAIAnalysis: glucoseInputAIAnalysis ?? '',
          mostAppearType: mostAppearType,
          mostAppearTypeColor: mostAppearTypeColor,
          rangeType: rangeType,
        );
      }
    } catch (e, _) {
      if (e is Error) {
        yield GlucoseError(message: e.message);
      } else {
        yield GlucoseError(
            message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<GlucoseState> fetchInputGlucose(
    String? currentDateTime,
    String? periodFilterType,
    int? page,
    String? timeFrameType,
    String? glucoseDistributionType,
    String? size,
  ) async* {
    // try {
    final client = GlucoseClient();
    final GlucoseState currenState = state;
    var model = await client.fetchInput(currentDateTime, periodFilterType, page,
        timeFrameType, glucoseDistributionType,
        size: size ?? '10');

    if (currenState is GlucoseAlllLoaded) {
      if (page != 1) {
        model.inputs.insertAll(0, currenState.inputGlucoseModel);
      }
    }

    yield GlucoseAlllLoaded(
      inputGlucoseModel: model.inputs,
      hasMore: model.hasMore,
      page: (page ?? 0) + 1,
    );
    // } catch (e, _) {
    //   if (e is Error) {
    //     yield GlucoseError(message: e.message);
    //   } else {
    //     yield GlucoseError(
    //         message:
    //             R.string.error_can_not_connect_to_server.tr());
    //   }
    // }
  }

  Stream<GlucoseState> fetchComparerGlucose(String? currentDateTime,
      String? periodFilterType, int? page, String? comparerType) async* {
    try {
      final client = GlucoseClient();
      final GlucoseState currenState = state;
      yield GlucoseLoading();
      var model = await client.fetchFlucoseComparer(
          currentDateTime, periodFilterType, page, comparerType);

      if (currenState is GlucoseComparerLoaded) {
        if (page != 1) {
          model.insertAll(0, currenState.listcomparer);
        }
      }
      yield GlucoseComparerLoaded(
        listcomparer: model,
        page: (page ?? 0) + 1,
      );
    } catch (e, _) {
      if (e is Error) {
        yield GlucoseError(message: e.message);
      } else {
        yield GlucoseError(
            message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }
}
