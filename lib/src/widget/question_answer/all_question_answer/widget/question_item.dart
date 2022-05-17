import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:medical/res/R.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/src/model/response/lesson_module_response.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/widget/question_answer/all_question_answer/model/question_model.dart';
import 'package:medical/src/widgets/network_image_widget.dart';

import '../../question_answer_utils.dart';

typedef CallbackDelete = Function(String);

class QuestionItem extends StatefulWidget {
  final QuestionModel questionModel;
  final VoidCallback callbackDetail;
  final CallbackDelete callbackDelete;
  final String currentAccountId;
  final List<LessonModuleItem> lessonModules;

  QuestionItem({
    Key? key,
    required this.questionModel,
    required this.currentAccountId,
    required this.lessonModules,
    required this.callbackDetail,
    required this.callbackDelete,
  }) : super(key: key);
  @override
  _QuestionItemState createState() => _QuestionItemState();
}

class _QuestionItemState extends State<QuestionItem> with AutomaticKeepAliveClientMixin {

  @override
  void initState() {
    super.initState();
   
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        widget.callbackDetail();
      },
      child: _buildQuestionItemWithSlide(widget.questionModel),
    );
  }

  _buildQuestionItemWithSlide(QuestionModel questionModel) {
    if (widget.questionModel.accountId != widget.currentAccountId) {
      return _buildQuestionItemInCard(questionModel);
    }
    if (widget.questionModel.status == 0) {
      return _buildQuestionItemInCard(widget.questionModel);
    }
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: [
        Container(
            margin: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: IconSlideAction(
          color: R.color.color0xffFF5552,
          iconWidget: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(R.drawable.ic_trash2, width: 24, height: 24),
                SizedBox(height: 8),
                Text(R.string.delete_question.tr(),
                    style: TextStyle(color: R.color.white, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
              ],
            ),
          ),
          onTap: () {
            _showDialogDelete(context, questionModel.id!);
          },
        ),
        ),
      ],
      child: _buildQuestionItemInCard(widget.questionModel),
    );
  }

  _buildQuestionItemInCard(QuestionModel questionModel) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        color: R.color.white,
        margin: EdgeInsets.symmetric(vertical: 8),
        elevation: 2,
        child: Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderItem(questionModel),
          SizedBox(height: 12),
          _buildTitleItem(questionModel),
          SizedBox(height: (questionModel.answer != null) ? 16 : 0),
          Visibility(
            visible: questionModel.answer != null,
            child: Divider(height: 0.5, color: R.color.grayBorder),
          ),
          SizedBox(height: 8),
          // ListView.builder(
          //   itemCount: questionModel.answers?.length ?? 0,
          //   shrinkWrap: true,
          //   physics: NeverScrollableScrollPhysics(),
          //   itemBuilder: (context, position) {
          //     return _buildDoctorItemInQuestionItem(
          //         questionModel.answers != null ? questionModel.answers![position] : null);
          //   },
          // ),
          _buildDoctorItemInQuestionItem((questionModel.answer != null)
              ? questionModel.answer
              : null),
        ],
      ),
        ),
    );
  }

   _buildHeaderItem(QuestionModel questionModel) {
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
            questionModel.lessonModule != null
                ? questionModel.lessonModule!.name ?? ''
                : getLessonModule(questionModel.lessonModuleId ?? '').name ?? '',
            style: TextStyle(
              color: true ? R.color.white : R.color.black,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Spacer(),
        Text(
          QuestionAnswerUtils.getStatus(questionModel.status ?? 0),
          style: TextStyle(
            color: QuestionAnswerUtils.getColorStatus(questionModel.status ?? 0),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  _buildTitleItem(QuestionModel questionModel) {
    return Text(
      questionModel.body ?? '',
      style: TextStyle(
        color: R.color.black,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  _buildDoctorItemInQuestionItem(Answer? answer) {
    if (answer == null) return Container();
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Row(
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
                SizedBox(height: 2),
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
          Image.asset(R.drawable.ic_right, width: 16, height: 16, color: R.color.greenGradientBottom),
        ],
      ),
    );
  }

  _showDialogDelete(BuildContext context, String id) {
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
                            onTap: () async {
                              widget.callbackDelete(id);
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

  LessonModuleItem getLessonModule(String id) {
    return widget.lessonModules.firstWhere((element) => element.id == id, orElse: null);
  }

  @override
  bool get wantKeepAlive => true;
}