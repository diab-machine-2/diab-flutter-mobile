import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/send_feedback_course_request.dart';
import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';

import 'course_feedback.dart';

class CourseFeedbackCubit extends Cubit<CourseFeedbackState> {
  final AppRepository repository;
  int rate = 0;

  CourseFeedbackCubit(this.repository) : super(InitialCourseFeedbackState());

  void rateFeedback(int rate) {
    emit(CourseFeedbackLoading());
    this.rate = rate;
    emit(InitialCourseFeedbackState());
  }

  void sendFeedback(String lessonId, String note) async {
    emit(CourseFeedbackLoading());
    SendFeedbackCourseRequest request = SendFeedbackCourseRequest(lessonId: lessonId, note: note, rating: rate);
    ApiResult<CommonResponse> apiResult = await repository.sendFeedbackCourse(request);
    apiResult.when(success: (CommonResponse response) {
      emit(CourseFeedbackSuccess());
    }, failure: (NetworkExceptions error) {
      emit(CourseFeedbackFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }
}
