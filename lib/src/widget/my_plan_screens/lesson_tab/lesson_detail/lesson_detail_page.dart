import 'package:better_player/better_player.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_sharing.dart';
import 'package:medical/src/app_setting/dynamic_link_config.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/lesson_section_list_response.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/my_plan_screens/exercise_tab/exercise_detail/models/video_manager.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/widgets/video_widget.dart';
import 'package:medical/src/widgets/background_page.dart';
import 'package:medical/src/widgets/custom_bottom_bar_widget.dart';
import 'package:medical/src/widgets/html_text_widget.dart';

import '../course_quiz/course_quiz.dart';
import 'lesson_detail.dart';
import 'models/audio_data.dart';
import 'widgets/bottom_sheet_share_lesson.dart';
import 'widgets/bottom_sheet_widget.dart';

import 'package:path_provider/path_provider.dart';

import 'widgets/share_lesson_button.dart';

class LessonDetailPage extends StatefulWidget {
  const LessonDetailPage({required this.lessonType, required this.lessonId});
  final int? lessonType;
  final String lessonId;

  @override
  _LessonDetailPageState createState() => _LessonDetailPageState();
}

class _LessonDetailPageState extends State<LessonDetailPage> {
  late final LessonDetailCubit _cubit;

  @override
  void initState() {
    super.initState();
    final AppRepository appRepository = AppRepository();

    _cubit = LessonDetailCubit(appRepository);
    _cubit.initData(widget.lessonType, widget.lessonId);
  }

  @override
  void dispose() {
    super.dispose();
    _cubit.videoManager?.disposeAllVideo();
    _cubit.audioManager?.disposeAllAudio();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: BlocConsumer<LessonDetailCubit, LessonDetailState>(
        listener: (context, state) {
          if (state is LessonDetailLoading) {
            BotToast.showLoading();
          } else {
            BotToast.closeAllLoading();
          }
          if (state is LessonDetailFailure) {
            Message.showToastMessage(context, state.error);
          }
          if (state is LessonDetailCompleted) {
            BottomSheetShareLesson.showDialogDeleteAccount(
              context,
              onShare: () {
                _onShareLesson(context, _cubit.currentSectionDetail!);
              },
              onCancel: () {
                NavigationUtil.pop(context, result: 0);
                BotToast.closeAllLoading();
              },
            );
          }
        },
        builder: (context, state) {
          return _cubit.showQuizLesson
              ? CourseQuizPage(
                  key: Key(_cubit.currentSectionDetail?.id ?? ''),
                  lessonId: _cubit.lessonId,
                  lessonSectionItem: widget.lessonType != 3
                      ? _cubit.currentSectionDetail
                      : null,
                  onDone: (isPassed) async {
                    _cubit.onChangeSection(context, _cubit.currentSection + 1);
                  })
              : Scaffold(
                  body: BackgroundPage(
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
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
                                        R.string.section_position
                                            .tr(args: [_cubit.sectionPosition]),
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
                                    lesson: _cubit.currentSectionDetail!,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            _cubit.currentSectionDetail?.name ?? '',
                            style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_cubit.currentSectionDetail
                                          ?.videoAddressLink !=
                                      null)
                                    _buildTitleWidget(
                                      child:
                                          //BetterPlayer(controller: _cubit.videoManager!.controller!),
                                          VideoWidget(
                                        url: _cubit.currentSectionDetail
                                                ?.videoAddressLink ??
                                            '',
                                        onComplete: () {
                                          BottomSheetShareLesson
                                              .showDialogDeleteAccount(
                                            context,
                                            onShare: () {},
                                            onCancel: () {
                                              NavigationUtil.pop(context,
                                                  result: 0);
                                              BotToast.closeAllLoading();
                                            },
                                          );
                                        },
                                        callbackByPercentVideo: () {
                                          _cubit.complete();
                                        },
                                        percentCallbackDefault: 0.5,
                                        setVideoManager: (videoManager) {
                                          _cubit.setVideoManager(videoManager);
                                        },
                                      ),
                                      title: _cubit.currentSectionDetail
                                          ?.videoDescription,
                                    ),
                                  SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 24),
                                    child: WidgetHtmlText(_cubit
                                            .currentSectionDetail
                                            ?.firstContent ??
                                        ''),
                                  ),
                                  if (_cubit.currentSectionDetail?.image?.url
                                          ?.isNotEmpty ==
                                      true)
                                    Container(
                                      alignment: Alignment.center,
                                      padding:
                                          const EdgeInsets.only(bottom: 24),
                                      child: _buildTitleWidget(
                                        child: CachedNetworkImage(
                                            height: 90,
                                            imageUrl: _cubit
                                                .currentSectionDetail!
                                                .image!
                                                .url!),
                                        title: _cubit
                                            .currentSectionDetail?.imageTitle,
                                      ),
                                    ),
                                  if (_cubit.currentSectionDetail?.secondContent
                                          ?.isNotEmpty ==
                                      true)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 24),
                                      child: WidgetHtmlText(_cubit
                                          .currentSectionDetail!
                                          .secondContent!),
                                    ),
                                  if (_cubit.audioManager?.controller != null)
                                    _buildTitleWidget(
                                        child: StreamBuilder<AudioData>(
                                            stream: _cubit.audioManager
                                                ?.controller!.onChanged.stream,
                                            builder: (context, snapshot) {
                                              return _buildAudioController(
                                                audioData: snapshot.data,
                                                seektoPosition: (newPosition) {
                                                  _cubit
                                                      .audioManager?.controller!
                                                      .seekTo(newPosition);
                                                },
                                                onTogglePlay: () {
                                                  _cubit
                                                      .audioManager?.controller!
                                                      .togglePlay();
                                                },
                                              );
                                            }),
                                        title: _cubit.currentSectionDetail
                                            ?.audioDescription),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                        CustomBottomBarWidget(
                          isPreviousButtonActive: _cubit.isFirstSection,
                          onTapPrevious: () {
                            _cubit.onChangeSection(
                                context, _cubit.currentSection - 1);
                          },
                          isNextButtonActive: (!_cubit.isLastSection &&
                              (_cubit.currentSectionDetail?.isComplete ??
                                  false)),
                          onTapNext: () {
                            _cubit.onChangeSection(
                                context, _cubit.currentSection + 1);
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
                );
        },
      ),
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

  _onShareLesson(BuildContext context, LessonSectionItem lesson) async {
    String shareLink =
        await DynamicLinkConfig.instance.createShareLessonLink(lesson: lesson);
    AppShare.instance.lessonDetail(context, shareLink);
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
          onChangeSection: (int newSectionIndex) {
            _cubit.onChangeSection(context, newSectionIndex, isFromList: true);
          },
        );
      },
    );
    _cubit.checkSectionComplete();
  }
}
