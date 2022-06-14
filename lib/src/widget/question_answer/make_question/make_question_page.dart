import 'dart:async';
import 'dart:math';

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
  late TextEditingController _searchLessonModuleController;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '');
    _searchLessonModuleController = TextEditingController(text: '');
    final AppRepository appRepository = AppRepository();
    _cubit = MakeQuestionCubit(appRepository, widget.lessonModuleItems);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //   resizeToAvoidBottomInset: false,
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
      onTap: () {
        _cubit.isShowSuggestLessonModuleList = false;
        if (_cubit.currentLessonModule == null) {
          _searchLessonModuleController.text = '';
        } else {
          _searchLessonModuleController.text = _cubit.currentLessonModule?.name ?? '';
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
                padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLessonModule(),
                      SizedBox(height: 16),
                      _buildQuestion(),
                    ],
                  ),
                ),
              ),
            ),
            _buildSendButton(),
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

  _buildLessonModule() {
    final String title = R.string.topic.tr();
    final String hintText = R.string.select_topic.tr();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            color: R.color.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Visibility(
              visible: _cubit.suggestLessonModuleItems.isEmpty && _cubit.isShowSuggestLessonModuleList,
              child: Padding(
                padding: EdgeInsets.only(top: 64.0, left: 4, bottom: 12),
                child: Text(
                  R.string.no_result.tr(),
                  style: TextStyle(
                    color: R.color.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            Visibility(
              visible: _cubit.suggestLessonModuleItems.isNotEmpty && _cubit.isShowSuggestLessonModuleList,
              child: Container(
                width: double.infinity,
                height: min(276, _cubit.suggestLessonModuleItems.length * 48 + 70),
                decoration: BoxDecoration(
                  color: R.color.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 8),
                  child: ListView.separated(
                    itemCount: _cubit.suggestLessonModuleItems.length,
                    shrinkWrap: true,
               //     physics: AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      bool isSelected = _cubit.suggestLessonModuleItems[index]!.id == _cubit.currentLessonModule?.id;
                      return InkWell(
                        onTap: () {
                          _cubit.currentLessonModule = _cubit.suggestLessonModuleItems[index];
                          _searchLessonModuleController.text = _cubit.currentLessonModule?.name ?? '';
                          _cubit.textSearch = '';
                          _cubit.isShowSuggestLessonModuleList = false;
                          _cubit.refresh();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          height: 48,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${_cubit.suggestLessonModuleItems[index]!.name ?? ""}',
                                  style: TextStyle(
                                    color: isSelected ? R.color.mainColor : R.color.textDark,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Visibility(
                                visible: isSelected,
                                child: Icon(
                                  Icons.check_rounded,
                                  size: 20,
                                  color: R.color.accentColor,
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Container(
                        height: 1,
                        color: R.color.color0xffE5E5E5,
                      );
                    },
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: R.color.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  width: 1.5,
                  color: R.color.color0xffE5E5E5,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onTap: () {
                        if (!_cubit.isShowSuggestLessonModuleList) {
                          _cubit.isShowSuggestLessonModuleList = true;
                          _cubit.refresh();
                        }
                      },
                      controller: _searchLessonModuleController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: hintText,
                      ),
                      style: TextStyle(
                        color: R.color.grey_2,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      onChanged: (text) {
                        _cubit.textSearch = text.trim();
                        _cubit.isShowSuggestLessonModuleList = true;
                        _cubit.refresh();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      if (_cubit.isShowSuggestLessonModuleList) {
                        _cubit.textSearch = '';
                        if (_cubit.currentLessonModule == null) {
                          _searchLessonModuleController.text = '';
                        } else {
                          _searchLessonModuleController.text = _cubit.currentLessonModule?.name ?? '';
                        }
                      }
                      _cubit.isShowSuggestLessonModuleList = !_cubit.isShowSuggestLessonModuleList;
                      _cubit.refresh();
                    },
                    child: Icon(
                      _cubit.isShowSuggestLessonModuleList ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 20,
                      color: R.color.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
                    colors: [R.color.greenGradientTop, R.color.greenGradientBottom])),
            child: Center(
              child: Text(R.string.send_question.tr(),
                  style: TextStyle(color: R.color.white, fontSize: 16, fontWeight: FontWeight.w600)),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
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
                        child: Image.asset(R.drawable.ic_close, width: 36, height: 36),
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
    if (!_cubit.isClickSend) {
      _cubit.setClickSend();
      if (_cubit.currentLessonModule == null) {
        Message.showToastMessage(context, R.string.input_topic_required.tr());
        return;
      }
      if (_controller.text.trim().isEmpty) {
        Message.showToastMessage(context, R.string.input_question_required.tr());
        return;
      }

      Utils.hideKeyboard(context);
      await _cubit.sendQuestion(_controller.text);
    }
  }
}
