import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/const.dart';

typedef TabbarSelected = Function(int);

class BottomTabbar extends StatefulWidget {
  final TabbarSelected callback;
  final int index;

  BottomTabbar({required this.callback, required this.index});

  final _BottomTabbar state = _BottomTabbar();

  @override
  _BottomTabbar createState() => state;
}

class _BottomTabbar extends State<BottomTabbar> with Observer {
  int currentTab = 0;
  int? ticketCount;

  @override
  void initState() {
    currentTab = widget.index;
    Observable.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    Observable.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> update(Observable observable, String? notifyName,
      Map<dynamic, dynamic>? map) async {
    if (notifyName == Const.NAVIGATE_TO_PROFILE_TAB) {
      jumpToIndex(Const.HOME_SCREEN);
    }
  }

  jumpToIndex(int index) {
    setState(() {
      this.currentTab = index;
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
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  tabWidget(R.string.home.tr(), R.drawable.ic_home,
                      Const.HOME_SCREEN),
                  tabWidget(R.string.title_lesson.tr(), R.drawable.ic_plan,
                      Const.PLAN_SCREEN),
                  Expanded(flex: 1, child: Container()),
                  tabWidget(R.string.qa_title.tr(), R.drawable.ic_qa,
                      Const.COURSE_SCREEN),
                  tabWidget(R.string.store.tr(), R.drawable.ic_home_store,
                      Const.ACCOUNT_SCREEN),
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
            padding: const EdgeInsets.only(left: 7, right: 7),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(image,
                    height: 20,
                    color: currentTab == screenIndex
                        ? R.color.accentColor
                        : R.color.gray),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: currentTab == screenIndex
                          ? R.color.accentColor
                          : R.color.gray,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          onTap: () {
            // Start to sync data from google fit
            if (title == "Trang chủ") {
              Observable.instance
                  .notifyObservers([], notifyName: "syncing_heath_app");
            }
            Observable.instance
                .notifyObservers([], notifyName: Const.HIDE_OVERLAY_KEY);
            setState(() {
              widget.callback(screenIndex);
              if (screenIndex != 3) {
                currentTab = screenIndex;
              }
            });
            // if (screenIndex == 1) {
            //   NavigationUtil.navigatePage(context, const MyPlanPage());
            // } else {

            // }
          }),
    );
  }
}
