part of 'emotion_bloc.dart';

@immutable
abstract class EmotionState {}

class EmotionInitial extends EmotionState {}

class EmotionError extends EmotionState {
  final String message;

  EmotionError({
    @required this.message,
  });
}

class EmotionLoading extends EmotionState {}

class EmotionLoaded extends EmotionState {
  final InputEmotionDataModel inputModel;
  EmotionLoaded({@required this.inputModel});
}

class EmotionStatisticLoaded extends EmotionState {
  final EmotionStatisticModel model;
  EmotionStatisticLoaded({@required this.model});
}

class SymptomStatisticLoaded extends EmotionState {
  final List<EmotionStatisticItemModel> symptoms;
  SymptomStatisticLoaded({@required this.symptoms});
}

class ActivityStatisticLoaded extends EmotionState {
  final List<EmotionStatisticItemModel> activities;
  ActivityStatisticLoaded({@required this.activities});
}
