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
import 'models/audio_management.dart';
import 'models/section_status_data.dart';
import 'models/video_management.dart';

class LessonDetailCubit extends Cubit<LessonDetailState> {
  LessonDetailCubit(this.repository) : super(const LessonDetailInitial());

  final AppRepository repository;
  late final String lessonId;

  List<LessonSectionListResponseDataSections?> sectionList = [];
  LessonSectionListResponseDataReview? review;
  int currentSection = 0;
  VideoManagement? videoManagement;
  AudioManagement? audioManagement;
  late SectionStatusData sectionStatus;

  List<String> videoUrls = [];
  List<String> audioUrls = [];

  LessonSectionListResponseDataSections? get currentSectionDetail =>
      sectionList.isEmpty ? null : sectionList[currentSection];

  String get sectionPosition =>
      '${sectionList.isEmpty ? 0 : currentSection + 1}/${sectionList.length}';

  bool get isLastSection => currentSection >= (sectionList.length - 1);

  bool get isFirstSection => currentSection <= 0;

  bool get reviewed => review?.rating != null;

  void onChangeSection(int newSection, {bool isFromList = false}) {
    if (newSection < 0 || newSection >= sectionList.length) return;

    currentSection = newSection;

    updateUrlSource();

    videoManagement?.refreshSourceList(
      urls: videoUrls,
    );

    audioManagement?.refreshSourceList(
      urls: audioUrls,
    );

    sectionStatus = SectionStatusData(type: currentSectionDetail?.type);

    if (!isFromList) {
      checkSectionComplete(withDelay: true);
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

    checkSectionComplete(withDelay: true);

    videoManagement = VideoManagement(
        urls: videoUrls,
        onExitFullScreen: () {},
        onAllFinished: () {
          sectionStatus.isVideoCompleted = true;
          checkSectionComplete();
        });

    audioManagement = AudioManagement(
        urls: audioUrls,
        onAllFinished: () {
          sectionStatus.isAudioCompleted = true;
          checkSectionComplete();
        });
  }

  Future<void> checkSectionComplete({bool withDelay = false}) async {
    if (withDelay) {
      await Future.delayed(const Duration(seconds: 1));
    }
    if (sectionStatus.isSectionCompleted &&
        currentSectionDetail?.isComplete != null &&
        state is! LessonDetailFeedBack) {
      print('LOG call API complete');
      await completeLearningCurrentSection();
    }
    if (isAllSectionCompleted && !reviewed) {
      print('LOG navigate to FeedBack screen');
      emit(const LessonDetailFeedBack());
    }
  }

  Future<void> getSectionList() async {
    await Future.delayed(Duration.zero);
    emit(const LessonDetailLoading());
    final ApiResult<LessonSectionListResponse> apiResult =
        await repository.getListLessonSection(lessonId);
    apiResult.when(success: (LessonSectionListResponse response) {
      sectionList = response.data?.sections ?? [];
      review = response.data?.review;
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
      currentSectionDetail?.isComplete = true;
      emit(const LessonDetailSuccess());
    }, failure: (NetworkExceptions error) {
      emit(LessonDetailFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const LessonDetailInitial());
  }
}
