part of 'bcb_campaign_bloc.dart';

@immutable
abstract class BcbCampaignEvent {}

class SubmitBcbRegistrationEvent extends BcbCampaignEvent {
  final String bcbCampaignId;
  final String? doctorNote;
  final String slotId;

  SubmitBcbRegistrationEvent({
    required this.bcbCampaignId,
    this.doctorNote,
    required this.slotId,
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

class RescheduleBcbAppointmentEvent extends BcbCampaignEvent {
  final String appointmentId;
  final String slotId;

  RescheduleBcbAppointmentEvent({
    required this.appointmentId,
    required this.slotId,
  });
}
