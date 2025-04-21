import 'package:medical/src/widget/subscription/model/subscription_banner_model.dart';

abstract class SubscriptionState {}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionSuccess extends SubscriptionState {
  final List<BannerModel> banners;

  SubscriptionSuccess({required this.banners});
}

class SubscriptionFailure extends SubscriptionState {
  final String error;
  
  SubscriptionFailure({required this.error});
}