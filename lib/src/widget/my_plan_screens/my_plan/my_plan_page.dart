import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/common_page.dart';
import 'package:medical/src/widgets/widget_custom_multi_select_toggle.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../activity_tab/activity_tab.dart';
import '../exercise_tab/exercise_tab/exercise_tab.dart';
import '../lesson_tab/lesson_tab/lesson_tab.dart';
import 'models/plan_type.dart';
import 'my_plan.dart';

class MyPlanPage extends StatefulWidget {
  const MyPlanPage();

  @override
  State<MyPlanPage> createState() => _MyPlanPageState();
}

class _MyPlanPageState extends State<MyPlanPage> {
  late final MyPlanCubit _cubit;
  final PageController _pageController = PageController(initialPage: 1);
  final RefreshController _controller = RefreshController();

  @override
  void initState() {
    final AppRepository appRepository = AppRepository();
    _cubit = MyPlanCubit(appRepository);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocConsumer<MyPlanCubit, MyPlanState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is MyPlanLoading) {
              BotToast.showLoading();
            } else {
              BotToast.closeAllLoading();
              _controller.refreshCompleted();
            }
            if (state is MyPlanFailure) {
              Message.showToastMessage(context, state.error);
            }
            return CommonPage(
              title: R.string.my_plan.tr(),
              background: R.drawable.bg_welcome,
              appbarColor: R.color.white,
              showCloseBackButton: true,
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
                        _cubit.changePlanType(index);
                        _pageController.jumpToPage(index);
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
