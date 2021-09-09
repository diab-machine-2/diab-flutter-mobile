part of 'glucose_bloc.dart';

@immutable
abstract class GlucoseState {}

class GlucoseInitial extends GlucoseState {}

class GlucoseError extends GlucoseState {
  final String message;

  GlucoseError({
    @required this.message,
  });
}

class GlucoseLoading extends GlucoseState {}

class GlucoseLoaded extends GlucoseState {
  GlucoseLoaded(List<TimeFrameModel> list);
}

class GlucoseComparerLoaded extends GlucoseState {
  final List<ComparerModel> listcomparer;
  GlucoseComparerLoaded({@required this.listcomparer});
}

class GlucoseDistributionLoaded extends GlucoseState {
  final DistributionModel listDistribution;
  GlucoseDistributionLoaded({@required this.listDistribution});
}

class GlucoseAlllLoaded extends GlucoseState {
  final List<InputGlucoseModel> inputGlucoseModel;
  final bool hasMore;
  GlucoseAlllLoaded({@required this.inputGlucoseModel, @required this.hasMore});
}

class GlucoseTrendLoaded extends GlucoseState {
  final TrendDataModel trend;
  GlucoseTrendLoaded({@required this.trend});
}
