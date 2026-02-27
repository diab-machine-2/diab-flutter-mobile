import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
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
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/activity_tab/models/schedule_type.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/widgets/mini_video_bar.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/widgets/video_widget.dart';
import 'package:medical/src/widgets/background_page.dart';
import 'package:medical/src/widgets/custom_bottom_bar_widget.dart';
import 'package:medical/src/widgets/html_text_widget.dart';

import '../course_quiz/course_quiz.dart';
import 'lesson_detail.dart';
import 'models/audio_data.dart';
import 'widgets/bottom_sheet_share_lesson.dart';
import 'widgets/bottom_sheet_widget.dart';
import 'widgets/share_lesson_button.dart';

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

  // ── Floating mini video bar ──
  final GlobalKey _videoWidgetKey = GlobalKey();
  bool _showMiniBar = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final AppRepository appRepository = AppRepository();
    _cubit = LessonDetailCubit(appRepository);
    _cubit.initData(widget.lessonType, widget.lessonId);
    LessonDetailTracking.firebaseSetup();
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
            if (state.showPopupShare == true) {
              LessonDetailTracking.lessonCompleted(
                objectId: _cubit.lessonDetail?.id,
                objectTitle: _cubit.lessonDetail?.name,
              );
              BottomSheetShareLesson.showDialogShareLesson(
                context,
                onShare: () =>
                    _onShareLesson(context, _cubit.currentSectionDetail!),
                onCancel: () async {
                  if (widget.smartGoal?.id != null) {
                    await HomeClient().completeSmartGoal(DateTime.now(),
                        widget.smartGoal!.id, 1, ScheduleType.lesson.typeIndex);
                  }
                  NavigationUtil.pop(context, result: 0);
                  BotToast.closeAllLoading();
                },
              );
            }
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
                              SafeArea(
                                bottom: false,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 18, horizontal: 16),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                debugPrint(
                                                    '[VIDEO][${DateTime.now().toIso8601String().substring(11, 23)}] Back button pressed - pausing video and audio');

                                                // Pause video and audio before navigation (don't dispose here - let dispose() handle it)
                                                if (_cubit.videoManager !=
                                                    null) {
                                                  try {
                                                    _cubit.videoManager
                                                        ?.controller
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

                                                if (_cubit.audioManager !=
                                                    null) {
                                                  try {
                                                    _cubit.audioManager
                                                        ?.controller
                                                        ?.pause();
                                                    debugPrint(
                                                        '[VIDEO][${DateTime.now().toIso8601String().substring(11, 23)}] Audio controller paused on back press');
                                                  } catch (e) {
                                                    debugPrint(
                                                        '[VIDEO][${DateTime.now().toIso8601String().substring(11, 23)}] Error pausing audio controller: $e');
                                                  }
                                                }

                                                // Schedule tracking asynchronously (non-blocking)
                                                TrackingManager.analytics
                                                    .logEvent(
                                                  name: 'component_clicked',
                                                  parameters: {
                                                    "screen_name":
                                                        'lesson_detail',
                                                    "component_name":
                                                        'close_lesson',
                                                    'object_id': _cubit
                                                            .lessonDetail?.id ??
                                                        '',
                                                    'object_title': _cubit
                                                            .lessonDetail
                                                            ?.name ??
                                                        '',
                                                  },
                                                ).catchError((e) {
                                                  debugPrint(
                                                      '[VIDEO] Error in tracking: $e');
                                                });

                                                NavigationUtil.pop(context);
                                              },
                                              child: Icon(
                                                Icons.clear_rounded,
                                                size: 26,
                                                color: R.color.grey_2,
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              R.string.section_position.tr(
                                                  args: [
                                                    _cubit.sectionPosition
                                                  ]),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: R.color.textDark,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (_cubit.currentSectionDetail != null)
                                        ShareLessonButton(
                                          lessonDescription:
                                              _cubit.lessonDescription,
                                          featureImage: _cubit.featureImage,
                                          lesson: _cubit.currentSectionDetail!,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
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
                                  SizedBox(
                                    height: 16,
                                  ),
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
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (_cubit.currentSectionDetail
                                                  ?.videoAddressLink !=
                                              null)
                                            _buildTitleWidget(
                                              child: VideoWidget(
                                                isYouTubeLink: isYouTubeLink(
                                                    _cubit.currentSectionDetail
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
                                                    objectId:
                                                        _cubit.lessonDetail?.id,
                                                    objectTitle: _cubit
                                                        .lessonDetail?.name,
                                                  );
                                                  _cubit.complete();
                                                  _onTrackingVideoComplete();
                                                },
                                                callbackByPercentVideo: () {
                                                  LessonDetailTracking
                                                      .completed50PercentVideo(
                                                    objectId:
                                                        _cubit.lessonDetail?.id,
                                                    objectTitle: _cubit
                                                        .lessonDetail?.name,
                                                  );
                                                  widget.onComplete(
                                                      _cubit.lessonDetail!.id!,
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
                                                    .currentSectionDetail?.name,
                                                videoThumbnail: _cubit
                                                    .lessonDetail?.image?.url,
                                              ),
                                              title: _cubit.currentSectionDetail
                                                  ?.videoDescription,
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
                                            _buildTitleWidget(
                                                child: StreamBuilder<AudioData>(
                                                    stream: _cubit
                                                        .audioManager
                                                        ?.controller!
                                                        .onChanged
                                                        .stream,
                                                    builder:
                                                        (context, snapshot) {
                                                      return _buildAudioController(
                                                        audioData:
                                                            snapshot.data,
                                                        seektoPosition:
                                                            (newPosition) {
                                                          _cubit.audioManager
                                                              ?.controller!
                                                              .seekTo(
                                                                  newPosition);
                                                        },
                                                        onTogglePlay: () {
                                                          _cubit.audioManager
                                                              ?.controller!
                                                              .togglePlay();
                                                        },
                                                      );
                                                    }),
                                                title: _cubit
                                                    .currentSectionDetail
                                                    ?.audioDescription),
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
                                onTapNext: () async {
                                  await TrackingManager.logEvent(
                                    name: 'cta_button_clicked',
                                    parameters: {
                                      "screen_name": 'lesson_detail',
                                      "component_name": 'cta_next_lesson',
                                      'object_id':
                                          _cubit.lessonDetail?.id ?? '',
                                      'object_title':
                                          _cubit.lessonDetail?.name ?? '',
                                    },
                                  );
                                  _cubit.onChangeSection(
                                      context, _cubit.currentSection + 1,
                                      smartGoal: widget.smartGoal);
                                },
                                currentPositionTitle: _cubit.sectionPosition,
                                onTapCenter: () {
                                  showLessonCategoryList();
                                },
                                isCompleted: _cubit.canComplete,
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
      BottomSheetShareLesson.showDialogShareLesson(
        context,
        onShare: () => _onShareLesson(context, _cubit.currentSectionDetail!),
        onCancel: () {
          NavigationUtil.pop(context, result: 0);
          BotToast.closeAllLoading();
        },
      );
      setState(() {
        _isShowModal = true;
      });
    }
  }

  // ── Floating mini video bar helpers ────────────────────────────────────

  void _checkVideoVisibility() {
    final hasVideo =
        _cubit.currentSectionDetail?.videoAddressLink?.isNotEmpty == true;
    if (!hasVideo) {
      if (_showMiniBar) setState(() => _showMiniBar = false);
      return;
    }

    if (_videoWidgetKey.currentContext == null) return;

    final renderObj = _videoWidgetKey.currentContext!.findRenderObject();
    if (renderObj == null || !renderObj.attached) return;

    final RenderBox box = renderObj as RenderBox;
    final position = box.localToGlobal(Offset.zero);

    // Video bị khuất (scroll xuống) → show mini bar
    final isVideoHidden = position.dy + box.size.height < 0;

    if (isVideoHidden != _showMiniBar) {
      setState(() => _showMiniBar = isVideoHidden);
    }
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

  _onShareLesson(BuildContext context, LessonSectionItem lesson) async {
    String shareLink = await BranchioLinkConfig.instance.createShareLessonLink(
        lesson: lesson,
        featureImage: _cubit.featureImage,
        lessonDescription: _cubit.lessonDescription);
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
        return BottomSheetWidget(
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
