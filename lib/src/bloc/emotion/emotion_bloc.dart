import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/emotion/emotion_statistic_item_model.dart';
import 'package:medical/src/modal/emotion/emotion_statistic_model.dart';
import 'package:medical/src/modal/emotion/input_emotion_data_model.dart';
import 'package:medical/src/repo/emotion/emotion_client.dart';
import 'package:meta/meta.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:easy_localization/easy_localization.dart';
part 'emotion_bloc_event.dart';
part 'emotion_bloc_state.dart';

class EmotionBloc extends Bloc<EmotionEvent, EmotionState> {
  EmotionBloc() : super(EmotionInitial());

  @override
  Stream<EmotionState> mapEventToState(EmotionEvent event) async* {
    if (event is FetchInputEmotion) {
      yield* fetchInputEmotion(event.currentDateTime, event.periodFilterType,
          event.emotionId, event.page);
    }
    if (event is FetchEmotionStatistic) {
      yield* fetchEmotionStatistic(
          event.currentDateTime, event.periodFilterType);
    }
    if (event is FetchSymptomStatistic) {
      yield* fetchSymptomStatistic(
          event.currentDateTime, event.periodFilterType);
    }
    if (event is FetchActivityStatistic) {
      yield* fetchActivityStatistic(
          event.currentDateTime, event.periodFilterType);
    }
  }

  Stream<EmotionState> fetchInputEmotion(String currentDateTime,
      String periodFilterType, String emotionId, int page) async* {
    try {
      final client = EmotionClient();
      final currenState = state;
      var model = await client.fetchInput(
          currentDateTime, periodFilterType, emotionId, page);

      if (currenState is EmotionLoaded) {
        if (currenState.inputModel != null && page != 1) {
          model.inputs.insertAll(0, currenState.inputModel.inputs);
        }
      }
      yield EmotionLoaded(inputModel: model);
    } catch (e, _) {
      if (e is Error) {
        yield EmotionError(message: e.message);
      } else {
        yield EmotionError(
            message:
                R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<EmotionState> fetchEmotionStatistic(
      String currentDateTime, String periodFilterType) async* {
    try {
      yield EmotionLoading();
      yield EmotionStatisticLoaded(
          model: await EmotionClient()
              .fetchEmotionStatistic(currentDateTime, periodFilterType));
    } catch (e, _) {
      if (e is Error) {
        yield EmotionError(message: e.message);
      } else {
        yield EmotionError(
            message:
                R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<EmotionState> fetchSymptomStatistic(
      String currentDateTime, String periodFilterType) async* {
    try {
      yield EmotionLoading();
      yield SymptomStatisticLoaded(
          symptoms: await EmotionClient()
              .fetchSymptomStatistic(currentDateTime, periodFilterType));
    } catch (e, _) {
      if (e is Error) {
        yield EmotionError(message: e.message);
      } else {
        yield EmotionError(
            message:
                R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<EmotionState> fetchActivityStatistic(
      String currentDateTime, String periodFilterType) async* {
    try {
      yield EmotionLoading();
      yield ActivityStatisticLoaded(
          activities: await EmotionClient()
              .fetchActivityStatistic(currentDateTime, periodFilterType));
    } catch (e, _) {
      if (e is Error) {
        yield EmotionError(message: e.message);
      } else {
        yield EmotionError(
            message:
                R.string.error_can_not_connect_to_server.tr());
      }
    }
  }
}
