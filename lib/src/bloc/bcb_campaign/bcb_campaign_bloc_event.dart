part of 'bcb_campaign_bloc.dart';

@immutable
abstract class BcbCampaignEvent {}

class LoadBcbCampaignEvent extends BcbCampaignEvent {
  final String? campaignId;
  LoadBcbCampaignEvent({this.campaignId});
}

class LoadMyBcbCustomerEvent extends BcbCampaignEvent {
  final String campaignId;
  LoadMyBcbCustomerEvent({required this.campaignId});
}

class SubmitBcbRegistrationEvent extends BcbCampaignEvent {
  final String campaignCustomerId;
  final String? doctorNote;
  final String? medicalHistory;
  final List<BcbAppointmentWishModel> wishes;

  SubmitBcbRegistrationEvent({
    required this.campaignCustomerId,
    this.doctorNote,
    this.medicalHistory,
    required this.wishes,
  });
}

class LoadBcbExamResultEvent extends BcbCampaignEvent {
  final String campaignCustomerId;
  LoadBcbExamResultEvent({required this.campaignCustomerId});
}

class MarkResultViewedEvent extends BcbCampaignEvent {
  final String examResultId;
  MarkResultViewedEvent({required this.examResultId});
}
