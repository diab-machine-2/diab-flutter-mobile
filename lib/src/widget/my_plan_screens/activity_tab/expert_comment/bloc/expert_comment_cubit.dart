import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/expert_comment_list_response.dart';
import 'package:medical/src/model/response/user_info_referral_code_response.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/expert_comment/model/expert_comment_model.dart';
import '../../../../../model/service/api_result.dart';
import '../../../../../model/service/network_exceptions.dart';
import '../expert_comment.dart';

class ExpertCommentCubit extends Cubit<ExpertCommentState> {
  List<ExpertCommentModel>? commentList;
  final AppRepository repository;
  var user = AppSettings.userInfo!;

  ExpertCommentCubit(this.repository) : super(ExpertCommentInitial()) {
    getData();
  }

  getData() async {
    await Future.delayed(Duration(microseconds: 50));
    emit(ExpertCommentLoading());
    final ApiResult<ExpertCommentListResponse> apiResult =
        await repository.getCommentProfessorByAccountId(user.id!);
    apiResult.when(success: (ExpertCommentListResponse response) {
      commentList = response.data?.items ?? [];
      emit(const ExpertCommentSuccess());
    }, failure: (NetworkExceptions error) {
      commentList = [];
      // commentList!.add(ExpertCommentModel(
      //   calendarTrainingId: 'calendarTrainingId',
      //   accountId: 'accountId',
      //   comment:
      //       'Bạn đã hoàn thành rất tốt những mục tiêu, hãy giữ nguyên phong độ này trong thời gian sắp tới và đón nhận những kết quả tích cực hơn nhé!',
      //   creatorId: 'creatorId',
      //   creator: 'Duc',
      //   updateDateTime: 1644999319,
      //   calendarTraining: CalendarTraining(
      //     calendarId: 'calendarId',
      //     trainingGroupId: 'trainingGroupId',
      //     comment:
      //         'Bạn đã hoàn thành rất tốt những mục tiêu, hãy giữ nguyên phong độ này trong thời gian sắp tới và đón nhận những kết quả tích cực hơn nhé!',
      //     coachId: 'coachId',
      //     type: 3,
      //     calendar: CalendarModel(
      //       name: 'name',
      //       type: 0,
      //       appointmentDate: 1644999319,
      //       duration: 10,
      //       performerId: 'performerId',
      //       repeatType: 0,
      //       goal: 'goal',
      //       meetingLink: 'meetingLink',
      //       meetingPassword: 'meetingPassword',
      //       calendarSchedulerId: 'calendarSchedulerId',
      //       calendarId: 'calendarId',
      //       roomId: 'roomId',
      //       complete: false,
      //       performer: UserInfoReferralCodeResponseData(
      //           fullName: 'Duc Pham',
      //           avatar: 'https://i.picsum.photos/id/866/300/300.jpg?hmac=9qmLpcaT9TgKd6PD37aZJZ_7QvgrVFMcvI3JQKWVUIQ'),
      //     ),
      //   ),
      // ));
      emit(ExpertCommentFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }
}
