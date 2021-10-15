import 'package:flutter/material.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/my_plan_screens/my_plan/my_plan.dart';
import 'package:medical/src/widgets/button_widget.dart';

class ListPlanPage extends StatelessWidget {
  const ListPlanPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: ButtonWidget(
          title: 'Go to MyPlan',
          onPressed: () {
            NavigationUtil.navigatePage(context, const MyPlanPage());
          },
        ),
      ),
    );
  }
}
