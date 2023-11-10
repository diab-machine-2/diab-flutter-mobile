part of 'glucose_bloc.dart';

@immutable
abstract class GlucoseState {}

class GlucoseInitial extends GlucoseState {}

class GlucoseError extends GlucoseState {
  final String? message;

  GlucoseError({
    required this.message,
  });
}

class GlucoseLoading extends GlucoseState {}

class GlucoseLoaded extends GlucoseState {
  GlucoseLoaded(List<TimeFrameModel> list);
}

class GlucoseComparerLoaded extends GlucoseState {
  final List<ComparerModel> listcomparer;
  final bool? hasMore;
  final int? page;
  GlucoseComparerLoaded({
    required this.listcomparer,
    this.hasMore,
    this.page,
  });
}

class GlucoseDistributionLoaded extends GlucoseState {
  final DistributionModel listDistribution;
  GlucoseDistributionLoaded({required this.listDistribution});
}

class GlucoseAlllLoaded extends GlucoseState {
  final List<InputGlucoseModel> inputGlucoseModel;
  final bool? hasMore;
  final int page;
  GlucoseAlllLoaded({
    required this.inputGlucoseModel,
    required this.hasMore,
    required this.page,
  });
}

class GlucoseTrendLoaded extends GlucoseState {
  final TrendDataModel trend;
  GlucoseTrendLoaded({required this.trend});
}
