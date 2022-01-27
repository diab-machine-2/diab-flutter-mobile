import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/lesson_module_response.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/show_message.dart';
//import 'package:medical/src/widgets/custom_dropdown.dart';
import 'make_question.dart';

class MakeQuestionPage extends StatefulWidget {
  final List<LessonModuleItem> lessonModuleItems;

  MakeQuestionPage({Key? key, required this.lessonModuleItems}) : super(key: key);

  @override
  _MakeQuestionPageState createState() => _MakeQuestionPageState();
}

class _MakeQuestionPageState extends State<MakeQuestionPage> {
  late MakeQuestionCubit _cubit;
  late TextEditingController _controller;
  Timer? _timer;
  bool isClickSend = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '');
    final AppRepository appRepository = AppRepository();
    _cubit = MakeQuestionCubit(appRepository, widget.lessonModuleItems);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocListener<MakeQuestionCubit, MakeQuestionState>(
          listener: (context, state) {
            if (state is MakeQuestionLoading) {
              BotToast.showLoading();
            } else {
              BotToast.closeAllLoading();
              if (state is SendQuestionSuccess) {
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
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Container(
        color: R.color.greenbg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(context),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTopic(),
                          SizedBox(height: 8),
                          _buildQuestion(),
                          Spacer(),
                        ],
                      ),
                    ),
                    _buildSendButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildAppBar(BuildContext context) {
    return CustomAppBar(
      backgroundColor: R.color.transparent,
      title: Text(R.string.ask_question.tr(),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: R.color.textDark)),
      leadingIcon: IconButton(
          splashColor: R.color.transparent,
          highlightColor: R.color.transparent,
          icon: Icon(Icons.arrow_back, color: R.color.textDark),
          onPressed: () {
            Navigator.pop(context);
          }),
    );
  }

  _buildTopic() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          R.string.topic.tr(),
          style: TextStyle(
            color: R.color.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: R.color.grayBorder, style: BorderStyle.solid, width: 1),
            color: R.color.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<LessonModuleItem>(
              alignment: AlignmentDirectional.bottomEnd,
              isDense: true,
              isExpanded: true,
              value: _cubit.currentLessonModule,
              icon: Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: R.color.textDark,
              ),
              hint: Text(
                R.string.select_topic.tr(),
                style: TextStyle(
                  color: R.color.gray,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              items: _cubit.lessonModuleItems.map((LessonModuleItem value) {
                return DropdownMenuItem<LessonModuleItem>(
                  value: value,
                  child: Text(value.name ?? ''),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _cubit.setCurrentLessonModule(value);
                }
              },
            ),
          ),
        ),
        SizedBox(height: 8),
      ],
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
          maxLines: 8,
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
      child: Container(
          height: 48,
          width: 300,
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: R.color.mainColor,
              borderRadius: BorderRadius.circular(200),
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.centerRight,
                  colors: [R.color.greenGradientTop, R.color.greenGradientBottom])),
          child: Center(
            child: Text(R.string.send_question.tr(),
                style: TextStyle(color: R.color.white, fontSize: 16, fontWeight: FontWeight.w600)),
          )),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
            content: Container(
              padding: EdgeInsets.all(8),
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
                        child: Image.asset(R.drawable.ic_close, width: 28, height: 28),
                      ),
                    ],
                  ),
                  Image.asset(R.drawable.img_question, width: 200, height: 200),
                  SizedBox(height: 16),
                  Text(
                    R.string.send_question_success.tr(),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: R.color.textDark),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    R.string.response_as_soon_as_possible.tr(),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: R.color.textDark),
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
    if (!isClickSend) {
      if (_cubit.currentLessonModule == null) {
        Message.showToastMessage(context, R.string.input_topic_required.tr());
        setClickSend();
        return;
      }
      if (_controller.text.trim().isEmpty) {
        Message.showToastMessage(context, R.string.input_question_required.tr());
        setClickSend();
        return;
      }

      Utils.hideKeyboard(context);
      await _cubit.sendQuestion(_controller.text);
    }
  }

  setClickSend() {
    isClickSend = true;
    if (_timer != null) _timer!.cancel();
    _timer = Timer(Duration(seconds: 3), () {
      isClickSend = false;
    });
  }
}
