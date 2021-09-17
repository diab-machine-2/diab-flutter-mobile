part of 'HbA1C_bloc.dart';

@immutable
abstract class HbA1CState {}

class HbA1CInitial extends HbA1CState {}

class HbA1CError extends HbA1CState {
  final String message;

  HbA1CError({
    @required this.message,
  });
}

class HbA1CLoading extends HbA1CState {}

class HbA1CLoaded extends HbA1CState {
  final LastestSummaryModel lastestSummaryModel;
  HbA1CLoaded({@required this.lastestSummaryModel});
}

class HbA1CTrendLoaded extends HbA1CState {
  final TrendModel trendModel;
  HbA1CTrendLoaded({@required this.trendModel});
}

class HbA1CDetailLoaded extends HbA1CState {
  final List<InputHbA1CModel> inputHbA1CModel;
  final bool hasMore;
  HbA1CDetailLoaded({@required this.inputHbA1CModel, @required this.hasMore});
}
