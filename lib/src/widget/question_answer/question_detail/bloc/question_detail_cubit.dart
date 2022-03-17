import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/make_comment_request.dart';
import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/response/question_answer_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/widget/question_answer/all_question_answer/model/question_model.dart';
import '../question_detail.dart';

class QuestionDetailCubit extends Cubit<QuestionDetailState> {
  QuestionModel questionModel;
  bool isAll = true;
  final AppRepository repository;
  Timer? timer;
  bool isClickSend = false;
  bool canRefreshScreen = true;
  final userInfo = AppSettings.userInfo;
  double titleHeight = 280;
  final ScrollController commentScrollController = ScrollController();

  QuestionDetailCubit(this.repository, this.isAll, this.questionModel) : super(QuestionDetailInitial()) {}

  Future<bool> get keyboardHidden async {
    final check = () => (WidgetsBinding.instance?.window.viewInsets.bottom ?? 0) <= 0;
    if (!check()) return false;
    return await Future.delayed(Duration(milliseconds: 100), () => check());
  }

  refreshScreen() {
    if (canRefreshScreen) {
      emit(QuestionDetailLoading());
      emit(QuestionDetailSuccess());
    }
  }

  getQuestionById({bool isShowLoading = false}) async {
    if (isShowLoading) {
      emit(QuestionDetailLoading());
    }
    final ApiResult<QuestionResponse> apiResult = await repository.getQuestionById(questionModel.id!);
    apiResult.when(success: (QuestionResponse response) {
      if (response.data != null) {
        questionModel = questionModel.copyWith(
          id: response.data!.id,
          status: response.data!.status,
          createDateTime: response.data!.createDateTime,
          creator: response.data!.creator,
          creatorId: response.data!.creatorId,
          creatorUrl: response.data!.creatorUrl,
          accountId: response.data!.accountId,
          lessonModule: response.data!.lessonModule,
          lessonModuleId: response.data!.lessonModuleId,
          professor: response.data!.professor,
          answers: response.data!.answers,
        );
        emit(const QuestionDetailSuccess());

        //if (questionModel.answers != null && questionModel.answers!.isNotEmpty) {
        //   commentScrollController.jumpTo(questionModel.answers!.length - 1);
        //}
        
        // if (isAll) {
        //   if (questionModel.status == 0) {
        //     if (questionModel.answers != null && questionModel.answers!.isNotEmpty) {
        //       bool isReplied = false;
        //       for (var answer in questionModel.answers!) {
        //         if (answer.accountId != userInfo?.accountId) {
        //           isReplied = true;
        //           break;
        //         }
        //       }
        //       questionModel.status = isReplied ? 2 : 1;
        //     } else {
        //       questionModel.status = 1;
        //     }
        //   }
        // }
      }
    }, failure: (NetworkExceptions error) {
      emit(QuestionDetailFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }

  // Future<void> sendComment(String? body) async {
  //   var userInfo = AppSettings.userInfo;
  //   if (userInfo == null) return;

  //   emit(QuestionDetailLoading());
  //   final MakeCommentRequest request =
  //       MakeCommentRequest(body: body, questionId: questionModel.id, accountId: userInfo.accountId);
  //   var response = await QuestionAnswerClient().makeComment(request);
  //   if (response is bool && response) {
  //     await getQuestionById();
  //   } else if (response is Error) {
  //     emit(MakeCommentFailure(response.message ?? ''));
  //   } else if (response is String) {
  //     emit(MakeCommentFailure(response));
  //   }
  // }

  Future<void> sendComment(String? body) async {
    var userInfo = AppSettings.userInfo;
    if (userInfo == null) return;
    canRefreshScreen = false;
    emit(QuestionDetailLoading());
    final MakeCommentRequest request = MakeCommentRequest(
        body: body?.trim() ?? '', questionId: questionModel.id, accountId: userInfo.accountId, isComment: true);
    final ApiResult<CommonResponse> apiResult = await repository.makeComment(request);
    apiResult.when(success: (CommonResponse response) async {
      canRefreshScreen = true;
      await Future.delayed(Duration(milliseconds: 100));
      await getQuestionById();
    }, failure: (NetworkExceptions error) {
      canRefreshScreen = true;
      emit(MakeCommentFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }

  Future<void> deleteQuestion(String id) async {
    emit(QuestionDetailLoading());
    canRefreshScreen = false;
    final ApiResult<CommonResponse> apiResult = await repository.deleteQuestion(id);
    apiResult.when(success: (CommonResponse response) {
      canRefreshScreen = true;
      emit(DeleteQuestionSuccess(message: id));
    }, failure: (NetworkExceptions error) {
      canRefreshScreen = true;
      emit(DeleteQuestionFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }

  Future<void> deleteComment(String id) async {
    emit(QuestionDetailLoading());
    canRefreshScreen = false;
    final ApiResult<CommonResponse> apiResult = await repository.deleteComment(id);
    apiResult.when(success: (CommonResponse response) {
      canRefreshScreen = true;
      if (questionModel.answers != null) {
        questionModel.answers!.removeWhere((element) => element.id == id);
      }
      emit(DeleteCommentSuccess(message: id));
    }, failure: (NetworkExceptions error) {
      canRefreshScreen = true;
      emit(DeleteCommentFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }

  setClickSend() {
    isClickSend = true;
    if (timer != null) timer!.cancel();
    timer = Timer(Duration(seconds: 3), () {
      isClickSend = false;
    });
  }
}
