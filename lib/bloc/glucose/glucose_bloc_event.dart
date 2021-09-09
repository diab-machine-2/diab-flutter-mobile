part of 'glucose_bloc.dart';

@immutable
abstract class GlucoseEvent {}

class FetchGlucoseTimeFrame extends GlucoseEvent {
  FetchGlucoseTimeFrame();
}

class FetchGlucoseDistribution extends GlucoseEvent {
  final String currentDateTime;
  final String periodFilterType;
  final String page;

  FetchGlucoseDistribution(
      {this.currentDateTime, this.periodFilterType, this.page});
}

class FetchInputGlucose extends GlucoseEvent {
  final String currentDateTime;
  final String periodFilterType;
  final int page;
  final String timeFrameType;
  final String glucoseDistributionType;

  FetchInputGlucose(
      {this.currentDateTime,
      this.periodFilterType,
      this.page,
      this.timeFrameType,
      this.glucoseDistributionType});
}

class FetchComparerGlucose extends GlucoseEvent {
  final String currentDateTime;
  final String periodFilterType;
  final String page;
  final String comparerType;

  FetchComparerGlucose(
      {this.currentDateTime,
      this.periodFilterType,
      this.page,
      this.comparerType});
}

class FetchTrendGlucose extends GlucoseEvent {
  final String trendType;
  final String currentDateTime;
  final String periodFilterType;
  final String page;

  FetchTrendGlucose(
      {this.trendType, this.currentDateTime, this.periodFilterType, this.page});
}
