import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/response/expert_comment_response.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/expert_comment/model/expert_comment_model.dart';
import '../../../../../../model/repository/app_repository.dart';
import '../../../../../../model/service/api_result.dart';
import '../../../../../../model/service/network_exceptions.dart';
import '../expert_comment_detail.dart';

class ExpertCommentDetailCubit extends Cubit<ExpertCommentDetailState> {
  final AppRepository repository;
  ExpertCommentModel? expertCommentModel;

  ExpertCommentDetailCubit(this.repository, this.expertCommentModel) : super(ExpertCommentDetailInitial()) {
    // TODO
  }

  getCommentById(String id) async {
    emit(ExpertCommentDetailLoading());
    final ApiResult<ExpertCommentResponse> apiResult = await repository.getCommentById(id);
    apiResult.when(success: (ExpertCommentResponse response) {
      expertCommentModel = response.data;
      emit(const ExpertCommentDetailSuccess());
    }, failure: (NetworkExceptions error) {
      emit(ExpertCommentDetailFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }
}