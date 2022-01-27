import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/response/lesson_module_response.dart';
import 'package:medical/src/model/response/question_answer_response.dart';
import 'package:medical/src/model/response/smart_goal_list_reponse.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/widget/question_answer/all_question_answer/model/question_model.dart';
import '../all_question_answer.dart';
import 'package:medical/src/repo/question_answer/question_answer_client.dart';
import 'package:medical/src/modal/error/error_model.dart';

class AllQuestionAnswerCubit extends Cubit<AllQuestionAnswerState> {
  int currentLessonModule = 0;
  final AppRepository repository;
  List<LessonModuleItem> lessonModules = [];
  List<bool> listSelectedLessonModule = [];
  List<String> lessonModuleIds = [];
  List<QuestionModel> questions = [];

  List<LessonModuleItem> allLessonModules = [];

  AllQuestionAnswerCubit(this.repository) : super(AllQuestionAnswerInitial()) {
    initData();
  }

  onSelectLessonModule(int index) {
    if (index == 0) {
      for (int i = 0; i < listSelectedLessonModule.length; i++) {
        listSelectedLessonModule[i] = false;
      }
      if (listSelectedLessonModule.isNotEmpty) {
        listSelectedLessonModule[0] = true;
      }
      lessonModuleIds = [];
    } else {
      if (listSelectedLessonModule.isNotEmpty) {
        listSelectedLessonModule[0] = false;
      }
      listSelectedLessonModule[index] = !listSelectedLessonModule[index];

      lessonModuleIds = [];
      for (int i = 0; i < listSelectedLessonModule.length; i++) {
        if (listSelectedLessonModule[i]) {
          if (lessonModules[i].id != null) {
            lessonModuleIds.add(lessonModules[i].id!);
          }
        }
      }
    }
    currentLessonModule = index;

    getQuestions(isShowLoading: true);
  }

  onAnimate(int index) {
    currentLessonModule = index;
    emit(AllQuestionAnswerLoading());
    emit(AllQuestionAnswerSuccess());
  }

  initData({bool isRefresh = false}) async {
    if (!isRefresh) {
      BotToast.showLoading();
    }

    await getListLessonModule();
    await getQuestions();
  }

  getListLessonModule() async {
    final ApiResult<LessonModuleResponse> apiResult = await repository.getListLessonModule();
    apiResult.when(success: (LessonModuleResponse response) {
      allLessonModules = [];
      allLessonModules.add(LessonModuleItem(id: "0", code: "0", name: 'Tất cả'));
      if (response.data?.items != null) {
        allLessonModules.addAll(response.data!.items!);
      }
    }, failure: (NetworkExceptions error) {
      allLessonModules = [];
      allLessonModules.add(LessonModuleItem(id: "0", code: "0", name: 'Tất cả'));
      //   emit(AllQuestionAnswerFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }

  getQuestions({bool isShowLoading = false}) async {
    if (isShowLoading) {
      emit(AllQuestionAnswerLoading());
    }
    final ApiResult<QuestionAnswerResponse> apiResult =
        await repository.getListQuestion(lessonModuleIds: lessonModuleIds);
    apiResult.when(success: (QuestionAnswerResponse response) {
      if (response.data != null) {
        questions = [];
        questions = response.data!;

        if (lessonModuleIds.isEmpty) {
          createLessonModules();
        }
      }
      emit(const AllQuestionAnswerSuccess());
    }, failure: (NetworkExceptions error) {
      emit(AllQuestionAnswerFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }

  createLessonModules() {
    lessonModules = [];
    lessonModules.add(LessonModuleItem(id: "0", code: "0", name: 'Tất cả'));
    for (int i = 0; i < questions.length; i++) {
      if (questions[i].lessonModule != null) {
        lessonModules.add(questions[i].lessonModule!);
      }
    }
    lessonModules = lessonModules.toSet().toList();

    listSelectedLessonModule = [];
    for (var lesson in lessonModules) {
      listSelectedLessonModule.add(false);
    }
    if (listSelectedLessonModule.isNotEmpty) {
      listSelectedLessonModule[0] = true;
    }
  }

  refreshData() async {
    //  emit(AllQuestionAnswerInitial());
    await getQuestions();
  }

  Future<void> deleteQuestion(String id) async {
    emit(AllQuestionAnswerLoading());
    final ApiResult<CommonResponse> apiResult = await repository.deleteQuestion(id);
    apiResult.when(success: (CommonResponse response) {
      questions.removeWhere((element) => element.id == id);
      emit(DeleteQuestionSuccess());
    }, failure: (NetworkExceptions error) {
      emit(DeleteQuestionFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }

  Future<void> deleteQuestionLocal(String id) async {
    emit(AllQuestionAnswerLoading());
    questions.removeWhere((element) => element.id == id);
    emit(DeleteQuestionSuccess());
  }

  Future<void> deleteCommentLocal(String questionId, String commentId) async {
    emit(AllQuestionAnswerLoading());
    var question = questions.firstWhere((element) => element.id == questionId, orElse: null);
    if (question != null) {
      if (question.answers != null) {
        question.answers!.removeWhere((element) => element.id == commentId);
      }
    }
    emit(DeleteCommentSuccess());
  }

  Future<void> updateQuestionsLocal(QuestionModel questionModel) async {
    emit(AllQuestionAnswerLoading());
    var index = questions.indexWhere((element) => element.id == questionModel.id);
    questions[index] = questionModel;
    emit(const AllQuestionAnswerSuccess());
  }

  LessonModuleItem getLessonModule(String id) {
    return lessonModules.firstWhere((element) => element.id == id, orElse: null);
  }
}
