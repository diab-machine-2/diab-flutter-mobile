import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/circle_graph.dart';

import '../../my_plan/my_plan.dart';
import '../../my_plan/widgets/app_bar_bottom.dart';
import 'activity_tab.dart';
import 'models/goal_type.dart';
import 'widgets/custom_progress_bar_widget.dart';

class ActivityTabPage extends StatefulWidget {
  const ActivityTabPage();

  @override
  _ActivityTabPageState createState() => _ActivityTabPageState();
}

class _ActivityTabPageState extends State<ActivityTabPage>
    with AutomaticKeepAliveClientMixin<ActivityTabPage> {
  late final ActivityTabCubit _cubit;

  @override
  void initState() {
    super.initState();
    final MyPlanCubit _myPlanCubit = BlocProvider.of<MyPlanCubit>(context);
    final AppRepository appRepository = AppRepository();
    _cubit = ActivityTabCubit(appRepository, _myPlanCubit);
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
          if (state is GoalTypeChanged) {
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
                        Row(
                          children: [
                            ...List.generate(
                              _cubit.goalTypeList.length,
                              (index) {
                                return _buildLessonTypeSelect(
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
                              child: Image.asset(
                                R.drawable.ic_activity_process,
                                width: 20,
                                height: 20,
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
                        padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const CircleGraphWidget(
                                  percent: 40,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Bài tập vận động',
                                          style: TextStyle(
                                            color: R.color.textDark,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          'Bài tập mềm dẻo',
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
                          ],
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
                  onTap: () {},
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

  Widget _buildLessonTypeSelect({
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
            margin: const EdgeInsets.only(top: 7),
            decoration: BoxDecoration(
              color: isActive ? R.color.mainColor : R.color.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
