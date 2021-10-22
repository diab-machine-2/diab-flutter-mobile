import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/update_lesson_section_request.dart';
import 'package:medical/src/model/response/lesson_section_list_response.dart';
import 'package:medical/src/model/response/update_lesson_section_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/utils/const.dart';

import 'lesson_detail.dart';
import 'models/audio_management.dart';
import 'models/section_status_data.dart';
import 'models/video_management.dart';

class LessonDetailCubit extends Cubit<LessonDetailState> {
  LessonDetailCubit(this.repository) : super(const LessonDetailInitial());

  final AppRepository repository;
  late final String lessonId;

  List<LessonSectionListResponseData?> sectionList = [];
  int currentSection = 0;
  VideoManagement? videoManagement;
  AudioManagement? audioManagement;
  late SectionStatusData sectionStatus;

  LessonSectionListResponseData? get currentSectionDetail =>
      sectionList.isEmpty ? null : sectionList[currentSection];

  String get sectionPosition =>
      '${sectionList.isEmpty ? 0 : currentSection + 1}/${sectionList.length}';

  void onChangeSection(int newSection) {
    if (newSection < 0 || newSection >= sectionList.length) return;

    currentSection = newSection;

    videoManagement?.refreshSourceList(
      urls: currentSectionDetail?.sourceUrls ?? [],
    );

    audioManagement?.refreshSourceList(
      urls: currentSectionDetail?.sourceUrls ?? [],
    );

    sectionStatus = SectionStatusData(type: currentSectionDetail?.type);

    Timer(const Duration(seconds: 1), () {
      checkSectionComplete();
    });

    emit(const LessonDetailSuccess());
    emit(const LessonDetailInitial());
  }

  Future<void> initData(String lessonId) async {
    this.lessonId = lessonId;
    await getSectionList();

    sectionStatus = SectionStatusData(type: currentSectionDetail?.type);

    Timer(const Duration(seconds: 1), () {
      checkSectionComplete();
    });

    if (currentSectionDetail?.type == Const.LESSON_SECTION_TYPE_VIDEO) {
      videoManagement = VideoManagement(
          urls: currentSectionDetail?.sourceUrls ?? [],
          onExitFullScreen: () {},
          onAllFinished: () {
            sectionStatus.isVideoCompleted = true;
            checkSectionComplete();
          });
    }

    if (currentSectionDetail?.type == Const.LESSON_SECTION_TYPE_AUDIO) {
      audioManagement = AudioManagement(
          urls: currentSectionDetail?.sourceUrls ?? [],
          onAllFinished: () {
            sectionStatus.isAudioCompleted = true;
            checkSectionComplete();
          });
    }
  }

  Future<void> checkSectionComplete() async {
    if (sectionStatus.isAllComplete &&
        currentSectionDetail?.isComplete != true) {
      print('LOG call API done');
      // print('LOG ${sectionStatus.isAllComplete}');
      if (await completeLearningSection()) {
        currentSectionDetail?.isComplete = true;
      }
    }
  }

  Future<void> getSectionList() async {
    await Future.delayed(Duration.zero);
    emit(const LessonDetailLoading());
    final ApiResult<LessonSectionListResponse> apiResult =
        await repository.getListLessonSection(lessonId);
    apiResult.when(success: (LessonSectionListResponse response) {
      sectionList = response.data ?? [];
      emit(const LessonDetailSuccess());
    }, failure: (NetworkExceptions error) {
      emit(LessonDetailFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const LessonDetailInitial());
  }

  Future<bool> startLearningSection() async {
    await Future.delayed(Duration.zero);
    emit(const LessonDetailLoading());
    final ApiResult<UpdateLessonSectionResponse> apiResult =
        await repository.insertLearningLessonAccount(
      UpdateLessonSectionRequest(
        lessonId: lessonId,
        type: currentSectionDetail?.type,
        lessonSectionId: currentSectionDetail?.id,
      ),
    );
    apiResult.when(success: (UpdateLessonSectionResponse response) {
      emit(const LessonDetailSuccess());
      return true;
    }, failure: (NetworkExceptions error) {
      emit(LessonDetailFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const LessonDetailInitial());
    return false;
  }

  Future<bool> completeLearningSection() async {
    await Future.delayed(Duration.zero);
    emit(const LessonDetailLoading());
    final ApiResult<UpdateLessonSectionResponse> apiResult =
        await repository.setCompletedLessonAccount(
      UpdateLessonSectionRequest(
        lessonId: lessonId,
        type: currentSectionDetail?.type,
        lessonSectionId: currentSectionDetail?.id,
      ),
    );
    apiResult.when(success: (UpdateLessonSectionResponse response) {
      emit(const LessonDetailSuccess());
      return true;
    }, failure: (NetworkExceptions error) {
      emit(LessonDetailFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const LessonDetailInitial());
    return false;
  }
}
