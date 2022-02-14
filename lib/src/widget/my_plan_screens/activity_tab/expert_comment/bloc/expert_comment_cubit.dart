import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/expert_comment/model/expert_comment_model.dart';
import '../expert_comment.dart';

class ExpertCommentCubit extends Cubit<ExpertCommentState> {
  List<ExpertCommentModel> commentList = [];
  final AppRepository repository;

  ExpertCommentCubit(this.repository) : super(ExpertCommentInitial()) {
    getData();
  }

  getData() async {
    emit(ExpertCommentLoading());
    commentList = [];
    for (int i = 0; i < 10; i++) {
      commentList.add(
        ExpertCommentModel(
            name: 'Duc Pham $i',
            role: 'Tư vấn cá nhân $i',
            comment:
                'Bạn đã hoàn thành rất tốt những mục tiêu, hãy giữ nguyên phong độ này trong thời gian sắp tới và đón nhận những kết quả tích cực hơn nhé!',
            dateTime: '24/12/2021',
            url: ''),
      );
    }

    // final ApiResult<SmartGoalListReponse> apiResult =
    //     await repository.getListSmartGoal(day: currentDay, week: currentWeek);
    // apiResult.when(success: (SmartGoalListReponse response) {
    //   emit(const ExpertCommentSuccess());
    // }, failure: (NetworkExceptions error) {
    //   emit(ExpertCommentFailure(NetworkExceptions.getErrorMessage(error)));
    // });
    emit(ExpertCommentSuccess());
  }
}
