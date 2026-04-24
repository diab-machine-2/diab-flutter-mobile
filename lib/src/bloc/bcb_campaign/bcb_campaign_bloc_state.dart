part of 'bcb_campaign_bloc.dart';

@immutable
abstract class BcbCampaignState {}

class BcbCampaignInitial extends BcbCampaignState {}

class BcbCampaignLoading extends BcbCampaignState {}

class BcbCampaignListLoaded extends BcbCampaignState {
  final List<BcbCampaignModel> campaigns;
  BcbCampaignListLoaded({required this.campaigns});
}

class BcbCampaignLoaded extends BcbCampaignState {
  final BcbCustomerModel customer;
  BcbCampaignLoaded({required this.customer});
}

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
