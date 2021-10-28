import 'package:equatable/equatable.dart';

abstract class ActivityFeedbackState extends Equatable {
  const ActivityFeedbackState() : super();

  @override
  List<Object> get props => [];
}

class ActivityFeedbackInitial extends ActivityFeedbackState {
  const ActivityFeedbackInitial();
  @override
  String toString() {
    return 'ActivityFeedbackInitial{}';
  }
}

class ActivityFeedbackFailure extends ActivityFeedbackState {
  final String? error;

  const ActivityFeedbackFailure(this.error);

  @override
  String toString() {
    return 'ActivityFeedbackFailure {error: $error}';
  }
}

class ActivityFeedbackSuccess extends ActivityFeedbackState {
  const ActivityFeedbackSuccess();
  @override
  String toString() {
    return 'ActivityFeedbackSuccess{}';
  }
}

class ActivityFeedbackLoading extends ActivityFeedbackState {
  const ActivityFeedbackLoading();
  @override
  String toString() {
    return 'ActivityFeedbackLoading{}';
  }
}
