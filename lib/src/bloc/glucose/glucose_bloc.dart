import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/glucose/glucose_comparer.dart';
import 'package:medical/src/modal/glucose/glucose_data_trend.dart';
import 'package:medical/src/modal/glucose/glucose_distribution.dart';
import 'package:medical/src/modal/glucose/glucose_input.dart';
import 'package:medical/src/modal/glucose/glucose_timeFrame.dart';
import 'package:medical/src/repo/glucose/glucose_client.dart';
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
      var model = await client.fetchGlucoseTrend(
          timeFrameId, currentDateTime, periodFilterType, page);
      yield GlucoseTrendLoaded(trend: model);
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
        size: size ?? '20');

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
