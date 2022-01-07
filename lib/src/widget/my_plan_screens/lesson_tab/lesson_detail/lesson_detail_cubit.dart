import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/update_lesson_section_request.dart';
import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/response/lesson_section_list_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/utils/const.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'lesson_detail.dart';
import 'models/audio_manager.dart';
import 'models/section_status_data.dart';
import 'models/video_manager.dart';

class LessonDetailCubit extends Cubit<LessonDetailState> {
  LessonDetailCubit(this.repository) : super(const LessonDetailInitial());

  final AppRepository repository;
  late final String lessonId;

  String? path = '';

  List<LessonSectionItem?> sectionList = [];
  LessonSectionListResponseDataLessonReviews? review;
  bool? isEnabledRating;
  int currentSection = 0;
  VideoManager? videoManager;
  AudioManager? audioManager;
  SectionStatusData? sectionStatus;

  bool isQuizLesson = false;

  bool alreadyDoneLesson = true;

  LessonSectionItem? get currentSectionDetail => sectionList.isEmpty ? null : sectionList[currentSection];

  String get sectionPosition => '${sectionList.isEmpty ? 0 : currentSection + 1}/${sectionList.length}';

  bool get isLastSection => currentSection >= (sectionList.length - 1);

  bool get isFirstSection => currentSection <= 0;

  bool get reviewed => review?.rating != null;

  bool get showQuizLesson => currentSectionDetail?.type == Const.LESSON_SECTION_TYPE_QUIZ || isQuizLesson;

  void onChangeSection(int newSection, {bool isFromList = false}) {
    //Check can complete the lesson and make sure that user tapped next button
    if (isAllSectionCompleted && newSection > currentSection && !alreadyDoneLesson) {
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

    sectionStatus = SectionStatusData(
      hasVideo: currentSectionDetail?.videoAddressLink?.isNotEmpty == true,
      hasAudio: currentSectionDetail?.audioAddressLink?.isNotEmpty == true,
      isQuizSection: currentSectionDetail?.type == Const.LESSON_SECTION_TYPE_QUIZ,
    );

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
    //If all lesson were done before, not show complete button
    if (alreadyDoneLesson) return null;
    if (isAllSectionCompleted && sectionList.isNotEmpty == true) return true;
    if (isOtherCompleted) return false;
    return null;
  }

  Future<void> initData(int? type, String lessonId) async {
    this.lessonId = lessonId;

    if (type == 3) {
      isQuizLesson = true;
    } else {
      await getSectionList();
    }

    for (int index = 0; index < sectionList.length; index++) {
      if (sectionList[index]?.isComplete == false) {
        currentSection = index;
        break;
      }
    }

    sectionStatus = SectionStatusData(
      hasVideo: currentSectionDetail?.videoAddressLink?.isNotEmpty == true,
      hasAudio: currentSectionDetail?.audioAddressLink?.isNotEmpty == true,
      isQuizSection: currentSectionDetail?.type == Const.LESSON_SECTION_TYPE_QUIZ,
    );

    // videoManager = VideoManager(
    //     url: currentSectionDetail?.videoAddressLink,
    //     placeHolder: path != null ? Image.file(File(path!)) : Container(),
    //     onExitFullScreen: () {},
    //     onCompleted: () {
    //       sectionStatus?.isVideoCompleted = true;
    //       checkSectionComplete();
    //     });

    audioManager = AudioManager(
        url: currentSectionDetail?.audioAddressLink,
        onCompleted: () {
          sectionStatus?.isAudioCompleted = true;
          checkSectionComplete();
        });
    checkSectionComplete();
  }

  Future<void> checkSectionComplete() async {
    if (!isQuizLesson &&
        sectionStatus?.isSectionCompleted == true &&
        currentSectionDetail?.isComplete != true &&
        state is! LessonDetailCompleted) {
      currentSectionDetail?.isComplete = true;
      await completeLearningCurrentSection();
    }
  }

  void setVideoManager(VideoManager manager) {
    videoManager = manager;
  }

  void complete() {
    sectionStatus?.isVideoCompleted = true;
    checkSectionComplete();
  }

  Future<void> getThumbnail() async {
    if (currentSectionDetail!.videoAddressLink != null) {
      path = (await VideoThumbnail.thumbnailFile(
        video: currentSectionDetail!.videoAddressLink!,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.PNG,
        maxHeight: 190,
        quality: 10,
      ));
    }
  }

  Future<void> getSectionList() async {
    await Future.delayed(Duration.zero);
    emit(const LessonDetailLoading());
    final ApiResult<LessonSectionListResponse> apiResult = await repository.getListLessonSection(lessonId);
    apiResult.when(success: (LessonSectionListResponse response) {
      sectionList = response.data?.lessonSections ?? [];

      if (response.data?.lessonReviews?.isNotEmpty == true) {
        review = response.data?.lessonReviews?.first;
      }
      isEnabledRating = response.data?.isEnabledRating;
      alreadyDoneLesson = isAllSectionCompleted;

      emit(const LessonDetailSuccess());
    }, failure: (NetworkExceptions error) {
      emit(LessonDetailFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const LessonDetailInitial());
  }

  Future<void> completeLearningCurrentSection() async {
    await Future.delayed(Duration.zero);
    emit(const LessonDetailLoading());
    final ApiResult<CommonResponse> apiResult = await repository.setCompletedLessonAccount(
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
      currentSectionDetail?.isComplete = false;
    });
    emit(const LessonDetailInitial());
  }
}
