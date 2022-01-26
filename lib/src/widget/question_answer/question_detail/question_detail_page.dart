import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/question_answer/all_question_answer/model/question_model.dart';
import 'package:medical/src/widgets/network_image_widget.dart';
import 'question_detail.dart';

class QuestionDetailPage extends StatefulWidget {
  final QuestionModel questionModel;
  QuestionDetailPage({Key? key, required this.questionModel}) : super(key: key);

  @override
  _QuestionDetailPageState createState() => _QuestionDetailPageState();
}

class _QuestionDetailPageState extends State<QuestionDetailPage> {
  late QuestionDetailCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = QuestionDetailCubit(widget.questionModel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocListener<QuestionDetailCubit, QuestionDetailState>(
          listener: (context, state) {},
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
    return Column(
      children: [
        _buildAppBar(context),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeaderItem(),
                SizedBox(height: 12),
                _buildTitleItem(),
                SizedBox(height: 16),
                Divider(height: 0.5, color: R.color.grayBorder),
                SizedBox(height: 10),
                _buildListComment(),
              ],
            ),
          ),
        ),
      ],
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

  _buildHeaderItem() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 3, horizontal: 6),
          decoration: BoxDecoration(
            color: true ? R.color.greenGradientBottom : R.color.grayBorder,
            border: true ? Border.all(color: R.color.greenGradientBottom) : null,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.questionModel.lessonModule!.name ?? '',
            style: TextStyle(
              color: true ? R.color.white : R.color.black,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          _cubit.getStatus(widget.questionModel.status ?? 0),
          style: TextStyle(
            color: _cubit.getColorStatus(widget.questionModel.status ?? 0),
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
          child: Text(
            widget.questionModel.body ?? '',
            style: TextStyle(color: R.color.black, fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        SizedBox(width: 16),
        PopupMenuButton(
          color: R.color.color0xffFF5552,
          child: Center(
            child: Icon(Icons.more_vert, size: 24, color: R.color.black54),
          ),
          itemBuilder: (context) {
            return List.generate(1, (index) {
              return PopupMenuItem<String>(
                  height: 30,
                  padding: EdgeInsets.zero,
                  onTap: () {
                    Future.delayed(const Duration(seconds: 0), () => _showDialogDelete(context, ''));
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
        ),
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
                    ? Container()
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
                    SizedBox(height: 2),
                    Text(
                      answer.account?.createDatetime == null
                          ? ''
                          : DateUtil.parseDateToString(
                              DateTime.fromMillisecondsSinceEpoch(answer.account!.createDatetime! * 1000),
                              'dd/MM/yyyy - hh:mm'),
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
              PopupMenuButton(
                color: R.color.color0xffFF5552,
                child: Center(
                  child: Icon(Icons.more_vert, size: 24, color: R.color.black54),
                ),
                itemBuilder: (context) {
                  return List.generate(1, (index) {
                    return PopupMenuItem<String>(
                        height: 30,
                        padding: EdgeInsets.zero,
                        onTap: () {
                          Future.delayed(const Duration(seconds: 0), () => _showDialogComment(context, ''));
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
              ),
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
        itemCount: widget.questionModel.answers?.length ?? 0,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, position) {
          return _buildDoctorItemInQuestionItem(
              widget.questionModel.answers != null ? widget.questionModel.answers![position] : null);
        },
      ),
    );
  }

  _showDialogDelete(BuildContext context, String model) {
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
                    Image.asset(R.drawable.ic_earse, width: 40, height: 40),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
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
                            onTap: () {
                              //     delete(model);
                              Navigator.pop(context);
                            },
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: R.color.red,
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

  _showDialogComment(BuildContext context, String model) {
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
                    Image.asset(R.drawable.ic_earse, width: 40, height: 40),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
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
                            onTap: () {
                              //     delete(model);
                              Navigator.pop(context);
                            },
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: R.color.red,
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
