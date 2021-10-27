import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/send_feedback_course_request.dart';
import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';

import 'booking_coach.dart';

class BookingCoachCubit extends Cubit<BookingCoachState> {
  final AppRepository repository;
  DateTime? selectedDate;
  String? selectedTime;

  BookingCoachCubit(this.repository) : super(InitialBookingCoachState());

  void pickDate(DateTime date) {
    emit(BookingCoachLoading());
    this.selectedDate = date;
    emit(SelectedDateSuccess());
  }

  void pickTime(String time) {
    emit(BookingCoachLoading());
    this.selectedTime = time;
    emit(InitialBookingCoachState());
  }

  void sendFeedback(String lessonId, String note) async {
    emit(BookingCoachLoading());
    SendFeedbackCourseRequest request = SendFeedbackCourseRequest(lessonId: lessonId, note: note, rating: 0);
    ApiResult<CommonResponse> apiResult = await repository.sendFeedbackCourse(request);
    apiResult.when(success: (CommonResponse response) {
      emit(BookingCoachSuccess());
    }, failure: (NetworkExceptions error) {
      emit(BookingCoachFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }
}
