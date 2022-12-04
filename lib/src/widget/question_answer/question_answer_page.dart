import 'package:medical/res/R.dart';
import 'package:flutter/material.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import '../../app_setting/app_setting.dart';
import 'package:medical/src/utils/const.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:flutter_observer/Observable.dart';
import 'my_question_answer/my_question_answer.dart';
import 'all_question_answer/all_question_answer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/src/widgets/widget_custom_multi_select_toggle.dart';

class QuestionAnswerPage extends StatefulWidget {
  const QuestionAnswerPage();

  @override
  State<QuestionAnswerPage> createState() => _QuestionAnswerPageState();
}

class _QuestionAnswerPageState extends State<QuestionAnswerPage> with Observer {
  final PageController _pageController = PageController(initialPage: 0);
  List<QuestionAnswerType> questionAnswerList = [
    QuestionAnswerType.Mine,
    QuestionAnswerType.All
  ];

  QuestionAnswerType currentQuestionAnswerType = QuestionAnswerType.Mine;

  int get currentQuestionAnswerTypeIndex {
    final int index = questionAnswerList.indexOf(currentQuestionAnswerType);
    return index == -1 ? 0 : index;
  }

  var userInfo = AppSettings.userInfo;

  @override
  void initState() {
    super.initState();
    Observable.instance.addObserver(this);
    firebaseSetup();
  }

  Future firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
      screenName: 'qna_home',
      screenClass: "QuestionAnswerPage",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        top: true,
        bottom: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTitleAppBar(),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 16),
                  _buildTabBar(),
                  SizedBox(height: 16),
                  _buildPageView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildTitleAppBar() {
    return Container(
      padding: EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            R.string.question_doctor.tr(),
            style: TextStyle(
                color: R.color.black,
                fontWeight: FontWeight.w700,
                fontSize: 24),
          ),
          GestureDetector(
            onTap: () {
              //    Navigator.pop(context);
            },
            child: Container(
              height: 24,
              width: 24,
              //    child: Image.asset(R.drawable.ic_close),
            ),
          ),
        ],
      ),
    );
  }

  _buildTabBar() {
    return Container(
      color: R.color.white,
      padding: EdgeInsets.only(left: 16, right: 16),
      child: CustomMultiSelectToggle(
        toggleList: questionAnswerList.map((e) => e.title).toList(),
        selectedIndex: currentQuestionAnswerTypeIndex,
        onChange: (index) {
          Observable.instance
              .notifyObservers([], notifyName: Const.HIDE_OVERLAY_KEY);
          changeQuestionAnswerType(index);
        },
      ),
    );
  }

  _buildPageView() {
    List<Widget> widgets = [];
    questionAnswerList.forEach((type) {
      switch (type) {
        case QuestionAnswerType.All:
          widgets.add(AllQuestionAnswerPage());
          break;
        case QuestionAnswerType.Mine:
          widgets.add(MyQuestionAnswerPage());
          break;
      }
    });
    return Expanded(
      child: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: widgets,
      ),
    );
  }

  @override
  void dispose() {
    Observable.instance.removeObserver(this);
    super.dispose();
  }

  @override
  update(Observable observable, String? notifyName, Map? map) {}

  Future<void> changeQuestionAnswerType(int newIndex) async {
    currentQuestionAnswerType = questionAnswerList[newIndex];
    late String componentName;
    switch (currentQuestionAnswerType) {
      case QuestionAnswerType.All:
        componentName = "all_qna";
        break;
      case QuestionAnswerType.Mine:
        componentName = "my_qna";
        break;
    }
    await TrackingManager.analytics.logEvent(
      name: 'component_clicked',
      parameters: {
        "screen_name": 'qna_home',
        'component_name': 'top_navigation_$componentName',
      },
    );

    _pageController.jumpToPage(newIndex);
    setState(() {});
  }
}

enum QuestionAnswerType {
  All,
  Mine,
}

extension QuestionAnswerDetail on QuestionAnswerType {
  String get title {
    switch (this) {
      case QuestionAnswerType.All:
        return R.string.all.tr();
      case QuestionAnswerType.Mine:
        return R.string.mine.tr();
    }
  }
}
