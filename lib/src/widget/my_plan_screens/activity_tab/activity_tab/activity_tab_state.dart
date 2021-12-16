import 'package:equatable/equatable.dart';

abstract class ActivityTabState extends Equatable {
  const ActivityTabState() : super();

  @override
  List<Object> get props => [];
}

class ActivityTabInitial extends ActivityTabState {
  const ActivityTabInitial();
  @override
  String toString() {
    return 'ActivityTabInitial{}';
  }
}

class ActivityTabFailure extends ActivityTabState {
  final String? error;

  const ActivityTabFailure(this.error);

  @override
  String toString() {
    return 'ActivityTabFailure {error: $error}';
  }
}

class ActivityTabSuccess extends ActivityTabState {
  const ActivityTabSuccess();
  @override
  String toString() {
    return 'ActivityTabSuccess{}';
  }
}

class ActivityTabLoading extends ActivityTabState {
  const ActivityTabLoading();
  @override
  String toString() {
    return 'ActivityTabLoading{}';
  }
}

class ActivityTabProgressChanged extends ActivityTabState {
  const ActivityTabProgressChanged();
  @override
  String toString() {
    return 'ActivityTabProgressChanged{}';
  }
}

class ActivityTabHideProgressMessage extends ActivityTabState {
  const ActivityTabHideProgressMessage();
  @override
  String toString() {
    return 'ActivityTabHideProgressMessage{}';
  }
}

class ActivityTabWeekChanged extends ActivityTabState {
  const ActivityTabWeekChanged(this.newIndex);
  final int newIndex;
  @override
  String toString() {
    return 'ActivityTabWeekChanged{}';
  }
}
