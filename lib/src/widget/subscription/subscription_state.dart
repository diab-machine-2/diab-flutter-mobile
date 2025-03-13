abstract class SubscriptionState {}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionSuccess extends SubscriptionState {}

class SubscriptionFailure extends SubscriptionState {
  final String error;
  
  SubscriptionFailure({required this.error});
}