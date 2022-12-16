part of 'healthApp_bloc.dart';

class HealthAppState {
  final BlocStatus blocStatus;
  final List<HealthDataType> types;

  HealthAppState({
    this.types = const [],
    this.blocStatus = BlocStatus.loading,
  });

  HealthAppState copyWith({
    BlocStatus? blocStatus,
    List<HealthDataType>? types
  }) {
    return HealthAppState(
      blocStatus: blocStatus ?? BlocStatus.loading,
      types: types ?? this.types,
    );
  }
}

enum BlocStatus {
  error,
  loading,
}
