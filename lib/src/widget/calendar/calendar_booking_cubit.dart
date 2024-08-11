import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/create_calendar_request.dart';
import 'package:medical/src/model/response/create_calendar_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/widget/calendar/calendar_booking_state.dart';
import 'package:medical/src/widget/calendar/calendar_model.dart';

class CalendarBookingCubit extends Cubit<CalendarBookingState> {
  final AppRepository repository;

  late List<CalendarCoachModel> calendarCoachs = [];

  static CreateCalendarResponse? myCalendar;
  static String? courseId;

  static int updateCount = 1;

  CalendarBookingCubit(this.repository) : super(InitialCalendarBookingState());

  Future<List<CalendarCoachModel>> getCalendarBooking({String? id}) async {
    try {
      emit(CalendarBookingLoading());

      List<CalendarCoachModel> data =
          await UserClient().fetchCalendarCoach() ?? [];

      // Filter based on status
      data = data
          .where((e) =>
              e.status == 0 ||
              (myCalendar != null &&
                  e.startTime == myCalendar!.appointmentDate))
          .toList();

      calendarCoachs = data;
      emit(CalendarBookingSuccess());
      return data;
    } catch (e) {
      emit(CalendarBookingFailure(
          "An error occurred while fetching calendar data."));
      return [];
    } finally {
      BotToast.closeAllLoading();
    }
  }

  Future<void> completedCalendar(String id) async {
    try {
      await repository.markCompletedCalendar(id);
    } catch (e) {
      print(e);
    }
  }

  Future<void> initializeMyCalendar({
    String? courseId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    courseId ??= "71546da0-3a83-11ef-956b-3713adbaa661";
    startDate ??= DateTime.now().add(Duration(days: 1));
    endDate ??= DateTime.now().add(Duration(days: 21));
    emit(CalendarBookingLoading());

    final request = CalendarFilter(
        accountPatientId: AppSettings.userInfo!.accountId,
        courseId: courseId,
        fromDate: startDate,
        toDate: endDate,
        calendarType: 1);

    final ApiResult<List<CreateCalendarResponse>> apiResult =
        await repository.getMyCalendar(request);
    apiResult.when(success: (List<CreateCalendarResponse> response) {
      if (response.length > 0) {
        updateCount = response.length;
        var filteredItems = response.where((item) => item.isDeleted == false);
        myCalendar = filteredItems.isNotEmpty ? filteredItems.first : null;
      }
    }, failure: (NetworkExceptions error) {
      emit(CalendarBookingFailure("Lỗi hệ thống trong quá trình tạo lịch"));
    });
  }

  Future<void> createCalendar(
    CreateCalendarRequest request,
  ) async {
    emit(CalendarBookingLoading());
    final ApiResult<CreateCalendarResponse> apiResult =
        await repository.createCalendar(request);
    apiResult.when(success: (CreateCalendarResponse response) {
      myCalendar = response;
      emit(CreateCalendarSuccess(response));
      return apiResult;
    }, failure: (NetworkExceptions error) {
      emit(CalendarBookingFailure("Lỗi hệ thống trong quá trình tạo lịch"));
    });
  }

  Future<void> deleteCalendar(
    Map<String, String> request,
  ) async {
    emit(CalendarBookingLoading());
    final ApiResult<Map<String, dynamic>?> apiResult =
        await repository.deleteCalendar(request);
    apiResult.when(success: (response) {
      print(request);
      emit(DeleteCalendarSuccess());
    }, failure: (NetworkExceptions error) {
      emit(CalendarBookingFailure("Lỗi hệ thống trong quá trình tạo lịch"));
    });
  }
}
