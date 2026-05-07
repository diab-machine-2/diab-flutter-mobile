import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/app_sharing.dart';
import 'package:medical/src/app_setting/branchio_link_config.dart';
import 'package:medical/src/app_setting/firebase_tracking/lesson_detail_tracking.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/lesson_section_list_response.dart';
import 'package:medical/src/model/response/smart_goal_list_reponse.dart';
import 'package:medical/src/repo/home/home_client.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/activity_tab/models/schedule_type.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/widgets/mini_video_bar.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/widgets/lesson_completed_review_page.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/widgets/video_widget.dart';
import 'package:medical/src/widgets/background_page.dart';
import 'package:medical/src/widgets/custom_bottom_bar_widget.dart';
import 'package:medical/src/widgets/gap_widget.dart';
import 'package:medical/src/widgets/html_text_widget.dart';

import '../course_quiz/course_quiz.dart';
import 'lesson_detail_cubit.dart';
import 'lesson_detail_state.dart';
import 'models/audio_data.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/widgets/bottom_sheet_widget.dart'
    as lesson_bottom_sheet;

class LessonDetailPage extends StatefulWidget {
  final Function(String, int) onComplete;
  final SmartGoalList? smartGoal;
  const LessonDetailPage({
    required this.lessonType,
    required this.lessonId,
    required this.onComplete,
    this.smartGoal,
  });
  final int? lessonType;
  final String lessonId;

  @override
  _LessonDetailPageState createState() => _LessonDetailPageState();
}

class _LessonDetailPageState extends State<LessonDetailPage> {
  late final LessonDetailCubit _cubit;
  bool _isShowModal = false;
  int percentComplete = 10;

  // ── Floating mini bars ──
  final GlobalKey _videoWidgetKey = GlobalKey();
  final GlobalKey _audioWidgetKey = GlobalKey();
  bool _showMiniBar = false;
  bool _showMiniAudioBar = false;
  final ScrollController _scrollController = ScrollController();

  List<String> _ratingReasonsByScore(int score) {
    switch (score) {
      case 1:
        return [
          R.string.lesson_reason_hard_to_understand.tr(),
          R.string.lesson_reason_low_quality_video.tr(),
          R.string.lesson_reason_insufficient_references.tr(),
          R.string.lesson_reason_unclear_images.tr(),
        ];
      case 2:
        return [
          R.string.lesson_reason_not_fit_needs.tr(),
          R.string.lesson_reason_low_quality_video.tr(),
          R.string.lesson_reason_not_practical_examples.tr(),
          R.string.lesson_reason_unclear_images.tr(),
        ];
      case 3:
        return [
          R.string.lesson_reason_temporary_ok.tr(),
          R.string.lesson_reason_need_more_examples.tr(),
          R.string.lesson_reason_need_shorter_presentation.tr(),
          R.string.lesson_reason_need_more_illustrations.tr(),
        ];
      case 4:
      case 5:
        return [
          R.string.lesson_reason_useful_content.tr(),
          R.string.lesson_reason_high_quality_video.tr(),
          R.string.lesson_reason_sufficient_references.tr(),
          R.string.lesson_reason_beautiful_images.tr(),
        ];
      default:
        return const [];
    }
  }

  String _ratingLabel(int rating) {
    if (rating >= 4) return R.string.lesson_rating_very_useful.tr();
    if (rating == 3) return R.string.lesson_rating_normal.tr();
    if (rating > 0) return R.string.lesson_rating_not_useful.tr();
    return '';
  }

  @override
  void initState() {
    super.initState();
    final AppRepository appRepository = AppRepository();
    _cubit = LessonDetailCubit(appRepository);
    _cubit.initData(widget.lessonType, widget.lessonId);
    LessonDetailTracking.firebaseSetup();
    _scrollController.addListener(_checkMediaVisibility);
  }

  @override
  Future<void> dispose() async {
    debugPrint(
        '[VIDEO] LessonDetailPage.dispose start for lessonId=${_cubit.lessonDetail?.id} title=${_cubit.lessonDetail?.name}');

    // Immediately dispose video and audio to prevent background audio
    debugPrint('[VIDEO] Immediately disposing lesson media managers');
    _cubit.videoManager?.disposeAllVideo();
    _cubit.audioManager?.disposeAllAudio();
    _scrollController.dispose();

    // Schedule async tracking after disposal (only if lessonDetail is available)
    if (_cubit.lessonDetail?.id != null && _cubit.lessonDetail?.name != null) {
      LessonDetailTracking.lessonDetailScrolling(
        percentComplete: percentComplete,
        objectId: _cubit.lessonDetail!.id!,
        objectTitle: _cubit.lessonDetail!.name!,
      ).catchError((e) {
        debugPrint('[VIDEO] Error in lessonDetailScrolling: $e');
      });
    }

    debugPrint('[VIDEO] LessonDetailPage.dispose done');
    super.dispose();
  }

  bool isYouTubeLink(String? videoAddressLink) {
    if (videoAddressLink == null || videoAddressLink.isEmpty) {
      return false;
    }

    final RegExp youtubeRegex = RegExp(
      r'^(https?:\/\/)?(www\.)?(youtube\.com|youtu\.be)\/',
      caseSensitive: false,
    );

    return youtubeRegex.hasMatch(videoAddressLink);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: BlocConsumer<LessonDetailCubit, LessonDetailState>(
        listener: (context, state) async {
          if (state is LessonDetailSuccess) {
            if (state.lessonBegin) {
              LessonDetailTracking.lessonBegin(
                objectId: "${_cubit.lessonDetail?.id}",
                objectTitle: "${_cubit.lessonDetail?.name}",
              );
            } else {
              widget.onComplete(
                  _cubit.lessonDetail!.id!, _cubit.percentComplete);
            }
          }
          if (state is LessonDetailLoading) {
            BotToast.showLoading();
          } else {
            BotToast.closeAllLoading();
          }
          if (state is LessonDetailFailure) {
            Message.showToastMessage(context, state.error);
          }
          if (state is LessonDetailCompleted) {
            // For quiz-only lessons we skip the rating/review screen entirely:
            // just complete the smart goal (if any) and pop back to the caller.
            if (state.showPopupShare != true) {
              // Smart goal is completed in [CourseQuizPage] share-sheet onCancel before
              // this emit. Pop modal (if still open) + lesson in one [popUntil] to tab bar.
              NavigationUtil.popUntilTabbar(context);
              BotToast.closeAllLoading();
              return;
            }

            LessonDetailTracking.lessonCompleted(
              objectId: _cubit.lessonDetail?.id,
              objectTitle: _cubit.lessonDetail?.name,
            );
            final int rating = _cubit.review?.rating ?? 0;
            final String note = _cubit.review?.note ?? '';
            final dynamic result = await NavigationUtil.navigatePage(
              context,
              LessonCompletedReviewPage(
                moduleName: _cubit.lessonDetail?.lessonModule?.name ?? '',
                title: _cubit.lessonDetail?.name ?? '',
                description: _cubit.lessonDetail?.description ?? '',
                imageUrl: _cubit.lessonDetail?.image?.url ?? '',
                rating: rating,
                note: note,
                onShare: () =>
                    _onShareLesson(context, _cubit.currentSectionDetail!),
              ),
            );
            if (widget.smartGoal?.id != null) {
              await HomeClient().completeSmartGoal(DateTime.now(),
                  widget.smartGoal!.id, 1, ScheduleType.lesson.typeIndex);
            }
            NavigationUtil.pop(context, result: result ?? 1);
            BotToast.closeAllLoading();
          }
        },
        builder: (context, state) {
          return WillPopScope(
            onWillPop: () async {
              debugPrint(
                  '[VIDEO][${DateTime.now().toIso8601String().substring(11, 23)}] System back button pressed - pausing and disposing video and audio');
              // Immediately pause video and audio before disposal
              if (_cubit.videoManager != null) {
                try {
                  _cubit.videoManager?.controller.then((controller) {
                    if (controller != null) {
                      try {
                        controller.pause();
                        debugPrint(
                            '[VIDEO][${DateTime.now().toIso8601String().substring(11, 23)}] Video controller paused on system back press');
                      } catch (e) {
                        debugPrint(
                            '[VIDEO][${DateTime.now().toIso8601String().substring(11, 23)}] Error pausing video controller: $e');
                      }
                    }
                  }).catchError((e) {
                    debugPrint(
                        '[VIDEO][${DateTime.now().toIso8601String().substring(11, 23)}] Error getting video controller: $e');
                  });
                } catch (e) {
                  debugPrint(
                      '[VIDEO][${DateTime.now().toIso8601String().substring(11, 23)}] Error accessing video manager: $e');
                }
              }
              if (_cubit.audioManager != null) {
                try {
                  _cubit.audioManager?.controller?.pause();
                  debugPrint(
                      '[VIDEO][${DateTime.now().toIso8601String().substring(11, 23)}] Audio controller paused on system back press');
                } catch (e) {
                  debugPrint(
                      '[VIDEO][${DateTime.now().toIso8601String().substring(11, 23)}] Error pausing audio controller: $e');
                }
              }
              return true;
            },
            child: _cubit.showQuizLesson
                ? CourseQuizPage(
                    key: Key(_cubit.currentSectionDetail?.id ?? ''),
                    currentPercent: (((_cubit.currentSection + 1) /
                                _cubit.sectionList.length) *
                            100)
                        .toInt(), // Khi hoàn thành quiz sẽ gửi luôn phần trăm đã tính sẵn
                    lessonId: _cubit.lessonId,
                    lessonSectionItem: widget.lessonType != 3
                        ? _cubit.currentSectionDetail
                        : null,
                    onDone: (isPassed) async {
                      _cubit.onChangeSection(
                          context, _cubit.currentSection + 1);
                    },
                    onComplete: () {
                      widget.onComplete(
                          _cubit.lessonDetail!.id!, _cubit.percentComplete);
                    },
                    lessonDetail: _cubit.lessonDetail!,
                    smartGoal: widget.smartGoal,
                  )
                : Scaffold(
                    body: Stack(
                      children: [
                        BackgroundPage(
                          background: R.drawable.bg_lesson_detail,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      R.color.greenGradientTop,
                                      R.color.greenGradientBottom,
                                    ],
                                  ),
                                ),
                                child: SafeArea(
                                  bottom: false,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 18, horizontal: 16),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            debugPrint(
                                                '[VIDEO][${DateTime.now().toIso8601String().substring(11, 23)}] Back button pressed - pausing video and audio');

                                            // Pause video and audio before navigation (don't dispose here - let dispose() handle it)
                                            if (_cubit.videoManager != null) {
                                              try {
                                                _cubit.videoManager?.controller
                                                    .then((controller) {
                                                  if (controller != null) {
                                                    try {
                                                      controller.pause();
                                                      debugPrint(
                                                          '[VIDEO][${DateTime.now().toIso8601String().substring(11, 23)}] Video controller paused on back press');
                                                    } catch (e) {
                                                      debugPrint(
                                                          '[VIDEO][${DateTime.now().toIso8601String().substring(11, 23)}] Error pausing video controller: $e');
                                                    }
                                                  }
                                                }).catchError((e) {
                                                  debugPrint(
                                                      '[VIDEO][${DateTime.now().toIso8601String().substring(11, 23)}] Error getting video controller: $e');
                                                });
                                              } catch (e) {
                                                debugPrint(
                                                    '[VIDEO][${DateTime.now().toIso8601String().substring(11, 23)}] Error accessing video manager: $e');
                                              }
                                            }

                                            if (_cubit.audioManager != null) {
                                              try {
                                                _cubit.audioManager?.controller
                                                    ?.pause();
                                                debugPrint(
                                                    '[VIDEO][${DateTime.now().toIso8601String().substring(11, 23)}] Audio controller paused on back press');
                                              } catch (e) {
                                                debugPrint(
                                                    '[VIDEO][${DateTime.now().toIso8601String().substring(11, 23)}] Error pausing audio controller: $e');
                                              }
                                            }

                                            // Schedule tracking asynchronously (non-blocking)
                                            TrackingManager.analytics.logEvent(
                                              name: 'component_clicked',
                                              parameters: {
                                                "screen_name": 'lesson_detail',
                                                "component_name":
                                                    'close_lesson',
                                                'object_id':
                                                    _cubit.lessonDetail?.id ??
                                                        '',
                                                'object_title':
                                                    _cubit.lessonDetail?.name ??
                                                        '',
                                              },
                                            ).catchError((e) {
                                              debugPrint(
                                                  '[VIDEO] Error in tracking: $e');
                                            });

                                            NavigationUtil.pop(context);
                                          },
                                          child: Icon(
                                            Icons.arrow_back,
                                            size: 26,
                                            color: R.color.white,
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        Expanded(
                                          child: MediaQuery(
                                            data:
                                                MediaQuery.of(context).copyWith(
                                              textScaler: MediaQuery.of(context)
                                                  .textScaler
                                                  .clamp(
                                                      minScaleFactor: 1.0,
                                                      maxScaleFactor: 1.3),
                                            ),
                                            child: Text(
                                              _cubit.lessonDetail?.name ?? '',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: R.color.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (_cubit.currentSectionDetail != null)
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                              minWidth: 20,
                                              minHeight: 20,
                                            ),
                                            icon: Icon(
                                              Icons.share_outlined,
                                              size: 24,
                                              color: R.color.white,
                                            ),
                                            onPressed: () => _onShareLesson(
                                                context,
                                                _cubit.currentSectionDetail!),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const GapH(16),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  _cubit.currentSectionDetail?.name ?? '',
                                  style: TextStyle(
                                    color: R.color.textDark,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(children: [
                                  if (AppSettings.isOwnPackage)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(width: 2),
                                        Image.network(
                                          height: 40,
                                          AppSettings.userInfo?.ownPackage
                                                  ?.graphic ??
                                              "",
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return SizedBox();
                                          },
                                        ),
                                      ],
                                    ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                ]),
                              ),
                              const SizedBox(height: 14),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child:
                                      NotificationListener<ScrollNotification>(
                                    onNotification: (scrollNotification) {
                                      int currentPosition =
                                          (scrollNotification.metrics.pixels /
                                                  scrollNotification
                                                      .metrics.maxScrollExtent *
                                                  100)
                                              .round();
                                      if (currentPosition >= percentComplete) {
                                        percentComplete = currentPosition;
                                        print(
                                            'currentPosition: $percentComplete');
                                      }
                                      return true;
                                    },
                                    child: SingleChildScrollView(
                                      controller: _scrollController,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (_cubit.currentSectionDetail
                                                  ?.videoAddressLink !=
                                              null)
                                            Container(
                                              key: _videoWidgetKey,
                                              child: _buildTitleWidget(
                                                child: VideoWidget(
                                                  isYouTubeLink: isYouTubeLink(
                                                      _cubit
                                                          .currentSectionDetail
                                                          ?.videoAddressLink),
                                                  url: _cubit
                                                      .currentSectionDetail!
                                                      .videoAddressLink!,
                                                  callbackEventListener:
                                                      (event, videoDuration) {
                                                    LessonDetailTracking
                                                        .videoPlayerLesson(
                                                      videoDuration:
                                                          videoDuration,
                                                      objectTitle: _cubit
                                                          .lessonDetail!.name!,
                                                      objectId: _cubit
                                                          .lessonDetail!.id!,
                                                      eventType: event,
                                                    );
                                                  },
                                                  onPlay: () async =>
                                                      _onTrackingVideoPlay(),
                                                  onComplete: () {
                                                    LessonDetailTracking
                                                        .completed50PercentVideo(
                                                      objectId: _cubit
                                                          .lessonDetail?.id,
                                                      objectTitle: _cubit
                                                          .lessonDetail?.name,
                                                    );
                                                    _cubit.complete();
                                                    _onTrackingVideoComplete();
                                                  },
                                                  callbackByPercentVideo: () {
                                                    LessonDetailTracking
                                                        .completed50PercentVideo(
                                                      objectId: _cubit
                                                          .lessonDetail?.id,
                                                      objectTitle: _cubit
                                                          .lessonDetail?.name,
                                                    );
                                                    widget.onComplete(
                                                        _cubit
                                                            .lessonDetail!.id!,
                                                        _cubit.percentComplete);
                                                    _cubit.complete();
                                                  },
                                                  percentCallbackDefault: 0.5,
                                                  setVideoManager:
                                                      (videoManager) {
                                                    _cubit.setVideoManager(
                                                        videoManager);
                                                  },
                                                  videoTitle: _cubit
                                                      .currentSectionDetail
                                                      ?.name,
                                                  videoThumbnail: _cubit
                                                      .lessonDetail?.image?.url,
                                                ),
                                                title: _cubit
                                                    .currentSectionDetail
                                                    ?.videoDescription,
                                              ),
                                            ),
                                          SizedBox(height: 8),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 12),
                                            child: WidgetHtmlText(_cubit
                                                    .currentSectionDetail
                                                    ?.firstContent ??
                                                ''),
                                          ),
                                          if (_cubit.currentSectionDetail?.image
                                                  ?.url?.isNotEmpty ==
                                              true)
                                            Container(
                                              alignment: Alignment.center,
                                              padding: const EdgeInsets.only(
                                                  bottom: 24),
                                              child: _buildTitleWidget(
                                                child: CachedNetworkImage(
                                                    // height: 90,
                                                    imageUrl: _cubit
                                                        .currentSectionDetail!
                                                        .image!
                                                        .url!),
                                                title: _cubit
                                                    .currentSectionDetail
                                                    ?.imageTitle,
                                              ),
                                            ),
                                          if (_cubit.currentSectionDetail
                                                  ?.secondContent?.isNotEmpty ==
                                              true)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 24),
                                              child: WidgetHtmlText(_cubit
                                                  .currentSectionDetail!
                                                  .secondContent!),
                                            ),
                                          if (_cubit.audioManager?.controller !=
                                              null)
                                            Container(
                                              key: _audioWidgetKey,
                                              child: _buildTitleWidget(
                                                  child:
                                                      StreamBuilder<AudioData>(
                                                          stream: _cubit
                                                              .audioManager
                                                              ?.controller!
                                                              .onChanged
                                                              .stream,
                                                          builder: (context,
                                                              snapshot) {
                                                            return _buildAudioController(
                                                              audioData:
                                                                  snapshot.data,
                                                              seektoPosition:
                                                                  (newPosition) {
                                                                _cubit
                                                                    .audioManager
                                                                    ?.controller!
                                                                    .seekTo(
                                                                        newPosition);
                                                              },
                                                              onTogglePlay: () {
                                                                _cubit
                                                                    .audioManager
                                                                    ?.controller!
                                                                    .togglePlay();
                                                              },
                                                            );
                                                          }),
                                                  title: _cubit
                                                      .currentSectionDetail
                                                      ?.audioDescription),
                                            ),
                                          const SizedBox(height: 20),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Mini video bar — hiện khi video bị khuất
                              if (_showMiniBar && _cubit.videoManager != null)
                                FutureBuilder(
                                  future: _cubit.videoManager!.controller,
                                  builder: (context, snapshot) {
                                    if (snapshot.data == null)
                                      return const SizedBox.shrink();
                                    return MiniVideoBar(
                                        videoController: snapshot.data!);
                                  },
                                ),
                              // Mini audio bar — hiện khi audio bị khuất
                              if (_showMiniAudioBar &&
                                  _cubit.audioManager?.controller != null)
                                _buildMiniAudioBar(),
                              CustomBottomBarWidget(
                                isPreviousButtonActive: _cubit.isFirstSection,
                                onTapPrevious: () async {
                                  await TrackingManager.logEvent(
                                    name: 'cta_button_clicked',
                                    parameters: {
                                      "screen_name": 'lesson_detail',
                                      "component_name": 'cta_previous_lesson',
                                      'object_id':
                                          _cubit.lessonDetail?.id ?? '',
                                      'object_title':
                                          _cubit.lessonDetail?.name ?? '',
                                    },
                                  );
                                  _cubit.onChangeSection(
                                      context, _cubit.currentSection - 1);
                                },
                                isNextButtonActive: (!_cubit.isLastSection &&
                                    (_cubit.currentSectionDetail?.isComplete ??
                                        false)),
                                onTapNext: _handleNextOrComplete,
                                currentPositionTitle: _cubit.sectionPosition,
                                onTapCenter: () {
                                  showLessonCategoryList();
                                },
                                isCompleted: _cubit.canComplete,
                                previousButtonTitle:
                                    R.string.previous_lesson.tr(),
                              ),
                            ],
                          ),
                        ),
                        if (AppSettings.isOwnPackage)
                          Positioned(
                            child: Container(
                              child: Opacity(
                                opacity: 0.15,
                                child: Transform.scale(
                                  scale: 2.5,
                                  child: Image.network(
                                    AppSettings.userInfo!.ownPackage!.logo ??
                                        "",
                                  ),
                                ),
                              ),
                            ),
                            top: MediaQuery.of(context).size.height * 0.55,
                            left: MediaQuery.of(context).size.width * 0.5 - 50,
                          ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  Future<void> _handleNextOrComplete() async {
    await TrackingManager.logEvent(
      name: 'cta_button_clicked',
      parameters: {
        "screen_name": 'lesson_detail',
        "component_name": 'cta_next_lesson',
        'object_id': _cubit.lessonDetail?.id ?? '',
        'object_title': _cubit.lessonDetail?.name ?? '',
      },
    );

    if (_cubit.lessonDetail?.type != Const.LESSON_SECTION_TYPE_QUIZ &&
        _cubit.canComplete == true &&
        _cubit.alreadyDoneLesson == false &&
        _cubit.isEnabledRating == true &&
        _cubit.reviewed == false) {
      final bool canContinue = await _showLessonRatingBottomSheet();
      if (!canContinue) return;
    }

    _cubit.onChangeSection(
      context,
      _cubit.currentSection + 1,
      smartGoal: widget.smartGoal,
    );
  }

  Future<bool> _showLessonRatingBottomSheet() async {
    if (
        // _cubit.reviewed ||
        _cubit.isEnabledRating != true) {
      log('[RATING] reviewed: ${_cubit.reviewed}');
      log('[RATING] isEnabledRating: ${_cubit.isEnabledRating}');
      return true;
    }

    int rating = 0;
    final Set<String> selectedReasons = <String>{};
    final bool? result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final List<String> reasons = _ratingReasonsByScore(rating);
            final bool canSubmit = rating > 0 && selectedReasons.isNotEmpty;
            final String ratingText = _ratingLabel(rating);
            return Container(
              decoration: BoxDecoration(
                color: R.color.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () => Navigator.of(sheetContext).pop(false),
                          child: Icon(Icons.close, color: R.color.textDark),
                        ),
                      ),
                    ),
                    Text(
                      R.string.lesson_rating_question.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: R.color.color0xff111515,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final int value = index + 1;
                        final bool isActive = value <= rating;
                        return InkWell(
                          onTap: () {
                            setModalState(() {
                              rating = value;
                              selectedReasons.clear();
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              Icons.favorite,
                              size: 30,
                              color: isActive
                                  ? const Color(0xFFD9A93B)
                                  : const Color(0xFFD6DBDE),
                            ),
                          ),
                        );
                      }),
                    ),
                    if (ratingText.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        ratingText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: R.color.textDark,
                        ),
                      ),
                    ],
                    if (reasons.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          R.string.lesson_share_feeling.tr(),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: R.color.color0xff5E6566,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: reasons.map((reason) {
                            final bool selected =
                                selectedReasons.contains(reason);
                            return InkWell(
                              onTap: () {
                                setModalState(() {
                                  if (selected) {
                                    selectedReasons.remove(reason);
                                  } else {
                                    selectedReasons.add(reason);
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: selected
                                      ? R.color.mainColor
                                      : R.color.color0xffF4F7F7,
                                ),
                                child: Text(
                                  reason,
                                  style: TextStyle(
                                    color: selected
                                        ? R.color.white
                                        : R.color.color0xff5E6566,
                                    fontSize: 13,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      decoration: BoxDecoration(
                        color: R.color.white,
                        boxShadow: [Utils.getBoxShadowDropButton()],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: ElevatedButton(
                                onPressed: () =>
                                    Navigator.of(sheetContext).pop(true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: R.color.color0xffDCFFFC,
                                  foregroundColor: R.color.mainColor,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                ),
                                child: Text(
                                  R.string.skip.tr(),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: ElevatedButton(
                                onPressed: canSubmit
                                    ? () async {
                                        final String? error =
                                            await _cubit.sendLessonFeedback(
                                          rating: rating,
                                          note: selectedReasons.join(','),
                                        );
                                        if (!context.mounted) return;
                                        if (error != null) {
                                          Message.showToastMessage(
                                              context, error);
                                          return;
                                        }
                                        Navigator.of(sheetContext).pop(true);
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: R.color.mainColor,
                                  foregroundColor: R.color.white,
                                  disabledBackgroundColor:
                                      const Color(0xFFEAEDEE),
                                  disabledForegroundColor:
                                      R.color.color0xff5E6566,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                ),
                                child: Text(
                                  R.string.lesson_rate_action.tr(),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).padding.bottom),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    return result ?? false;
  }

  _onTrackingVideoPlay() {
    LessonDetailTracking.playVideo(
      objectId: '${_cubit.lessonDetail?.id}',
      objectTitle: '${_cubit.lessonDetail?.name}',
    );
  }

  _onTrackingVideoComplete() {
    Observable.instance
        .notifyObservers([], notifyName: "refresh_home_activity");
    if (_cubit.sectionList.length == 1 && _isShowModal == false) {
      NavigationUtil.navigatePage(
        context,
        LessonCompletedReviewPage(
          moduleName: _cubit.lessonDetail?.lessonModule?.name ?? '',
          title: _cubit.lessonDetail?.name ?? '',
          description: _cubit.lessonDetail?.description ?? '',
          imageUrl: _cubit.lessonDetail?.image?.url ?? '',
          rating: _cubit.review?.rating ?? 0,
          note: _cubit.review?.note ?? '',
          onShare: () => _onShareLesson(context, _cubit.currentSectionDetail!),
        ),
      ).then((_) {
        NavigationUtil.pop(context, result: 1);
        BotToast.closeAllLoading();
      });
      setState(() {
        _isShowModal = true;
      });
    }
  }

  // ── Floating mini bar helpers ─────────────────────────────────────────

  void _checkMediaVisibility() {
    bool needsSetState = false;

    // ── Video ──
    final hasVideo =
        _cubit.currentSectionDetail?.videoAddressLink?.isNotEmpty == true;
    if (!hasVideo) {
      if (_showMiniBar) {
        _showMiniBar = false;
        needsSetState = true;
      }
    } else if (_videoWidgetKey.currentContext != null) {
      final renderObj = _videoWidgetKey.currentContext!.findRenderObject();
      if (renderObj != null && renderObj.attached) {
        final RenderBox box = renderObj as RenderBox;
        final pos = box.localToGlobal(Offset.zero);
        final isVideoHidden = pos.dy + box.size.height < 0;
        if (isVideoHidden != _showMiniBar) {
          _showMiniBar = isVideoHidden;
          needsSetState = true;
        }
      }
    }

    // ── Audio ──
    final hasAudio = _cubit.audioManager?.controller != null;
    if (!hasAudio) {
      if (_showMiniAudioBar) {
        _showMiniAudioBar = false;
        needsSetState = true;
      }
    } else if (_audioWidgetKey.currentContext != null) {
      final renderObj = _audioWidgetKey.currentContext!.findRenderObject();
      if (renderObj != null && renderObj.attached) {
        final RenderBox box = renderObj as RenderBox;
        final pos = box.localToGlobal(Offset.zero);
        final isAudioHidden = pos.dy + box.size.height < 0;
        if (isAudioHidden != _showMiniAudioBar) {
          _showMiniAudioBar = isAudioHidden;
          needsSetState = true;
        }
      }
    }

    if (needsSetState) setState(() {});
  }

  /// Mini audio bar — dùng chung AudioController với audio chính ở trên.
  Widget _buildMiniAudioBar() {
    final audioCtrl = _cubit.audioManager!.controller!;
    return StreamBuilder<AudioData>(
      stream: audioCtrl.onChanged.stream,
      builder: (context, snapshot) {
        final data = snapshot.data ?? audioCtrl.audioData;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5F3),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: Row(
            children: [
              // Play / Pause
              GestureDetector(
                onTap: audioCtrl.togglePlay,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: R.color.greenGradientBottom,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    data.isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 18,
                    color: R.color.greenGradientBottom,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Time
              Text(
                data.timeText,
                style: TextStyle(
                  fontSize: 13,
                  color: R.color.textDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 10),
              // Progress slider
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2.5,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 0,
                    ),
                    overlayShape: SliderComponentShape.noOverlay,
                  ),
                  child: Slider(
                    inactiveColor: const Color(0xFFD0D0D0),
                    activeColor: R.color.greenGradientBottom,
                    value: data.position,
                    onChanged: (v) {
                      if (data.totalTime.inMilliseconds == 0) return;
                      final newPos = v * data.totalTime.inMilliseconds;
                      audioCtrl.seekTo(newPos);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTitleWidget({required Widget child, String? title}) {
    return Column(
      children: [
        child,
        if (title != null) const SizedBox(height: 6),
        if (title != null)
          Text(
            title,
            style: TextStyle(
              color: R.color.mediaTitle,
              fontSize: 10,
              fontWeight: FontWeight.w400,
            ),
          ),
      ],
    );
  }

  Future<void> _onShareLesson(
      BuildContext context, LessonSectionItem lesson) async {
    String shareLink = lesson.linkShare ?? "";
    if (shareLink.isEmpty) {
      shareLink = await BranchioLinkConfig.instance.createShareLessonLink(
        lesson: lesson,
        featureImage: _cubit.featureImage,
        lessonDescription: _cubit.lessonDescription,
      );
    }
    AppShare.instance.lessonDetail(context, shareLink, lesson.name ?? "");
  }

  Widget _buildAudioController({
    required AudioData? audioData,
    required Function(double newPosition) seektoPosition,
    VoidCallback? onTogglePlay,
  }) {
    return Row(
      children: [
        IconButton(
          onPressed: onTogglePlay,
          icon: audioData?.isPlaying ?? false
              ? const Icon(Icons.pause)
              : const Icon(Icons.play_arrow),
          iconSize: 24,
        ),
        Text(audioData?.timeText ?? '00:00 / 00:00',
            style: R.style.normalTextStyle),
        Expanded(
          child: Slider(
            inactiveColor: R.color.gray,
            activeColor: R.color.textDark,
            onChanged: (v) {
              if (audioData?.totalTime == null) {
                return;
              }
              final double newPosition =
                  v * audioData!.totalTime.inMilliseconds;
              seektoPosition(newPosition);
            },
            value: audioData?.position ?? 0.0,
          ),
        ),
      ],
    );
  }

  Future<void> showLessonCategoryList() async {
    await showModalBottomSheet(
      context: context,
      clipBehavior: Clip.hardEdge,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
      ),
      builder: (BuildContext context) {
        return lesson_bottom_sheet.BottomSheetWidget(
          sectionList: _cubit.sectionList,
          currentSection: _cubit.currentSection,
          onChangeSection: (int newSectionIndex) async {
            _cubit.videoManager?.disposeAllVideo();
            await Future.delayed(const Duration(milliseconds: 200));
            _cubit.onChangeSection(context, newSectionIndex, isFromList: true);
          },
          lessonDetail: _cubit.lessonDetail!,
        );
      },
    );
    _cubit.checkSectionComplete();
  }
}
