import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/widget/subscription/services/revenue_cat_service.dart';
import 'package:medical/src/widget/subscription/subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit() : super(SubscriptionInitial());
  
  bool hasActiveSubscription = false;

  Future<void> checkSubscriptionStatus() async {
    try {
      emit(SubscriptionLoading());
      
      // Check if user has an active subscription
      hasActiveSubscription = await RevenueCatService.hasActiveSubscription();
      
      emit(SubscriptionSuccess());
    } catch (e) {
      emit(SubscriptionFailure(error: e.toString()));
    }
  }
}