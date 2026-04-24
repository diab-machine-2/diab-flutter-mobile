import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:medical/src/model/bcb_campaign/bcb_campaign_model.dart';
import 'package:medical/src/model/bcb_campaign/bcb_customer_model.dart';
import 'package:medical/src/model/bcb_campaign/bcb_exam_result_model.dart';
import 'package:medical/src/repo/bcb_campaign/bcb_campaign_client.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';

part 'bcb_campaign_bloc_event.dart';
part 'bcb_campaign_bloc_state.dart';

class BcbCampaignBloc extends Bloc<BcbCampaignEvent, BcbCampaignState> {
  BcbCampaignBloc() : super(BcbCampaignInitial());

  @override
  Stream<BcbCampaignState> mapEventToState(BcbCampaignEvent event) async* {
    if (event is LoadBcbCampaignEvent) {
      yield* _loadCampaigns(event.campaignId);
    } else if (event is LoadMyBcbCustomerEvent) {
      yield* _loadMyCustomer(event.campaignId);
    } else if (event is SubmitBcbRegistrationEvent) {
      yield* _submitRegistration(event);
    } else if (event is LoadBcbExamResultEvent) {
      yield* _loadExamResult(event.campaignCustomerId);
    } else if (event is MarkResultViewedEvent) {
      yield* _markResultViewed(event.examResultId);
    }
  }

  Stream<BcbCampaignState> _loadCampaigns(String? campaignId) async* {
    try {
      yield BcbCampaignLoading();
      final client = BcbCampaignClient();
      final campaigns = await client.fetchCampaigns(campaignId);
      yield BcbCampaignListLoaded(campaigns: campaigns);
    } catch (e, _) {
      if (e is Error) {
        yield BcbCampaignError(message: e.message ?? '');
      } else {
        yield BcbCampaignError(
            message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<BcbCampaignState> _loadMyCustomer(String campaignId) async* {
    try {
      yield BcbCampaignLoading();
      final client = BcbCampaignClient();
      final customer = await client.fetchCustomerDetail(campaignId);
      yield BcbCampaignLoaded(customer: customer);
    } catch (e, _) {
      if (e is Error) {
        yield BcbCampaignError(message: e.message ?? '');
      } else {
        yield BcbCampaignError(
            message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<BcbCampaignState> _submitRegistration(
      SubmitBcbRegistrationEvent event) async* {
    try {
      yield BcbCampaignLoading();
      final client = BcbCampaignClient();
      final registration = BcbCustomerRegistrationModel(
        campaignCustomerId: event.campaignCustomerId,
        doctorNote: event.doctorNote,
        medicalHistory: event.medicalHistory,
        wishes: event.wishes,
      );
      await client.submitRegistration(registration);
      yield BcbRegistrationSubmitted();
    } catch (e, _) {
      if (e is Error) {
        yield BcbCampaignError(message: e.message ?? '');
      } else {
        yield BcbCampaignError(
            message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<BcbCampaignState> _loadExamResult(String campaignCustomerId) async* {
    try {
      yield BcbCampaignLoading();
      final client = BcbCampaignClient();
      final result = await client.fetchExamResult(campaignCustomerId);
      yield BcbExamResultLoaded(result: result);
    } catch (e, _) {
      if (e is Error) {
        yield BcbCampaignError(message: e.message ?? '');
      } else {
        yield BcbCampaignError(
            message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<BcbCampaignState> _markResultViewed(String examResultId) async* {
    try {
      final client = BcbCampaignClient();
      await client.markResultViewed(examResultId);
      yield BcbResultMarkedViewed();
    } catch (e, _) {
      // Silent failure — best effort mark as viewed
    }
  }
}
