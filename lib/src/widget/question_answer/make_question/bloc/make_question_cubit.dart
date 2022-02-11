import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/make_question_request.dart';
import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/response/lesson_module_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/repo/question_answer/question_answer_client.dart';
import '../make_question.dart';
import 'package:medical/src/modal/error/error_model.dart';

class MakeQuestionCubit extends Cubit<MakeQuestionState> {
  LessonModuleItem? currentLessonModule;
  final AppRepository repository;
  final List<LessonModuleItem> lessonModuleItems;
  String textSearch = '';

  Timer? timer;
  bool isClickSend = false;
  bool isShowSuggestLessonModuleList = false;

  List<LessonModuleItem?> get suggestLessonModuleItems {
    final List<LessonModuleItem?> suggestList = lessonModuleItems;
    if (textSearch.isEmpty) return suggestList;
    final List<LessonModuleItem?> suggestFiltered = [];
    for (final LessonModuleItem? filterDataItem in suggestList) {
      if (filterDataItem?.name
              ?.toUpperCase()
              .contains(textSearch.toUpperCase()) ==
          true) {
        suggestFiltered.add(filterDataItem);
      }
    }
    return suggestFiltered;
  }

  MakeQuestionCubit(this.repository, this.lessonModuleItems) : super(MakeQuestionInitial()) {}

  setCurrentLessonModule(LessonModuleItem item) {
    currentLessonModule = item;
    emit(MakeQuestionInitial());
    emit(MakeQuestionSuccess());
  }

  void refresh() {
    emit(MakeQuestionSuccess());
    emit(MakeQuestionInitial());
  }

  Future<void> sendQuestion(String? body) async {
    if (currentLessonModule == null) return;
    var userInfo = AppSettings.userInfo;
    if (userInfo == null) return;
    body = body?.trim() ?? '';

    emit(MakeQuestionLoading());
    final MakeQuestionRequest request =
        MakeQuestionRequest(body: body, lessonModuleId: currentLessonModule!.id, accountId: userInfo.accountId);
    var response = await QuestionAnswerClient().makeQuestion(request);
    if (response is bool && response) {
      emit(SendQuestionSuccess());
    } else if (response is Error) {
      emit(SendQuestionFailure(response.message ?? ''));
    } else if (response is String) {
      emit(SendQuestionFailure(response));
    }

    // final ApiResult<CommonResponse> apiResult = await repository.makeQuestion(request);
    // apiResult.when(success: (CommonResponse response) {
    //   emit(SendQuestionSuccess());
    // }, failure: (NetworkExceptions error) {
    //   emit(SendQuestionFailure(NetworkExceptions.getErrorMessage(error)));
    // });
  }

  setClickSend() {
    isClickSend = true;
    if (timer != null) timer!.cancel();
    timer = Timer(Duration(seconds: 3), () {
      isClickSend = false;
    });
  }
}
