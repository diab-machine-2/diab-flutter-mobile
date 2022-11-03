import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/dynamic_link_config.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/common_page.dart';
import 'package:medical/src/widgets/widget_custom_multi_select_toggle.dart';

import '../activity_tab/activity_tab/activity_tab.dart';
import '../exercise_tab/exercise_tab/exercise_tab.dart';
import '../lesson_tab/lesson_tab/lesson_tab.dart';
import 'models/plan_type.dart';
import 'my_plan.dart';

class MyPlanPage extends StatefulWidget {
  final int index;
  MyPlanPage({this.index = 0});

  @override
  State<MyPlanPage> createState() => _MyPlanPageState();
}

class _MyPlanPageState extends State<MyPlanPage> with Observer {
  late final MyPlanCubit _cubit;
  late PageController _pageController;
  final user = AppSettings.userInfo!;
  int index = 0;

  @override
  void initState() {
    super.initState();
    Observable.instance.addObserver(this);
    if (user.isUserFree) {
      index = 1;
    } else {
      index = widget.index;
    }

    _pageController = PageController(initialPage: index);
    final AppRepository appRepository = AppRepository();
    _cubit = MyPlanCubit(appRepository, index);
  }

  @override
  update(Observable observable, String? notifyName, Map? map) {
    if (notifyName == Const.NAVIGATE_TO_ACTIVITY_TAB) {
      if (_cubit.currentPlanType != PlanType.goal) {
        _cubit.changePlanType(0);
      }
    } else if (notifyName == Const.NAVIGATE_TO_LESSON_TAB) {
      if (_cubit.currentPlanType != PlanType.lesson) {
        _cubit.changePlanType(1);
      }
    } else if (notifyName == Const.NAVIGATE_TO_EXERCISE_TAB) {
      if (_cubit.currentPlanType != PlanType.activity) {
        _cubit.changePlanType(2);
      }
    }
  }

  @override
  void dispose() {
    Observable.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocConsumer<MyPlanCubit, MyPlanState>(
          listener: (context, state) {
            if (state is MyPlanFailure) {
              Message.showToastMessage(context, state.error);
            }
            if (state is MyPlanChangeType) {
              _pageController.jumpToPage(state.index);
            }
          },
          builder: (context, state) {
            if (state is MyPlanLoading) {
              BotToast.showLoading();
            } else {
              //     BotToast.closeAllLoading();
            }
            return CommonPage(
              title: R.string.my_plan.tr(),
              background: R.drawable.bg_welcome,
              appbarColor: R.color.white,
              hideAllBackButton: true,
              child: Column(
                children: [
                  Container(
                    color: R.color.white,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    child: CustomMultiSelectToggle(
                      toggleList:
                          _cubit.planTypeList.map((e) => e.title).toList(),
                      selectedIndex: _cubit.currentPlanTypeIndex,
                      onChange: (index) {
                        Observable.instance.notifyObservers([],
                            notifyName: Const.HIDE_OVERLAY_KEY);
                        if (index == 1) {
                          Observable.instance.notifyObservers([],
                              notifyName: "switch_lesson_tab");
                        }

                        _cubit.changePlanType(index);
                      },
                    ),
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: const [
                        ActivityTabPage(),
                        LessonTabPage(),
                        ExerciseTabPage(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
