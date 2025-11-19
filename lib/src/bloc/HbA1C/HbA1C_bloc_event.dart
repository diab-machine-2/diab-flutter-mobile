part of 'HbA1C_bloc.dart';

@immutable
abstract class HbA1CEvent {}

class FetchHbA1C extends HbA1CEvent {
  final int currentDateTime;
  final int periodFilterType;
  FetchHbA1C({required this.currentDateTime, required this.periodFilterType});
}

class FetchHbA1CTrend extends HbA1CEvent {
  final int type;
  final bool takeAll;
  FetchHbA1CTrend({required this.type, this.takeAll = false});
}

class FetchInputHbA1C extends HbA1CEvent {
  final int currentDateTime;
  final int periodFilterType;
  final int page;
  final bool takeAll;

  FetchInputHbA1C({
    required this.currentDateTime,
    required this.periodFilterType,
    required this.page,
    this.takeAll = false,
  });
}
