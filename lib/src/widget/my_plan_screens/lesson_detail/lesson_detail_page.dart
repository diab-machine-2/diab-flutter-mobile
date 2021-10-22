import 'package:better_player/better_player.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/course_quiz/course_quiz.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/background_page.dart';
import 'package:medical/src/widgets/html_text_widget.dart';

import 'lesson_detail.dart';
import 'models/audio_data.dart';
import 'widgets/bottom_sheet_widget.dart';

class LessonDetailPage extends StatefulWidget {
  const LessonDetailPage(this.lessonId);
  final String lessonId;

  @override
  _LessonDetailPageState createState() => _LessonDetailPageState();
}

class _LessonDetailPageState extends State<LessonDetailPage> {
  late final LessonDetailCubit _cubit;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final AppRepository appRepository = AppRepository();
    _cubit = LessonDetailCubit(appRepository);
    _cubit.initData(widget.lessonId);
  }

  @override
  void dispose() {
    super.dispose();
    _cubit.videoManagement?.disposeAllVideo();
    _cubit.audioManagement?.disposeAllAudio();
    _scrollController.removeListener(() {});
    _scrollController.dispose();
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
        },
        builder: (context, state) {
          return _cubit.currentSectionDetail?.type ==
                  Const.LESSON_SECTION_TYPE_QUIZ
              ? CourseQuizPage(
                  lessonId: _cubit.currentSectionDetail?.id ?? '',
                )
              : Scaffold(
                  body: BackgroundPage(
                    background: R.drawable.bg_lesson_detail,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SafeArea(
                          bottom: false,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 18.h, horizontal: 16.h),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Phần ${_cubit.sectionPosition}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        color: R.color.textDark,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    NavigationUtil.pop(context);
                                  },
                                  child: Icon(
                                    Icons.clear_rounded,
                                    size: 24,
                                    color: R.color.grey_2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            _cubit.currentSectionDetail?.name ?? '',
                            style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(height: 14.h),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: NotificationListener(
                              onNotification: (notify) {
                                if (notify is KeepAliveNotification) {
                                  if (_cubit.sectionStatus.isScrollToEnd !=
                                      true) {
                                    if (_scrollController.position.pixels ==
                                            0 &&
                                        _scrollController
                                                .position.maxScrollExtent ==
                                            0) {
                                      _cubit.sectionStatus.isScrollToEnd = true;
                                    }
                                    print(
                                        'LOG max: ${_scrollController.position.maxScrollExtent}');
                                  }
                                }
                                if (notify is ScrollEndNotification &&
                                    _scrollController.position.pixels ==
                                        _scrollController
                                            .position.maxScrollExtent) {
                                  _cubit.sectionStatus.isScrollToEnd = true;
                                  _cubit.checkSectionComplete();
                                }
                                return true;
                              },
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ...List.generate(
                                      _cubit.videoManagement?.videoAmount ?? 0,
                                      (index) {
                                        return Padding(
                                          padding:
                                              EdgeInsets.only(bottom: 24.h),
                                          child: BetterPlayer(
                                              controller: _cubit
                                                  .videoManagement!
                                                  .controllerList[index]),
                                        );
                                      },
                                    ),
                                    ...List.generate(
                                        _cubit.audioManagement?.audioAmount ??
                                            0, (index) {
                                      final AudioController? _controller =
                                          _cubit.audioManagement
                                              ?.getController(index);
                                      return StreamBuilder<AudioData>(
                                          stream: _controller?.onChanged.stream,
                                          builder: (context, snapshot) {
                                            return _buildAudioController(
                                              audioData: snapshot.data,
                                              seektoPosition: (newPosition) {
                                                _controller
                                                    ?.seekTo(newPosition);
                                              },
                                              onTogglePlay: () {
                                                _controller?.togglePlay();
                                              },
                                            );
                                          });
                                    }).toList(),
                                    WidgetHtmlText(
                                        _cubit.currentSectionDetail?.content ??
                                            ''),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          color: R.color.white,
                          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 18.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _cubit.onChangeSection(
                                      _cubit.currentSection - 1);
                                },
                                child: Container(
                                  height: 36.h,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 16.w),
                                  decoration: BoxDecoration(
                                    color: R.color.main_6,
                                    borderRadius: BorderRadius.circular(200),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.chevron_left_rounded,
                                        size: 20.w,
                                        color: R.color.greenGradientBottom,
                                      ),
                                      Text(
                                        'Quay lại',
                                        style: TextStyle(
                                          color: R.color.accentColor,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  showLessonCategoryList();
                                },
                                child: Container(
                                  width: 36.w,
                                  height: 36.w,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border:
                                        Border.all(color: R.color.accentColor),
                                  ),
                                  child: Text(
                                    _cubit.sectionPosition,
                                    style: TextStyle(
                                      color: R.color.accentColor,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _cubit.onChangeSection(
                                      _cubit.currentSection + 1);
                                },
                                child: Container(
                                  height: 36.h,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 16.w),
                                  decoration: BoxDecoration(
                                    color: R.color.main_6,
                                    borderRadius: BorderRadius.circular(200),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Tiếp theo',
                                        style: TextStyle(
                                          color: R.color.accentColor,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        size: 20.w,
                                        color: R.color.greenGradientBottom,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).padding.bottom,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                );
        },
      ),
    );
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
          iconSize: 24.sp,
        ),
        Text(
          audioData?.timeText ?? '',
          style: TextStyle(
            color: R.color.textDark,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
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

  void showLessonCategoryList() {
    showModalBottomSheet(
      context: context,
      clipBehavior: Clip.hardEdge,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
      ),
      builder: (BuildContext context) {
        return BottomSheetWidget(
          sectionList: _cubit.sectionList,
          currentSection: _cubit.currentSection,
          onChangeSection: _cubit.onChangeSection,
        );
      },
    );
  }
}
