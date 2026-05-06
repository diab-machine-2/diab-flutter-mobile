part of 'bcb_campaign_bloc.dart';

abstract class BcbCampaignState {}

class BcbCampaignInitial extends BcbCampaignState {}

class BcbCampaignLoading extends BcbCampaignState {}

class BcbRegistrationSubmitted extends BcbCampaignState {}

class BcbExamResultLoaded extends BcbCampaignState {
  final BcbExamResultModel result;
  BcbExamResultLoaded({required this.result});
}

class BcbResultMarkedViewed extends BcbCampaignState {}

class BcbCampaignError extends BcbCampaignState {
  final String message;
  BcbCampaignError({required this.message});
}
