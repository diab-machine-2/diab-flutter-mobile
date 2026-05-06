import 'package:medical/src/model/bcb_campaign/bcb_campaign_model.dart';
import 'package:medical/src/model/bcb_campaign/bcb_exam_result_model.dart';
import 'package:medical/src/model/bcb_campaign/bcb_partner_schedule_model.dart';
import 'package:medical/src/model/bcb_campaign/bcb_registration_model.dart';
import 'package:medical/src/repo/bcb_campaign/bcb_campaign_client.dart';

/// Service layer for BCB Campaign — delegates to BcbCampaignClient (Dio-based).
class BcbCampaignService {
  final BcbCampaignClient _client;

  BcbCampaignService({BcbCampaignClient? client})
      : _client = client ?? BcbCampaignClient();

  /// GET App/BcbCampaign?accountId={accountId} — lấy danh sách chiến dịch của KH
  Future<List<BcbCampaignModel>> getCampaigns(String accountId) {
    return _client.fetchCampaigns(accountId);
  }

  /// GET App/BcbPartnerScheduleDay/BcBCampaignId?bcbCampaignId=…
  Future<List<BcbPartnerScheduleDay>> getPartnerScheduleDays(
      String bcbCampaignId) {
    return _client.fetchPartnerScheduleDays(bcbCampaignId);
  }

  /// POST App/BcbCustomerRegistration
  Future<void> submitRegistration(BcbCampaignRegistrationModel registration) {
    return _client.submitRegistration(registration);
  }

  /// GET App/BcbExamResult/{campaignCustomerId} — lấy kết quả khám
  Future<BcbExamResultModel> getExamResult(String campaignCustomerId) {
    return _client.fetchExamResult(campaignCustomerId);
  }

  /// PUT App/BcbExamResult/{id}/mark-viewed — đánh dấu đã xem
  Future<void> markResultViewed(String examResultId) {
    return _client.markResultViewed(examResultId);
  }
}
