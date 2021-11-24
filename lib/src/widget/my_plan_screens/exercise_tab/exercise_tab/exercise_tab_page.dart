import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/exercise_movement_response.dart';
import 'package:medical/src/model/response/week_states_response.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/lesson_status_widget.dart';
import 'package:medical/src/widgets/network_image_widget.dart';
import 'package:medical/src/widgets/video_player_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../my_plan/models/completion_status.dart';
import '../../my_plan/my_plan.dart';
import '../../my_plan/widgets/app_bar_bottom.dart';
import '../exercise_detail/exercise_detail.dart';
import '../select_road_map/select_road_map.dart';
import 'exercise_tab.dart';

class ExerciseTabPage extends StatefulWidget {
  const ExerciseTabPage();

  @override
  _ExerciseTabPageState createState() => _ExerciseTabPageState();
}

class _ExerciseTabPageState extends State<ExerciseTabPage>
    with AutomaticKeepAliveClientMixin<ExerciseTabPage> {
  late final ExerciseTabCubit _cubit;
  final RefreshController _controller = RefreshController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final MyPlanCubit _myPlanCubit = BlocProvider.of<MyPlanCubit>(context);
    final AppRepository appRepository = AppRepository();
    _cubit = ExerciseTabCubit(appRepository, _myPlanCubit);
    _cubit.initData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider(
      create: (context) => _cubit,
      child: BlocConsumer<ExerciseTabCubit, ExerciseTabState>(
        listener: (context, state) {
          if (state is ExerciseTabLoading) {
            BotToast.showLoading();
          } else {
            BotToast.closeAllLoading();
            _controller.refreshCompleted();
          }
          if (state is ExerciseTabFailure) {
            Message.showToastMessage(context, state.error);
          }
          if (state is ExerciseTabRoadmapEmpty) {
            changeRoadMap();
          }
          if (state is ExerciseTabWeekChanged) {
            animateToIndex(state.newIndex, refresh: false);
          }
        },
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBarBottom(
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        changeRoadMap();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            R.string.change_road_map.tr(),
                            style: TextStyle(
                              color: R.color.greenGradientBottom,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Image.asset(
                            R.drawable.ic_start_exercise_bold,
                            width: 16,
                            height: 16,
                          ),
                        ],
                      ),
                    ),
                    _buildScheduleWidget(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: SmartRefresher(
                    controller: _controller,
                    onRefresh: () =>
                        _cubit.getExerciseMovement(isRefresh: true),
                    child:
                        _cubit.exerciseMovementResponse?.data?.isEmpty == null
                            ? const SizedBox.shrink()
                            : _cubit.isDayOff
                                ? _buildDayOffWidget()
                                : ListView.separated(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 20),
                                    itemCount: _cubit.isPremium
                                        ? 1
                                        : (_cubit.exerciseMovementResponse?.data
                                                ?.length ??
                                            0),
                                    itemBuilder: (context, index) {
                                      return _buildExerciseWidget(
                                          exerciseItem: _cubit.isPremium
                                              ? _cubit.currentExercise
                                              : _cubit.exerciseMovementResponse
                                                  ?.data?[index]);
                                    },
                                    separatorBuilder: (context, index) {
                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 20),
                                        height: 1,
                                        color: R.color.grayBorder,
                                      );
                                    }),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void animateToIndex(int index, {bool refresh = true}) {
    if (_cubit.weekStatesList.isEmpty) return;
    if (index < 0) {
      index = 0;
      refresh = false;
    }
    if (index >= _cubit.weekStatesList.length) {
      index = _cubit.weekStatesList.length - 1;
      refresh = false;
    }
    final double newPosition = index * 96 + (6 * index.toDouble());
    _scrollController.animateTo(
      newPosition,
      duration: const Duration(milliseconds: 400),
      curve: Curves.ease,
    );
    if (refresh) {
      _cubit.onSelectWeek(index);
    }
  }

  Widget _buildWeekListWidget() {
    if (_cubit.weekStatesList.isEmpty) return const SizedBox();
    return Row(
      children: [
        InkWell(
          onTap: () {
            if (_cubit.currentWeekIndex == null) return;
            animateToIndex(_cubit.currentWeekIndex! - 1);
          },
          child: Icon(
            Icons.chevron_left_rounded,
            size: 24,
            color: (_cubit.currentWeekIndex ?? 0) <= 0
                ? R.color.captionColorGray
                : R.color.greenGradientBottom,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            child: Row(
              children: List.generate(_cubit.weekStatesList.length, (index) {
                return _buildSingleWeek(
                    state: _cubit.weekStatesList[index],
                    isSelected: index == _cubit.currentWeekIndex,
                    onSelect: () {
                      _cubit.onSelectWeek(index);
                    });
              })
                ..add(SizedBox(
                    width: MediaQuery.of(context).size.width - 96 * 2)),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            if (_cubit.currentWeekIndex == null) return;
            animateToIndex(_cubit.currentWeekIndex! + 1);
          },
          child: Icon(
            Icons.chevron_right_rounded,
            size: 24,
            color: (_cubit.currentWeekIndex ?? 0) >=
                    (_cubit.weekStatesList.length - 1)
                ? R.color.captionColorGray
                : R.color.greenGradientBottom,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseWidget({
    required ExerciseMovementResponseData? exerciseItem,
  }) {
    if (exerciseItem?.code == null) return const SizedBox();
    return Container(
      color: R.color.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              height: 87,
              width: 87,
              child: const NetWorkImageWidget(imageUrl: '')),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        exerciseItem!.name ?? '',
                        style: TextStyle(
                          color: R.color.textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${exerciseItem.practiceTime ?? ''} ${R.string.minute.tr()}',
                      style: TextStyle(
                          color: R.color.grey_2,
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Visibility(
                  visible: exerciseItem.exerciseMovementStates !=
                      Const.LESSON_LOCKED,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCustomIconButton(
                          title: R.string.start_exercise.tr(),
                          icon: R.drawable.ic_start_exercise,
                          borderColor: R.color.greenGradientBottom,
                          backgroundColor: R.color.greenGradientBottom,
                          textColor: R.color.white,
                          onTap: () {
                            NavigationUtil.navigatePage(
                              context,
                              ExerciseDetail(
                                exerciseData: exerciseItem,
                              ),
                            );
                          },
                        ),
                        _buildCustomIconButton(
                          title: R.string.show_instruction.tr(),
                          icon: R.drawable.ic_play,
                          borderColor: R.color.greenGradientBottom,
                          backgroundColor: R.color.white,
                          textColor: R.color.greenGradientBottom,
                          onTap: () {
                            NavigationUtil.navigatePage(
                              context,
                              VideoPlayerWidget(
                                videoUrl: exerciseItem.videoUrl ?? '',
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                LessonStatusWidget(
                  learningStatus: exerciseItem.exerciseMovementStates,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayOffWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 53),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Image.asset(R.drawable.img_activity_empty),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                Text(
                  R.string.today_is_day_off.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: R.color.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  R.string.today_is_day_off_description.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: R.color.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCustomIconButton({
    required String title,
    required String icon,
    required Color borderColor,
    required Color backgroundColor,
    required Color textColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: R.color.main_6,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                icon,
                width: 16,
                height: 16,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
              child: Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleWidget() {
    if (_cubit.weekStatesList.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWeekListWidget(),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    7,
                    (index) => Container(
                      alignment: Alignment.bottomCenter,
                      width: 24,
                      child: Text(
                        index == 6 ? 'CN' : 'T${index + 2}',
                        style: TextStyle(
                          color: R.color.grey_1,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(
                    13,
                    (index) {
                      return index.isOdd
                          ? Expanded(
                              child: Container(
                                height: 1,
                                color: index ~/ 2 >= _cubit.mark
                                    ? R.color.grayBorder
                                    : R.color.green,
                              ),
                            )
                          : _buildSingleDay(
                              status: _cubit.getExerciseOfDay(index ~/ 2) ??
                                  CompletionStatus.not_start_yet,
                              isSelected: _cubit.currentDayIndex == index ~/ 2,
                              onTap: () {
                                _cubit.onSelectDay(index ~/ 2);
                              });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleDay(
      {required CompletionStatus status,
      required bool isSelected,
      VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: status.dayStatusIcon(isSelected),
    );
  }

  Widget _buildSingleWeek({
    required WeekStatesResponseData state,
    required bool isSelected,
    VoidCallback? onSelect,
  }) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(left: 6),
        width: 96,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected &&
                  state.completionStatus == CompletionStatus.not_start_yet
              ? R.color.greenbg
              : state.completionStatus.statusBackgroundColor,
          border: isSelected &&
                  state.completionStatus != CompletionStatus.not_start_yet
              ? Border.all(color: state.completionStatus.statusIconColor)
              : null,
          borderRadius: BorderRadius.circular(200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              state.weekTitle ?? '',
              style: TextStyle(
                color: isSelected &&
                        state.completionStatus == CompletionStatus.not_start_yet
                    ? R.color.green
                    : state.completionStatus.statusIconColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (!(isSelected &&
                state.completionStatus == CompletionStatus.not_start_yet))
              state.completionStatus.weekStatusIcon
          ],
        ),
      ),
    );
  }

  Future<void> changeRoadMap() async {
    final newRoadmapId =
        await NavigationUtil.navigatePage(context, const SelectRoadMapPage());
    if (newRoadmapId is String &&
        newRoadmapId.isNotEmpty &&
        newRoadmapId != _cubit.roadmapId) {
      _cubit.roadmapChanged(newRoadmapId);
    }
  }

  @override
  bool get wantKeepAlive => true;
}
