part of 'weight_bloc.dart';

@immutable
abstract class WeightEvent {}

// class FetchInputWeight extends WeightEvent {
//   final String startDateTime;
//   final String endDateTime;
//   final int page;

//   FetchInputWeight({
//     this.startDateTime,
//     this.endDateTime,
//     this.page,
//   });
// }

class FetchTrendWeight extends WeightEvent {
  final String? currentDateTime;
  final String? periodFilterType;
  final String? page;

  FetchTrendWeight({this.currentDateTime, this.periodFilterType, this.page});
}

class FetchTrendHip extends WeightEvent {
  final String? currentDateTime;
  final String? periodFilterType;
  final String? page;

  FetchTrendHip({this.currentDateTime, this.periodFilterType, this.page});
}

class FetchInputWeight extends WeightEvent {
  final String? currentDateTime;
  final String? periodFilterType;
  final int? page;

  FetchInputWeight({
    this.currentDateTime,
    this.periodFilterType,
    this.page,
  });
}

class FetchTrendBMI extends WeightEvent {
  final String? currentDateTime;
  final String? periodFilterType;

  FetchTrendBMI({this.currentDateTime, this.periodFilterType});
}
