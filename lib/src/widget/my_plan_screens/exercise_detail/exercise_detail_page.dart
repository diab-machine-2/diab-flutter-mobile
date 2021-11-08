import 'package:better_player/better_player.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/exercise_movement_response.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/button_widget.dart';

import '../exercise_feedback/exercise_feedback.dart';
import 'exercise_detail.dart';

class ExerciseDetail extends StatefulWidget {
  const ExerciseDetail({required this.exerciseData});
  final ExerciseMovementResponseData exerciseData;

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
    _cubit.initData(widget.exerciseData);
  }

  @override
  void dispose() {
    _cubit.videoManager.dispose();
    super.dispose();
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
                  //TODO: Lesson completed
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
                return Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: _cubit.videoManager.controller != null
                      ? BetterPlayer(
                          controller: _cubit.videoManager.controller!)
                      : const SizedBox.shrink(),
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
                            onPressed: () {
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
}
