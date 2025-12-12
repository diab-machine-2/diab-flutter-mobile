import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/lesson_module_response.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/question_answer/all_question_answer/model/question_model.dart';
import 'package:medical/src/widget/question_answer/all_question_answer/widget/make_question_header.dart';
import 'package:medical/src/widget/question_answer/all_question_answer/widget/question_item.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'all_question_answer.dart';

class AllQuestionAnswerPage extends StatefulWidget {
  const AllQuestionAnswerPage({Key? key}) : super(key: key);

  @override
  _AllQuestionAnswerPageState createState() => _AllQuestionAnswerPageState();
}

class _AllQuestionAnswerPageState extends State<AllQuestionAnswerPage>
    with AutomaticKeepAliveClientMixin, Observer {
  late AllQuestionAnswerCubit _cubit;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _questionScrollController = ScrollController();

  var userInfo = AppSettings.userInfo;

  @override
  void initState() {
    super.initState();
    Observable.instance.addObserver(this);
    final AppRepository appRepository = AppRepository();
    _cubit = AllQuestionAnswerCubit(appRepository);
    _questionScrollController.addListener(_scrollListener);
  }

  @override
  void update(Observable observable, String? notifyName,
      Map<dynamic, dynamic>? map) async {
    if (notifyName == 'update_all_question') {
      // if (map != null) {
      //   String? id = map['id'];
      //   String? commentId = map['commentId'];
      //   QuestionModel? question = map['question'];
      //   if (id != null && commentId != null) {
      //     _cubit.deleteCommentLocal(id, commentId);
      //   } else if (id != null && commentId == null) {
      //     _cubit.deleteQuestionLocal(id);
      //   } else if (question != null) {
      //     _cubit.updateQuestionsLocal(question);
      //   } else {
      //     _cubit.controller.requestRefresh();
      //     _cubit.refreshData();
      //   }
      // } else {
      await refresh();
      //}
    }
  }

  @override
  void dispose() {
    Observable.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocListener<AllQuestionAnswerCubit, AllQuestionAnswerState>(
          listener: (context, state) {
            if (state is AllQuestionAnswerLoading) {
              BotToast.showLoading();
            } else {
              BotToast.closeAllLoading();
              if (state is AllQuestionAnswerSuccess ||
                  state is AllQuestionAnswerFailure) {
                _cubit.controller.refreshCompleted();
              }
            }
          },
          child: BlocBuilder<AllQuestionAnswerCubit, AllQuestionAnswerState>(
            builder: (context, state) {
              return _buildPage(context, state);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, AllQuestionAnswerState state) {
    final media = MediaQuery.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLessonModule(context),
        Expanded(
          child: Container(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            color: R.color.greenbg,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMakeQuestion(),
                SizedBox(height: 8),
                _buildQuestionList(state),
                Visibility(
                  visible: state is LoadmoreAllQuestionAnswerLoading,
                  child: Container(
                    margin: EdgeInsets.only(top: 16, bottom: 8 + media.padding.bottom / 2),
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(),
                  ),
                ),
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
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(10.0)),
        boxShadow: [
          BoxShadow(
              blurRadius: 1, color: R.color.grayBorder, offset: Offset(1, 3))
        ],
        color: Colors.white,
      ),
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            R.string.view_by_topic.tr(),
            style: TextStyle(
                color: R.color.black,
                fontWeight: FontWeight.w400,
                fontSize: 14),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              InkWell(
                onTap: () {
                  animateToIndex(_cubit.currentLessonModule - 1);
                },
                child: Icon(
                  Icons.chevron_left_rounded,
                  size: 28,
                  color: (_cubit.currentLessonModule) <= 0
                      ? R.color.captionColorGray
                      : R.color.greenGradientBottom,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _scrollController,
                  child: Row(
                    children:
                        List.generate(_cubit.lessonModules.length, (index) {
                      LessonModuleItem lessonModule =
                          _cubit.lessonModules[index];
                      if (lessonModule.name != null)
                        return _buildLessonModuleItem(
                            item: lessonModule.name ?? '',
                            isSelected: _cubit.listSelectedLessonModule[index],
                            onSelect: () async {
                              await TrackingManager.logEvent(
                                name: 'component_clicked',
                                parameters: {
                                  "screen_name": 'qna_home',
                                  'component_name': 'list_filter_qna',
                                  'filter_title': '${lessonModule.name}',
                                },
                              );
                              _cubit.onSelectLessonModule(index);
                            });
                      return SizedBox();
                    })
                          ..add(SizedBox(
                              width: _cubit.lessonModules.isEmpty
                                  ? MediaQuery.of(context).size.width - 96 * 2
                                  : 0)),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  if (_cubit.currentLessonModule == null) return;
                  animateToIndex(_cubit.currentLessonModule + 1);
                },
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 28,
                  color: (_cubit.currentLessonModule) >=
                          (_cubit.lessonModules.length - 1)
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

  _buildLessonModuleItem({
    required String item,
    required bool isSelected,
    VoidCallback? onSelect,
  }) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(right: 8),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? R.color.greenGradientBottom : R.color.grayBorder,
          border: isSelected
              ? Border.all(color: R.color.greenGradientBottom)
              : null,
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

  _buildMakeQuestion() {
    return MakeQuestionHeader(
      callback: () async {
        // if(userInfo?.isUserFree == true) {
        //   NavigationUtil.showUpdateRequirePopup(context: context, title: R.string.ask_doctor.tr());
        //   return;
        // }
        var result = await Navigator.pushNamed(
            context, NavigatorName.make_question,
            arguments: {'lessonModuleItems': _cubit.allLessonModules});
        if (result != null) {
          await refresh();
          Observable.instance.notifyObservers([],
              notifyName: "update_my_question",
              map: {'question': _cubit.questions.first});
        }
      },
    );
  }

  _buildQuestionList(AllQuestionAnswerState state) {
    return Expanded(
      child: SmartRefresher(
        controller: _cubit.controller,
        onRefresh: () => _cubit.refreshData(),
        child: _cubit.questions.isNotEmpty
            ? ListView.builder(
                itemCount: _cubit.questions.length,
                shrinkWrap: true,
                controller: _questionScrollController,
                itemBuilder: (context, position) {
                  return _buildQuestionItem(
                      _cubit.questions[position], position);
                },
              )
            : (state is AllQuestionAnswerSuccess ||
                    state is AllQuestionAnswerFailure)
                ? _buildEmpty()
                : Container(),
      ),
    );
  }

  void _scrollListener() async {
    if (_questionScrollController.offset >=
            _questionScrollController.position.maxScrollExtent &&
        !_questionScrollController.position.outOfRange) {
      //reach the bottom
      await TrackingManager.logEvent(
        name: 'component_loadmore',
        parameters: {
          "screen_name": 'qna_home',
          'component_name': 'list_qna',
          'page_index': _cubit.page + 1,
        }
      );
      await _cubit.loadmore();
    }
    if (_questionScrollController.offset <=
            _questionScrollController.position.minScrollExtent &&
        !_questionScrollController.position.outOfRange) {
      //reach the top
    }
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
              style: TextStyle(
                  color: R.color.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }

  _buildQuestionItem(QuestionModel questionModel, int position) {
    return QuestionItem(
      questionModel: questionModel,
      currentAccountId: _cubit.userInfo!.accountId!,
      lessonModules: _cubit.lessonModules,
      callbackDetail: () async {
        await TrackingManager.logEvent(
          name: 'component_clicked',
          parameters: {
            "screen_name": 'qna_home',
            'component_name': 'list_qna_item',
            'object_id': questionModel.id,
            'object_title': questionModel.body,
          },
        );
        await TrackingManager.logEvent(
          name: 'select_content',
          parameters: {
            "screen_name": 'qna_home',
            "content_type": 'qna doctor',
            "item_id": questionModel.id,
            "item_name": questionModel.body,
            "index": position,
          },
        );
        var result = await Navigator.pushNamed(
            context, NavigatorName.question_detail,
            arguments: {'questionModel': questionModel, 'isAll': true});
        if (result != null) {
          //    await refresh();
          //    Observable.instance.notifyObservers([], notifyName: "update_my_question");

          // if (result is Map) {
          //   var type = result['type'];
          //   var id = result['id'];
          //   if (type == 'question') {
          //     _cubit.deleteQuestionLocal(id);
          //     Observable.instance.notifyObservers([], notifyName : "update_my_question", map: {'id': id});
          //   } else if (type == 'comment') {
          //     _cubit.deleteCommentLocal(questionModel.id!, id);
          //     Observable.instance.notifyObservers([], notifyName : "update_my_question", map: {'id': questionModel.id!, 'commentId': id});
          //   }
          // } else if (result is QuestionModel) {
          //   _cubit.updateQuestionsLocal(result);
          //   Observable.instance.notifyObservers([], notifyName : "update_my_question", map: {'question': result});
          // }
        }
      },
      callbackDelete: (id) async {
        await _cubit.deleteQuestion(id);
        Navigator.pop(context);
      },
    );
  }

  refresh() async {
    _cubit.controller.requestRefresh();
    await _cubit.refreshData();
    _questionScrollController.jumpTo(0);
  }

  @override
  bool get wantKeepAlive => true;
}
