import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/send_feedback_course_request.dart';
import 'package:medical/src/model/request/update_lesson_section_request.dart';
import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/response/lesson_section_list_response.dart';
import 'package:medical/src/model/response/smart_goal_list_reponse.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/repo/home/home_client.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/activity_tab/models/schedule_type.dart';

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
  LessonSectionListResponseData? lessonDetail;
  LessonSectionListResponseDataLessonReviews? review;
  bool? isEnabledRating;
  int currentSection = 0;
  VideoManager? videoManager;
  AudioManager? audioManager;
  SectionStatusData? sectionStatus;
  String? featureImage;
  String? lessonDescription;
  int percentComplete = 0;

  bool isQuizLesson = false;

  bool alreadyDoneLesson = true;

  LessonSectionItem? get currentSectionDetail =>
      sectionList.isEmpty ? null : sectionList[currentSection];

  String get sectionPosition =>
      '${sectionList.isEmpty ? 0 : currentSection + 1}/${sectionList.length}';

  bool get isLastSection => currentSection >= (sectionList.length - 1);

  bool get isFirstSection => currentSection <= 0;

  bool get reviewed => review?.rating != null;

  bool get showQuizLesson =>
      currentSectionDetail?.type == Const.LESSON_SECTION_TYPE_QUIZ ||
      isQuizLesson;

  void onChangeSection(BuildContext context, int newSection,
      {bool isFromList = false, SmartGoalList? smartGoal}) async {
    //Check can complete the lesson and make sure that user tapped next button
    if (isAllSectionCompleted &&
        newSection > currentSection &&
        !alreadyDoneLesson) {
      checkSectionComplete();
      if (isAllSectionCompleted && currentSection == (sectionList.length - 1)) {
        Observable.instance
            .notifyObservers([], notifyName: "refresh_home_activity");
        Observable.instance
            .notifyObservers([], notifyName: "refresh_lesson_tab");
        Observable.instance
            .notifyObservers([], notifyName: "goal_calo_changed");
        emit(LessonDetailCompleted(showPopupShare: showQuizLesson == false));
        return;
      }
    }

    if (newSection < 0 || newSection >= sectionList.length) {
      if (Navigator.canPop(context)) {
        if (smartGoal?.id != null) {
          await HomeClient().completeSmartGoal(
              DateTime.now(), smartGoal!.id, 1, ScheduleType.lesson.typeIndex);
        }
        Navigator.pop(context, 1);
      }
      return;
    }

    // Match next-button rule: cannot jump forward from the section picker until current is complete.
    if (isFromList &&
        newSection > currentSection &&
        currentSectionDetail?.isComplete != true) {
      return;
    }

    currentSection = newSection;
    percentComplete = ((currentSection + 1) / sectionList.length).round() * 100;

    // Clear the video manager reference - the VideoWidget will create a new one
    // This prevents race conditions where the widget disposes the manager while we're trying to refresh it
    // The widget will detect the URL change through didUpdateWidget and recreate the video manager properly
    videoManager = null;

    audioManager?.refreshUrl(
      url: currentSectionDetail?.audioAddressLink,
    );

    sectionStatus = SectionStatusData(
      hasVideo: currentSectionDetail?.videoAddressLink?.isNotEmpty == true,
      hasAudio: currentSectionDetail?.audioAddressLink?.isNotEmpty == true,
      isQuizSection:
          currentSectionDetail?.type == Const.LESSON_SECTION_TYPE_QUIZ,
    );

    if (!isFromList) {
      checkSectionComplete();
    }

    emit(const LessonDetailSuccess(lessonBegin: true));
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
    if (currentSection == (sectionList.length - 1)) {
      if (isAllSectionCompleted && sectionList.isNotEmpty == true) {
        return true;
      } else {
        return false;
      }
    }

    if (alreadyDoneLesson) return null;
    //   if (isAllSectionCompleted && sectionList.isNotEmpty == true) return true;
    // if (isOtherCompleted) return false;
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
        percentComplete =
            ((currentSection + 1) / sectionList.length * 100).round();
        break;
      }
    }

    sectionStatus = SectionStatusData(
      hasVideo: currentSectionDetail?.videoAddressLink?.isNotEmpty == true,
      hasAudio: currentSectionDetail?.audioAddressLink?.isNotEmpty == true,
      isQuizSection:
          currentSectionDetail?.type == Const.LESSON_SECTION_TYPE_QUIZ,
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

  // Future<void> getThumbnail() async {
  //   if (currentSectionDetail!.videoAddressLink != null) {
  //     path = (await VideoThumbnail.thumbnailFile(
  //       video: currentSectionDetail!.videoAddressLink!,
  //       thumbnailPath: (await getTemporaryDirectory()).path,
  //       imageFormat: ImageFormat.PNG,
  //       maxHeight: 190,
  //       quality: 10,
  //     ));
  //   }
  // }

  Future<void> getSectionList() async {
    await Future.delayed(Duration.zero);
    emit(const LessonDetailLoading());
    final ApiResult<LessonSectionListResponse> apiResult =
        await repository.getListLessonSection(lessonId);
    apiResult.when(success: (LessonSectionListResponse response) {
      lessonDetail = response.data;
      sectionList = response.data?.lessonSections ?? [];
      featureImage = response.data?.image?.url;
      lessonDescription = response.data?.description;
      if (response.data?.lessonReviews?.isNotEmpty == true) {
        review = response.data?.lessonReviews?.first;
      }
      isEnabledRating = response.data?.isEnabledRating;
      alreadyDoneLesson = isAllSectionCompleted;

      emit(const LessonDetailSuccess(lessonBegin: true));
    }, failure: (NetworkExceptions error) {
      emit(LessonDetailFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const LessonDetailInitial());
  }

  Future<void> completeLearningCurrentSection() async {
    await Future.delayed(Duration.zero);
    emit(const LessonDetailLoading());
    print("percentComplete: ===================>" + percentComplete.toString());
    final ApiResult<CommonResponse> apiResult =
        await repository.setCompletedLessonAccount(
      UpdateLessonSectionRequest(
          lessonId: lessonId,
          type: currentSectionDetail?.type,
          lessonSectionId: currentSectionDetail?.id,
          completePercent: percentComplete),
    );
    apiResult.when(success: (CommonResponse response) {
      if (response.meta?.success == true) {
        currentSectionDetail?.isComplete = true;
      }
      emit(const LessonDetailSuccess());
    }, failure: (NetworkExceptions error) {
      emit(LessonDetailFailure(NetworkExceptions.getErrorMessage(error)));
      currentSectionDetail?.isComplete = true;
    });
    emit(const LessonDetailInitial());
  }

  Future<String?> sendLessonFeedback({
    required int rating,
    required String note,
  }) async {
    final SendFeedbackCourseRequest request = SendFeedbackCourseRequest(
      lessonId: lessonId,
      rating: rating,
      note: note,
    );
    final ApiResult<CommonResponse> apiResult =
        await repository.sendFeedbackCourse(lessonId, request);
    return apiResult.when(
      success: (_) => null,
      failure: (NetworkExceptions error) =>
          NetworkExceptions.getErrorMessage(error),
    );
  }
}
