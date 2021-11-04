import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/common_page.dart';

import 'activity_feedback.dart';

class ActivityFeedbackPage extends StatefulWidget {
  const ActivityFeedbackPage();

  @override
  _ActivityFeedbackPageState createState() => _ActivityFeedbackPageState();
}

class _ActivityFeedbackPageState extends State<ActivityFeedbackPage> {
  late final ActivityFeedbackCubit _cubit;

  @override
  void initState() {
    super.initState();
    final AppRepository appRepository = AppRepository();
    _cubit = ActivityFeedbackCubit(appRepository);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: CommonPage(
            title: 'Đánh giá bài tập vận động 1',
            //TODO: Change background
            background: R.drawable.bg_lesson_detail,
            bottomSafeArea: true,
            showCloseBackButton: true,
            child: BlocConsumer<ActivityFeedbackCubit, ActivityFeedbackState>(
              listener: (context, state) {
                if (state is ActivityFeedbackLoading) {
                  BotToast.showLoading();
                } else {
                  BotToast.closeAllLoading();
                }
                if (state is ActivityFeedbackFailure) {
                  Message.showToastMessage(context, state.error);
                }
              },
              builder: (context, state) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
                    child: Column(
                      children: [
                        Image.asset(
                          R.drawable.img_course_feedback,
                          width: 152,
                          height: 153,
                        ),
                        const SizedBox(height: 24),
                        ...List.generate(
                          _cubit.level.length,
                          (index) => buildQuestion(
                              title: _cubit.level[index],
                              isSelected: index == _cubit.selectedAnswer,
                              onTap: () {
                                _cubit.onSelectAnswer(index);
                              }),
                        ),
                        const SizedBox(height: 14),
                        _buildNotesInput(),
                        const SizedBox(height: 32),
                        Container(
                          width: 195,
                          child: ButtonWidget(
                            title: 'Gửi đánh giá',
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              _cubit.onSumit();
                              showFeedbackSuccessed();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildQuestion({
    required String title,
    required bool isSelected,
    bool isSingleChoice = true,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isSelected ? R.color.color0xffB1DDDB : R.color.white,
        border: Border.all(
          width: isSelected ? 0 : 1,
          color: isSelected ? Colors.transparent : R.color.grayComponentBorder,
        ),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
          onTap?.call();
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Theme(
              data: ThemeData(
                unselectedWidgetColor: R.color.grayBorder,
              ),
              child: Transform.scale(
                scale: 1.3,
                child: isSingleChoice
                    ? Radio<bool>(
                        value: isSelected,
                        activeColor: R.color.accentColor,
                        splashRadius: 20,
                        onChanged: (value) {
                          FocusScope.of(context).unfocus();
                          onTap?.call();
                        },
                        groupValue: true,
                      )
                    : Checkbox(
                        value: isSelected,
                        activeColor: R.color.accentColor,
                        splashRadius: 20,
                        onChanged: (value) {}),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? R.color.accentColor : R.color.textDark,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: R.color.white,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.chat_outlined,
                size: 20,
                color: R.color.textDark,
              ),
              const SizedBox(width: 12),
              Text(
                R.string.feeling.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: R.color.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          TextField(
            textInputAction: TextInputAction.go,
            maxLines: 5,
            minLines: 1,
            keyboardType: TextInputType.multiline,
            expands: false,
            cursorColor: R.color.accentColor,
            onChanged: (text) {
              _cubit.note = text;
            },
            decoration: InputDecoration(
              hintText: R.string.enter_your_feeling.tr(),
              hintStyle: TextStyle(color: R.color.gray, fontSize: 16),
              focusColor: R.color.accentColor,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: R.color.gray),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: R.color.gray),
              ),
            ),
          )
        ],
      ),
    );
  }

  void showFeedbackSuccessed() {
    showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
      context: context,
      builder: (_) => Scaffold(
        backgroundColor: R.color.transparent,
        body: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: R.color.white,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 40,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => NavigationUtil.pop(context),
                        child: Icon(
                          Icons.close,
                          color: R.color.textDark,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  Image.asset(
                    R.drawable.img_send_feedback_successed,
                    height: 160,
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Gửi đánh giá thành công!',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: R.color.textDark,
                        height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
