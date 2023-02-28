import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/lesson_module_response.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
//import 'package:medical/src/widgets/custom_dropdown.dart';
import 'make_question.dart';
import 'widgets/index.dart';

class MakeQuestionPage extends StatefulWidget {
  final List<LessonModuleItem> lessonModuleItems;

  MakeQuestionPage({Key? key, required this.lessonModuleItems})
      : super(key: key);

  @override
  _MakeQuestionPageState createState() => _MakeQuestionPageState();
}

class _MakeQuestionPageState extends State<MakeQuestionPage> {
  late MakeQuestionCubit _cubit;
  // late TextEditingController _searchLessonModuleController;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '');
    // _searchLessonModuleController = TextEditingController(text: '');
    final AppRepository appRepository = AppRepository();
    _cubit = MakeQuestionCubit(appRepository, widget.lessonModuleItems);
    firebaseSetup();
  }

  Future firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
      screenName: "qna_add",
      screenClass: "MakeQuestionPage",
    );
    await TrackingManager.analytics.logEvent(
      name: 'qna_begin',
      parameters: {
        "screen_name": 'qna_add',
      },
    );
    AppSettings.currentScreenName = 'qna_add';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //   resizeToAvoidBottomInset: false,
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocListener<MakeQuestionCubit, MakeQuestionState>(
          listener: (context, state) async {
            if (state is MakeQuestionLoading) {
              BotToast.showLoading();
            } else {
              BotToast.closeAllLoading();
              if (state is SendQuestionSuccess) {
                await TrackingManager.analytics.logEvent(
                  name: 'qna_complete',
                  parameters: {
                    "screen_name": 'qna_add',
                  },
                );
                showSuccessDialog();
              } else if (state is SendQuestionFailure) {
                Message.showToastMessage(context, state.error);
              }
            }
          },
          child: BlocBuilder<MakeQuestionCubit, MakeQuestionState>(
            builder: (context, state) {
              return _buildPage(context, state);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, MakeQuestionState state) {
    return GestureDetector(
      onTap: () {
        _cubit.isShowSuggestLessonModuleList = false;
        if (_cubit.currentLessonModule == null) {
          _cubit.searchLessonModuleController.text = '';
        } else {
          _cubit.searchLessonModuleController.text =
              _cubit.currentLessonModule?.name ?? '';
        }
        _cubit.textSearch = '';
        _cubit.refresh();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Container(
        color: R.color.greenbg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(context),
            Expanded(
              child: Container(
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // BuildLessonModule(cubit: _cubit),
                      _buildQuestion(),
                      SizedBox(height: 16),
                      ImagePickerItem(cubit: _cubit),
                    ],
                  ),
                ),
              ),
            ),
            // _buildSendButton(),
          ],
        ),
      ),
    );
  }

  _buildAppBar(BuildContext context) {
    return CustomAppBar(
      backgroundColor: R.color.transparent,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(R.string.ask_question.tr(),
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: R.color.textDark)),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                await _submitData();
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: AutoSizeText(
                      "Gửi câu hỏi",
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: R.color.accentColor),
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(
                    Icons.send,
                    size: 16,
                    color: R.color.accentColor,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      leadingIcon: IconButton(
        splashColor: R.color.transparent,
        highlightColor: R.color.transparent,
        icon: Icon(Icons.arrow_back, color: R.color.textDark),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  _buildQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          R.string.your_question.tr(),
          style: TextStyle(
            color: R.color.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: R.color.grayBorder, width: 1),
              ),
              filled: true,
              hintStyle: TextStyle(color: R.color.gray),
              hintText: "Bạn muốn hỏi bác sỹ điều gì?",
              fillColor: R.color.white),
          minLines: 5,
          maxLines: 15,
          maxLength: 5000,
          controller: _controller,
        ),
      ],
    );
  }

  _buildSendButton() {
    return GestureDetector(
      onTap: () async {
        await _submitData();
      },
      child: Center(
        child: Container(
            height: 48,
            margin: EdgeInsets.only(bottom: 16, left: 24, right: 24),
            decoration: BoxDecoration(
                color: R.color.mainColor,
                borderRadius: BorderRadius.circular(200),
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.centerRight,
                    colors: [
                      R.color.greenGradientTop,
                      R.color.greenGradientBottom
                    ])),
            child: Center(
              child: Text(R.string.send_question.tr(),
                  style: TextStyle(
                      color: R.color.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            )),
      ),
    );
  }

  showSuccessDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            backgroundColor: R.color.greenbg,
            contentPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            content: Container(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pop(context, true);
                        },
                        child: Image.asset(R.drawable.ic_close,
                            width: 36, height: 36),
                      ),
                    ],
                  ),
                  Image.asset(R.drawable.img_question, width: 200, height: 200),
                  SizedBox(height: 16),
                  Text(
                    R.string.send_question_success.tr(),
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: R.color.textDark),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    R.string.response_as_soon_as_possible.tr(),
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: R.color.textDark),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
            actions: <Widget>[],
          );
        });
  }

  _submitData() async {
    await TrackingManager.analytics.logEvent(
      name: 'cta_button_clicked',
      parameters: {
        "screen_name": 'add_question',
        'component_name': 'cta_add_question',
      },
    );
    if (!_cubit.isClickSend) {
      _cubit.setClickSend();
      // if (_cubit.currentLessonModule == null) {
      //   Message.showToastMessage(context, R.string.input_topic_required.tr());
      //   return;
      // }
      if (_controller.text.trim().isEmpty) {
        Message.showToastMessage(
            context, R.string.input_question_required.tr());
        return;
      }

      Utils.hideKeyboard(context);
      await _cubit.sendQuestion(_controller.text);
    }
  }
}
