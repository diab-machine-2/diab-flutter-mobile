import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app.dart';
import 'package:medical/src/app_setting/branchio_link_config.dart';
import 'package:medical/src/app_setting/firebase_tracking/activity_list_tracking.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/smart_goal_list_reponse.dart';
import 'package:medical/src/model/response/week_states_response.dart';
import 'package:medical/src/utils/app_log.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/smart_goal_navigation_util.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/expert_comment/expert_comment_page.dart';
import 'package:medical/src/widget/survey_screens/introduce_survey/introduce_survey.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/calendar_navigation_bar.dart';
import 'package:medical/src/widgets/day_in_week_widget.dart';
import 'package:medical/src/widgets/gap_widget.dart';
import 'package:medical/src/widgets/network_image_widget.dart';
import 'package:medical/src/widgets/pdf_viewer_widget.dart';
import 'package:medical/src/widget/BloodPressure/widget/horizontal_selector.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../../model/response/report_model.dart';

import '../../my_plan/models/completion_status.dart';
import '../../my_plan/my_plan.dart';
import '../my_progress/my_progress.dart';
import '../my_progress/widgets/report_list_widget.dart';
import 'activity_tab.dart';
import 'models/schedule_type.dart';
import 'widgets/custom_progress_widget.dart';
import 'widgets/smart_goal_item.dart';
import 'widgets/statistical_popup.dart';
import '../../exercise_tab/exercise_tab/exercise_tab.dart';

class ActivityTabPage extends StatefulWidget {
  const ActivityTabPage({this.extendTabbar = false});
  final bool extendTabbar;

  @override
  _ActivityTabPageState createState() => _ActivityTabPageState();
}

class _ActivityTabPageState extends State<ActivityTabPage>
    with AutomaticKeepAliveClientMixin<ActivityTabPage>, Observer {
  late final ActivityTabCubit _cubit;
  final RefreshController _controller = RefreshController();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollSmartGoalListController = ScrollController();
  bool isVisible = false;
  int _selectedTopTab = 0; // 0: Activities, 1: Knowledge, 2: Exercise

  @override
  void initState() {
    super.initState();
    Observable.instance.addObserver(this);
    final MyPlanCubit _myPlanCubit = BlocProvider.of<MyPlanCubit>(context);
    final AppRepository appRepository = AppRepository();
    _cubit = ActivityTabCubit(appRepository, _myPlanCubit);
    _cubit.initData();
    SmartGoalNavigationUtil.setConfig(SmartGoalConfig(
      screenName: 'activity_tab',
      trackingEnabled: false,
      showGlucoseBottomSheet: false,
      showBloodPressureIntro: true,
      hasInputBloodPressure: false,
      hasInputGlucose: false,
    ));
  }

  @override
  void dispose() {
    Observable.instance.removeObserver(this);
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  void _checkExistZoomId() async {
    String? meetingId = BranchioLinkConfig.instance.meetingId;
    if (meetingId != null) {
      BranchioLinkConfig.instance.removeMeetingId();
      // await _cubit.markCompletedCalendar(calendarId);
      if (isVisible) {
        _cubit.refreshData(isRefresh: true);
      }
    }
  }

  @override
  Future<void> update(Observable observable, String? notifyName,
      Map<dynamic, dynamic>? map) async {
    if (notifyName == 'mark_completed_calendar') {
      _checkExistZoomId();
    }
    if (notifyName == Const.NAVIGATE_TO_ACTIVITY_DETAIL) {
      _checkExistActivityId();
    }
    if (notifyName == 'refresh_activity_tab') {
      Future.delayed(Duration(milliseconds: 1000), () {
        if (isVisible) {
          _cubit.refreshData(isRefresh: true);
        }
      });
    }
    if (notifyName == 'activity_tab_reload') {
      // full reload
      Future.delayed(Duration(milliseconds: 1000), () {
        if (isVisible) {
          _cubit.initData();
        }
      });
    }
    if (notifyName == 'active_change_data' ||
        notifyName == 'glucose_change_data' ||
        notifyName == 'BloodPressure_change_data' ||
        notifyName == 'Weight_change_data' ||
        notifyName == 'Emotion_change_data' ||
        notifyName == 'food_change_data' ||
        notifyName == 'hba1c_change_data' ||
        notifyName == 'goal_calo_changed' ||
        notifyName == 'active_change_data_v2') {
      _controller.requestRefresh();
    }
  }

  void _checkExistActivityId() async {
    final String? activityId = BranchioLinkConfig.instance.activityId;
    if (activityId != null) {
      SmartGoalList smartGoal = SmartGoalList(surveyId: activityId, state: 0);
      await Future.delayed(Duration(milliseconds: 500));
      NavigationUtil.navigatePage(navigatorKey.currentState!.context,
          IntroduceSurveyPage(survey: smartGoal));
      Future.delayed(Duration(seconds: 1), () {
        BranchioLinkConfig.instance.removeActivityId();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider(
      create: (context) => _cubit,
      child: BlocConsumer<ActivityTabCubit, ActivityTabState>(
        listener: (context, state) {
          Console.log('state', state);
          if (state is ActivityTabLoading) {
            BotToast.showLoading();
          } else {
            //    BotToast.closeAllLoading();
            _controller.refreshCompleted();
          }
          if (state is ActivityTabSuccess) {
            _checkExistZoomId();
            _checkExistActivityId();
            //     _scrollSmartGoalListController.animateTo(_scrollSmartGoalListController.position.minScrollExtent, duration: Duration(milliseconds: 200), curve: Curves.ease);
          }
          if (state is ActivityTabFailure) {
            Message.showToastMessage(context, state.error);
          }
          if (state is ActivityTabWeekChanged) {
            _animateToIndex(state.newIndex, refresh: false);
          }
          if (state is ActivityTabDailyGoalCompleted) {
            _showPopupCongratulation(
                icon: R.drawable.img_smart_goal_day_achive,
                description: R.string.congratulation_achive_daily.tr());
          }
        },
        builder: (context, state) {
          return VisibilityDetector(
            key: Key('activity_tab_page'),
            onVisibilityChanged: (info) {
              isVisible = info.visibleFraction > 0;
              print('visibleFraction = ${info.visibleFraction}');
            },
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  color: R.color.backgroundColorNew,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GapH(12),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: HorizontalSelector(
                          initialValue: _selectedTopTab,
                          values: const [0, 1, 2],
                          labels: const ['Hoạt động', 'Kiến thức', 'Vận động'],
                          onSelected: (i) {
                            setState(() => _selectedTopTab = i);
                          },
                        ),
                      ),
                      if (_selectedTopTab == 0) _buildScheduleWidget(),
                    ],
                  ),
                ),
                if (_selectedTopTab == 0)
                  Expanded(
                    child: SmartRefresher(
                      controller: _controller,
                      physics: ClampingScrollPhysics(),
                      onRefresh: () async {
                        await _cubit.refreshData(isRefresh: true);
                      },
                      child: SingleChildScrollView(
                        controller: _scrollSmartGoalListController,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 8, 16,
                              MediaQuery.of(context).padding.bottom + 75),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_cubit.smartGoalDayList.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: R.color.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: R.color.color0xffE5E5E5),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ..._buildSmartGoalDayList(
                                        dailyList: _cubit.smartGoalDayList,
                                      ),
                                    ],
                                  ),
                                ),

                              if (_cubit
                                  .smartGoalNotCompleteInWeekly.isNotEmpty)
                                GapH(8),
                              if (_cubit
                                  .smartGoalNotCompleteInWeekly.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: R.color.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: R.color.color0xffE5E5E5),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ..._buildNotDoneDailyList(
                                        activitiesNotCompleteInWeekly:
                                            _cubit.smartGoalNotCompleteInWeekly,
                                      ),
                                    ],
                                  ),
                                ),

                              if (_selectedTopTab == 0)
                                Container(
                                  alignment: Alignment.center,
                                  margin:
                                      const EdgeInsets.fromLTRB(0, 8, 0, 12),
                                  child: InkWell(
                                    onTap: () async {
                                      ActivityListTracking.clickStatistical();
                                      Observable.instance.notifyObservers([],
                                          notifyName: Const.HIDE_OVERLAY_KEY);
                                      _showSelectActionPopup();
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: R.color.white,
                                        borderRadius: BorderRadius.circular(50),
                                        border: Border.all(
                                            color: R.color.grayBorder),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            R.string.view_report.tr(),
                                            style: TextStyle(
                                              color: R.color.textDark,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 16),
                              // SizedBox(
                              //   width: 195.w,
                              //   child: ButtonWidget(
                              //       title: R.string.create_smart_goal.tr(),
                              //       height: 48.w,
                              //       textSize: 16,
                              //       textColor: R.color.greenGradientBottom,
                              //       borderColor: R.color.greenGradientBottom,
                              //       backgroundColor: R.color.white,
                              //       onPressed: () async {
                              //         await TrackingManager.analytics.logEvent(
                              //           name: 'cta_button_clicked',
                              //           parameters: {
                              //             "screen_name": 'my_schedule',
                              //             'cta_button_name': 'cta_add_target',
                              //           },
                              //         );
                              //         if (DateUtil.isSameDay(
                              //             _cubit.currentDay,
                              //             DateTime.now().millisecondsSinceEpoch ~/
                              //                 1000)) {
                              //           Observable.instance.notifyObservers([],
                              //               notifyName: Const.HIDE_OVERLAY_KEY);
                              //           await NavigationUtil.navigatePage(
                              //               context,
                              //               CreateGoalPage(
                              //                   _cubit.smartGoalDayList));
                              //           //     _cubit.refreshData(isRefresh: true, keepCurrentDay: false);
                              //         } else {
                              //           _showDialogConfirmCreateGoal(
                              //             context,
                              //             'Mục tiêu sẽ hiệu lực từ ngày ${convertToUTC(DateTime.now().millisecondsSinceEpoch ~/ 1000, 'dd/MM/yyyy')}, bạn có muốn tiếp tục?',
                              //             () async {
                              //               Observable.instance.notifyObservers(
                              //                   [],
                              //                   notifyName:
                              //                       Const.HIDE_OVERLAY_KEY);
                              //               await NavigationUtil.navigatePage(
                              //                   context,
                              //                   CreateGoalPage(
                              //                       _cubit.smartGoalDayList));
                              //               //         _cubit.refreshData(isRefresh: true, keepCurrentDay: false);
                              //             },
                              //           );
                              //         }
                              //       }),
                              // ),
                              if (widget.extendTabbar) SizedBox(height: 56.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_selectedTopTab == 1)
                  Expanded(
                    child: SmartRefresher(
                      controller: _controller,
                      physics: ClampingScrollPhysics(),
                      onRefresh: () async {
                        await _cubit.refreshData(isRefresh: true);
                      },
                      child: _buildKnowledgeFromLessons(),
                    ),
                  ),
                if (_selectedTopTab == 2)
                  const Expanded(child: ExerciseTabPage()),
              ],
            ),
          );
        },
      ),
    );
  }

  void _animateToIndex(int index, {bool refresh = true}) {
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
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      newPosition,
      duration: const Duration(milliseconds: 400),
      curve: Curves.ease,
    );
    if (refresh) {
      _cubit.onSelectWeek(index);
    }
  }

  Widget _buildScheduleWidget() {
    if (_cubit.dayStatesList.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _buildWeekListWidget(),
            ),
          ),
          _buildDayListWidget(),
          GapH(8),
          // Calendar Navigation Bar
          CalendarNavigationBar(
            currentDate: _cubit.currentDateTime,
            onPreviousDay: () {
              Observable.instance
                  .notifyObservers([], notifyName: Const.HIDE_OVERLAY_KEY);
              _cubit.onPreviousDay();
            },
            onNextDay: () {
              Observable.instance
                  .notifyObservers([], notifyName: Const.HIDE_OVERLAY_KEY);
              _cubit.onNextDay();
            },
            onTodayPressed: () {
              Observable.instance
                  .notifyObservers([], notifyName: Const.HIDE_OVERLAY_KEY);
              _cubit.onTodayPressed();
            },
            onDatePicked: (DateTime date) {
              Observable.instance
                  .notifyObservers([], notifyName: Const.HIDE_OVERLAY_KEY);
              _cubit.onDatePicked(date);
            },
            minDate: DateTime(2020, 1, 1), // Set appropriate min date
            maxDate: DateTime.now()
                .add(const Duration(days: 365)), // Set appropriate max date
            isTodayDisabled: _cubit.isCurrentDateToday,
            selectedDate: _cubit.selectedDateForCalendar,
            activeDates: _cubit.activeDatesForCalendar,
            canNavigatePrevious: _cubit.canNavigatePrevious,
            canNavigateNext: _cubit.canNavigateNext,
          ),
        ],
      ),
    );
  }

  Widget _buildWeekListWidget() {
    if (_cubit.weekStatesList.isEmpty) return const SizedBox();
    return Row(
      children: [
        InkWell(
          onTap: () {
            Observable.instance
                .notifyObservers([], notifyName: Const.HIDE_OVERLAY_KEY);
            if (_cubit.currentWeekIndex == null) return;
            _animateToIndex(_cubit.currentWeekIndex! - 1);
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
                      ActivityListTracking.selectWeekActivity(
                        objectIndex: index,
                        objectTitle: _cubit.weekStatesList[index]?.weekTitle,
                        completionStatus:
                            _cubit.weekStatesList[index]!.completionStatus,
                      );
                      Observable.instance.notifyObservers([],
                          notifyName: Const.HIDE_OVERLAY_KEY);
                      _animateToIndex(index);
                    });
              })
                ..add(SizedBox(
                    width: MediaQuery.of(context).size.width - 96 * 2)),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            Observable.instance
                .notifyObservers([], notifyName: Const.HIDE_OVERLAY_KEY);
            if (_cubit.currentWeekIndex == null) return;
            _animateToIndex(_cubit.currentWeekIndex! + 1);
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

  Widget _buildDayListWidget() {
    return Row(
      children: [
        if (!_cubit.myPlanCubit.isHasRoadmapUser)
          InkWell(
            onTap: () {
              Observable.instance
                  .notifyObservers([], notifyName: Const.HIDE_OVERLAY_KEY);
              if (_cubit.currentWeekIndex! < -7) return;
              _cubit.onSelectWeek(_cubit.currentWeekIndex! - 1,
                  hideLoadingAfterDone: true);
            },
            child: Icon(
              Icons.chevron_left_rounded,
              size: 24,
              color: _cubit.currentWeekIndex! < -7
                  ? R.color.captionColorGray
                  : R.color.greenGradientBottom,
            ),
          ),
        Expanded(
          child: Container(
            alignment: Alignment.centerRight,
            color: R.color.transparent,
            child: DayInWeekWidget(
              data: _cubit.dayInWeekList,
              mark: _cubit.mark,
              currentDayIndex: _cubit.currentDayIndex,
              showDateTime: false,
              activeDashColor: R.color.accentColor,
              inactiveDashColor: R.color.color0xffE5E5E5,
              onSelectDay: (selectedDayIndex) {
                _cubit.onSelectDay(selectedDayIndex);
              },
            ),
          ),
        ),
        if (!_cubit.myPlanCubit.isHasRoadmapUser)
          InkWell(
            onTap: () {
              Observable.instance
                  .notifyObservers([], notifyName: Const.HIDE_OVERLAY_KEY);
              if (_cubit.currentWeekIndex! >= 4) return;
              _cubit.onSelectWeek(_cubit.currentWeekIndex! + 1,
                  hideLoadingAfterDone: true);
            },
            child: Icon(
              Icons.chevron_right_rounded,
              size: 24,
              color: _cubit.currentWeekIndex! >= 4
                  ? R.color.captionColorGray
                  : R.color.greenGradientBottom,
            ),
          ),
      ],
    );
  }

  Widget _buildSingleWeek({
    required WeekStatesResponseData? state,
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
                  state?.completionStatus == CompletionStatus.not_start_yet
              ? R.color.grey_6
              : state?.completionStatus.statusBackgroundColor,
          border: (isSelected &&
                  state?.completionStatus != null &&
                  state?.completionStatus != CompletionStatus.not_start_yet)
              ? Border.all(color: state!.completionStatus.statusIconColor)
              : (isSelected &&
                      state?.completionStatus != null &&
                      state?.completionStatus == CompletionStatus.not_start_yet)
                  ? Border.all(color: R.color.mainColor)
                  : null,
          borderRadius: BorderRadius.circular(200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              Utils.getNewTitle(state?.weekTitle ?? ''),
              style: TextStyle(
                color: isSelected &&
                        state?.completionStatus ==
                            CompletionStatus.not_start_yet
                    ? R.color.mainColor
                    : state?.completionStatus.statusIconColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (!(isSelected &&
                state?.completionStatus == CompletionStatus.not_start_yet))
              state!.completionStatus.weekStatusIcon
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSmartGoalDayList({
    required List<SmartGoalList?> dailyList,
  }) {
    int index = -1;
    final countDone =
        dailyList.where((element) => element?.progress == 1).length;
    final List<Widget> children = [
      Visibility(
        visible: dailyList.length > 0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                R.string.goal_of_day.tr(),
                style: TextStyle(
                    color: R.color.grey_1,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
            ),
            CustomProgressWidget(
              count: countDone,
              total: dailyList.length,
            ),
          ],
        ),
      ),
      Visibility(
        visible: dailyList.length > 0,
        child: SizedBox(height: 20),
      ),
      ...dailyList.map((smartGoal) {
        final ScheduleType type =
            ScheduleTypeExtend.getTypeFromIndexWithLessonData(smartGoal?.type,
                lessonData: smartGoal?.lessonData);
        index++;
        return SmartGoalItem(
          type: type,
          name: smartGoal?.name ?? '',
          frequency: smartGoal?.description ?? '',
          subject: smartGoal?.lessonData?.lessonModule?.name ?? '',
          appointmentDate: smartGoal?.appointmentDate,
          isDone: smartGoal?.progress == 1,
          state: smartGoal?.state ?? 0,
          onTap: () async {
            calendarActivitySelectDay(
                index, smartGoal?.name, smartGoal?.progress == 1);
            // Temporary: treat selected activity as examination activity for testing purpose.
            // In production, replace `_isExaminationActivity` with the real examination activity check.
            if (_isExaminationActivity(type, smartGoal)) {
              final examinationType = _extractExaminationType(smartGoal);
              await _showExaminationOptionsBottomSheet(
                  examinationType: examinationType);
            } else {
              _onSelectGoal(
                type,
                smartGoal: smartGoal,
              );
            }
          },
          onRemove: () {
            _cubit.deleteSmartGoal(smartGoal?.id);
          },
        );
      }).toList(),
    ];
    return children;
  }

  calendarActivitySelectDay(
    int index,
    String? objectTitle,
    bool isDone,
  ) async {
    await TrackingManager.logEvent(
      name: 'component_clicked',
      parameters: {
        "screen_name": 'my_schedule',
        'component_name': 'calendar_activity_select_day',
        'object_index': index,
        'object_title': objectTitle ?? "",
        'object_status': isDone ? 'done' : 'new',
      },
    );
  }

  List<Widget> _buildSmartGoalWeekList({
    required List<SmartGoalList?> smartGoalList,
  }) {
    int index = -1;
    final countDone =
        smartGoalList.where((element) => element?.progress == 1).length;
    final List<Widget> children = [
      Visibility(
        visible: smartGoalList.length > 0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                R.string.goal_of_week.tr(),
                style: TextStyle(
                    color: R.color.grey_1,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
            ),
            CustomProgressWidget(
              count: countDone,
              total: smartGoalList.length,
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      ...smartGoalList.map((smartGoal) {
        index++;
        final ScheduleType type =
            ScheduleTypeExtend.getTypeFromIndexWithLessonData(smartGoal?.type,
                lessonData: smartGoal?.lessonData);
        return SmartGoalItem(
          type: type,
          name: smartGoal?.name ?? '',
          frequency: smartGoal?.description ?? '',
          subject: smartGoal?.lessonData?.lessonModule?.name ?? '',
          appointmentDate: smartGoal?.appointmentDate,
          isDone: smartGoal?.progress == 1,
          state: smartGoal?.state ?? 0,
          onTap: () async {
            calendarActivitySelectDay(
                index, smartGoal?.name, smartGoal?.progress == 1);
            _onSelectGoal(
              type,
              smartGoal: smartGoal,
            );
          },
          onRemove: () {},
        );
      }).toList(),
    ];
    return children;
  }

  List<Widget> _buildNotDoneDailyList({
    required List<SmartGoalList?> activitiesNotCompleteInWeekly,
  }) {
    final List<SmartGoalList?> notDone = activitiesNotCompleteInWeekly
        .where((e) => (e?.progress ?? 0) != 1)
        .toList();
    if (notDone.isEmpty) return [];
    int index = -1;
    final List<Widget> children = [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              R.string.incomplete_activities.tr(),
              style: TextStyle(
                  color: R.color.grey_1,
                  fontSize: 16,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      ...notDone.map((smartGoal) {
        index++;
        final ScheduleType type =
            ScheduleTypeExtend.getTypeFromIndexWithLessonData(smartGoal?.type,
                lessonData: smartGoal?.lessonData);
        return SmartGoalItem(
          type: type,
          name: smartGoal?.name ?? '',
          frequency: smartGoal?.description ?? '',
          subject: smartGoal?.lessonData?.lessonModule?.name ?? '',
          appointmentDate: smartGoal?.appointmentDate,
          isDone: smartGoal?.progress == 1,
          state: smartGoal?.state ?? 0,
          onTap: () async {
            calendarActivitySelectDay(
                index, smartGoal?.name, smartGoal?.progress == 1);
            _onSelectGoal(
              type,
              smartGoal: smartGoal,
            );
          },
          onRemove: () {
            _cubit.deleteSmartGoal(smartGoal?.id);
          },
        );
      }).toList(),
    ];
    return children;
  }

  Widget _buildKnowledgeFromLessons() {
    final List<SmartGoalList> lessons = _cubit.lessonsWeekly
        .where((e) => e != null)
        .cast<SmartGoalList>()
        .where((e) {
      final t = e.type;
      // Include lessons (type 11) and infographics
      // Exclude quizzes (type 11 where lesson.code contains "quiz")
      if (t == ScheduleType.lesson.typeIndex) {
        // Check if lesson.code contains "quiz" - if yes, it's a quiz, exclude it
        final lessonCode = e.lesson?.code?.toLowerCase() ?? '';
        return !lessonCode.contains('quiz');
      }
      return t == ScheduleType.infographic.typeIndex;
    }).toList();

    if (lessons.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: R.color.gray.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                R.string.no_data.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: R.color.captionColorGray,
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
              ),
            )
          ],
        ),
      );
    }

    final Map<int, List<SmartGoalList>> grouped = {};
    for (final SmartGoalList? item in lessons) {
      final int week = item?.weekInTranServicePackage ?? 0;
      if (grouped[week] == null) grouped[week] = [];
      grouped[week]!.add(item!);
    }
    final List<int> sortedWeeks = grouped.keys.toList()..sort();

    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).padding.bottom + 75),
      child: SingleChildScrollView(
        child: Column(
          children: List.generate(sortedWeeks.length, (index) {
            final int week = sortedWeeks[index];
            final List<SmartGoalList> items = grouped[week] ?? [];
            final int done = items.where((e) => e.progress == 1).length;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: R.color.white,
                border: Border.all(color: R.color.grayBorder),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Tuần ${week <= 0 ? 1 : week}',
                          style: TextStyle(
                              color: R.color.grey_1,
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      CustomProgressWidget(
                        count: done,
                        total: items.length,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...items.map((smartGoal) {
                    final bool isDone = smartGoal.progress == 1;
                    final bool isLocked = (smartGoal.state ?? 0) == 3;
                    final ScheduleType type =
                        ScheduleTypeExtend.getTypeFromIndexWithLessonData(
                            smartGoal.type,
                            lessonData: smartGoal.lessonData);
                    return GestureDetector(
                      onTap: isLocked
                          ? null
                          : () async {
                              _onSelectGoal(type, smartGoal: smartGoal);
                            },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: R.color.color0xffF2F6F9,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                                clipBehavior: Clip.hardEdge,
                                height: 48,
                                width: 48,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8)),
                                child: NetWorkImageWidget(
                                    imageUrl: smartGoal.lesson?.image?.url)),
                            GapW(12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(smartGoal.name ?? '',
                                      style: TextStyle(
                                          color: R.color.textDark,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  Text(
                                      smartGoal.lesson?.lessonModule?.name ??
                                          '',
                                      style: TextStyle(
                                          color: R.color.captionColorGray,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400)),
                                ],
                              ),
                            ),
                            GapW(4),
                            if (isLocked)
                              Icon(Icons.lock_outline,
                                  color: R.color.captionColorGray)
                            else
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: isDone
                                      ? R.color.greenGradientBottom
                                      : R.color.white,
                                  border: isDone
                                      ? null
                                      : Border.all(
                                          color: R.color.grey_2, width: 1.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check_rounded,
                                  color:
                                      isDone ? R.color.white : R.color.grey_2,
                                  size: 20,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  // Future<void> _onSelectGoal(ScheduleType type,
  //     {SmartGoalList? smartGoal}) async {
  //   Observable.instance.notifyObservers([], notifyName: Const.HIDE_OVERLAY_KEY);
  //   switch (type) {
  //     case ScheduleType.blood_sugar:
  //       await Navigator.pushNamed(context, NavigatorName.add_blood_sugar_new,
  //           arguments: {'type': 'input', 'goalId': smartGoal?.id});
  //       _cubit.refreshData(isRefresh: true);
  //       break;
  //     case ScheduleType.blood_pressure:
  //       await Navigator.pushNamed(context, NavigatorName.add_blood_pressure,
  //           arguments: {'type': 'input', 'goalId': smartGoal?.id});
  //       _cubit.refreshData(isRefresh: true);
  //       break;
  //     case ScheduleType.weight:
  //       await Navigator.pushNamed(context, NavigatorName.add_bmi,
  //           arguments: {'type': 'input', 'goalId': smartGoal?.id});
  //       _cubit.refreshData(isRefresh: true);
  //       break;
  //     case ScheduleType.emotion:
  //       await Navigator.pushNamed(context, NavigatorName.add_emo,
  //           arguments: {'type': 'input', 'goalId': smartGoal?.id});
  //       //    _cubit.refreshData(isRefresh: true);
  //       break;
  //     case ScheduleType.food:
  //       await NavigationUtil.navigatePage(
  //         context,
  //         DailyNutritionPage(type: 'input', id: null, goalId: smartGoal?.id),
  //       );
  //       _cubit.refreshData(isRefresh: true);
  //       break;
  //     case ScheduleType.exercise:
  //       await Navigator.pushNamed(context, NavigatorName.add_exercrises,
  //           arguments: {'type': 'input', 'goalId': smartGoal?.id});
  //       _cubit.refreshData(isRefresh: true);
  //       break;
  //     case ScheduleType.exercise_movement:
  //       if (smartGoal?.exerciseData == null) break;
  //       if (smartGoal?.exerciseData?.exerciseMovementStates == null ||
  //           smartGoal?.state == Const.LESSON_LOCKED) {
  //         _showLockedDialog(
  //           title: R.string.exercise_lesson_locked.tr(),
  //           description: R.string.exercise_lesson_locked_warning.tr(),
  //         );
  //         break;
  //       }
  //       await NavigationUtil.navigatePage(
  //           context, ExerciseDetail(exerciseData: smartGoal?.exerciseData));
  //       _cubit.refreshData(isRefresh: true);
  //       Observable.instance
  //           .notifyObservers([], notifyName: "refresh_exercise_tab");
  //       Observable.instance.notifyObservers([], notifyName: "refresh_home");
  //       break;
  //     case ScheduleType.custom:
  //       _showCustomGoalPopup(
  //         smartGoal: smartGoal,
  //       );
  //       break;
  //     case ScheduleType.book_1_1:
  //       _showCoachingPopup(smartGoal);
  //       break;
  //     case ScheduleType.book_1_n:
  //       _showCoachingPopup(smartGoal);
  //       break;
  //     case ScheduleType.survey:
  //       //_showCoachingPopup();
  //       _showSurveyPopup(survey: smartGoal);
  //       break;
  //     case ScheduleType.lesson:
  //     case ScheduleType.infographic:
  //       final LessonSectionListResponseData? lessonDetail =
  //           smartGoal?.lessonData;
  //       if (smartGoal?.state == Const.LESSON_LOCKED) {
  //         // if (lessonDetail?.learningStatus == null || lessonDetail?.learningStatus == Const.LESSON_LOCKED) {
  //         _showLockedDialog(
  //             title: R.string.lesson_locked.tr(),
  //             description: R.string.lesson_locked_warning.tr());
  //         return;
  //       }
  //       await NavigationUtil.navigatePage(
  //           context,
  //           LessonDetailPage(
  //             lessonType: lessonDetail?.type,
  //             lessonId: lessonDetail?.id ?? '',
  //             onComplete: (String, int) {},
  //             smartGoal: smartGoal,
  //           ));
  //       _cubit.refreshData(isRefresh: true);
  //       Observable.instance
  //           .notifyObservers([], notifyName: "refresh_lesson_tab");
  //       Observable.instance.notifyObservers([], notifyName: "refresh_home");
  //       break;
  //     case ScheduleType.io_evaluate:
  //       _showCoachingPopup(smartGoal);
  //       break;
  //     case ScheduleType.update_profile:
  //       await Navigator.pushNamed(context, NavigatorName.profile_info,
  //           arguments: {
  //             'id': smartGoal?.state != 1 ? smartGoal?.id : null,
  //           });
  //       break;
  //     case ScheduleType.output_assessment:
  //       _showCoachingPopup(smartGoal);
  //       break;
  //     case ScheduleType.screening_interview:
  //       await _handleInterviewNavigation(
  //           interviewType: 30, smartGoal: smartGoal);
  //       break;
  //     case ScheduleType.evaluate_interview:
  //       await _handleInterviewNavigation(
  //           interviewType: 31, smartGoal: smartGoal);
  //       break;
  //     case ScheduleType.booking_solo:
  //       await _handleInterviewNavigation(
  //           interviewType: 32, smartGoal: smartGoal);
  //       break;
  //     case ScheduleType.hba1c_recommend:
  //       await Navigator.pushNamed(context, NavigatorName.add_hba1c,
  //           arguments: {'type': 'input', 'goalId': smartGoal?.id});
  //       break;
  //     case ScheduleType.schedule_glucose_recommend:
  //       await Navigator.pushNamed(context, NavigatorName.schedule_glucose,
  //           arguments: {
  //             'smartGoal': smartGoal,
  //           });
  //       break;
  //   }
  // }

  Future<void> _onSelectGoal(ScheduleType type,
      {SmartGoalList? smartGoal}) async {
    await SmartGoalNavigationUtil.onSelectGoal(
      context,
      type,
      smartGoal: smartGoal,
      onRefreshData: () {
        _cubit.refreshData(isRefresh: true);
      },
    );
  }

  bool _isExaminationActivity(ScheduleType type, SmartGoalList? smartGoal) {
    final name = ("Xét nghiệm HbA1C").toLowerCase();
    return name.contains('xét nghiệm') || name.contains('xet nghiem');
  }

  String? _extractExaminationType(SmartGoalList? smartGoal) {
    final name = "Xét nghiệm HbA1C" ?? '';
    if (name.isEmpty) return null;

    // List of valid examination types
    final examinationTypes = [
      'Công thức máu',
      'HbA1C',
      'Bộ gan',
      'Bộ thận',
      'Bộ mỡ',
      'Acid uric',
      'Bộ vi chất',
    ];

    final nameLower = name.toLowerCase();

    // Check if name contains "xét nghiệm" or "xet nghiem"
    if (!nameLower.contains('xét nghiệm') &&
        !nameLower.contains('xet nghiem')) {
      return null;
    }

    // Extract the type by checking which examination type is in the name
    for (final type in examinationTypes) {
      if (nameLower.contains(type.toLowerCase())) {
        return type;
      }
    }

    return null;
  }

  Future<void> _showExaminationOptionsBottomSheet(
      {String? examinationType}) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          decoration: BoxDecoration(
            color: R.color.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chọn cách nhập',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: R.color.color0xff111515,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: R.color.color0xff111515),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildExaminationOptionItem(
                icon: R.drawable.ic_home_doctor_consult,
                title: 'Xét nghiệm tại nhà',
                onTap: () => Navigator.of(context).pop('at_home'),
              ),
              const SizedBox(height: 12),
              _buildExaminationOptionItem(
                icon: R.drawable.ic_booking_clinic,
                title: 'Xét nghiệm tại cơ sở',
                onTap: () => Navigator.of(context).pop('at_clinic'),
              ),
            ],
          ),
        );
      },
    );

    if (result == 'at_home') {
      _startExaminationAtHomeFlow(examinationType: examinationType);
    } else if (result == 'at_clinic') {
      // Currently no special flow for "examination at facility".
      // This can be implemented later if needed.
    }
  }

  Widget _buildExaminationOptionItem({
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: R.color.color0xffF7F8F8,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Image.asset(icon, width: 32, height: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: R.color.color0xff111515,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 16, color: R.color.color0xff111515),
          ],
        ),
      ),
    );
  }

  void _startExaminationAtHomeFlow({String? examinationType}) {
    Navigator.of(context).pushNamed(
      NavigatorName.booking_clinic,
      arguments: {
        'isExamination': true,
        'examinationClinicId': 816,
        'examinationType': examinationType,
      },
    );
  }

  void _showPopup({
    required BuildContext context,
    required Widget child,
    String? buttonTitle,
    VoidCallback? onTap,
    bool isDisableCompleteButton = false,
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
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          child,
                          Visibility(
                            visible: onTap != null,
                            child: SizedBox(height: 16),
                          ),
                          Visibility(
                            visible: onTap != null,
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 16),
                              child: ButtonWidget(
                                backgroundColor: isDisableCompleteButton
                                    ? R.color.white
                                    : R.color.accentColor,
                                title: buttonTitle ?? '',
                                textSize: 14,
                                onPressed:
                                    isDisableCompleteButton ? null : onTap,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                      top: 4,
                      right: 24,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        iconSize: 24,
                        onPressed: () {
                          NavigationUtil.pop(context);
                        },
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _showPopupCongratulation({
    required String icon,
    required String description,
  }) {
    return _showPopup(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(57, 10, 57, 30),
            child: Image.asset(icon),
          ),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: R.color.textDark,
                fontSize: 20,
                fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Future<void> _showSelectActionPopup() async {
    await _cubit.getReports();
    List<ReportModel> reportsFromPreferences =
        await _cubit.getReportsFromPreferences();
    _cubit.hasNewReports =
        reportsFromPreferences.length < _cubit.reports.length;
    await _cubit.saveHasNewReportsFromPreferences(_cubit.hasNewReports);

    final action = await showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.9),
      useSafeArea: true,
      barrierDismissible: true,
      context: context,
      builder: (_) {
        return StatisticalPopup(
          hasRoadmapUser: _cubit.myPlanCubit.isHasRoadmapUser,
          hasNewReports: _cubit.hasNewReports,
        );
      },
    );
    if (action is StatisticalAction) {
      switch (action) {
        case StatisticalAction.my_progress:
          final result = await NavigationUtil.navigatePage(
              context,
              MyProgressPage(
                  reports: _cubit.reports,
                  hasNewReports: _cubit.hasNewReports));
          if (result is int) {
            if (result == 1) {
              _cubit.goToLessonTab();
            } else if (result == 2) {
              _cubit.goToExerciseTab();
            }
          }
          break;
        case StatisticalAction.my_report:
          await _showReportBottomSheet();
          break;
        case StatisticalAction.chatting:
          await NavigationUtil.navigatePage(context, const ExpertCommentPage());
          break;
        default:
      }
    }
  }

  _showReportBottomSheet() async {
    await _cubit.saveHasNewReportsFromPreferences(false);
    _cubit.hasNewReports = false;
    await _cubit.saveReportsFromPreferences(_cubit.reports);

    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(15),
        ),
      ),
      backgroundColor: R.color.white,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return ReportListWidget(
          title: R.string.report.tr(),
          reportList: _cubit.reports,
          onSelected: (url) {
            NavigationUtil.navigatePage(context, PDFViewerWidget(url: url));
          },
        );
      },
    );
  }

  _showDialogConfirmCreateGoal(
      BuildContext context, String title, VoidCallback onContinue) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            contentPadding: EdgeInsets.all(0),
            content: Stack(children: [
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          top: 36.0, bottom: 10, left: 16, right: 16),
                      child: Text(title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 16),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(200),
                                        color: R.color.grayBorder),
                                    child: Center(
                                      child: Text(R.string.back.tr(),
                                          style: TextStyle(
                                              color: R.color.textDark,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600)),
                                    )),
                              ),
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  Navigator.pop(context);
                                  onContinue();
                                },
                                child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: R.color.mainColor,
                                    borderRadius: BorderRadius.circular(200),
                                  ),
                                  child: Center(
                                    child: Text(R.string.tiep_tuc.tr(),
                                        style: TextStyle(
                                            color: R.color.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                    icon: Icon(Icons.close, color: R.color.color0xffBEC0C8),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              )
            ]));
      },
    );
  }
}
