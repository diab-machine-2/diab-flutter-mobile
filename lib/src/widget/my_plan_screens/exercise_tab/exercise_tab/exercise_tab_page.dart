import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/firebase_tracking/motion_list_tracking.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/exercise_movement_response.dart';
import 'package:medical/src/model/response/week_states_response.dart';
import 'package:medical/src/utils/app_log.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/day_in_week_widget.dart';
import 'package:medical/src/widgets/network_image_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../../../utils/utils.dart';
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
    with AutomaticKeepAliveClientMixin<ExerciseTabPage>, Observer {
  late final ExerciseTabCubit _cubit;
  final RefreshController _controller = RefreshController();
  final ScrollController _scrollController = ScrollController();
  final AutoScrollController _exerciseScrollController = AutoScrollController();
  final ScrollController _progressScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Observable.instance.addObserver(this);
    final MyPlanCubit _myPlanCubit = BlocProvider.of<MyPlanCubit>(context);
    final AppRepository appRepository = AppRepository();
    _cubit = ExerciseTabCubit(appRepository, _myPlanCubit);
    _cubit.initData();
    MotionListTracking.firebaseSetup();

    // Scroll synchronization will be handled via NotificationListener in the build method
  }

  @override
  void update(Observable observable, String? notifyName,
      Map<dynamic, dynamic>? map) async {
    if (notifyName == 'refresh_exercise_tab') {
      await _cubit.onRefresh(isRefresh: true);
    }
  }

  @override
  void dispose() {
    Observable.instance.removeObserver(this);
    _progressScrollController.dispose();
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
            if (state is! ExerciseTabWeekChanged) {
              BotToast.closeAllLoading();
            }
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
            _exerciseScrollController.scrollToIndex(state.newIndex,
                preferPosition: AutoScrollPosition.begin);
          }
        },
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: R.color.backgroundColorNew,
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        changeRoadMap();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 9,
                            child: Text(
                              _cubit.roadMapName.isNotEmpty
                                  ? _cubit.roadMapName
                                  : R.string.title_route.tr(),
                              style: TextStyle(
                                color: R.color.hba1c_text_color,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                              softWrap: true,
                              maxLines: null,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              R.string.change.tr(),
                              style: TextStyle(
                                color: R.color.accentColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // _buildScheduleWidget(),
                    // const SizedBox(height: 20),
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
                    child: (_cubit.exerciseMovementResponse?.data?.isEmpty ==
                                null ||
                            _cubit.exerciseMovementResponse?.data?.isEmpty ==
                                true)
                        ? GestureDetector(
                            onTap: () {
                              changeRoadMap();
                            },
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                      padding: EdgeInsets.all(8),
                                      child: Text(
                                        R.string.please_select_roadmap.tr(),
                                        style: TextStyle(
                                            fontSize: 14, color: R.color.black),
                                        textAlign: TextAlign.center,
                                      )),
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
                              ),
                            ),
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Progress tracking bar on the left
                              _buildProgressTrackingBar(),
                              // Exercise list with scroll notification listener
                              Expanded(
                                child: NotificationListener<ScrollNotification>(
                                  onNotification:
                                      (ScrollNotification notification) {
                                    // Sync progress bar scrolling with exercise list
                                    if (notification
                                            is ScrollUpdateNotification &&
                                        _progressScrollController.hasClients) {
                                      final double offset =
                                          notification.metrics.pixels;
                                      if ((_progressScrollController.offset -
                                                  offset)
                                              .abs() >
                                          0.5) {
                                        final maxExtent =
                                            _progressScrollController.position
                                                    .hasContentDimensions
                                                ? _progressScrollController
                                                    .position.maxScrollExtent
                                                : double.infinity;
                                        final clamped =
                                            offset.clamp(0.0, maxExtent);
                                        _progressScrollController
                                            .jumpTo(clamped);
                                      }
                                    }
                                    return false;
                                  },
                                  child: ListView.separated(
                                    controller: _exerciseScrollController,
                                    padding: const EdgeInsets.only(
                                        left: 16, right: 16, top: 0, bottom: 0),
                                    itemCount: _cubit.dataLength + 1,
                                    itemBuilder: (context, index) {
                                      return AutoScrollTag(
                                          key: ValueKey(index),
                                          controller: _exerciseScrollController,
                                          index: index,
                                          child: index < _cubit.dataLength
                                              ? _buildExerciseWidget(
                                                  index: index,
                                                  exerciseItem: _cubit
                                                      .exerciseMovementResponse
                                                      ?.data?[index])
                                              : SizedBox(height: 20.h));
                                    },
                                    separatorBuilder: (context, index) {
                                      return const SizedBox(height: 16);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              // GapH(32),
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
    // Check if scroll controller is attached before animating
    if (!_scrollController.hasClients) {
      if (refresh) {
        _cubit.onSelectWeek(index);
      }
      return;
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
    Console.log("PHUONG _cubit.weekStatesList", _cubit.weekStatesList);
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
                      MotionListTracking.selectWeekWorkout(
                        objectTitle:
                            '${_cubit.weekStatesList[index].weekTitle}',
                        objectIndex: '$index',
                        status: _cubit.weekStatesList[index].completionStatus,
                      );
                      _cubit.onSelectWeek(index);
                    });
              })
                ..add(SizedBox(
                    width: _cubit.weekStatesList.isEmpty
                        ? MediaQuery.of(context).size.width - 96 * 2
                        : 0)),
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
    required int index,
    required ExerciseMovementResponseData? exerciseItem,
  }) {
    final int dayNumber = exerciseItem?.day ?? (index + 1);
    if (exerciseItem?.name == null)
      return _buildDayNoExerciseWidget(dayNumber: dayNumber);
    if (exerciseItem?.name == 'Ngày nghỉ')
      return _buildDayOffWidget(dayNumber: dayNumber);

    final bool isCompleted =
        exerciseItem?.exerciseMovementStates == Const.LESSON_LEARNT;
    final bool isLocked =
        exerciseItem?.exerciseMovementStates == Const.LESSON_LOCKED ||
            exerciseItem?.exerciseMovementStates == Const.LESSON_CAN_NOT_LEARN;

    // Unified height 153: padding 16 + title 24 + spacing 12 + subcard (16 + 70 + 16) + extra space
    const double fixedHeight = 153.0;

    return SizedBox(
      height: fixedHeight,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: R.color.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: R.color.gray_btn),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day title
            Text(
              'Ngày $dayNumber',
              style: TextStyle(
                color: R.color.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            // Activity sub-card
            InkWell(
              onTap: () async {
                late String status = '';
                switch (exerciseItem?.exerciseMovementStates) {
                  case Const.LESSON_LOCKED:
                    status = 'lock';
                    break;
                  case Const.LESSON_NOT_LEARN:
                  case Const.LESSON_LEARNING:
                    status = 'open';
                    break;
                  case Const.LESSON_LEARNT:
                    status = 'complete';
                    break;
                  case Const.LESSON_CAN_NOT_LEARN:
                    status = 'lock';
                    break;
                }
                await TrackingManager.logEvent(
                  name: 'component_clicked',
                  parameters: {
                    "screen_name": 'my_schedule',
                    'component_name': 'list_motion_item',
                    'object_index': index,
                    'object_title': exerciseItem?.name,
                    'object_status': status,
                  },
                );
                MotionListTracking.selectDayWorkout(
                  objectTitle: exerciseItem?.name,
                  objectIndex: index,
                  objectStatus: exerciseItem?.exerciseMovementStates,
                );
                if (exerciseItem?.exerciseMovementStates ==
                    Const.LESSON_CAN_NOT_LEARN) {
                  showUpdateRequirePopup(context: context);
                  return;
                }
                if (exerciseItem?.exerciseMovementStates ==
                    Const.LESSON_LOCKED) {
                  _showLockedDialog();
                  return;
                }
                if (!isLocked) {
                  await NavigationUtil.navigatePage(
                    context,
                    ExerciseDetail(
                      exerciseData: exerciseItem,
                    ),
                  );
                  _controller.requestRefresh();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  color: R.color.color0xffF2F6F9,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // Image thumbnail
                    Container(
                      clipBehavior: Clip.hardEdge,
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: NetWorkImageWidget(
                        imageUrl: exerciseItem?.image?.url ?? '',
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Activity details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exerciseItem?.name ?? '',
                            style: TextStyle(
                              color: exerciseItem?.exerciseMovementStates ==
                                      Const.LESSON_LOCKED
                                  ? R.color.grayCaption
                                  : R.color.textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${exerciseItem?.practiceTime ?? ''} ${R.string.minute.tr()}',
                            style: TextStyle(
                              color: R.color.grey_2,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status icon (checkmark or padlock)
                    if (isCompleted)
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: R.color.greenGradientBottom,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: R.color.white,
                        ),
                      )
                    else if (isLocked)
                      Icon(
                        Icons.lock_outline,
                        size: 20,
                        color: R.color.grayCaption,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTrackingBar() {
    if (_cubit.exerciseMovementResponse?.data == null ||
        _cubit.exerciseMovementResponse!.data!.isEmpty) {
      return const SizedBox.shrink();
    }

    final data = _cubit.exerciseMovementResponse!.data!;

    // Find the index where isToday is true in the original data (mark position)
    // This is similar to DayInWeekWidget's mark - lines before this are thick, after are thin
    int markIndex = -1;
    for (int i = 0; i < data.length; i++) {
      if (data[i] != null && data[i]!.isToday == true) {
        markIndex = i;
        break;
      }
    }

    // Calculate exact item height to match exercise widget (fixed at 153px)
    // Card: padding 16 + title (center at 16 + 9 = 25px) + spacing 12 + subcard (16 + 70 + 16)
    const double itemHeight = 153.0; // Current fixed card height
    const double iconSize = 20.0; // dayStatusIcon is 20x20
    const double separatorHeight = 16.0;

    // Icon should align with "Ngày X" text center
    // Title font size is 18 → text center = 16 + (18 / 2) = 25px
    // Icon top = text center - (iconSize / 2) = 25 - 10 = 15px
    const double iconTopOffset = 15.0; // aligns spot center with title center

    return Container(
      width: 24,
      margin: const EdgeInsets.only(left: 12),
      child: ListView.separated(
        controller: _progressScrollController,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,

        itemCount: _cubit.dataLength + 1, // Match exercise list itemCount
        itemBuilder: (context, index) {
          // Handle the spacer at the end (same as exercise list)
          if (index >= _cubit.dataLength) {
            return SizedBox(height: 20.h);
          }

          final item = data[index];

          // Determine status icon considering today and before/after today for not learned items
          final completionStatus =
              item?.completionStatus ?? CompletionStatus.not_completed;
          final bool isToday = (item?.isToday == true);

          CompletionStatus statusToShow;
          if (isToday) {
            // Today uses the special learning icon via dayStatusIcon(isToday=true)
            statusToShow = CompletionStatus.studying;
          } else if (item?.exerciseMovementStates == Const.LESSON_LOCKED) {
            statusToShow = CompletionStatus.not_start_yet;
          } else {
            // Default mapping based on completionStatus
            statusToShow = completionStatus == CompletionStatus.completed
                ? CompletionStatus.completed
                : CompletionStatus.not_completed;
          }

          // Calculate line height to connect from current icon center to next icon center
          // Current icon center: iconTopOffset + (iconSize / 2) = 15 + 10 = 25px (from top of current item)
          // Next icon center target: ~191px (from top of current item) with itemHeight=145 and separator=16
          // We apply a small visual fudge so the line reliably touches the next spot.
          final double lineStart =
              iconTopOffset + (iconSize / 2); // 25px - current icon center
          // Visual correction so next center effectively lands at ~191px
          const double visualFudge = 5.0;
          final double nextIconCenter = itemHeight +
              separatorHeight +
              iconTopOffset +
              (iconSize / 2) +
              visualFudge; // ~196px - next icon center from top of current item (with fudge)
          final double lineHeight =
              nextIconCenter - lineStart + 1; // ~172px, ensures touching

          return SizedBox(
            height: itemHeight,
            child: Stack(
              clipBehavior: Clip.none, // Allow line to overflow to next item
              alignment: Alignment.topCenter,
              children: [
                // Vertical line segment between items (except for last item)
                // Line connects from center of current icon to center of next icon
                if (index < _cubit.dataLength - 1)
                  Positioned(
                    top: lineStart, // Start from current icon center
                    left:
                        index < markIndex ? 10 : 12, // Center of the 24px width
                    child: Container(
                      width: index < markIndex
                          ? 4
                          : 2, // Thick before mark, thin after (like DayInWeekWidget)
                      height: lineHeight, // Extend to next icon center
                      color: index < markIndex
                          ? R.color.accentColor // Active color before today
                          : R.color
                              .color0xffE5E5E5, // Inactive color after today
                    ),
                  ),
                // Progress marker using dayStatusIcon - aligned with "Ngày X" text
                Positioned(
                  top: iconTopOffset, // Align with "Ngày X" text center
                  child: statusToShow.dayStatusIcon(false, isToday),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) {
          // Match the exercise list separator (always 16px)
          if (index >= _cubit.dataLength) {
            return const SizedBox.shrink();
          }
          return const SizedBox(height: separatorHeight);
        },
      ),
    );
  }

  Widget _buildDayOffWidget({int? dayNumber}) {
    // Unified height and padding to match exercise card
    const double fixedHeight = 153.0;

    return SizedBox(
      height: fixedHeight,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: R.color.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: R.color.gray_btn),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day title
            Text(
              dayNumber != null
                  ? 'Ngày $dayNumber'
                  : R.string.today_is_day_off.tr(),
              style: TextStyle(
                color: R.color.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            // Activity sub-card (not clickable)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                color: R.color.color0xffF2F6F9,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Image thumbnail
                  Container(
                    clipBehavior: Clip.hardEdge,
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset(R.drawable.img_activity_empty),
                  ),
                  const SizedBox(width: 4),
                  // Activity details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          R.string.today_is_day_off.tr(),
                          style: TextStyle(
                            color: R.color.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          R.string.today_is_day_off_description.tr(),
                          style: TextStyle(
                            color: R.color.grey_2,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayNoExerciseWidget({int? dayNumber}) {
    // Unified height and padding to match exercise card
    const double fixedHeight = 153.0;

    return SizedBox(
      height: fixedHeight,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: R.color.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: R.color.gray_btn),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day title
            Text(
              dayNumber != null
                  ? 'Ngày $dayNumber'
                  : R.string.today_is_day_no_exercise.tr(),
              style: TextStyle(
                color: R.color.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            // Activity sub-card (not clickable)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                color: R.color.color0xffF2F6F9,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Image thumbnail
                  Container(
                    clipBehavior: Clip.hardEdge,
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset(R.drawable.img_day_no_exercise),
                  ),
                  const SizedBox(width: 4),
                  // Activity details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          R.string.today_is_day_no_exercise.tr(),
                          style: TextStyle(
                            color: R.color.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          R.string.today_is_day_off_description.tr(),
                          style: TextStyle(
                            color: R.color.grey_2,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
          // _buildWeekListWidget(),
          // const SizedBox(height: 20),
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
          color: isSelected &&
                  state.completionStatus == CompletionStatus.not_start_yet
              ? R.color.grey_6
              : state.completionStatus.statusBackgroundColor,
          border: isSelected &&
                  state.completionStatus != CompletionStatus.not_start_yet
              ? Border.all(color: state.completionStatus.statusIconColor)
              : (isSelected &&
                      state.completionStatus == CompletionStatus.not_start_yet)
                  ? Border.all(color: R.color.mainColor)
                  : null,
          borderRadius: BorderRadius.circular(200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              Utils.getNewTitle(state.weekTitle ?? ''),
              style: TextStyle(
                color: isSelected &&
                        state.completionStatus == CompletionStatus.not_start_yet
                    ? R.color.mainColor
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
    MotionListTracking.clickChangeRoadMap();
    final newRoadmapId =
        await NavigationUtil.navigatePage(context, const SelectRoadMapPage());
    if (newRoadmapId is String &&
        newRoadmapId.isNotEmpty &&
        newRoadmapId != _cubit.roadmapId) {
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50.0, vertical: 30),
                        child: Image.asset(R.drawable.img_upgrade_package),
                      ),
                      Text(
                        R.string.lesson_locked,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: R.color.textDark,
                            fontSize: 20,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Vui lòng nâng cấp tài khoản để tiếp tục học!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: R.color.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
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
