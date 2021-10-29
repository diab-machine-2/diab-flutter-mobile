import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/my_lesson_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';

import 'lesson_tab.dart';
import 'models/lesson_type.dart';

class LessonTabCubit extends Cubit<LessonTabState> {
  LessonTabCubit(this.repository) : super(const LessonTabInitial());

  final AppRepository repository;

  final List<LessonType> lessonTypeList = [
    LessonType.route,
    LessonType.suggest
  ];

  LessonType currentLessonType = LessonType.route;

  List<MyLessonResponseData?> lessonsList = [];

  int get currentLessonTypeIndex {
    final int index = lessonTypeList.indexOf(currentLessonType);
    return index == -1 ? 0 : index;
  }

  void changeLessonType(int newIndex) {
    currentLessonType = lessonTypeList[newIndex];
    getLessonsList();
    emit(const LessonTabChangeType());
    emit(const LessonTabInitial());
  }

  Future<void> getLessonsList({bool isRefresh = false}) async {
    if (!isRefresh) {
      await Future.delayed(Duration.zero);
      emit(const LessonTabLoading());
    }
    final ApiResult<MyLessonResponse> apiResult =
        await repository.getLessonsList(currentLessonTypeIndex + 1);
    apiResult.when(success: (MyLessonResponse response) {
      lessonsList = response.data ?? [];
      emit(const LessonTabSuccess());
    }, failure: (NetworkExceptions error) {
      emit(LessonTabFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const LessonTabInitial());
  }
}
