import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:medical/src/model/bcb_campaign/bcb_exam_result_model.dart';
import 'package:medical/src/model/bcb_campaign/bcb_registration_model.dart';
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
    if (event is SubmitBcbRegistrationEvent) {
      yield* _submitRegistration(event);
    } else if (event is RescheduleBcbAppointmentEvent) {
      yield* _rescheduleAppointment(event);
    } else if (event is LoadBcbExamResultEvent) {
      yield* _loadExamResult(event);
    } else if (event is MarkResultViewedEvent) {
      yield* _markResultViewed(event.examResultId);
    }
  }

  Stream<BcbCampaignState> _submitRegistration(
      SubmitBcbRegistrationEvent event) async* {
    try {
      yield BcbCampaignLoading();
      final client = BcbCampaignClient();
      await client.submitRegistration(
        BcbCampaignRegistrationModel(
          bcbCampaignId: event.bcbCampaignId,
          doctorNote: event.doctorNote,
          slotId: event.slotId,
        ),
      );
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

  Stream<BcbCampaignState> _rescheduleAppointment(
      RescheduleBcbAppointmentEvent event) async* {
    try {
      yield BcbCampaignLoading();
      final client = BcbCampaignClient();
      await client.rescheduleAppointment(
        appointmentId: event.appointmentId,
        slotId: event.slotId,
      );
      yield BcbAppointmentRescheduled();
    } catch (e, _) {
      if (e is Error) {
        yield BcbCampaignError(message: e.message ?? '');
      } else {
        yield BcbCampaignError(
            message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<BcbCampaignState> _loadExamResult(
      LoadBcbExamResultEvent event) async* {
    try {
      yield BcbCampaignLoading();
      final client = BcbCampaignClient();
      final results = await client.fetchExamResult(
        campaignId: event.campaignCustomerId,
      );
      yield BcbExamResultLoaded(results: results);
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
