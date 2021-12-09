import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/update_lesson_section_request.dart';
import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/response/lesson_section_list_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';

import 'lesson_detail.dart';
import 'models/audio_manager.dart';
import 'models/section_status_data.dart';
import 'models/video_manager.dart';

class LessonDetailCubit extends Cubit<LessonDetailState> {
  LessonDetailCubit(this.repository) : super(const LessonDetailInitial());

  final AppRepository repository;
  late final String lessonId;

  List<LessonSectionListResponseDataLessonSections?> sectionList = [];
  LessonSectionListResponseDataLessonReviews? review;
  bool? isEnabledRating;
  int currentSection = 0;
  VideoManager? videoManager;
  AudioManager? audioManager;
  SectionStatusData? sectionStatus;

  LessonSectionListResponseDataLessonSections? get currentSectionDetail =>
      sectionList.isEmpty ? null : sectionList[currentSection];

  String get sectionPosition =>
      '${sectionList.isEmpty ? 0 : currentSection + 1}/${sectionList.length}';

  bool get isLastSection => currentSection >= (sectionList.length - 1);

  bool get isFirstSection => currentSection <= 0;

  bool get reviewed => review?.rating != null;

  void onChangeSection(int newSection, {bool isFromList = false}) {
    //Check can complete the lesson and make sure that user tapped next button
    if (isAllSectionCompleted && newSection > currentSection) {
      checkSectionComplete();
      if (isAllSectionCompleted) {
        emit(const LessonDetailCompleted());
      }
      return;
    }
    if (newSection < 0 || newSection >= sectionList.length) return;

    currentSection = newSection;

    videoManager?.refreshUrl(
      url: currentSectionDetail?.videoAddressLink,
    );

    audioManager?.refreshUrl(
      url: currentSectionDetail?.audioAddressLink,
    );

    sectionStatus = SectionStatusData(type: currentSectionDetail?.type);

    if (!isFromList) {
      checkSectionComplete();
    }

    emit(const LessonDetailSuccess());
    emit(const LessonDetailInitial());
  }

  bool get isAllSectionCompleted {
    for (final section in sectionList) {
      if (section?.isComplete != true) {
        return false;
      }
    }
    return true;
  }

  bool get isOtherCompleted {
    for (int index = 0; index < sectionList.length; index++) {
      if (index == currentSection) continue;
      if (sectionList[index]?.isComplete != true) {
        return false;
      }
    }
    return true;
  }

  bool? get canComplete {
    if (isAllSectionCompleted && sectionList.isNotEmpty == true) return true;
    if (isOtherCompleted) return false;
    return null;
  }

  Future<void> initData(String lessonId) async {
    this.lessonId = lessonId;

    await getSectionList();

    for (int index = 0; index < sectionList.length; index++) {
      if (sectionList[index]?.isComplete == false) {
        currentSection = index;
        break;
      }
    }

    sectionStatus = SectionStatusData(type: currentSectionDetail?.type);

    videoManager = VideoManager(
        url: currentSectionDetail?.videoAddressLink,
        onExitFullScreen: () {},
        onCompleted: () {
          sectionStatus?.isVideoCompleted = true;
          checkSectionComplete();
        });

    audioManager = AudioManager(
        url: currentSectionDetail?.audioAddressLink,
        onCompleted: () {
          sectionStatus?.isAudioCompleted = true;
          checkSectionComplete();
        });

    checkSectionComplete();
  }

  Future<void> checkSectionComplete() async {
    if (sectionStatus?.isSectionCompleted == true &&
        currentSectionDetail?.isComplete != true &&
        state is! LessonDetailCompleted) {
      await completeLearningCurrentSection();
    }
  }

  Future<void> getSectionList() async {
    await Future.delayed(Duration.zero);
    emit(const LessonDetailLoading());
    final ApiResult<LessonSectionListResponse> apiResult =
        await repository.getListLessonSection(lessonId);
    apiResult.when(success: (LessonSectionListResponse response) {
      sectionList = response.data?.lessonSections ?? [];
      if (response.data?.lessonReviews?.isNotEmpty == true) {
        review = response.data?.lessonReviews?.first;
      }
      isEnabledRating = response.data?.isEnabledRating;
      emit(const LessonDetailSuccess());
    }, failure: (NetworkExceptions error) {
      emit(LessonDetailFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const LessonDetailInitial());
  }

  Future<void> completeLearningCurrentSection() async {
    await Future.delayed(Duration.zero);
    emit(const LessonDetailLoading());
    final ApiResult<CommonResponse> apiResult =
        await repository.setCompletedLessonAccount(
      UpdateLessonSectionRequest(
        lessonId: lessonId,
        type: currentSectionDetail?.type,
        lessonSectionId: currentSectionDetail?.id,
      ),
    );
    apiResult.when(success: (CommonResponse response) {
      if (response.meta?.success == true) {
        currentSectionDetail?.isComplete = true;
      }
      emit(const LessonDetailSuccess());
    }, failure: (NetworkExceptions error) {
      emit(LessonDetailFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const LessonDetailInitial());
  }
}
