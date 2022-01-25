import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/lesson_module_response.dart';
import 'package:medical/src/model/response/question_answer_response.dart';
import 'package:medical/src/model/response/smart_goal_list_reponse.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/widget/question_answer/all_question_answer/model/question_model.dart';
import '../all_question_answer.dart';

class AllQuestionAnswerCubit extends Cubit<AllQuestionAnswerState> {
  int currentTopic = 0;
  final AppRepository repository;
  List<LessonModuleItem> lessonModules = [];
  List<bool> listSelectedLessonModule = [];
  List<String> lessonModuleIds = [];
  List<QuestionModel> questions = [];

  AllQuestionAnswerCubit(this.repository) : super(AllQuestionAnswerInitial()) {
    // TODO
  }

  onSelectLessonModule(int index) {
    if(index == 0){
      for(int i = 0; i < listSelectedLessonModule.length; i++){
        listSelectedLessonModule[i] = false;
      }
      if(listSelectedLessonModule.isNotEmpty){
        listSelectedLessonModule[0] = true;
      }
      lessonModuleIds = [];
    } else {
      if(listSelectedLessonModule.isNotEmpty){
        listSelectedLessonModule[0] = false;
      }
      listSelectedLessonModule[index] = !listSelectedLessonModule[index];

      lessonModuleIds = [];
      for(int i = 0; i < listSelectedLessonModule.length; i++){
        if(listSelectedLessonModule[i]){
          if(lessonModules[i].id != null){
            lessonModuleIds.add(lessonModules[i].id!);
          }
        }
      }
    }
    currentTopic = index;

    getQuestions(isShowLoading: true);
  }

  onAnimate(int index) {
    currentTopic = index;
    emit(AllQuestionAnswerLoading());
    emit(AllQuestionAnswerSuccess());
  }

  initData() async {
    emit(AllQuestionAnswerLoading());
    await getListLessonModule();
    await getQuestions();
  }

  getListLessonModule() async {
    final ApiResult<LessonModuleResponse> apiResult =
        await repository.getListLessonModule();
    apiResult.when(success: (LessonModuleResponse response) {
      if(response.data?.items != null){
        lessonModules = [];
        lessonModules.add(LessonModuleItem(id: "0", code: "0", name: 'Tất cả'));
        lessonModules.addAll(response.data!.items!);

        listSelectedLessonModule = [];
        for(var lesson in lessonModules){
          listSelectedLessonModule.add(false);
        }
        if(listSelectedLessonModule.isNotEmpty){
          listSelectedLessonModule[0] = true;
        }
      }
    }, failure: (NetworkExceptions error) {
  //   emit(AllQuestionAnswerFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }

  getQuestions({bool isShowLoading = false}) async {
    if(isShowLoading){
      emit(AllQuestionAnswerLoading());
    }
    final ApiResult<QuestionAnswerResponse> apiResult =
        await repository.getListQuestion(lessonModuleIds: lessonModuleIds);
    apiResult.when(success: (QuestionAnswerResponse response) {
      if(response.data != null){
        questions = [];
        questions = response.data!;
      }
      emit(const AllQuestionAnswerSuccess());
    }, failure: (NetworkExceptions error) {
      emit(AllQuestionAnswerFailure(NetworkExceptions.getErrorMessage(error)));
    });

  }

  refreshData({bool isRefresh = false}) async {
    await initData();
  }

  String getStatus(int status){
    switch(status){
      case 0: 
        return 'Đã đóng';
      case 1:
        return 'Đang chờ';
      case 2:
        return 'Đã trả lời';
      default:
        return '';
    }
  }

  Color getColorStatus(int status){
    switch(status){
      case 0: 
        return R.color.red;
      case 1:
        return R.color.yellow;
      case 2:
        return R.color.greenGradientBottom;
      default:
        return R.color.transparent;
    }
  }

  LessonModuleItem getLessonModule(String id){
    return lessonModules.firstWhere((element) => element.id == id, orElse: null);
  }
}
