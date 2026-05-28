/// Payload for POST `/App/BcbCustomerRegistration`.
class BcbCampaignRegistrationModel {
  final String bcbCampaignId;
  final String? doctorNote;

  /// Selected partner slot id.
  final String slotId;

  BcbCampaignRegistrationModel({
    required this.bcbCampaignId,
    this.doctorNote,
    required this.slotId,
  });
}
