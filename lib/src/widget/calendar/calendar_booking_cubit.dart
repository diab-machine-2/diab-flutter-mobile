import 'package:flutter_bloc/flutter_bloc.dart';
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

  static int updateCount = 1;

  CalendarBookingCubit(this.repository) : super(InitialCalendarBookingState());

  Future<List<CalendarCoachModel>> getCalendarBooking() async {
    emit(CalendarBookingLoading());
    List<CalendarCoachModel> data =
        await UserClient().fetchCalendarCoach() ?? [];
    calendarCoachs = data;
    emit(CalendarBookingSuccess());
    return data;
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
