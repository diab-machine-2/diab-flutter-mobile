import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/expert_comment_list_response.dart';
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
    emit(ExpertCommentLoading());
    final ApiResult<ExpertCommentListResponse> apiResult = await repository
        .getCommentProfessorByAccountId(user.accountId!);
    apiResult.when(success: (ExpertCommentListResponse response) {
        commentList = [];
        commentList = response.data!;
      emit(const ExpertCommentSuccess());
    }, failure: (NetworkExceptions error) {
      commentList = [];
      emit(ExpertCommentFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }
}
