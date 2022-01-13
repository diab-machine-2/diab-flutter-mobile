import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/const.dart';

typedef TabbarSelected = Function(int);

class BottomTabbar extends StatefulWidget {
  final TabbarSelected callback;

  BottomTabbar({required this.callback});

  final _BottomTabbar state = _BottomTabbar();

  @override
  _BottomTabbar createState() => state;
}

class _BottomTabbar extends State<BottomTabbar> {
  int index = 0;
  int? ticketCount;

  @override
  void initState() {
    super.initState();
  }

  jumpToIndex(int index) {
    setState(() {
      this.index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 12,
        child: SafeArea(
          child: Container(
            height: 60,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              tabWidget(R.string.home.tr(), R.drawable.ic_home, Const.HOME_SCREEN),
              tabWidget(R.string.schedule.tr(), R.drawable.ic_plan, Const.PLAN_SCREEN),
              Expanded(flex: 1, child: Container()),
              tabWidget(R.string.q_and_a.tr(), R.drawable.ic_qa, Const.COURSE_SCREEN),
              tabWidget(R.string.individual.tr(), R.drawable.ic_account, Const.ACCOUNT_SCREEN),
            ]),
          ),
        ));
  }

  Widget tabWidget(String title, String image, int screenIndex) {
    return Expanded(
      flex: 1,
      child: GestureDetector(
          child: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(image, height: 20, color: index == screenIndex ? R.color.accentColor : R.color.gray),
                const SizedBox(height: 4),
                Text(title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: index == screenIndex ? R.color.accentColor : R.color.gray,
                        fontSize: 12,
                        fontWeight: FontWeight.bold))
              ],
            ),
          ),
          onTap: () {
            Observable.instance.notifyObservers([], notifyName: Const.HIDE_OVERLAY_KEY);
            setState(() {
              index = screenIndex;
              widget.callback(index);
            });
            // if (screenIndex == 1) {
            //   NavigationUtil.navigatePage(context, const MyPlanPage());
            // } else {

            // }
          }),
    );
  }
}
