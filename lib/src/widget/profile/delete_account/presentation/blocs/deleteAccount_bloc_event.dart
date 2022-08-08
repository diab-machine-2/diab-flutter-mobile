part of 'deleteAccount_bloc.dart';

@immutable
abstract class DeleteAccountEvent {}

class FetchBloodPressureTimeFrame extends DeleteAccountEvent {
  FetchBloodPressureTimeFrame();
}

class EventChangeValue extends DeleteAccountEvent {
  final String? password;
  final String? deleteReason;

  EventChangeValue({
    this.password,
    this.deleteReason,
  });
}

class EventSubmitDeleteAccount extends DeleteAccountEvent {
  EventSubmitDeleteAccount();
}

class EventSubmitValidatePassword extends DeleteAccountEvent {
  EventSubmitValidatePassword();
}
