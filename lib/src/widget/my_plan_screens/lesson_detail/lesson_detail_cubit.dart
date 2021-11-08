import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/update_lesson_section_request.dart';
import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/response/lesson_section_list_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/utils/const.dart';

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

  List<String> videoUrls = [];
  List<String> audioUrls = [];

  LessonSectionListResponseDataLessonSections? get currentSectionDetail =>
      sectionList.isEmpty ? null : sectionList[currentSection];

  String get sectionPosition =>
      '${sectionList.isEmpty ? 0 : currentSection + 1}/${sectionList.length}';

  bool get isLastSection => currentSection >= (sectionList.length - 1);

  bool get isFirstSection => currentSection <= 0;

  bool get reviewed => review?.rating != null;

  void onChangeSection(int newSection, {bool isFromList = false}) {
    if (newSection < 0) return;
    if (newSection >= sectionList.length) {
      checkSectionComplete();
      return;
    }

    currentSection = newSection;

    updateUrlSource();

    videoManager?.refreshSourceList(
      urls: videoUrls,
    );

    audioManager?.refreshSourceList(
      urls: audioUrls,
    );

    sectionStatus = SectionStatusData(type: currentSectionDetail?.type);

    if (!isFromList) {
      checkSectionComplete();
    }

    emit(const LessonDetailSuccess());
    emit(const LessonDetailInitial());
  }

  void updateUrlSource() {
    if (currentSectionDetail?.type == Const.LESSON_SECTION_TYPE_VIDEO) {
      videoUrls = currentSectionDetail?.sourceUrls ?? [];
    } else {
      videoUrls = [];
    }

    if (currentSectionDetail?.type == Const.LESSON_SECTION_TYPE_AUDIO) {
      audioUrls = currentSectionDetail?.sourceUrls ?? [];
    } else {
      audioUrls = [];
    }
  }

  bool get isAllSectionCompleted {
    for (final section in sectionList) {
      if (section?.isComplete != true) {
        return false;
      }
    }
    return true;
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

    updateUrlSource();

    sectionStatus = SectionStatusData(type: currentSectionDetail?.type);

    videoManager = VideoManager(
        urls: videoUrls,
        onExitFullScreen: () {},
        onAllFinished: () {
          sectionStatus?.isVideoCompleted = true;
          checkSectionComplete();
        });

    audioManager = AudioManager(
        urls: audioUrls,
        onAllFinished: () {
          sectionStatus?.isAudioCompleted = true;
          checkSectionComplete();
        });
  }

  Future<void> checkSectionComplete() async {
    if (sectionStatus?.isSectionCompleted == true &&
        currentSectionDetail?.isComplete != null &&
        state is! LessonDetailFeedBack) {
      await completeLearningCurrentSection();
    }
    if (isEnabledRating == true && isAllSectionCompleted && !reviewed) {
      emit(const LessonDetailFeedBack());
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

  Future<void> completeLearningCurrentSection({bool showLoading = true}) async {
    if (showLoading) {
      await Future.delayed(Duration.zero);
      emit(const LessonDetailLoading());
    }
    final ApiResult<CommonResponse> apiResult =
        await repository.setCompletedLessonAccount(
      UpdateLessonSectionRequest(
        lessonId: lessonId,
        type: currentSectionDetail?.type,
        lessonSectionId: currentSectionDetail?.id,
      ),
    );
    apiResult.when(success: (CommonResponse response) {
      currentSectionDetail?.isComplete = true;
      emit(const LessonDetailSuccess());
    }, failure: (NetworkExceptions error) {
      emit(LessonDetailFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const LessonDetailInitial());
  }
}
