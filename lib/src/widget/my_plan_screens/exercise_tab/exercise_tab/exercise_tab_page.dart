import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/exercise_movement_response.dart';
import 'package:medical/src/model/response/week_states_response.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/day_in_week_widget.dart';
import 'package:medical/src/widgets/lesson_status_widget.dart';
import 'package:medical/src/widgets/network_image_widget.dart';
import 'package:medical/src/widgets/video_player_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

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

class _ExerciseTabPageState extends State<ExerciseTabPage> with AutomaticKeepAliveClientMixin<ExerciseTabPage>, Observer {
  late final ExerciseTabCubit _cubit;
  final RefreshController _controller = RefreshController();
  final ScrollController _scrollController = ScrollController();
  final AutoScrollController _exerciseScrollController = AutoScrollController();

  @override
  void initState() {
    super.initState();
    Observable.instance.addObserver(this);
    final MyPlanCubit _myPlanCubit = BlocProvider.of<MyPlanCubit>(context);
    final AppRepository appRepository = AppRepository();
    _cubit = ExerciseTabCubit(appRepository, _myPlanCubit);
    _cubit.initData();
  }

  @override
  void update(Observable observable, String? notifyName, Map<dynamic, dynamic>? map) async {
    if (notifyName == 'refresh_exercise_tab') {
      await _cubit.onRefresh(isRefresh: true);
    }
  }

  @override
  void dispose() {
    Observable.instance.removeObserver(this);
    super.dispose();
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
          if (state is ExerciseTabScrollToLesson) {
            _exerciseScrollController.scrollToIndex(state.newIndex, preferPosition: AutoScrollPosition.begin);
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
                    onRefresh: () async {
                       await _cubit.onRefresh(isRefresh: true);
                    },
                    child: (_cubit.exerciseMovementResponse?.data?.isEmpty == null || _cubit.exerciseMovementResponse?.data?.isEmpty == true)
                        ? GestureDetector(
                          onTap: () {
                            changeRoadMap();
                          },
                          child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(padding: EdgeInsets.all(8), child: Text(R.string.please_select_roadmap.tr(), style: TextStyle(fontSize: 14, color: R.color.black), textAlign: TextAlign.center,)),
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          R.string.select_road_map.tr(),
                                          style: TextStyle(
                                            color: R.color.greenGradientBottom,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                            ),),
                        )
                        : ListView.separated(
                            controller: _exerciseScrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                            itemCount: _cubit.isHasRoadmapUser ? 1 : _cubit.dataLength + 1,
                            itemBuilder: (context, index) {
                              return AutoScrollTag(
                                  key: ValueKey(index),
                                  controller: _exerciseScrollController,
                                  index: index,
                                  child: index < _cubit.dataLength
                                      ? _buildExerciseWidget(
                                          exerciseItem: _cubit.isHasRoadmapUser
                                              ? _cubit.currentExercise
                                              : _cubit.exerciseMovementResponse?.data?[index])
                                      : SizedBox(height: 20.h));
                            },
                            separatorBuilder: (context, index) {
                              return (_cubit.exerciseMovementResponse?.data?[index]?.isBlank == true) ? Container() : Container(
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
            color: (_cubit.currentWeekIndex ?? 0) <= 0 ? R.color.captionColorGray : R.color.greenGradientBottom,
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
                ..add(SizedBox(width: _cubit.weekStatesList.isEmpty ? MediaQuery.of(context).size.width - 96 * 2 : 0)),
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
            color: (_cubit.currentWeekIndex ?? 0) >= (_cubit.weekStatesList.length - 1)
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
    if (exerciseItem?.name == null) return _buildDayNoExerciseWidget();
    if (exerciseItem?.name == 'Ngày nghỉ') return _buildDayOffWidget();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      color: R.color.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              clipBehavior: Clip.hardEdge,
              height: 87,
              width: 87,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: NetWorkImageWidget(imageUrl: exerciseItem?.image?.url ?? '')),
          const SizedBox(width: 14),
          Expanded(
            child: InkWell(
              onTap: () {
                if (exerciseItem?.exerciseMovementStates == Const.LESSON_CAN_NOT_LEARN) {
                  showUpdateRequirePopup(context: context);
                  return;
                }
                if (exerciseItem?.exerciseMovementStates == Const.LESSON_LOCKED) {
                  _showLockedDialog();
                  return;
                }
              },
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
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${exerciseItem.practiceTime ?? ''} ${R.string.minute.tr()}',
                        style: TextStyle(color: R.color.grey_2, fontSize: 12, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Visibility(
                    visible: exerciseItem.exerciseMovementStates != Const.LESSON_LOCKED &&
                        exerciseItem.exerciseMovementStates != Const.LESSON_CAN_NOT_LEARN,
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
                            onTap: () async {
                              await NavigationUtil.navigatePage(
                                context,
                                ExerciseDetail(
                                  exerciseData: exerciseItem,
                                ),
                              );
                              _controller.requestRefresh();
                           //   _cubit.onRefresh(isRefresh: true, keepSelectedDayIndex: true);
                            },
                          ),
                          // _buildCustomIconButton(
                          //   title: R.string.show_instruction.tr(),
                          //   icon: R.drawable.ic_play,
                          //   borderColor: R.color.greenGradientBottom,
                          //   backgroundColor: R.color.white,
                          //   textColor: R.color.greenGradientBottom,
                          //   onTap: () {
                          //     NavigationUtil.navigatePage(
                          //       context,
                          //       VideoPlayerWidget(
                          //         videoUrl: exerciseItem.videoUrl ?? '',
                          //       ),
                          //     );
                          //   },
                          // ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildDayOffWidget() {
    if (!_cubit.isHasRoadmapUser) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Image.asset(R.drawable.img_activity_empty),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                Text(
                  R.string.today_is_day_off.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: R.color.textDark, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  R.string.today_is_day_off_description.tr(),
                  textAlign: TextAlign.center,
                  style: R.style.normalTextStyle,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDayNoExerciseWidget() {
    if (!_cubit.isHasRoadmapUser) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Image.asset(R.drawable.img_day_no_exercise),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Text(
                  R.string.today_is_day_no_exercise.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: R.color.textDark, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  R.string.today_is_day_off_description.tr(),
                  textAlign: TextAlign.center,
                  style: R.style.normalTextStyle,
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
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DayInWeekWidget(
              data: _cubit.dayInWeekList,
              mark: _cubit.mark,
              currentDayIndex: _cubit.currentDayIndex,
              onSelectDay: (selectedDayIndex) {
                _cubit.onSelectDay(selectedDayIndex);
              },
            ),
          ),
        ],
      ),
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
          color: isSelected && state.completionStatus == CompletionStatus.not_start_yet
              ? R.color.grey_6
              : state.completionStatus.statusBackgroundColor,
          border: isSelected && state.completionStatus != CompletionStatus.not_start_yet
              ? Border.all(color: state.completionStatus.statusIconColor)
              : (isSelected && state.completionStatus == CompletionStatus.not_start_yet) ? Border.all(color: R.color.mainColor) :null,
          borderRadius: BorderRadius.circular(200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              state.weekTitle ?? '',
              style: TextStyle(
                color: isSelected && state.completionStatus == CompletionStatus.not_start_yet
                    ? R.color.mainColor
                    : state.completionStatus.statusIconColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (!(isSelected && state.completionStatus == CompletionStatus.not_start_yet))
              state.completionStatus.weekStatusIcon
          ],
        ),
      ),
    );
  }

  Future<void> changeRoadMap() async {
    final newRoadmapId = await NavigationUtil.navigatePage(context, const SelectRoadMapPage());
    if (newRoadmapId is String && newRoadmapId.isNotEmpty && newRoadmapId != _cubit.roadmapId) {
      await _cubit.roadmapChanged(newRoadmapId);
    }
  }

  void _showLockedDialog() {
    showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
      barrierDismissible: true,
      context: context,
      builder: (_) => Scaffold(
        backgroundColor: R.color.transparent,
        body: Center(
          child: GestureDetector(
            child: Container(
              width: 344,
              padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 24.h),
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
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(84.w, 0, 84.w, 20),
                    child: Image.asset(
                      R.drawable.img_lesson_locked,
                    ),
                  ),
                  Text(
                    R.string.exercise_lesson_locked.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: R.color.textDark,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    R.string.exercise_lesson_locked_warning.tr(),
                    textAlign: TextAlign.center,
                    style: R.style.normalTextStyle,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: ButtonWidget(
                      height: 43,
                      title: R.string.agree.tr(),
                      onPressed: () {
                        NavigationUtil.pop(context);
                      },
                      textSize: 14,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showUpdateRequirePopup({
    required BuildContext context,
  }) {
    showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
      context: context,
      barrierDismissible: true,
      builder: (_) => GestureDetector(
        onTap: () {
          NavigationUtil.pop(context);
        },
        child: Scaffold(
          backgroundColor: R.color.transparent,
          body: Center(
            child: GestureDetector(
              onTap: () {},
              child: Container(
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 30),
                        child: Image.asset(R.drawable.img_upgrade_package),
                      ),
                      Text(
                        'Bài học chưa mở khoá!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: R.color.textDark, fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Vui lòng nâng cấp tài khoản để tiếp tục học!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: R.color.textDark, fontSize: 16, fontWeight: FontWeight.w400),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: ButtonWidget(
                          height: 43,
                          title: R.string.agree.tr(),
                          onPressed: () {
                            NavigationUtil.pop(context);
                          },
                          textSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
