part of 'bcb_campaign_bloc.dart';

@immutable
abstract class BcbCampaignEvent {}

class SubmitBcbRegistrationEvent extends BcbCampaignEvent {
  final String bcbCampaignId;
  final String? doctorNote;
  final String? medicalHistory;
  final List<String> slotIds;

  SubmitBcbRegistrationEvent({
    required this.bcbCampaignId,
    this.doctorNote,
    this.medicalHistory,
    required this.slotIds,
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
