part of 'emotion_bloc.dart';

@immutable
abstract class EmotionEvent {}

class FetchInputEmotion extends EmotionEvent {
  final String? currentDateTime;
  final String? periodFilterType;
  final String? emotionId;
  final int? page;

  FetchInputEmotion(
      {this.currentDateTime, this.periodFilterType, this.emotionId, this.page});
}

class FetchEmotionStatistic extends EmotionEvent {
  final String? currentDateTime;
  final String? periodFilterType;

  FetchEmotionStatistic({this.currentDateTime, this.periodFilterType});
}

class FetchSymptomStatistic extends EmotionEvent {
  final String? currentDateTime;
  final String? periodFilterType;

  FetchSymptomStatistic({this.currentDateTime, this.periodFilterType});
}

class FetchActivityStatistic extends EmotionEvent {
  final String? currentDateTime;
  final String? periodFilterType;

  FetchActivityStatistic({this.currentDateTime, this.periodFilterType});
}
