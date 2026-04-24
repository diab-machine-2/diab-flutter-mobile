import 'package:medical/src/model/bcb_campaign/bcb_campaign_model.dart';
import 'package:medical/src/model/bcb_campaign/bcb_customer_model.dart';
import 'package:medical/src/model/bcb_campaign/bcb_exam_result_model.dart';
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

  /// GET App/BcbCampaignCustomer/{campaignCustomerId} — lấy thông tin KH trong chiến dịch
  Future<BcbCustomerModel> getCustomerDetail(String campaignCustomerId) {
    return _client.fetchCustomerDetail(campaignCustomerId);
  }

  /// POST App/BcbCustomerRegistration — KH submit form + 3 wishes
  Future<void> submitRegistration(BcbCustomerRegistrationModel registration) {
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
