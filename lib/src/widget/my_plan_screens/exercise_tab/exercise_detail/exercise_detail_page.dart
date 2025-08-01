import 'package:better_player_plus/better_player_plus.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/firebase_tracking/excercise_detail_tracking.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/exercise_movement_response.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/widgets/youtube_video_widget.dart';
import 'package:medical/src/widget/my_plan_screens/my_plan/models/completion_status.dart';
import 'package:medical/src/widgets/button_widget.dart';

import '../exercise_feedback/exercise_feedback.dart';
import 'exercise_detail.dart';

class ExerciseDetail extends StatefulWidget {
  const ExerciseDetail({required this.exerciseData});
  final ExerciseMovementResponseData? exerciseData;

  @override
  _ExerciseDetailState createState() => _ExerciseDetailState();
}

class _ExerciseDetailState extends State<ExerciseDetail> {
  late final ExerciseDetailCubit _cubit;

  @override
  void initState() {
    super.initState();
    final AppRepository appRepository = AppRepository();
    _cubit = ExerciseDetailCubit(appRepository);
    _cubit.initData(widget.exerciseData, context);
    ExcerciseDetailTracking.firebaseSetup();

    // Initialize player after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePlayer();
    });
  }

  @override
  void dispose() {
    _cubit.videoManager.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    if (_cubit.videoManager.controller != null) {
      try {
        // Make sure the player is properly initialized
        await _cubit.videoManager.ensureVideoInitialized();

        // If there's still an issue, you can force a reload
        if (_cubit.videoManager.videoDuration == null ||
            _cubit.videoManager.videoDuration!.inMilliseconds <= 0) {
          debugPrint('[EXERCISE] Forcing video data source retry');
          await _cubit.videoManager.controller!.retryDataSource();
        }

        // Set autoplay
        await _cubit.videoManager.controller!.play();

        if (mounted) setState(() {});
      } catch (e) {
        debugPrint('[EXERCISE] Error initializing player: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: Scaffold(
        backgroundColor: R.color.textDark,
        body: Stack(
          children: [
            BlocConsumer<ExerciseDetailCubit, ExerciseDetailState>(
              listener: (context, state) {
                if (state is ExerciseDetailLoading) {
                  BotToast.showLoading();
                } else {
                  BotToast.closeAllLoading();
                }
                if (state is ExerciseDetailFailure) {
                  Message.showToastMessage(context, state.error);
                }
                if (state is ExerciseDetailAllCompleted) {
                  _showDonePopup(context);
                }
                if (state is ExerciseDetailMakeFeedback) {
                  NavigationUtil.navigatePage(
                    context,
                    ExerciseFeedbackPage(
                      exerciseMovementId: _cubit.exerciseData.id ?? '',
                    ),
                  );
                }
              },
              builder: (context, state) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 120),
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: _cubit.videoManager.isYoutubeUrl() == false
                          ? _cubit.videoManager.controller != null
                              ? BetterPlayer(
                                  controller: _cubit.videoManager.controller!,
                                  // Add key to force rebuild when needed
                                  key: ValueKey(
                                      'better_player_${DateTime.now().millisecondsSinceEpoch}'),
                                )
                              : const SizedBox.shrink()
                          : YoutubeVideoWidget(
                              videoUrl: _cubit.exerciseData.videoUrl ?? '',
                              videoTitle:
                                  _cubit.exerciseData.name ?? 'Exercise Video',
                              videoThumbnail: _cubit.exerciseData.image?.url,
                              onPlay: ({meta}) {
                                debugPrint(
                                    '[EXERCISE] onPlay youtube video: $meta - ${_cubit.exerciseData.id} - ${_cubit.exerciseData.name}');
                                ExcerciseDetailTracking.playVideo(
                                  eventType: CustomPlayerEventType.videoPlay,
                                  videoDuration:
                                      meta?.duration ?? Duration(seconds: 0),
                                  objectId: _cubit.exerciseData.id,
                                  objectTitle: _cubit.exerciseData.name,
                                );
                              },
                              onEnded: ({meta}) async {
                                debugPrint(
                                    '[EXERCISE] onEnded youtube video: $meta - ${_cubit.exerciseData.id} - ${_cubit.exerciseData.name}');
                                ExcerciseDetailTracking.playVideo(
                                  eventType:
                                      CustomPlayerEventType.videoCompleted,
                                  videoDuration:
                                      meta?.duration ?? Duration(seconds: 0),
                                  objectId: _cubit.exerciseData.id,
                                  objectTitle: _cubit.exerciseData.name,
                                );
                                await _cubit.completeExercise(
                                    _cubit.exerciseData.id ?? '');
                              },
                            ),
                    ),
                    SizedBox(height: 2),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Text(
                            _cubit.exerciseData.description ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: R.color.white,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top,
              right: 16,
              child: IconButton(
                onPressed: () {
                  if (_cubit.videoManager.isCompleted ||
                      _cubit.videoManager.controller == null) {
                    NavigationUtil.pop(context);
                    return;
                  }
                  showWarningDialog(context);
                },
                icon: const Icon(
                  Icons.close_rounded,
                ),
                color: R.color.white,
                iconSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showWarningDialog(BuildContext context) async {
    final dynamic confirm = await showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
      context: context,
      builder: (_) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    R.color.white,
                    R.color.main_6,
                  ],
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 24),
                    child: Image.asset(R.drawable.img_stop_exercise,
                        width: 231, height: 150),
                  ),
                  Text(
                    R.string.stop_exercise_warning.tr(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: R.color.textDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    R.string.stop_exercise_warning_description.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: R.color.textDark,
                    ),
                    maxLines: 3,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                          flex: 1,
                          child: ButtonWidget(
                            title: R.string.cancel.tr(),
                            backgroundColor: R.color.grayBorder,
                            textColor: R.color.textDark,
                            height: 43,
                            onPressed: () => NavigationUtil.pop(context),
                          )),
                      const SizedBox(width: 15),
                      Expanded(
                        flex: 1,
                        child: ButtonWidget(
                            title: R.string.confirm.tr(),
                            height: 43,
                            onPressed: () async {
                              await TrackingManager.analytics.logEvent(
                                name: 'cta_button_clicked',
                                parameters: {
                                  "screen_name": 'excercise_detail',
                                  'cta_button_name': 'cta_exercise_cancel',
                                  'object_id': '${widget.exerciseData?.id}',
                                  'object_title':
                                      '${widget.exerciseData?.name}',
                                },
                              );
                              NavigationUtil.pop(context, result: true);
                            }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (confirm is bool && confirm) {
      NavigationUtil.pop(context);
    }
  }

  Future<void> _showDonePopup(BuildContext context) async {
    Observable.instance.notifyObservers([], notifyName: "goal_calo_changed");

    await showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
      context: context,
      builder: (_) => Scaffold(
        backgroundColor: R.color.transparent,
        body: Center(
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      R.color.white,
                      R.color.main_6,
                    ],
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Image.asset(
                        R.drawable.img_learn_result_high,
                        height: 205,
                        width: 200,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        R.string.exercise_done.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: R.color.textDark),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 24,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded),
                  iconSize: 24,
                  onPressed: () async {
                    await TrackingManager.analytics.logEvent(
                      name: 'cta_button_clicked',
                      parameters: {
                        "screen_name": 'excercise_detail',
                        'cta_button_name': 'cta_exercise_complete',
                        'object_id': '${widget.exerciseData?.id}',
                        'object_title': '${widget.exerciseData?.name}',
                      },
                    );
                    NavigationUtil.pop(context);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
    NavigationUtil.pop(context);
  }
}
