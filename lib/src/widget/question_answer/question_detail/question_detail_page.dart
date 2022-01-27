import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/question_answer/all_question_answer/model/question_model.dart';
import 'package:medical/src/widgets/network_image_widget.dart';
import '../question_answer_utils.dart';
import 'question_detail.dart';

class QuestionDetailPage extends StatefulWidget {
  final QuestionModel questionModel;
  QuestionDetailPage({Key? key, required this.questionModel}) : super(key: key);

  @override
  _QuestionDetailPageState createState() => _QuestionDetailPageState();
}

class _QuestionDetailPageState extends State<QuestionDetailPage> {
  late QuestionDetailCubit _cubit;
  late TextEditingController _controller;
  final userInfo = AppSettings.userInfo;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '');
    final AppRepository appRepository = AppRepository();
    _cubit = QuestionDetailCubit(appRepository, widget.questionModel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocListener<QuestionDetailCubit, QuestionDetailState>(
          listener: (context, state) {
            if (state is QuestionDetailLoading) {
              BotToast.showLoading();
            } else {
              BotToast.closeAllLoading();
              if (state is DeleteQuestionSuccess) {
                Navigator.pop(context);
                Navigator.pop(context, {'type': 'question', 'id': state.message});
              } else if (state is DeleteQuestionFailure) {
                Message.showToastMessage(context, state.error);
              } else if (state is DeleteCommentSuccess) {
                Navigator.pop(context);
                //  Navigator.pop(context, {'type': 'comment', 'id': state.message});
              } else if (state is DeleteCommentFailure) {
                Message.showToastMessage(context, state.error);
              } else if (state is MakeCommentFailure) {
                Message.showToastMessage(context, state.error);
              }
            }
          },
          child: BlocBuilder<QuestionDetailCubit, QuestionDetailState>(
            builder: (context, state) {
              return _buildPage(context, state);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, QuestionDetailState state) {
    return WillPopScope(
      onWillPop: () => _backPressed(),
      child: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeaderItem(),
                  SizedBox(height: 12),
                  _buildTitleItem(),
                  Visibility(
                    visible: _cubit.questionModel.answers!.isNotEmpty,
                    child: SizedBox(height: 16),
                  ),
                  Visibility(
                      visible: _cubit.questionModel.answers!.isNotEmpty,
                      child: Divider(height: 0.5, color: R.color.grayBorder)),
                  SizedBox(height: 10),
                  _buildListComment(),
                  _buildCommentTextBox(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _backPressed() async {
    Navigator.pop(context, _cubit.questionModel);
    return true;
  }

  _buildAppBar(BuildContext context) {
    return CustomAppBar(
      backgroundColor: R.color.transparent,
      title: Text('', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: R.color.textDark)),
      leadingIcon: IconButton(
          splashColor: R.color.transparent,
          highlightColor: R.color.transparent,
          icon: Icon(Icons.arrow_back, color: R.color.textDark),
          onPressed: () {
            Navigator.pop(context, _cubit.questionModel);
          }),
    );
  }

  _buildHeaderItem() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
          decoration: BoxDecoration(
            color: true ? R.color.greenGradientBottom : R.color.grayBorder,
            border: true ? Border.all(color: R.color.greenGradientBottom) : null,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _cubit.questionModel.lessonModule!.name ?? '',
            style: TextStyle(
              color: true ? R.color.white : R.color.black,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          QuestionAnswerUtils.getStatus(_cubit.questionModel.status ?? 0),
          style: TextStyle(
            color: QuestionAnswerUtils.getColorStatus(_cubit.questionModel.status ?? 0),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  _buildTitleItem() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 0.0,
              maxHeight: 270,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Text(
                _cubit.questionModel.body ?? '',
                style: TextStyle(color: R.color.black, fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        (_cubit.questionModel.accountId == userInfo?.accountId || _cubit.questionModel.status == 0)
            ? PopupMenuButton(
                color: R.color.color0xffFF5552,
                child: Icon(Icons.more_vert, size: 24, color: R.color.black54),
                itemBuilder: (context) {
                  return List.generate(1, (index) {
                    return PopupMenuItem<String>(
                        height: 30,
                        padding: EdgeInsets.zero,
                        onTap: () {
                          Future.delayed(const Duration(seconds: 0),
                              () => _showDialogDeleteQuestion(context, _cubit.questionModel.id!));
                        },
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(R.drawable.ic_trash2, width: 24, height: 24),
                              SizedBox(width: 8),
                              Text(R.string.delete_question.tr(),
                                  style: TextStyle(color: R.color.white, fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                        value: 'Doge');
                  });
                },
              )
            : Container(),
      ],
    );
  }

  _buildDoctorItemInQuestionItem(Answer? answer) {
    if (answer == null) return Container();
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                clipBehavior: Clip.hardEdge,
                height: 40,
                width: 40,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(90), color: R.color.grayBorder),
                child: answer.account?.avatar?.url == null
                    ? Icon(Icons.person, size: 24, color: R.color.white)
                    : NetWorkImageWidget(imageUrl: answer.account!.avatar!.url),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      answer.account?.fullName ?? '',
                      style: TextStyle(
                        color: R.color.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      answer.account?.createDatetime == null
                          ? ''
                          : DateUtil.parseDateToString(
                              DateTime.fromMillisecondsSinceEpoch(answer.createDateTime! * 1000), 'dd/MM/yyyy - hh:mm'),
                      style: TextStyle(
                        color: R.color.gray,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              (answer.accountId == userInfo?.accountId || _cubit.questionModel.status == 0)
                  ? PopupMenuButton(
                      color: R.color.color0xffFF5552,
                      child: Icon(Icons.more_vert, size: 24, color: R.color.black54),
                      itemBuilder: (context) {
                        return List.generate(1, (index) {
                          return PopupMenuItem<String>(
                              height: 30,
                              padding: EdgeInsets.zero,
                              onTap: () {
                                Future.delayed(
                                    const Duration(seconds: 0), () => _showDialogDeleteComment(context, answer.id!));
                              },
                              child: Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(R.drawable.ic_trash2, width: 24, height: 24),
                                    SizedBox(width: 8),
                                    Text(R.string.delete_comment.tr(),
                                        style: TextStyle(color: R.color.white, fontWeight: FontWeight.w500),
                                        textAlign: TextAlign.center),
                                  ],
                                ),
                              ),
                              value: 'Doge');
                        });
                      },
                    )
                  : Container(),
            ],
          ),
          SizedBox(height: 4),
          Text(
            answer.body ?? '',
            style: TextStyle(
              color: R.color.black,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  _buildListComment() {
    return Expanded(
      child: ListView.builder(
        // separatorBuilder: (context, index) {
        //   return Divider(height: 0.0);
        // },
        itemCount: _cubit.questionModel.answers?.length ?? 0,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, position) {
          return _buildDoctorItemInQuestionItem(
              _cubit.questionModel.answers != null ? _cubit.questionModel.answers![position] : null);
        },
      ),
    );
  }

  _buildCommentTextBox() {
    return (_cubit.questionModel.accountId == userInfo?.accountId || _cubit.questionModel.status == 0)
        ? Container(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: R.color.grayBorder, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        hintStyle: TextStyle(color: R.color.gray),
                        hintText: "Thêm bình luận",
                        fillColor: R.color.white),
                    controller: _controller,
                  ),
                ),
                SizedBox(width: 12),
                FloatingActionButton(
                    backgroundColor: R.color.greenGradientBottom,
                    child: Image.asset(
                      R.drawable.ic_send,
                      width: 28,
                      height: 28,
                    ),
                    onPressed: () async {
                      if (_controller.text.isNotEmpty) {
                        Utils.hideKeyboard(context);
                        await _cubit.sendComment(_controller.text);
                        _controller.clear();
                      } else {
                        Message.showToastMessage(context, R.string.input_comment_required.tr());
                      }
                    }),
              ],
            ),
          )
        : Container();
  }

  _showDialogDeleteQuestion(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            contentPadding: EdgeInsets.all(0),
            content: Stack(children: [
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(R.drawable.ic_earse, width: 44, height: 44),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(R.string.confirm_delete_question.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: R.color.textDark, fontSize: 20, fontWeight: FontWeight.w700)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(R.string.confirm_delete_question_subtitle.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: R.color.textDark, fontSize: 16, fontWeight: FontWeight.w400)),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 16),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                                height: 40,
                                decoration:
                                    BoxDecoration(borderRadius: BorderRadius.circular(200), color: R.color.grayBorder),
                                child: Center(
                                  child: Text(R.string.back.tr(),
                                      style: TextStyle(
                                          color: R.color.textDark, fontSize: 16, fontWeight: FontWeight.w600)),
                                )),
                          ),
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              await _cubit.deleteQuestion(id);
                            },
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: R.color.attentionText,
                                borderRadius: BorderRadius.circular(200),
                              ),
                              child: Center(
                                child: Text(R.string.delete.tr(),
                                    style: TextStyle(color: R.color.white, fontSize: 16, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                    icon: Icon(Icons.close, color: R.color.color0xffBEC0C8),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              )
            ]));
      },
    );
  }

  _showDialogDeleteComment(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            contentPadding: EdgeInsets.all(0),
            content: Stack(children: [
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(R.drawable.ic_earse, width: 44, height: 44),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(R.string.confirm_delete_comment.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: R.color.textDark, fontSize: 20, fontWeight: FontWeight.w700)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(R.string.confirm_delete_comment_subtitle.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: R.color.textDark, fontSize: 16, fontWeight: FontWeight.w400)),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 16),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                                height: 40,
                                decoration:
                                    BoxDecoration(borderRadius: BorderRadius.circular(200), color: R.color.grayBorder),
                                child: Center(
                                  child: Text(R.string.back.tr(),
                                      style: TextStyle(
                                          color: R.color.textDark, fontSize: 16, fontWeight: FontWeight.w600)),
                                )),
                          ),
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              await _cubit.deleteComment(id);
                            },
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: R.color.attentionText,
                                borderRadius: BorderRadius.circular(200),
                              ),
                              child: Center(
                                child: Text(R.string.delete.tr(),
                                    style: TextStyle(color: R.color.white, fontSize: 16, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                    icon: Icon(Icons.close, color: R.color.color0xffBEC0C8),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              )
            ]));
      },
    );
  }
}
