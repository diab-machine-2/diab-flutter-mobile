import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/booking_success_request.dart';
import 'package:medical/src/model/request/create_calendar_request.dart';
import 'package:medical/src/model/request/delete_calendar_request.dart';
import 'package:medical/src/model/response/branchio_generate_zoom_response.dart';
import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/response/create_calendar_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/widget/calendar/calendar_booking_state.dart';
import 'package:medical/src/widget/calendar/calendar_model.dart';
import 'package:medical/src/modal/error/error_model.dart' as error;

class CalendarBookingCubit extends Cubit<CalendarBookingState> {
  final AppRepository repository;

  late List<CalendarCoachModel> calendarCoachs = [];

  static CreateCalendarResponse? myCalendar;

  static int updateCount = 1;

  CalendarBookingCubit(this.repository) : super(InitialCalendarBookingState());

  Future<List<CalendarCoachModel>> getCalendarCoach(
      String courseId, String endTime,
      {String? id, bool isAdd1Day = true}) async {
    try {
      emit(CalendarBookingLoading());

      List<CalendarCoachModel> data = await UserClient()
              .fetchCalendarCoach(courseId, endTime, isAdd1Day: isAdd1Day) ??
          [];

      // Filter based on status
      data = data
          .where((e) =>
              e.status == 0 ||
              (myCalendar != null &&
                  e.startTime == myCalendar!.appointmentDate))
          .toList();

      List<CalendarCoachModel> extendedData = data;
      if (isAdd1Day == false) {
        data = data.where((calendar) {
          final now = DateTime.now();
          final compareDate = DateTime.utc(now.year, now.month, now.day,
                      now.hour, now.minute, now.second)
                  .add(Duration(days: 1))
                  .millisecondsSinceEpoch ~/
              1000;
          final validDate = calendar.startTime >= compareDate;
          return validDate;
        }).toList();
      }

      calendarCoachs = data;
      emit(CalendarBookingSuccess());
      return isAdd1Day == false ? extendedData : data;
    } catch (e) {
      emit(CalendarBookingFailure(
          (e as error.Error).message ?? R.string.error_unexpected_error.tr()));
      return [];
    } finally {
      BotToast.closeAllLoading();
    }
  }

  Future<void> completedCalendar(String calendarId, String courseId) async {
    try {
      await repository.markCompletedCalendar(calendarId);
      await repository.updateDoneInterview(courseId);
    } catch (e) {
      print(e);
    }
  }

  Future<void> initializeMyCalendar({
    required String courseId,
    DateTime? startDate,
    DateTime? endDate,
    int interviewType = 30,
  }) async {
    startDate = DateTime.now().add(Duration(days: 0));
    endDate = DateTime.now()
        .add(Duration(days: Const.MAX_DAY_RANGE_PRIMARY_SCREENING));
    emit(CalendarBookingLoading());

    final request = CalendarFilter(
      accountPatientId: AppSettings.userInfo!.accountId,
      courseId: courseId,
      fromDate: startDate,
      toDate: endDate,
      calendarType: interviewType,
    );

    final ApiResult<List<CreateCalendarResponse>> apiResult =
        await repository.getMyCalendar(request);
    apiResult.when(success: (List<CreateCalendarResponse> response) {
      if (response.length > 0) {
        updateCount = response.length;
        var filteredItems = response.where((item) => item.isDeleted == false);
        myCalendar = filteredItems.isNotEmpty ? filteredItems.first : null;
      }
      emit(CalendarBookingCloseLoading());
    }, failure: (NetworkExceptions error) {
      emit(CalendarBookingFailure("Lỗi hệ thống trong quá trình tạo lịch"));
    });
  }

  Future<bool> createCalendar(
    CreateCalendarRequest request,
  ) async {
    bool result = false;
    emit(CalendarBookingLoading());
    final ApiResult<CreateCalendarResponse> apiResult =
        await repository.createCalendar(request);
    apiResult.when(success: (CreateCalendarResponse response) async {
      myCalendar = response;
      result = true;

      // final email = AppSettings.userInfo!.email ?? '';
      // final topic = "Phỏng Vấn Đầu Vào - ${AppSettings.userInfo!.fullName}";
      // DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
      //     response.appointmentDate * 1000,
      //     isUtc: true); // Convert seconds to milliseconds
      // String formattedDate =
      //     DateFormat('MM/dd/yyyy hh:mm:ss a', 'en_US').format(dateTime);
      // final branchioLink = await getZoomLink(
      //   email: email.isEmpty ? 'diabvn21coach5@gmail.com' : email,
      //   topic: topic,
      //   date: formattedDate,
      // );

      final bookingSuccessRequest = BookingSuccessRequest(
        link: response.dynamicLink ?? '',
        appointmentDate: response.appointmentDate,
        coachName: response.updaterName ?? '',
      );
      await notifyBookingSuccess(bookingSuccessRequest);

      emit(CreateCalendarSuccess(response));
      emit(CalendarBookingCloseLoading());
      // return apiResult;
    }, failure: (NetworkExceptions error) {
      log('[BOOKING] error ${error.toString()}');
      emit(CalendarBookingFailure("Lỗi trong quá trình đặt lịch"));
    });
    return result;
  }

  Future<String?> getZoomLink(
      {String? email, String? topic, String? date}) async {
    String? branchioLink;
    final ApiResult<BranchioGenerateZoomResponse> apiResult = await repository
        .branchioGenerateZoom(email: email, topic: topic, date: date);
    apiResult.when(success: (BranchioGenerateZoomResponse response) {
      branchioLink = response.branchioLink;
    }, failure: (NetworkExceptions error) {
      emit(CalendarBookingFailure("Lấy link Zoom thất bại"));
    });
    return branchioLink;
  }

  Future<void> notifyBookingSuccess(BookingSuccessRequest request) async {
    final ApiResult<CommonResponse> apiResult =
        await repository.notifyBookingSuccess(request);
    apiResult.when(success: (CommonResponse response) async {
      return;
    }, failure: (NetworkExceptions error) {
      emit(CalendarBookingFailure("Xác nhận đặt lịch thất bại"));
    });
  }

  Future<void> deleteCalendar(
    DeleteCalendarRequest request,
  ) async {
    final ApiResult<CommonResponse> apiResult =
        await repository.deleteCalendar(request.id, request);
    apiResult.when(success: (response) {
      emit(DeleteCalendarSuccess());
    }, failure: (NetworkExceptions error) {
      emit(CalendarBookingFailure("Lỗi hệ thống trong quá trình xoá lịch"));
    });
  }
}
