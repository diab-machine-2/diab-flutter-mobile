part of 'healthApp_bloc.dart';

@immutable
abstract class HealthAppEvent {}

class FetchBloodPressureTimeFrame extends HealthAppEvent {
  FetchBloodPressureTimeFrame();
}

class SyncData extends HealthAppEvent {
  final String? password;
  final String? deleteReason;

  SyncData({
    this.password,
    this.deleteReason,
  });
}

class EventSubmitDeleteAccount extends HealthAppEvent {
  EventSubmitDeleteAccount();
}

class EventSubmitValidatePassword extends HealthAppEvent {
  EventSubmitValidatePassword();
}
