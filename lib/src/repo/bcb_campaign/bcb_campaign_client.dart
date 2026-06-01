import 'package:dio/dio.dart';
import 'package:medical/src/widget/helper/http_helper.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/model/bcb_campaign/bcb_campaign_model.dart';
import 'package:medical/src/model/bcb_campaign/bcb_exam_result_model.dart';
import 'package:medical/src/model/bcb_campaign/bcb_partner_schedule_model.dart';
import 'package:medical/src/model/bcb_campaign/bcb_registration_model.dart';
import 'package:medical/src/model/bcb_campaign/bcb_customer_appointment_model.dart';
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
        return BcbCampaignModel.toList(response.data['data'] as List<dynamic>);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  /// GET App/BcbPartnerScheduleDay/BcBCampaignId?bcbCampaignId={uuid}
  Future<List<BcbPartnerScheduleDay>> fetchPartnerScheduleDays(
      String bcbCampaignId) async {
    try {
      final Response response = await super.fetchData(
        url: '/App/BcbPartnerScheduleDay/BcBCampaignId',
        params: {'bcbCampaignId': bcbCampaignId},
      );
      if (response.statusCode == 200) {
        final body = response.data;
        final raw = body is Map<String, dynamic> ? body['data'] : body;
        return BcbPartnerScheduleDay.listFrom(raw);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  /// POST App/BcbCustomerRegistration — đăng ký với 1 slotId đã chọn
  Future<void> submitRegistration(
      BcbCampaignRegistrationModel registration) async {
    try {
      final formData = FormData();
      formData.fields.add(MapEntry('campaignId', registration.bcbCampaignId));
      if (registration.doctorNote != null &&
          registration.doctorNote!.trim().isNotEmpty) {
        formData.fields.add(MapEntry('doctorNote', registration.doctorNote!));
      }
      formData.fields.add(MapEntry('slotId', registration.slotId));
      final Response response = await super.postData(
        url: '/App/BcbCustomerRegistration',
        params: formData,
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  /// GET App/BcbExamResult/CampaginCustomerId — lấy kết quả khám
  Future<List<BcbExamResultModel>> fetchExamResult({String? campaignId}) async {
    try {
      final Map<String, String> params = {};
      if (campaignId != null && campaignId.isNotEmpty) {
        params['campaignId'] = campaignId;
      }
      final Response response = await super.fetchData(
        url: '/App/BcbExamResult/CampaginCustomerId',
        params: params,
      );
      if (response.statusCode == 200) {
        final body = response.data;
        final raw = body is Map<String, dynamic> ? body['data'] : body;
        return BcbExamResultModel.listFrom(raw);
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

  /// GET App/BcbCustomerAppointment/my-registered?campaignId={campaignId}
  Future<BcbCustomerAppointmentModel?> fetchMyRegisteredAppointment(
      String campaignId) async {
    try {
      final Response response = await super.fetchData(
        url: '/App/BcbCustomerAppointment/my-registered',
        params: {'campaignId': campaignId},
      );
      if (response.statusCode == 200) {
        final body = response.data;
        final raw = body is Map<String, dynamic> ? body['data'] : body;
        if (raw == null) return null;
        return BcbCustomerAppointmentModel.fromJson(
            raw as Map<String, dynamic>);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }
}

