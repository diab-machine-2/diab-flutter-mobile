import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/question_answer/all_question_answer/model/question_model.dart';
import 'package:medical/src/widgets/block_bottom_sheet.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/html_text_widget.dart';
import 'package:medical/src/widgets/network_image_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../question_answer_utils.dart';
import 'question_detail.dart';

class QuestionDetailPage extends StatefulWidget {
  final QuestionModel questionModel;
  final bool isAll;
  QuestionDetailPage(
      {Key? key, required this.questionModel, required this.isAll})
      : super(key: key);

  @override
  _QuestionDetailPageState createState() => _QuestionDetailPageState();
}

class _QuestionDetailPageState extends State<QuestionDetailPage>
    with WidgetsBindingObserver {
  late QuestionDetailCubit _cubit;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = TextEditingController(text: '');
    final AppRepository appRepository = AppRepository();

    // if(widget.questionModel.answer != null){
    //   widget.questionModel.answers = [];
    //   widget.questionModel.answers!.add(widget.questionModel.answer!);
    // }

    _cubit =
        QuestionDetailCubit(appRepository, widget.isAll, widget.questionModel);
    firebaseSetup();
  }

  Future firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
      screenName: "qna_detail",
      screenClass: "QuestionDetailPage",
    );
    AppSettings.currentScreenName = 'qna_detail';
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeMetrics() {
    _cubit.keyboardHidden.then((value) {
      if (value) {
        _cubit.titleHeight = 280;
      } else {
        _cubit.titleHeight = 120;
      }
      _cubit.refreshScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: R.color.transparent,
        leading: IconButton(
          splashColor: R.color.transparent,
          highlightColor: R.color.transparent,
          icon: Icon(Icons.arrow_back, color: R.color.accentColor),
          onPressed: () {
            _backPressed();
          },
        ),
      ),
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
                Navigator.pop(
                    context, {'type': 'question', 'id': state.message});
              } else if (state is DeleteQuestionFailure) {
                Navigator.pop(context);
                Message.showToastMessage(context, state.error);
              } else if (state is DeleteCommentSuccess) {
                Navigator.pop(context);
                //  Navigator.pop(context, {'type': 'comment', 'id': state.message});
              } else if (state is DeleteCommentFailure) {
                Navigator.pop(context);
                Message.showToastMessage(context, state.error);
              } else if (state is MakeCommentFailure) {
                Message.showToastMessage(context, state.error);
              } else if (state is RatingCommentSuccess) {
                Message.showToastMessage(context, 'Gửi đánh giá thành công.');
              }
            }
          },
          child: BlocBuilder<QuestionDetailCubit, QuestionDetailState>(
            builder: (context, state) {
              if (_cubit.questionModel.status != null)
                return _buildPage(context, state);
              return SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, QuestionDetailState state) {
    return WillPopScope(
      onWillPop: () => _backPressed(),
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Container(
                padding:
                    EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeaderItem(),
                    SizedBox(height: 12),
                    _buildTitleItem(),
                    // _cubit.questionModel.answers!.isEmpty ? Flexible(child: _buildTitleItem()) : _buildTitleItem(),
                    SizedBox(height: 16),
                    _buildAuthor(_cubit.questionModel),
                    Visibility(
                      visible: _cubit.questionModel.answers!.isNotEmpty,
                      child: SizedBox(height: 16),
                    ),
                    Visibility(
                        visible: _cubit.questionModel.answers!.isNotEmpty,
                        child: Divider(height: 0.5, color: R.color.grayBorder)),
                    SizedBox(height: 8),
                    _buildListComment(),
                  ],
                ),
              ),
            ),
            _buildCommentTextBox(context),
          ],
        ),
      ),
    );
  }

  Future<bool> _backPressed() async {
    Navigator.pop(context, _cubit.questionModel);
    return true;
  }

  _buildHeaderItem() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_cubit.questionModel.lessonModule!.name != null)
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
            decoration: BoxDecoration(
              color: R.color.greenGradientBottom,
              border: Border.all(color: R.color.greenGradientBottom),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _cubit.questionModel.lessonModule!.name ?? '',
              style: TextStyle(
                color: R.color.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          Spacer(),
        Text(
          QuestionAnswerUtils.getStatus(_cubit.questionModel.status ?? 0),
          style: TextStyle(
            color: QuestionAnswerUtils.getColorStatus(
                _cubit.questionModel.status ?? 0),
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
              maxHeight: _cubit.questionModel.answers!.isEmpty
                  ? double.infinity
                  : _cubit.titleHeight,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _cubit.questionModel.body ?? '',
                    style: TextStyle(
                        color: R.color.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  if (_cubit.questionModel.pictureUrls.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Row(
                        children: _cubit.questionModel.pictureUrls
                            .map(
                              (imageModel) => InkWell(
                                onTap: () =>
                                    _showDialogImage(context, imageModel.url!),
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 15),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(9),
                                    child: NetWorkImageWidget(
                                      imageUrl: imageModel.url!,
                                      width: 48.h,
                                      height: 48.h,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    )
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        _buildDeleteQuestion(),
      ],
      //  ),
      //   SizedBox(height: 16),
      //   _buildAuthor(_cubit.questionModel),
      // ],
    );
  }

  _showDialogImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          content: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [CachedNetworkImage(imageUrl: imageUrl)],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.close, color: R.color.color0xffBEC0C8),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }

  _buildAuthor(QuestionModel questionModel) {
    return Row(
      children: [
        Container(
          clipBehavior: Clip.hardEdge,
          height: 40,
          width: 40,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(90),
              color: R.color.grayBorder),
          child: questionModel.creatorUrl?.url == null
              ? Icon(Icons.person, size: 24, color: R.color.white)
              : NetWorkImageWidget(imageUrl: questionModel.creatorUrl!.url),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                questionModel.creator ?? '',
                style: TextStyle(
                  color: R.color.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 3),
              Text(
                questionModel.createDateTime == null
                    ? ''
                    : DateUtil.parseDateToString(
                        DateTime.fromMillisecondsSinceEpoch(
                            questionModel.createDateTime! * 1000),
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
      ],
    );
  }

  _buildDeleteQuestion() {
    if (_cubit.questionModel.status == 0) return Container();
    if (_cubit.questionModel.accountId != _cubit.userInfo?.accountId)
      return Container();
    return PopupMenuButton(
      color: R.color.color0xffFF5552,
      child: Icon(Icons.more_vert, size: 24, color: R.color.black54),
      itemBuilder: (context) {
        return List.generate(
          1,
          (index) {
            return PopupMenuItem<String>(
                height: 30,
                padding: EdgeInsets.zero,
                onTap: () {
                  Future.delayed(
                      const Duration(seconds: 0),
                      () => _showDialogDeleteQuestion(
                          context, _cubit.questionModel.id!));
                },
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(R.drawable.ic_trash2, width: 24, height: 24),
                      SizedBox(width: 8),
                      Text(R.string.delete_question.tr(),
                          style: TextStyle(
                              color: R.color.white,
                              fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
                value: 'Doge');
          },
        );
      },
    );
  }

  Widget _buildDoctorItemInQuestionItem(Answer? answer) {
    if (answer == null) return Container();
    bool isDoctorAnswer = !answer.account!.code!.contains("Patient") &&
        answer.accountId != _cubit.userInfo!.accountId;
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
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(90),
                    color: R.color.grayBorder),
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
                              DateTime.fromMillisecondsSinceEpoch(
                                  answer.createDateTime! * 1000),
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
              answer.accountId == _cubit.userInfo!.accountId
                  ? _buildDeleteComment(answer)
                  : Container(),
            ],
          ),
          SizedBox(height: 10),
          if (isDoctorAnswer) WidgetHtmlText(answer.body),
          if (!isDoctorAnswer)
            Text(
              answer.body ?? '',
              style: TextStyle(
                color: R.color.black,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          SizedBox(height: 8),
          if (isDoctorAnswer)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: RatingBar.builder(
                ignoreGestures: _cubit.ignoreGestures,
                itemSize: 20,
                initialRating: answer.rateAnswer != null
                    ? answer.rateAnswer!.rate.toDouble()
                    : 0,
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemPadding: const EdgeInsets.only(right: 5),
                itemBuilder: (context, _) => Icon(
                  CupertinoIcons.star_fill,
                  color: R.color.orange,
                ),
                onRatingUpdate: (rating) {
                  _cubit.ratingComment(
                    answer.id!,
                    rate: rating.toInt(),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  _buildDeleteComment(Answer answer) {
    if (_cubit.questionModel.status == 0) return Container();
    if (_cubit.questionModel.accountId != _cubit.userInfo?.accountId)
      return Container();
    return PopupMenuButton(
      color: R.color.color0xffFF5552,
      child: Icon(Icons.more_vert, size: 24, color: R.color.black54),
      itemBuilder: (context) {
        return List.generate(1, (index) {
          return PopupMenuItem<String>(
              height: 30,
              padding: EdgeInsets.zero,
              onTap: () {
                Future.delayed(const Duration(seconds: 0),
                    () => _showDialogDeleteComment(context, answer.id!));
              },
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(R.drawable.ic_trash2, width: 24, height: 24),
                    SizedBox(width: 8),
                    Text(R.string.delete_comment.tr(),
                        style: TextStyle(
                            color: R.color.white, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
              value: 'Doge');
        });
      },
    );
  }

  _buildListComment() {
    return _cubit.questionModel.answers!.isEmpty
        ? Container()
        : Expanded(
            child: ListView.builder(
              // separatorBuilder: (context, index) {
              //   return Divider(height: 0.0);
              // },
              itemCount: _cubit.questionModel.answers?.length ?? 0,
              shrinkWrap: true,
              controller: _cubit.commentScrollController,
              padding: EdgeInsets.zero,
              physics: AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, position) {
                return _buildDoctorItemInQuestionItem(
                    _cubit.questionModel.answers != null
                        ? _cubit.questionModel.answers![position]
                        : null);
              },
            ),
          );
  }

  _enterAnswer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlockBottomSheet(
        title: 'Nôi dung bình luận',
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 15),
              TextField(
                minLines: 16,
                maxLines: 16,
                style: TextStyle(
                  fontSize: 18.0,
                  color: R.color.black,
                ),
                decoration: InputDecoration(
                    counterText: '',
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: R.color.grayBorder, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    hintStyle: TextStyle(color: R.color.gray, fontSize: 18),
                    hintText: R.string.add_comment.tr(),
                    fillColor: R.color.white),
                controller: _controller,
              ),
              SizedBox(height: 25),
              ButtonWidget(
                title: "Gửi",
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  _buildCommentTextBox(BuildContext context) {
    if (_cubit.questionModel.status == 0) return Container();
    if (_cubit.questionModel.accountId != _cubit.userInfo?.accountId)
      return Container();
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 24),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              minLines: 1,
              maxLines: 6,
              style: TextStyle(
                fontSize: 18.0,
                color: R.color.black,
              ),
              // onTap: () {
              //   _enterAnswer(context);
              // },
              // readOnly: true,
              decoration: InputDecoration(
                counterText: '',
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: R.color.grayBorder, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                hintStyle: TextStyle(color: R.color.gray, fontSize: 18),
                hintText: R.string.add_comment.tr(),
                fillColor: R.color.white,
              ),
              controller: _controller,
            ),
          ),
          SizedBox(width: 12),
          FloatingActionButton(
            backgroundColor: R.color.greenGradientBottom,
            child: Image.asset(
              R.drawable.ic_send,
              width: 30,
              height: 30,
            ),
            onPressed: () async {
              await _submitData();
            },
          ),
        ],
      ),
    );
  }

  _submitData() async {
    if (!_cubit.isClickSend) {
      _cubit.setClickSend();
      if (_controller.text.isNotEmpty) {
        Utils.hideKeyboard(context);
        await _cubit.sendComment(_controller.text);
        // Future.delayed(Duration(milliseconds: 400), (){
        //    _cubit.getQuestionById();
        // });

        _controller.clear();
      } else {
        Message.showToastMessage(context, R.string.input_comment_required.tr());
      }
    }
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
                          style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 20,
                              fontWeight: FontWeight.w700)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                          R.string.confirm_delete_question_subtitle.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w400)),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 16),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(200),
                                        color: R.color.grayBorder),
                                    child: Center(
                                      child: Text(R.string.back.tr(),
                                          style: TextStyle(
                                              color: R.color.textDark,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600)),
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
                                        style: TextStyle(
                                            color: R.color.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600)),
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
                          style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 20,
                              fontWeight: FontWeight.w700)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(R.string.confirm_delete_comment_subtitle.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w400)),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 16),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(200),
                                        color: R.color.grayBorder),
                                    child: Center(
                                      child: Text(R.string.back.tr(),
                                          style: TextStyle(
                                              color: R.color.textDark,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600)),
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
                                        style: TextStyle(
                                            color: R.color.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600)),
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
