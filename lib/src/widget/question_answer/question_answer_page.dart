import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/common_page.dart';
import 'package:medical/src/widgets/widget_custom_multi_select_toggle.dart';

import 'all_question_answer/all_question_answer.dart';
import 'my_question_answer/my_question_answer.dart';

class QuestionAnswerPage extends StatefulWidget {
  const QuestionAnswerPage();

  @override
  State<QuestionAnswerPage> createState() => _QuestionAnswerPageState();
}

class _QuestionAnswerPageState extends State<QuestionAnswerPage> with Observer {
  final PageController _pageController = PageController(initialPage: 0);
  List<QuestionAnswerType> questionAnswerList = [QuestionAnswerType.All, QuestionAnswerType.Mine];

  QuestionAnswerType currentQuestionAnswerType = QuestionAnswerType.All;

  int get currentQuestionAnswerTypeIndex {
    final int index = questionAnswerList.indexOf(currentQuestionAnswerType);
    return index == -1 ? 0 : index;
  }

  @override
  void initState() {
    super.initState();
    Observable.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: true,
        child: Container(
          child: Column(
            children: [
              _buildTitleAppBar(),
              SizedBox(height: 16),
              _buildTabBar(),
              SizedBox(height: 16),
              _buildPageView(),
            ],
          ),
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
            style: TextStyle(color: R.color.black, fontWeight: FontWeight.w700, fontSize: 24),
          ),
          GestureDetector(
            onTap: () {
              //    Navigator.pop(context);
            },
            child: Container(
              height: 24,
              width: 24,
              child: Image.asset(R.drawable.ic_close),
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
          Observable.instance.notifyObservers([], notifyName: Const.HIDE_OVERLAY_KEY);
          changeQuestionAnswerType(index);
        },
      ),
    );
  }

  _buildPageView() {
    return Expanded(
      child: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          AllQuestionAnswerPage(),
          MyQuestionAnswerPage(),
        ],
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

  void changeQuestionAnswerType(int newIndex) {
    currentQuestionAnswerType = questionAnswerList[newIndex];
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
