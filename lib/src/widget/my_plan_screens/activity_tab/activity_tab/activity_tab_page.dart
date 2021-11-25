import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/week_states_response.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/circle_graph.dart';

import '../../my_plan/models/completion_status.dart';
import '../../my_plan/my_plan.dart';
import '../../my_plan/widgets/app_bar_bottom.dart';
import '../create_goal/create_goal.dart';
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
          }
          if (state is ActivityTabFailure) {
            Message.showToastMessage(context, state.error);
          }
          if (state is GoalTypeChanged) {}
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
                              onTap: () {},
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
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
                        child: Column(children: [
                          _buildSingleGoal(
                              icon: ScheduleType.exercise_movement.icon,
                              title: 'Bài tập vận động',
                              frequency: 'Bài tập mềm dẻo',
                              onTap: () {
                                onSelectGoal(ScheduleType.exercise_movement);
                              }),
                          _buildSingleGoal(
                              icon: ScheduleType.blood_sugar.icon,
                              title: 'Đo đường huyết',
                              frequency: '2 lần/ngày',
                              onTap: () {
                                onSelectGoal(ScheduleType.blood_sugar);
                              }),
                          _buildSingleGoal(
                              icon: ScheduleType.meditate.icon,
                              title: 'Ngồi thiền',
                              frequency: 'Còn 7 ngày để hoàn thành',
                              onTap: () {
                                onSelectGoal(ScheduleType.meditate);
                              }),
                          _buildSingleGoal(
                              icon: ScheduleType.exercise.icon,
                              title: 'Vận động',
                              frequency: '30 phút',
                              onTap: () {
                                onSelectGoal(ScheduleType.exercise);
                              }),
                          _buildSingleGoal(
                              icon: ScheduleType.weight.icon,
                              title: 'Đo cân nặng',
                              onTap: () {
                                onSelectGoal(ScheduleType.weight);
                              }),
                          _buildSingleGoal(
                              icon: ScheduleType.emotion.icon,
                              title: 'Cảm xúc',
                              onTap: () {
                                onSelectGoal(ScheduleType.emotion);
                              }),
                          _buildSingleGoal(
                              icon: ScheduleType.hba1c.icon,
                              title: 'Đo HbA1C',
                              onTap: () {
                                onSelectGoal(ScheduleType.hba1c);
                              }),
                          _buildSingleGoal(
                              icon: ScheduleType.food.icon,
                              title: 'Nhập món ăn',
                              frequency: '3 lần/ngày',
                              onTap: () {
                                onSelectGoal(ScheduleType.food);
                              }),
                          _buildSingleGoal(
                              icon: ScheduleType.blood_pressure.icon,
                              title: 'Huyết áp',
                              frequency: '10:00 am - 11:00 am',
                              onTap: () {
                                onSelectGoal(ScheduleType.blood_pressure);
                              }),
                          _buildSingleGoal(
                              icon: ScheduleType.coaching.icon,
                              title: 'Tư vấn với huấn luyện viên',
                              frequency: '10:00 am - 11:00 am',
                              onTap: () {
                                onSelectGoal(ScheduleType.coaching);
                              }),
                          _buildSingleGoal(
                              icon: ScheduleType.group.icon,
                              title: 'Sinh hoạt nhóm',
                              frequency: '19h15',
                              onTap: () {
                                onSelectGoal(ScheduleType.group);
                              }),
                          _buildSingleGoal(
                              icon: ScheduleType.survey.icon,
                              title: 'Khảo sát',
                              frequency: 'Khảo sát tháng',
                              onTap: () {
                                onSelectGoal(ScheduleType.survey);
                              }),
                        ]),
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
                  onTap: () {
                    NavigationUtil.navigatePage(
                        context, const CreateGoalPage());
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
    _scrollController.animateTo(
      newPosition,
      duration: const Duration(milliseconds: 400),
      curve: Curves.ease,
    );
    if (refresh) {}
  }

  Widget _buildScheduleWidget() {
    if (_cubit.weekStatesList.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
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
                              status: CompletionStatus.not_start_yet,
                              isSelected: _cubit.currentDayIndex == index ~/ 2,
                              onTap: () {});
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
                    onSelect: () {});
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
    required String icon,
    required String title,
    String? frequency,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            CircleGraphWidget(
              percent: 40,
              icon: icon,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: R.color.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (frequency != null) const SizedBox(height: 4),
                    if (frequency != null)
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
            Image.asset(
              R.drawable.ic_edit,
              width: 20,
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  void onSelectGoal(ScheduleType type) {
    switch (type) {
      case ScheduleType.blood_sugar:
        break;
      case ScheduleType.blood_pressure:
        break;
      case ScheduleType.weight:
        break;
      case ScheduleType.emotion:
        break;
      case ScheduleType.food:
        break;
      case ScheduleType.exercise:
        break;
      case ScheduleType.hba1c:
        break;
      case ScheduleType.exercise_movement:
        _cubit.goToExerciseTab();
        break;
      case ScheduleType.meditate:
        showCustomGoalPopup();
        break;
      case ScheduleType.coaching:
        showCoachingPopup();
        break;
      case ScheduleType.group:
        break;
      case ScheduleType.survey:
        showSurveyPopup();
        break;
    }
  }

  void showPopup({
    required BuildContext context,
    required Widget child,
    required String buttonTitle,
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
                      SizedBox(
                        width: 245,
                        child: ButtonWidget(
                          title: buttonTitle,
                          textSize: 14,
                          onPressed: () {
                            NavigationUtil.pop(context);
                          },
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

  showCustomGoalPopup() {
    return showPopup(
      context: context,
      buttonTitle: 'Hoàn thành',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 57, vertical: 10),
            child: Image.asset(R.drawable.img_custom_goal),
          ),
          Text(
            'Ngồi thiền',
            style: TextStyle(
                color: R.color.textDark,
                fontSize: 20,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Thời gian: 30 phút',
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
      buttonTitle: 'Tham gia',
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
      buttonTitle: 'Bắt đầu khảo sát',
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
