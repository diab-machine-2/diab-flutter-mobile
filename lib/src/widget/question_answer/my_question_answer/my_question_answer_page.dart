import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/question_answer/all_question_answer/model/question_model.dart';
import 'package:medical/src/widgets/network_image_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'my_question_answer.dart';

class MyQuestionAnswerPage extends StatefulWidget {
  const MyQuestionAnswerPage({Key? key}) : super(key: key);

  @override
  _MyQuestionAnswerPageState createState() => _MyQuestionAnswerPageState();
}

class _MyQuestionAnswerPageState extends State<MyQuestionAnswerPage> with AutomaticKeepAliveClientMixin {
  late MyQuestionAnswerCubit _cubit;
  final ScrollController _scrollController = ScrollController();
  final RefreshController _controller = RefreshController();
  final userInfo = AppSettings.userInfo;

  @override
  void initState() {
    super.initState();
    final AppRepository appRepository = AppRepository();
    _cubit = MyQuestionAnswerCubit(appRepository);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocListener<MyQuestionAnswerCubit, MyQuestionAnswerState>(
          listener: (context, state) {
            if (state is MyQuestionAnswerLoading) {
              BotToast.showLoading();
            } else {
              BotToast.closeAllLoading();
              if (state is MyQuestionAnswerSuccess || state is MyQuestionAnswerFailure) {
                _controller.refreshCompleted();
              }
            }
          },
          child: BlocBuilder<MyQuestionAnswerCubit, MyQuestionAnswerState>(
            builder: (context, state) {
              return _buildPage(context, state);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, MyQuestionAnswerState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLessonModule(context),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: R.color.greenbg,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildQuestionDoctor(),
                SizedBox(height: 8),
                _buildQuestionList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _buildLessonModule(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0)), // Set rounded corner radius
        boxShadow: [BoxShadow(blurRadius: 1, color: R.color.grayBorder, offset: Offset(1, 3))],
        color: Colors.white,
      ),
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            R.string.view_by_topic.tr(),
            style: TextStyle(color: R.color.black, fontWeight: FontWeight.w400, fontSize: 14),
          ),
          SizedBox(height: 6),
          Row(
            children: [
              InkWell(
                onTap: () {
                  if (_cubit.currentTopic == null) return;
                  animateToIndex(_cubit.currentTopic - 1);
                },
                child: Icon(
                  Icons.chevron_left_rounded,
                  size: 28,
                  color: (_cubit.currentTopic) <= 0 ? R.color.captionColorGray : R.color.greenGradientBottom,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _scrollController,
                  child: Row(
                    children: List.generate(_cubit.lessonModules.length, (index) {
                      return _buildTopicItem(
                          item: _cubit.lessonModules[index].name ?? '',
                          isSelected: _cubit.listSelectedLessonModule[index],
                          onSelect: () {
                            _cubit.onSelectLessonModule(index);
                          });
                    })
                      ..add(SizedBox(
                          width: _cubit.lessonModules.isEmpty ? MediaQuery.of(context).size.width - 96 * 2 : 0)),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  if (_cubit.currentTopic == null) return;
                  animateToIndex(_cubit.currentTopic + 1);
                },
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 28,
                  color: (_cubit.currentTopic) >= (_cubit.lessonModules.length - 1)
                      ? R.color.captionColorGray
                      : R.color.greenGradientBottom,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void animateToIndex(int index, {bool refresh = true}) {
    if (_cubit.lessonModules.isEmpty) return;
    if (index < 0) {
      index = 0;
      refresh = false;
    }
    if (index >= _cubit.lessonModules.length) {
      index = _cubit.lessonModules.length - 1;
      refresh = false;
    }
    final double newPosition = index * 96 + (6 * index.toDouble());
    _scrollController.animateTo(
      newPosition,
      duration: const Duration(milliseconds: 400),
      curve: Curves.ease,
    );
    if (refresh) {
      _cubit.onAnimate(index);
    }
  }

  _buildTopicItem({
    required String item,
    required bool isSelected,
    VoidCallback? onSelect,
  }) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(right: 8),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? R.color.greenGradientBottom : R.color.grayBorder,
          border: isSelected ? Border.all(color: R.color.greenGradientBottom) : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              item,
              style: TextStyle(
                color: isSelected ? R.color.white : R.color.black,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildQuestionDoctor() {
    return GestureDetector(
      onTap: () async {
        await Navigator.pushNamed(context, NavigatorName.make_question,
            arguments: {'lessonModuleItems': _cubit.lessonModules});
        _cubit.getQuestions(isShowLoading: true);
      },
      child: Container(
        height: 78,
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Container(
                height: 66,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  color: R.color.white,
                  elevation: 2,
                  child: Container(
                    padding: EdgeInsets.all(18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 32),
                        Text(
                          R.string.ask_doctor.tr(),
                          style:
                              TextStyle(color: R.color.greenGradientBottom, fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        Image.asset(R.drawable.ic_right, width: 18, height: 18, color: R.color.greenGradientBottom),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 8,
              bottom: 5,
              child: Image.asset(R.drawable.ic_doctor, width: 66, height: 66),
            ),
          ],
        ),
      ),
    );
  }

  _buildQuestionList() {
    return Expanded(
      child: SmartRefresher(
        controller: _controller,
        onRefresh: () => _cubit.refreshData(),
        child: _cubit.questions.isNotEmpty
            ? ListView.builder(
                itemCount: _cubit.questions.length,
                shrinkWrap: true,
                itemBuilder: (context, position) {
                  return _buildQuestionItem(_cubit.questions[position]);
                },
              )
            : _buildEmpty(),
      ),
    );
  }

  _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 32),
      child: Column(
        children: [
          Image.asset(R.drawable.img_question_empty),
          SizedBox(height: 20),
          Text(R.string.question_empty.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(color: R.color.textDark, fontSize: 15, fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }

  _buildQuestionItem(QuestionModel questionModel) {
    return GestureDetector(
      onTap: () async {
        var result = await Navigator.pushNamed(context, NavigatorName.question_detail,
            arguments: {'questionModel': questionModel});
        if (result != null) {
          if (result is Map) {
            var type = result['type'];
            var id = result['id'];
            if (type == 'question') {
              _cubit.deleteQuestionLocal(id);
            } else if (type == 'comment') {
              _cubit.deleteCommentLocal(questionModel.id!, id);
            }
          } else if (result is QuestionModel) {
            _cubit.updateQuestions(result);
          }
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        color: R.color.white,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        elevation: 2,
        child: questionModel.accountId == userInfo?.accountId
            ? Slidable(
                actionPane: SlidableDrawerActionPane(),
                secondaryActions: [
                  IconSlideAction(
                    color: R.color.color0xffFF5552,
                    iconWidget: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(R.drawable.ic_trash2, width: 24, height: 24),
                          SizedBox(height: 8),
                          Text(R.string.delete_question.tr(),
                              style: TextStyle(color: R.color.white, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                    onTap: () {
                      _showDialogDelete(context, questionModel.id!);
                    },
                  ),
                ],
                child: _buildQuestionItemInCard(questionModel),
              )
            : _buildQuestionItemInCard(questionModel),
      ),
    );
  }

  _buildQuestionItemInCard(QuestionModel questionModel) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderItem(questionModel),
          SizedBox(height: 12),
          _buildTitleItem(questionModel),
          SizedBox(height: (questionModel.answers != null && questionModel.answers!.isNotEmpty) ? 16 : 0),
          Visibility(
            visible: questionModel.answers != null && questionModel.answers!.isNotEmpty,
            child: Divider(height: 0.5, color: R.color.grayBorder),
          ),
          SizedBox(height: 8),
          ListView.builder(
            itemCount: questionModel.answers?.length ?? 0,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, position) {
              return _buildDoctorItemInQuestionItem(
                  questionModel.answers != null ? questionModel.answers![position] : null);
            },
          ),
        ],
      ),
    );
  }

  _buildHeaderItem(QuestionModel questionModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: true ? R.color.greenGradientBottom : R.color.grayBorder,
            border: true ? Border.all(color: R.color.greenGradientBottom) : null,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            questionModel.lessonModule != null
                ? questionModel.lessonModule!.name ?? ''
                : _cubit.getLessonModule(questionModel.lessonModuleId ?? '').name ?? '',
            style: TextStyle(
              color: true ? R.color.white : R.color.black,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          _cubit.getStatus(questionModel.status ?? 0),
          style: TextStyle(
            color: _cubit.getColorStatus(questionModel.status ?? 0),
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
          Image.asset(R.drawable.ic_right, width: 14, height: 14, color: R.color.greenGradientBottom),
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
                            onTap: () async {
                              await _cubit.deleteQuestion(id);
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

  @override
  bool get wantKeepAlive => true;
}
