import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/lesson_section_list_response.dart';
import 'package:medical/src/model/response/smart_goal_list_reponse.dart';
import 'package:medical/src/model/response/week_states_response.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/Food/daily_nutrition/daily_nutrition.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/my_booking/my_booking.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/expert_comment/expert_comment_page.dart';
import 'package:medical/src/widget/survey_screens/introduce_survey/introduce_survey.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/day_in_week_widget.dart';
import 'package:medical/src/widgets/network_image_widget.dart';
import 'package:medical/src/widgets/pdf_viewer_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../../model/response/report_model.dart';
import '../../../booking_coach/booking_coach.dart';
import '../../../helper/helper.dart';

import '../../exercise_tab/exercise_detail/exercise_detail_page.dart';
import '../../lesson_tab/lesson_detail/lesson_detail_page.dart';
import '../../my_plan/models/completion_status.dart';
import '../../my_plan/my_plan.dart';
import '../../my_plan/widgets/app_bar_bottom.dart';
import '../create_goal/create_goal.dart';
import '../my_progress/models/report_data.dart';
import '../my_progress/my_progress.dart';
import '../my_progress/widgets/report_list_widget.dart';
import 'activity_tab.dart';
import 'models/schedule_type.dart';
import 'widgets/custom_progress_widget.dart';
import 'widgets/smart_goal_item.dart';
import 'widgets/statistical_popup.dart';

class ActivityTabPage extends StatefulWidget {
  const ActivityTabPage();

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

  @override
  void initState() {
    super.initState();
    Observable.instance.addObserver(this);
    final MyPlanCubit _myPlanCubit = BlocProvider.of<MyPlanCubit>(context);
    final AppRepository appRepository = AppRepository();
    _cubit = ActivityTabCubit(appRepository, _myPlanCubit);
    _cubit.initData();
  }

  @override
  void update(Observable observable, String? notifyName, Map<dynamic, dynamic>? map) {
    if (notifyName == 'refresh_activity_tab') {
      Future.delayed(Duration(milliseconds: 1000), () {
        if (_cubit != null && isVisible) {
          _cubit.refreshData(isRefresh: true);
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
        notifyName == 'goal_calo_changed') {
       _controller.requestRefresh();
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
      child: BlocConsumer<ActivityTabCubit, ActivityTabState>(
        listener: (context, state) {
          if (state is ActivityTabLoading) {
            BotToast.showLoading();
          } else {
        //    BotToast.closeAllLoading();
            _controller.refreshCompleted();
          }
          if (state is ActivityTabSuccess) {
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
                icon: R.drawable.img_smart_goal_day_achive, description: R.string.congratulation_achive_daily.tr());
          }
          if (state is ActivityTabWeeklyGoalCompleted) {
            _showPopupCongratulation(
                icon: R.drawable.img_smart_goal_week_achive, description: R.string.congratulation_achive_weekly.tr());
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
                AppBarBottom(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildScheduleWidget(),
                      Container(
                        alignment: Alignment.centerRight,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () async {
                            Observable.instance.notifyObservers([], notifyName: Const.HIDE_OVERLAY_KEY);
                            _showSelectActionPopup();
                            // _showSurveyPopup();
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                R.string.statistical.tr(),
                                style: TextStyle(
                                  color: R.color.greenGradientBottom,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Image.asset(
                                R.drawable.ic_save,
                                width: 16,
                                height: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SmartRefresher(
                    controller: _controller,
                    onRefresh: () async { 
                      await _cubit.refreshData(isRefresh: true);
                    },
                    child: SingleChildScrollView(
                      controller: _scrollSmartGoalListController,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, 32, 16, MediaQuery.of(context).padding.bottom + 75),
                        child: Column(
                          children: [
                            ..._buildSmartGoalDayList(
                              dailyList: _cubit.smartGoalDayList,
                            ),
                            
                            ..._buildSmartGoalWeekList(smartGoalList: _cubit.smartGoalWeekList),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: 195.w,
                              child: ButtonWidget(
                                  title: R.string.create_smart_goal.tr(),
                                  height: 48.w,
                                  textSize: 16,
                                  textColor: R.color.greenGradientBottom,
                                  borderColor: R.color.greenGradientBottom,
                                  backgroundColor: R.color.white,
                                  onPressed: () async {
                                    if(DateUtil.isSameDay(_cubit.currentDay, DateTime.now().millisecondsSinceEpoch ~/ 1000)){
                                      Observable.instance.notifyObservers([], notifyName: Const.HIDE_OVERLAY_KEY);
                                      await NavigationUtil.navigatePage(context, CreateGoalPage(_cubit.smartGoalDayList));
                                 //     _cubit.refreshData(isRefresh: true, keepCurrentDay: false);
                                    } else {
                                      _showDialogConfirmCreateGoal(context, 
                                      'Mục tiêu sẽ hiệu lực từ ngày ${convertToUTC(DateTime.now().millisecondsSinceEpoch ~/ 1000, 'dd/MM/yyyy')}, bạn có muốn tiếp tục?',
                                       () async {
                                          Observable.instance.notifyObservers([], notifyName: Const.HIDE_OVERLAY_KEY);
                                          await NavigationUtil.navigatePage(context, CreateGoalPage(_cubit.smartGoalDayList));
                                 //         _cubit.refreshData(isRefresh: true, keepCurrentDay: false);
                                       },);
                                    }
                                  }),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
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
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: _cubit.myPlanCubit.isHasRoadmapUser,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _buildWeekListWidget(),
            ),
          ),
          _buildDayListWidget(),
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
            Observable.instance.notifyObservers([], notifyName: Const.HIDE_OVERLAY_KEY);
            if (_cubit.currentWeekIndex == null) return;
            _animateToIndex(_cubit.currentWeekIndex! - 1);
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
                      Observable.instance.notifyObservers([], notifyName: Const.HIDE_OVERLAY_KEY);
                      _animateToIndex(index);
                    });
              })
                ..add(SizedBox(width: MediaQuery.of(context).size.width - 96 * 2)),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            Observable.instance.notifyObservers([], notifyName: Const.HIDE_OVERLAY_KEY);
            if (_cubit.currentWeekIndex == null) return;
            _animateToIndex(_cubit.currentWeekIndex! + 1);
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

  Widget _buildDayListWidget() {
    return Row(
      children: [
        if (!_cubit.myPlanCubit.isHasRoadmapUser)
          InkWell(
            onTap: () {
              Observable.instance.notifyObservers([], notifyName: Const.HIDE_OVERLAY_KEY);
              if (_cubit.currentWeekIndex! < -7) return;
              _cubit.onSelectWeek(_cubit.currentWeekIndex! - 1, hideLoadingAfterDone: true);
            },
            child: Icon(
              Icons.chevron_left_rounded,
              size: 24,
              color: _cubit.currentWeekIndex! < -7 ? R.color.captionColorGray : R.color.greenGradientBottom,
            ),
          ),
        Expanded(
          child: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            color: R.color.transparent,
            child: DayInWeekWidget(
              data: _cubit.dayInWeekList,
              mark: _cubit.mark,
              currentDayIndex: _cubit.currentDayIndex,
              showDateTime: !_cubit.myPlanCubit.isHasRoadmapUser,
              onSelectDay: (selectedDayIndex) {
                _cubit.onSelectDay(selectedDayIndex);
              },
            ),
          ),
        ),
        if (!_cubit.myPlanCubit.isHasRoadmapUser)
          InkWell(
            onTap: () {
              Observable.instance.notifyObservers([], notifyName: Const.HIDE_OVERLAY_KEY);
              if (_cubit.currentWeekIndex! >= 4) return;
              _cubit.onSelectWeek(_cubit.currentWeekIndex! + 1, hideLoadingAfterDone: true);
            },
            child: Icon(
              Icons.chevron_right_rounded,
              size: 24,
              color: _cubit.currentWeekIndex! >= 4 ? R.color.captionColorGray : R.color.greenGradientBottom,
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
          color: isSelected && state?.completionStatus == CompletionStatus.not_start_yet
              ? R.color.grey_6
              : state?.completionStatus.statusBackgroundColor,
          border:
              (isSelected && state?.completionStatus != null && state?.completionStatus != CompletionStatus.not_start_yet)
                  ? Border.all(color: state!.completionStatus.statusIconColor)
                  : (isSelected && state?.completionStatus != null && state?.completionStatus == CompletionStatus.not_start_yet) ? Border.all(color: R.color.mainColor) :null,
          borderRadius: BorderRadius.circular(200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              Utils.getNewTitle(state?.weekTitle ?? ''),
              style: TextStyle(
                color: isSelected && state?.completionStatus == CompletionStatus.not_start_yet
                    ? R.color.mainColor
                    : state?.completionStatus.statusIconColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (!(isSelected && state?.completionStatus == CompletionStatus.not_start_yet))
              state!.completionStatus.weekStatusIcon
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSmartGoalDayList({
    required List<SmartGoalList?> dailyList,
  }) {
    final countDone = dailyList.where((element) => element?.progress == 1).length;
    final List<Widget> children = [
      Visibility(
        visible: dailyList.length > 0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                R.string.goal_of_day.tr(),
                style: TextStyle(color: R.color.grey_1, fontSize: 16, fontWeight: FontWeight.w700),
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
        final ScheduleType type = ScheduleTypeExtend.getTypeFromIndex(smartGoal?.type);
        return SmartGoalItem(
          type: type,
          name: smartGoal?.name ?? '',
          frequency: smartGoal?.description ?? '',
          appointmentDate: smartGoal?.appointmentDate,
          isDone: smartGoal?.progress == 1,
          state: smartGoal?.state ?? 0,
          onTap: () {
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
      Visibility(
        visible: dailyList.length > 0,
        child: SizedBox(height: 32),
      ),
    ];
    return children;
  }

  List<Widget> _buildSmartGoalWeekList({
    required List<SmartGoalList?> smartGoalList,
  }) {
    final countDone = smartGoalList.where((element) => element?.progress == 1).length;
    final List<Widget> children = [
      Visibility(
        visible: smartGoalList.length > 0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                R.string.goal_of_week.tr(),
                style: TextStyle(color: R.color.grey_1, fontSize: 16, fontWeight: FontWeight.w700),
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
        final ScheduleType type = ScheduleTypeExtend.getTypeFromIndex(smartGoal?.type);
        return SmartGoalItem(
          type: type,
          name: smartGoal?.name ?? '',
          frequency: smartGoal?.description ?? '',
          appointmentDate: smartGoal?.appointmentDate,
          isDone: smartGoal?.progress == 1,
          state: smartGoal?.state ?? 0,
          onTap: () {
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

  Future<void> _onSelectGoal(ScheduleType type, {SmartGoalList? smartGoal}) async {
    Observable.instance.notifyObservers([], notifyName: Const.HIDE_OVERLAY_KEY);
    switch (type) {
      case ScheduleType.blood_sugar:
        await Navigator.pushNamed(context, NavigatorName.add_blood_sugar, arguments: {'type': 'input', 'goalId': smartGoal?.id});
        _cubit.refreshData(isRefresh: true);
        break;
      case ScheduleType.blood_pressure:
        await Navigator.pushNamed(context, NavigatorName.add_blood_pressure, arguments: {'type': 'input', 'goalId': smartGoal?.id});
        _cubit.refreshData(isRefresh: true);
        break;
      case ScheduleType.weight:
        await Navigator.pushNamed(context, NavigatorName.add_bmi, arguments: {'type': 'input', 'goalId': smartGoal?.id});
        _cubit.refreshData(isRefresh: true);
        break;
      case ScheduleType.emotion:
        await Navigator.pushNamed(context, NavigatorName.add_emo, arguments: {'type': 'input', 'goalId': smartGoal?.id});
        //    _cubit.refreshData(isRefresh: true);
        break;
      case ScheduleType.food:
        await NavigationUtil.navigatePage(
          context,
          DailyNutritionPage(type: 'input', id: null, goalId: smartGoal?.id),
        );
        _cubit.refreshData(isRefresh: true);
        break;
      case ScheduleType.exercise:
        await Navigator.pushNamed(context, NavigatorName.add_exercrises, arguments: {'type': 'input', 'goalId': smartGoal?.id});
        _cubit.refreshData(isRefresh: true);
        break;
      case ScheduleType.exercise_movement:
        if (smartGoal?.exerciseData == null) break;
        if (smartGoal?.exerciseData?.exerciseMovementStates == null ||
            smartGoal?.state == Const.LESSON_LOCKED) {
          _showLockedDialog(
            title: R.string.exercise_lesson_locked.tr(),
            description: R.string.exercise_lesson_locked_warning.tr(),
          );
          break;
        }
        await NavigationUtil.navigatePage(context, ExerciseDetail(exerciseData: smartGoal?.exerciseData));
        _cubit.refreshData(isRefresh: true);
        Observable.instance.notifyObservers([], notifyName: "refresh_exercise_tab");
        Observable.instance.notifyObservers([], notifyName : "refresh_home");
        break;
      case ScheduleType.custom:
        _showCustomGoalPopup(
          smartGoal: smartGoal,
        );
        break;
      case ScheduleType.book_1_1:
        _showCoachingPopup(smartGoal);
        break;
      case ScheduleType.book_1_n:
        _showCoachingPopup(smartGoal);
        break;
      case ScheduleType.survey:
        //_showCoachingPopup();
        _showSurveyPopup(survey: smartGoal);
        break;
      case ScheduleType.lesson:
        final LessonSectionListResponseData? lessonDetail = smartGoal?.lessonData;
        if(smartGoal?.state == Const.LESSON_LOCKED){
        // if (lessonDetail?.learningStatus == null || lessonDetail?.learningStatus == Const.LESSON_LOCKED) {
          _showLockedDialog(
              title: R.string.lesson_locked.tr(), description: R.string.lesson_locked_warning.tr());
          return;
        }
        await NavigationUtil.navigatePage(
            context, LessonDetailPage(lessonType: lessonDetail?.type, lessonId: lessonDetail?.id ?? ''));
        _cubit.refreshData(isRefresh: true);
        Observable.instance.notifyObservers([], notifyName: "refresh_lesson_tab");
        Observable.instance.notifyObservers([], notifyName : "refresh_home");
        break;
      case ScheduleType.io_evaluate:
        _showCoachingPopup(smartGoal);
        break;
      case ScheduleType.update_profile:
        await Navigator.pushNamed(context, 
          NavigatorName.profile_info, 
          arguments: {
            'id': smartGoal?.state != 1 ? smartGoal?.id : null,
          }
        );
        break;
      case ScheduleType.output_assessment:
        _showCoachingPopup(smartGoal);
        break;
    }
  }

  void _showPopup({
    required BuildContext context,
    required Widget child,
    String? buttonTitle,
    VoidCallback? onTap,
    bool isDisableCompleteButton = false,
    bool isShowCompleteButton = true,
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
                                  backgroundColor: isDisableCompleteButton ? R.color.white : R.color.accentColor,
                                  title: buttonTitle ?? '',
                                  textSize: 14,
                                  onPressed: isDisableCompleteButton ? null : onTap,
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

  _showCustomGoalPopup({SmartGoalList? smartGoal}) {
    String description = '';
    if (smartGoal?.executeType == 0) {
      description = 'Thời gian: ${smartGoal?.executeDayTimes} phút';
    } else if (smartGoal?.executeType == 1) {
      description = 'Số lần: ${smartGoal?.executeDayTimes} lần';
    }
    return _showPopup(
      context: context,
      buttonTitle: R.string.complete_lesson.tr(),
      isDisableCompleteButton: DateUtil.isAfter(smartGoal?.appointmentDate, AppSettings.currentDateTime) ?? false,
      onTap: smartGoal?.isCompleted == true
          ? null
          : () {
              _cubit.completeSmartGoal(smartGoal?.id, smartGoal?.executeDayTimes, smartGoal?.type, smartGoal?.appointmentDate);
              NavigationUtil.pop(context);
            },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 57, vertical: 10),
            child: Image.asset(R.drawable.img_custom_goal),
          ),
          Text(
            smartGoal?.name ?? '',
            style: TextStyle(color: R.color.textDark, fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(color: R.color.textDark, fontSize: 14, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  _showCoachingPopup(SmartGoalList? smartGoal) {
    if(smartGoal?.calendar == null) return;
    return _showPopup(
      context: context,
      buttonTitle: R.string.join.tr(),
      isDisableCompleteButton: !DateUtil.isSameDay(DateTime.now().millisecondsSinceEpoch ~/ 1000, smartGoal?.appointmentDate),
      onTap: () async {
        await _cubit.markCompletedCalendar(smartGoal?.calendarId);
        Navigator.pop(context);

        if(smartGoal?.calendar?.meetingLink != null) {
          await canLaunch(smartGoal!.calendar!.meetingLink!)
            ? await launch(smartGoal.calendar!.meetingLink!, forceSafariVC: false, forceWebView: false)
            : throw 'Could not launch ${smartGoal.calendar!.meetingLink!}';
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${getWeekDay(smartGoal?.appointmentDate ?? 0)}, ${convertToUTC(smartGoal?.appointmentDate ?? 0, "dd/MM/yyyy")}",
            style: TextStyle(color: R.color.main_1, fontSize: 20, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4),
          if((smartGoal?.description != null && smartGoal!.description!.isNotEmpty))
            Text(
              smartGoal.description ?? "",
              style: TextStyle(color: R.color.main_1, fontSize: 20, fontWeight: FontWeight.w700),
            ),
          if(smartGoal?.description != null && smartGoal!.description!.isNotEmpty)
            const SizedBox(height: 12),
          if((smartGoal?.calendar?.goal != null && smartGoal!.calendar!.goal!.isNotEmpty))
            Text(
              smartGoal.calendar?.goal ?? "",
              style: TextStyle(color: R.color.textDark, fontSize: 16, fontWeight: FontWeight.w400),
            ),
          if((smartGoal?.calendar?.goal != null && smartGoal!.calendar!.goal!.isNotEmpty))
            const SizedBox(height: 16),
          if(smartGoal?.calendar?.performer != null)
            Row(
              children: [
                NetWorkImageWidget(imageUrl: smartGoal!.calendar!.performer!.avatar?.url ?? "", width: 44, height: 44),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Coach',
                      style: TextStyle(color: R.color.textDark, fontSize: 14, fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      smartGoal.calendar!.performer!.fullName ?? "",
                      style: TextStyle(color: R.color.main_1, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ],
                )
              ],
            ),
        ],
      ),
    );
  }

  _showSurveyPopup({SmartGoalList? survey}) {
    NavigationUtil.navigatePage(context, IntroduceSurveyPage(survey: survey));
    // return _showPopup(
    //   context: context,
    //   buttonTitle: R.string.start_survey.tr(),
    //   onTap: () {
    //     NavigationUtil.pop(context);
    //     NavigationUtil.navigatePage(context, IntroduceSurveyPage(survey: survey));
    //   },
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.center,
    //     children: [
    //       Padding(
    //         padding: const EdgeInsets.symmetric(horizontal: 57, vertical: 10),
    //         child: Image.asset(R.drawable.img_survey_4),
    //       ),
    //       Text(
    //         'Khảo sát',
    //         style: TextStyle(color: R.color.textDark, fontSize: 20, fontWeight: FontWeight.w700),
    //       ),
    //       const SizedBox(height: 6),
    //       Text(
    //         'Tìm hiểu về thói quen sinh hoạt',
    //         style: TextStyle(color: R.color.textDark, fontSize: 14, fontWeight: FontWeight.w400),
    //       ),
    //     ],
    //   ),
    // );
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
            style: TextStyle(color: R.color.textDark, fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Future<void> _showSelectActionPopup() async {
    await _cubit.getReports();
    List<ReportModel> reportsFromPreferences = await _cubit.getReportsFromPreferences();
    _cubit.hasNewReports = reportsFromPreferences.length < _cubit.reports.length;
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
          final result = await NavigationUtil.navigatePage(context, MyProgressPage(reports: _cubit.reports, hasNewReports: _cubit.hasNewReports));
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
          final result = await NavigationUtil.navigatePage(context, const ExpertCommentPage());
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

  void _showLockedDialog({required String title, required String description}) {
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
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
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
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: R.color.textDark,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: R.style.normalTextStyle,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
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

  _showDialogConfirmCreateGoal(BuildContext context, String title, VoidCallback onContinue) {
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
                      padding: EdgeInsets.only(top: 36.0, bottom: 10, left: 16, right: 16),
                      child: Text(title,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: R.color.textDark, fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 16),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                                height: 40,
                                decoration:
                                    BoxDecoration(borderRadius: BorderRadius.circular(200), color: R.color.grayBorder),
                                child: Center(
                                  child: Text(R.string.back.tr(),
                                      style: TextStyle(
                                          color: R.color.textDark, fontSize: 16, fontWeight: FontWeight.w600)),
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
                                    style: TextStyle(color: R.color.white, fontSize: 16, fontWeight: FontWeight.w600)),
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

  @override
  bool get wantKeepAlive => true;
}
