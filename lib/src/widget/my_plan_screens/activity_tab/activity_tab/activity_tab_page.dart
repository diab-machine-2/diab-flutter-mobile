import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/smart_goal_list_reponse.dart';
import 'package:medical/src/model/response/smart_goal_statistic_response.dart';
import 'package:medical/src/model/response/week_smart_goal_response.dart';
import 'package:medical/src/model/response/week_states_response.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Food/daily_nutrition/daily_nutrition.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/survey_screens/introduce_survey/introduce_survey.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/circle_progress_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../my_plan/models/completion_status.dart';
import '../../my_plan/my_plan.dart';
import '../../my_plan/widgets/app_bar_bottom.dart';
import '../create_goal/create_goal.dart';
import '../my_progress/my_progress.dart';
import 'activity_tab.dart';
import 'models/goal_filter_type.dart';
import 'models/schedule_type.dart';
import 'widgets/custom_progress_bar_widget.dart';

class ActivityTabPage extends StatefulWidget {
  const ActivityTabPage();

  @override
  _ActivityTabPageState createState() => _ActivityTabPageState();
}

class _ActivityTabPageState extends State<ActivityTabPage>
    with AutomaticKeepAliveClientMixin<ActivityTabPage> {
  late final ActivityTabCubit _cubit;
  final RefreshController _controller = RefreshController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final MyPlanCubit _myPlanCubit = BlocProvider.of<MyPlanCubit>(context);
    final AppRepository appRepository = AppRepository();
    _cubit = ActivityTabCubit(appRepository, _myPlanCubit);
    _cubit.initData();
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
            BotToast.closeAllLoading();
            _controller.refreshCompleted();
          }
          if (state is ActivityTabFailure) {
            Message.showToastMessage(context, state.error);
          }
          if (state is GoalTypeChanged) {}
          if (state is ActivityTabWeekChanged) {
            animateToIndex(state.newIndex, refresh: false);
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              Column(
                children: [
                  AppBarBottom(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildScheduleWidget(),
                        Row(
                          children: [
                            ...List.generate(
                              _cubit.goalTypeList.length,
                              (index) {
                                return _buildGoalTypeSelect(
                                  title: _cubit.goalTypeList[index].title,
                                  isActive:
                                      _cubit.currentGoalTypeIndex == index,
                                  onTap: () {
                                    _cubit.changeGoalType(index);
                                  },
                                );
                              },
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: () async {
                                final result =
                                    await NavigationUtil.navigatePage(
                                        context, const MyProgressPage());
                                if (result is int) {
                                  if (result == 1) {
                                    _cubit.goToLessonTab();
                                  } else if (result == 2) {
                                    _cubit.goToExerciseTab();
                                  }
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Image.asset(
                                  R.drawable.ic_activity_process,
                                  width: 20,
                                  height: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SmartRefresher(
                      controller: _controller,
                      onRefresh: () => _cubit.refreshData(isRefresh: true),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
                          child: Column(
                            children:
                                _cubit.currentGoalType == GoalFilterType.day
                                    ? _cubit.smartGoalList
                                        .map((smartGoal) =>
                                            _buildSingleGoal(data: smartGoal))
                                        .toList()
                                    : _cubit.weekSmartGoalList
                                        .map((weekSmartGoal) =>
                                            _buildSingleWeekGoal(
                                                data: weekSmartGoal))
                                        .toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom + 16),
                    child: const CustomProgressBarWidget(),
                  ),
                ],
              ),
              Positioned(
                bottom: 38 + MediaQuery.of(context).padding.bottom,
                right: 24,
                child: InkWell(
                  onTap: () async {
                    await NavigationUtil.navigatePage(
                        context, const CreateGoalPage());
                    _cubit.refreshData();
                  },
                  child: Image.asset(
                    R.drawable.ic_button_plus_home,
                    width: 60,
                    height: 60,
                  ),
                ),
              )
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
            visible: _cubit.myPlanCubit.isPremiumUser,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _buildWeekListWidget(),
            ),
          ),
          GestureDetector(
            onHorizontalDragEnd: _cubit.weekStatesList.isNotEmpty
                ? null
                : (DragEndDetails details) {
                    if (details.primaryVelocity! > 0) {
                      _cubit.onSelectWeek(_cubit.currentWeekIndex! - 1,
                          hideLoadingAfterDone: true);
                    } else if (details.primaryVelocity! < 0) {
                      _cubit.onSelectWeek(_cubit.currentWeekIndex! + 1,
                          hideLoadingAfterDone: true);
                    }
                  },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: R.color.transparent,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      7,
                      (index) {
                        final DayStatesResponseData? dayData =
                            _cubit.dayStatesList[index];
                        final DateTime today =
                            DateTime.fromMillisecondsSinceEpoch(
                                (dayData?.day ?? 0) * 1000);
                        final String dayTitle = '${today.day}/${today.month}';
                        return Container(
                          alignment: Alignment.bottomCenter,
                          width: 30,
                          child: Column(
                            children: [
                              Text(
                                index == 6 ? 'CN' : 'T${index + 2}',
                                style: TextStyle(
                                  color: R.color.grey_1,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Visibility(
                                visible: _cubit.weekStatesList.isEmpty,
                                child: Text(
                                  dayTitle,
                                  style: TextStyle(
                                    color: R.color.grey_1,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3.5),
                    child: Row(
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
                                  status: _cubit.dayStatesList[index ~/ 2]
                                          ?.completionStatus ??
                                      CompletionStatus.not_start_yet,
                                  isSelected:
                                      _cubit.currentDayIndex == index ~/ 2,
                                  onTap: () {
                                    _cubit.onSelectDay(index ~/ 2);
                                  });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                      animateToIndex(index);
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
              ? R.color.greenbg
              : state?.completionStatus.statusBackgroundColor,
          border: isSelected &&
                  state?.completionStatus != null &&
                  state?.completionStatus != CompletionStatus.not_start_yet
              ? Border.all(color: state!.completionStatus.statusIconColor)
              : null,
          borderRadius: BorderRadius.circular(200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              state?.weekTitle ?? '',
              style: TextStyle(
                color: isSelected &&
                        state?.completionStatus ==
                            CompletionStatus.not_start_yet
                    ? R.color.green
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

  Widget _buildGoalTypeSelect({
    required String title,
    required bool isActive,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isActive
                  ? R.color.greenGradientBottom
                  : R.color.captionColorGray,
              fontSize: 16,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          Container(
            width: 130,
            height: 3,
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              color: isActive ? R.color.mainColor : R.color.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleGoal({
    required SmartGoalListReponseData? data,
  }) {
    final type = ScheduleTypeExtend.getTypeFromIndex(data?.type);
    final String frequency = getSmartGoalDescription(type, data: data);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: InkWell(
        onTap: () {
          onSelectGoal(type, smartGoal: data);
        },
        child: Row(
          children: [
            CircleProgressWidget(
              percent: (data?.progress ?? 0) * 100,
              icon: type.icon,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type == ScheduleType.custom
                          ? data?.name ?? ''
                          : type.title,
                      style: TextStyle(
                        color: R.color.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (frequency.isNotEmpty) const SizedBox(height: 4),
                    if (frequency.isNotEmpty)
                      Text(
                        frequency,
                        style: TextStyle(
                          color: R.color.grey_1,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                onEditGoal(type, data: data);
              },
              child: Visibility(
                visible: type.editable,
                child: Image.asset(
                  R.drawable.ic_edit,
                  width: 20,
                  height: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleWeekGoal({
    required WeekSmartGoalData? data,
  }) {
    final type = ScheduleTypeExtend.getTypeFromIndex(data?.type);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: InkWell(
        onTap: () {},
        child: Row(
          children: [
            CircleProgressWidget(
              percent: (data?.progress ?? 0) * 100,
              icon: type.icon,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type == ScheduleType.custom
                          ? data?.name ?? ''
                          : type.title,
                      style: TextStyle(
                        color: R.color.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (data?.description?.isNotEmpty == true)
                      const SizedBox(height: 4),
                    if (data?.description?.isNotEmpty == true)
                      Text(
                        data?.description ?? '',
                        style: TextStyle(
                          color: R.color.grey_1,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                if (type == ScheduleType.exercise) {
                  onEditGoal(type,
                      data: SmartGoalListReponseData(
                          type: ScheduleType.exercise.typeIndex));
                }
              },
              child: Visibility(
                visible: type.editable,
                child: Image.asset(
                  R.drawable.ic_edit,
                  width: 20,
                  height: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onSelectGoal(ScheduleType type,
      {SmartGoalListReponseData? smartGoal}) async {
    switch (type) {
      case ScheduleType.blood_sugar:
        await Navigator.pushNamed(context, NavigatorName.add_blood_sugar,
            arguments: {'type': 'input'});
        _cubit.refreshData();
        break;
      case ScheduleType.blood_pressure:
        await Navigator.pushNamed(context, NavigatorName.add_blood_pressure,
            arguments: {'type': 'input'});
        _cubit.refreshData();
        break;
      case ScheduleType.weight:
        await Navigator.pushNamed(context, NavigatorName.add_bmi,
            arguments: {'type': 'input'});
        _cubit.refreshData();
        break;
      case ScheduleType.emotion:
        await Navigator.pushNamed(context, NavigatorName.add_emo,
            arguments: {'type': 'input'});
        _cubit.refreshData();
        break;
      case ScheduleType.food:
        await NavigationUtil.navigatePage(
          context,
          const DailyNutritionPage(type: 'input', id: null),
        );
        _cubit.refreshData();
        break;
      case ScheduleType.exercise:
        await Navigator.pushNamed(context, NavigatorName.add_exercrises,
            arguments: {'type': 'input'});
        _cubit.refreshData();
        break;
      case ScheduleType.hba1c:
        await Navigator.pushNamed(context, NavigatorName.add_hba1c,
            arguments: {'type': 'input'});
        _cubit.refreshData();
        break;
      case ScheduleType.exercise_movement:
        _cubit.goToExerciseTab();
        break;
      case ScheduleType.custom:
        showCustomGoalPopup(
          smartGoal: smartGoal,
        );
        break;
      case ScheduleType.coaching:
        showCoachingPopup();
        break;
      case ScheduleType.group:
        break;
      case ScheduleType.survey:
        showSurveyPopup();
        break;
      case ScheduleType.lesson:
        break;
    }
  }

  Future<void> onEditGoal(ScheduleType type,
      {SmartGoalListReponseData? data}) async {
    switch (type) {
      case ScheduleType.blood_sugar:
        await Navigator.pushNamed(context, NavigatorName.schedule_glucose);
        _cubit.refreshData();
        break;
      case ScheduleType.blood_pressure:
        editSmartGoal(data);
        break;
      case ScheduleType.weight:
        editSmartGoal(data);
        break;
      case ScheduleType.emotion:
        editSmartGoal(data);
        break;
      case ScheduleType.food:
        editSmartGoal(data);
        break;
      case ScheduleType.exercise:
        editSmartGoal(data);
        break;
      case ScheduleType.hba1c:
        editSmartGoal(data);
        break;
      case ScheduleType.exercise_movement:
        break;
      case ScheduleType.custom:
        editSmartGoal(data);
        break;
      case ScheduleType.coaching:
        break;
      case ScheduleType.group:
        break;
      case ScheduleType.survey:
        break;
      case ScheduleType.lesson:
        break;
    }
  }

  String getSmartGoalDescription(ScheduleType type,
      {SmartGoalListReponseData? data}) {
    switch (type) {
      case ScheduleType.blood_sugar:
        return '${data?.executeDayTimes ?? 0} lần/ngày';
      case ScheduleType.blood_pressure:
        return '${data?.executeDayTimes ?? 0} lần/ngày';
      case ScheduleType.weight:
        return '${data?.executeDayTimes ?? 0} lần/ngày';
      case ScheduleType.emotion:
        return '${data?.executeDayTimes ?? 0} lần/ngày';
      case ScheduleType.food:
        return '${data?.executeDayTimes ?? 0} lần/ngày';
      case ScheduleType.exercise:
        return '${data?.executeDayTimes ?? 0} phút';
      case ScheduleType.hba1c:
        return '${data?.executeDayTimes ?? 0} lần/ngày';
      case ScheduleType.exercise_movement:
        return '';
      case ScheduleType.custom:
        return '';
      case ScheduleType.coaching:
        return '';
      case ScheduleType.group:
        return '';
      case ScheduleType.survey:
        return '';
      case ScheduleType.lesson:
        return '';
    }
  }

  Future<void> editSmartGoal(SmartGoalListReponseData? smartGoal) async {
    await NavigationUtil.navigatePage(
        context, CreateGoalPage(smartGoalData: smartGoal));
    _cubit.refreshData();
  }

  void showPopup({
    required BuildContext context,
    required Widget child,
    required String buttonTitle,
    VoidCallback? onTap,
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
                      child,
                      const SizedBox(height: 16),
                      Visibility(
                        visible: onTap != null,
                        child: SizedBox(
                          width: 245,
                          child: ButtonWidget(
                            title: buttonTitle,
                            textSize: 14,
                            onPressed: onTap,
                          ),
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

  showCustomGoalPopup({SmartGoalListReponseData? smartGoal}) {
    String description = '';
    if (smartGoal?.executeType == 0) {
      description = 'Thời gian: ${smartGoal?.executeDayTimes} phút';
    } else if (smartGoal?.executeType == 1) {
      description = 'Số lần: ${smartGoal?.executeDayTimes} lần';
    }
    return showPopup(
      context: context,
      buttonTitle: R.string.complete_lesson.tr(),
      onTap: smartGoal?.isCompleted == true
          ? null
          : () {
              _cubit.completeSmartGoal(smartGoal?.id);
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
            style: TextStyle(
                color: R.color.textDark,
                fontSize: 20,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
                color: R.color.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  showCoachingPopup() {
    return showPopup(
      context: context,
      buttonTitle: R.string.join.tr(),
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thứ 6, 12/7/2021',
            style: TextStyle(
                color: R.color.main_1,
                fontSize: 20,
                fontWeight: FontWeight.w700),
          ),
          Text(
            '10:00 am - 11:00 am',
            style: TextStyle(
                color: R.color.main_1,
                fontSize: 20,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            'Buổi Coaching 1 - 1 lập kế hoạch học tập cho user sử dụng gói thấu cảm',
            style: TextStyle(
                color: R.color.textDark,
                fontSize: 16,
                fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(width: 44, height: 44, color: R.color.blue),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Coach',
                    style: TextStyle(
                        color: R.color.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Văn Hùng Trần',
                    style: TextStyle(
                        color: R.color.main_1,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  showSurveyPopup() {
    return showPopup(
      context: context,
      buttonTitle: R.string.start_survey.tr(),
      onTap: () {
        NavigationUtil.pop(context);
        NavigationUtil.navigatePage(context, const IntroduceSurveyPage());
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 57, vertical: 10),
            child: Image.asset(R.drawable.img_survey_4),
          ),
          Text(
            'Khảo sát',
            style: TextStyle(
                color: R.color.textDark,
                fontSize: 20,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Tìm hiểu về thói quen sinh hoạt',
            style: TextStyle(
                color: R.color.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
