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
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/widget/question_answer/all_question_answer/model/question_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../all_question_answer.dart';

class AllQuestionAnswerCubit extends Cubit<AllQuestionAnswerState> {
  int currentLessonModule = 0;
  final AppRepository repository;
  List<LessonModuleItem> lessonModules = [];
  List<bool> listSelectedLessonModule = [];
  List<String> lessonModuleIds = [];
  List<QuestionModel> questions = [];
  List<LessonModuleItem> allLessonModules = [];
  final userInfo = AppSettings.userInfo;
  int page = 1;
  bool canNext = false;

  final RefreshController controller = RefreshController();

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

    getLessonModules();
    getQuestions();
  }

  getLessonModules() async {
    allLessonModules = [];
    allLessonModules.add(LessonModuleItem(id: "0", code: "0", name: 'Tất cả'));

    final ApiResult<LessonModuleResponse> apiResult = await repository.getListLessonModule();
    apiResult.when(success: (LessonModuleResponse response) {
      if (response.data?.items != null) {
        allLessonModules.addAll(response.data!.items!);
      }
    }, failure: (NetworkExceptions error) {
      //   emit(AllQuestionAnswerFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }

  getQuestions({bool isShowLoading = false, bool isLoadmore = false, bool isFirstPage = true,}) async {
    if (isShowLoading) {
      emit(AllQuestionAnswerLoading());
    }
    if(isFirstPage) page = 1;
    final ApiResult<QuestionAnswerResponse> apiResult =
        await repository.getListQuestion(page: page, lessonModuleIds: lessonModuleIds);
    apiResult.when(success: (QuestionAnswerResponse response) {
      if (response.meta != null) {
        canNext = response.meta?.canNext ?? false;
      } else {
        canNext = false;
      }

      if (response.data != null) {
        var tempQuestions = response.data!;
        // for(var question in tempQuestions){
        //   question.originalStatus = question.status;
        //   if(question.status == 0){
        //     if(question.answers != null && question.answers!.isNotEmpty){
        //       bool isReplied = false;
        //       for(var answer in question.answers!){
        //         if(answer.accountId != userInfo?.accountId){
        //           isReplied = true;
        //           break;
        //         }
        //       }
        //       question.status = isReplied ? 2 : 1;
        //     } else {
        //       question.status = 1;
        //     }
        //   }
        // }
        if (isLoadmore) {
          questions.addAll(tempQuestions);
        } else {
          questions = [];
          questions = tempQuestions;
        }

        if (lessonModuleIds.isEmpty) {
          createLessonModules();
        }
      }
      emit(const AllQuestionAnswerSuccess());
    }, failure: (NetworkExceptions error) {
      emit(AllQuestionAnswerFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }

  loadmore() async {
    if (canNext) {
      page++;
      emit(LoadmoreAllQuestionAnswerLoading());
      getQuestions(isLoadmore: true, isFirstPage: false);
    }
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

  refreshData({bool isShowLoading = false}) async {
    emit(AllQuestionAnswerInitial());
    await getQuestions(isShowLoading: isShowLoading);
  }

  Future<void> deleteQuestion(String id) async {
    emit(AllQuestionAnswerLoading());
    final ApiResult<CommonResponse> apiResult = await repository.deleteQuestion(id);
    apiResult.when(success: (CommonResponse response) {
      questions.removeWhere((element) => element.id == id);
      if(currentLessonModule == 0){
        createLessonModules();
      }
      Observable.instance.notifyObservers([], notifyName : "update_my_question", map: {'id': id});
      emit(DeleteQuestionSuccess());
      if(questions.isEmpty){
        lessonModuleIds = [];
        controller.requestRefresh();
        getQuestions();
      }
    }, failure: (NetworkExceptions error) {
      emit(DeleteQuestionFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }



  Future<void> deleteQuestionLocal(String id) async {
    emit(AllQuestionAnswerLoading());
    questions.removeWhere((element) => element.id == id);
    if(currentLessonModule == 0){
      createLessonModules();
    }
 //   Observable.instance.notifyObservers([], notifyName : "update_my_question", map: {'id': id});
    emit(DeleteQuestionSuccess());
    if(questions.isEmpty){
      lessonModuleIds = [];
      controller.requestRefresh();
      getQuestions();
    }
  }

//   Future<void> deleteCommentLocal(String questionId, String commentId) async {
//     emit(AllQuestionAnswerLoading());
//     var question = questions.firstWhere((element) => element.id == questionId, orElse: null);
//     if (question != null) {
//       if (question.answers != null) {
//         question.answers!.removeWhere((element) => element.id == commentId);
//       }
//     }
//  //  Observable.instance.notifyObservers([], notifyName : "update_my_question", map: {'id': questionId, 'commentId': commentId});
//     emit(DeleteCommentSuccess());
//   }

  Future<void> updateQuestionsLocal(QuestionModel questionModel) async {
    emit(AllQuestionAnswerLoading());
    var index = questions.indexWhere((element) => element.id == questionModel.id);
    if(index >= 0){
      questions[index] = questionModel;
    } else {
      bool isLessonModuleExist = currentLessonModule == 0;
      if(!isLessonModuleExist) {
        for(var lessonModuleId in lessonModuleIds){
          if(questionModel.lessonModuleId == lessonModuleId){
            isLessonModuleExist = true;
            break;
          }
        }
      }
      if(isLessonModuleExist){
        questions.insert(0, questionModel);
        if(currentLessonModule == 0){
          createLessonModules();
        }
      }
    }
    
  //  Observable.instance.notifyObservers([], notifyName : "update_my_question", map: {'question': questionModel});
    emit(const AllQuestionAnswerSuccess());
  }
}
