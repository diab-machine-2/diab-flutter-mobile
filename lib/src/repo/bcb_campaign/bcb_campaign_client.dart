import 'package:dio/dio.dart';
import 'package:medical/src/widget/helper/http_helper.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/model/bcb_campaign/bcb_campaign_model.dart';
import 'package:medical/src/model/bcb_campaign/bcb_customer_model.dart';
import 'package:medical/src/model/bcb_campaign/bcb_exam_result_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';

class BcbCampaignClient extends FetchClient {
  /// GET App/BcbCampaign?accountId={accountId} — lấy danh sách chiến dịch của KH
  Future<List<BcbCampaignModel>> fetchCampaigns(String? accountId) async {
    try {
      final Map<String, String> params = {};
      if (accountId != null) {
        params['accountId'] = accountId;
      }
      final Response response = await super.fetchData(
        url: '/App/BcbCampaign',
        params: params,
      );
      if (response.statusCode == 200) {
        if (response.data['data'] == null) {
          return [];
        }
        return BcbCampaignModel.toList(
            response.data['data'] as List<dynamic>);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  /// GET App/BcbCampaignCustomer/{campaignCustomerId} — lấy thông tin KH trong chiến dịch
  Future<BcbCustomerModel> fetchCustomerDetail(
      String campaignCustomerId) async {
    try {
      final Response response = await super.fetchData(
        url: '/App/BcbCampaignCustomer/$campaignCustomerId',
      );
      if (response.statusCode == 200) {
        return BcbCustomerModel.fromJson(
            response.data['data'] as Map<String, dynamic>);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  /// POST App/BcbCustomerRegistration — KH submit form + 3 wishes
  Future<void> submitRegistration(
      BcbCustomerRegistrationModel registration) async {
    try {
      final Response response = await super.postData(
        url: '/App/BcbCustomerRegistration',
        params: registration.toJson(),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  /// GET App/BcbExamResult/{campaignCustomerId} — lấy kết quả khám
  Future<BcbExamResultModel> fetchExamResult(
      String campaignCustomerId) async {
    try {
      final Response response = await super.fetchData(
        url: '/App/BcbExamResult/$campaignCustomerId',
      );
      if (response.statusCode == 200) {
        return BcbExamResultModel.fromJson(
            response.data['data'] as Map<String, dynamic>);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  /// PUT App/BcbExamResult/{id}/mark-viewed — đánh dấu đã xem
  Future<void> markResultViewed(String examResultId) async {
    try {
      final Response response = await super.putData(
        url: '/App/BcbExamResult/$examResultId/mark-viewed',
        params: {},
      );
      if (response.statusCode != 200) {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }
}
