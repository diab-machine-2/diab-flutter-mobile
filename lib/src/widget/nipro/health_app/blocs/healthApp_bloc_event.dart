part of 'healthApp_bloc.dart';

@immutable
abstract class HealthAppEvent {}

class FetchBloodPressureTimeFrame extends HealthAppEvent {
  FetchBloodPressureTimeFrame();
}

class SubmitSyncData extends HealthAppEvent {
  final bool isSyncing;

  SubmitSyncData(this.isSyncing);
}

class SyncDataSuccess extends HealthAppEvent {
  SyncDataSuccess();
}
