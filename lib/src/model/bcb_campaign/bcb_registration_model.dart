/// Payload for POST `/App/BcbCustomerRegistration`.
class BcbCampaignRegistrationModel {
  final String bcbCampaignId;
  final String? doctorNote;
  final String? medicalHistory;

  /// Exactly three partner slot ids in priority order (1 → 3).
  final List<String> slotIds;

  BcbCampaignRegistrationModel({
    required this.bcbCampaignId,
    this.doctorNote,
    this.medicalHistory,
    required this.slotIds,
  });
}
