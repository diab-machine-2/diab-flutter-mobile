import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
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
import '../my_question_answer.dart';

class MyQuestionAnswerCubit extends Cubit<MyQuestionAnswerState> {
  int currentLessonModule = 0;
  final AppRepository repository;
  List<LessonModuleItem> lessonModules = [];
  List<LessonModuleItem> allLessonModules = [];
  List<bool> listSelectedLessonModule = [];
  List<String> lessonModuleIds = [];
  List<QuestionModel> questions = [];
  var userInfo = AppSettings.userInfo;
  int page = 1;
  bool canNext = false;

  MyQuestionAnswerCubit(this.repository) : super(MyQuestionAnswerInitial()) {
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
    emit(MyQuestionAnswerLoading());
    emit(MyQuestionAnswerSuccess());
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

  getQuestions({bool isShowLoading = false, bool isLoadmore = false}) async {
    if (isShowLoading) {
      emit(MyQuestionAnswerLoading());
    }

    final ApiResult<QuestionAnswerResponse> apiResult = await repository
        .getListQuestion(page: page, lessonModuleIds: lessonModuleIds, accountIds: [userInfo!.accountId!]);
    apiResult.when(success: (QuestionAnswerResponse response) {
      if (response.meta != null) {
        canNext = response.meta!.canNext ?? false;
      } else {
        canNext = false;
      }

      if (response.data != null) {
        if (isLoadmore) {
          questions.addAll(response.data!);
        } else {
          questions = [];
          questions = response.data!;
        }

        if (lessonModuleIds.isEmpty) {
          createLessonModules();
        }
      }
      emit(const MyQuestionAnswerSuccess());
    }, failure: (NetworkExceptions error) {
      emit(MyQuestionAnswerFailure(NetworkExceptions.getErrorMessage(error)));
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

  loadmore() async {
    if (canNext) {
      page++;
      emit(LoadmoreMyQuestionAnswerLoading());
      getQuestions(isLoadmore: true);
    }
  }

  Future<void> deleteQuestion(String id) async {
    emit(MyQuestionAnswerLoading());
    final ApiResult<CommonResponse> apiResult = await repository.deleteQuestion(id);
    apiResult.when(success: (CommonResponse response) {
      questions.removeWhere((element) => element.id == id);
      createLessonModules();
      Observable.instance.notifyObservers([], notifyName : "update_all_question", map: {'id': id});
      emit(DeleteQuestionSuccess());
    }, failure: (NetworkExceptions error) {
      emit(DeleteQuestionFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }

  Future<void> deleteQuestionLocal(String id) async {
    emit(MyQuestionAnswerLoading());
    questions.removeWhere((element) => element.id == id);
  //  createLessonModules();
  //  Observable.instance.notifyObservers([], notifyName : "update_all_question", map: {'id': id});
    emit(DeleteQuestionSuccess());
  }

  Future<void> deleteCommentLocal(String questionId, String commentId) async {
    emit(MyQuestionAnswerLoading());
    var question = questions.firstWhere((element) => element.id == questionId, orElse: null);
    if (question != null) {
      if (question.answers != null) {
        question.answers!.removeWhere((element) => element.id == commentId);
      }
    }
  //  Observable.instance.notifyObservers([], notifyName : "update_all_question", map: {'id': questionId, 'commentId': commentId});
    emit(DeleteCommentSuccess());
  }

  Future<void> updateQuestionsLocal(QuestionModel questionModel) async {
    emit(MyQuestionAnswerLoading());
    var index = questions.indexWhere((element) => element.id == questionModel.id);
    questions[index] = questionModel;
    Observable.instance.notifyObservers([], notifyName : "update_all_question", map: {'question': questionModel});
    emit(const MyQuestionAnswerSuccess());
  }

  refreshData() async {
    emit(MyQuestionAnswerInitial());
    await getQuestions();
  }

  LessonModuleItem getLessonModule(String id) {
    return lessonModules.firstWhere((element) => element.id == id, orElse: null);
  }
}
