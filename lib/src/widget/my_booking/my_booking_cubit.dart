import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/send_feedback_course_request.dart';
import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';

import 'my_booking.dart';

class MyBookingCubit extends Cubit<MyBookingState> {
  final AppRepository repository;
  DateTime? selectedDate;
  String? selectedTime;

  MyBookingCubit(this.repository) : super(InitialMyBookingState());

  void pickDate(DateTime date) {
    emit(MyBookingLoading());
    this.selectedDate = date;
    emit(SelectedDateSuccess());
  }

  void pickTime(String time) {
    emit(MyBookingLoading());
    this.selectedTime = time;
    emit(InitialMyBookingState());
  }

  Future<void> sendFeedback(String lessonId, String note) async {
    emit(MyBookingLoading());
    final SendFeedbackCourseRequest request =
        SendFeedbackCourseRequest(lessonId: lessonId, note: note, rating: 0);
    final ApiResult<CommonResponse> apiResult =
        await repository.sendFeedbackCourse(request);
    apiResult.when(success: (CommonResponse response) {
      emit(MyBookingSuccess());
    }, failure: (NetworkExceptions error) {
      emit(MyBookingFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }
}
