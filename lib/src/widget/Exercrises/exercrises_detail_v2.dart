import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loadmore/loadmore.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/exercrises/exercrises_bloc.dart';
import 'package:medical/src/modal/exercrises/exercrise_input.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/utils/app_log.dart';
import 'package:medical/src/widget/Exercrises/exercrises_detail_tabbar.dart';
import 'package:medical/src/widget/Exercrises/widget/filter_segment_button.dart';
import 'package:medical/src/widget/components/load_more.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/network_image_widget.dart';

import '../../utils/navigator_name.dart';
import 'widget/exercrises_list_card.dart';

class ExercrisesDetailV2 extends StatefulWidget {
  final int periodFilterType;

  ExercrisesDetailV2({Key? key, this.periodFilterType = 0}) : super(key: key);

  ExercrisesDetailV2State createState() => ExercrisesDetailV2State();
}

class ExercrisesDetailV2State extends State<ExercrisesDetailV2>
    with WidgetsBindingObserver, Observer {
  late BuildContext currentContext;
  ScrollController scrollController = ScrollController();

  int page = 1;
  bool? hasMore = false;
  bool isLoading = false;
  int periodFilterType = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    periodFilterType = widget.periodFilterType;

    final controller = ExercrisesDetailTabbarController.of(context);
    if (controller != null) {
      periodFilterType = controller.periodFilterType;
    } else {
      Console.log('ExercrisesDetailTabbarController is null');
    }
  }

  @override
  void update(
      Observable observable, String? notifyName, Map<dynamic, dynamic>? map) {
    if (notifyName == 'active_change_data_v2') {
      // overViewKey.currentState!.reloadData(periodFilterType);
    }
  }

  @override
  void dispose() {
    Observable.instance.removeObserver(this); // Hủy đăng ký observer
    scrollController.dispose(); // Hủy ScrollController nếu có
    super.dispose(); // Gọi super.dispose() để giải phóng tài nguyên
  }

  reloadData(int periodFilter) {
    if (scrollController.hasClients) {
      scrollController
          .jumpTo(0); // Chỉ gọi jumpTo nếu ScrollController đã được gắn
    }
    periodFilterType = periodFilter;
    _refresh();
  }

  void _goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      BotToast.showText(
        text: 'Opps! You can not go back',
        duration: Duration(seconds: 2),
        backgroundColor: R.color.black,
        textStyle: TextStyle(color: R.color.white),
      );
    }
  }

  Future<bool> _loadMore() async {
    if (isLoading || !hasMore!) {
      return true;
    } else {
      isLoading = true;
      BlocProvider.of<ExercrisesBloc>(currentContext).add(FetchInputExercrises(
        page: page,
        currentDateTime:
            (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
        periodFilterType: periodFilterType.toString(),
      ));
    }
    return true;
  }

  Future<bool> _refresh() async {
    page = 1;
    BlocProvider.of<ExercrisesBloc>(currentContext).add(FetchInputExercrises(
      page: 1,
      currentDateTime:
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      periodFilterType: periodFilterType.toString(),
    ));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _goBack();
        return false;
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: R.color.backgroundColorNew,
          appBar: AppBar(
            leading: IconButton(
                splashColor: R.color.transparent,
                highlightColor: R.color.transparent,
                icon: Icon(Icons.arrow_back, color: R.color.white),
                onPressed: _goBack),
            title: Transform(
              transform: Matrix4.translationValues(-20, 0.0, 0.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  R.string.exercrise_detail_v2_title.tr(),
                  style: TextStyle(
                      color: R.color.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w400),
                ),
              ),
            ),
            backgroundColor: R.color.transparent, //No more green
            elevation: 0.0, //Shadow gone
            flexibleSpace: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                    R.color.greenGradientMid,
                    R.color.greenGradientBottom
                  ])),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Message.showToastMessage(context,
                      R.string.exercrise_step_onboarding_action_btn.tr());
                },
                child: Text(
                  R.string.exercrise_step_onboarding_action_btn.tr(),
                  style: TextStyle(
                    color: R.color.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'sfpro',
                  ),
                ),
              ),
            ],
          ),
          body: _buildContainer(),
        ),
      ),
    );
  }

  Widget _buildContainer() {
    return Column(
      children: [
        // Thêm FilterSegmentButton ở đây
        FilterSegmentButton(
          initialFilterType: periodFilterType,
          onFilterChanged: (newFilterType) {
            setState(() {
              periodFilterType = newFilterType;
              reloadData(periodFilterType);
            });
          },
        ),
        Expanded(
          child: BlocProvider<ExercrisesBloc>(
            create: (context) => ExercrisesBloc(),
            child: BlocBuilder<ExercrisesBloc, ExercrisesState>(
                builder: (BuildContext context, ExercrisesState state) {
              currentContext = context;
              List<InputDataExercriseModel>? model;
              if (state is ExercrisesInitial) {
                BlocProvider.of<ExercrisesBloc>(context).add(
                    FetchInputExercrises(
                        currentDateTime:
                            (DateTime.now().millisecondsSinceEpoch ~/ 1000)
                                .toString(),
                        periodFilterType: periodFilterType.toString(),
                        page: 1));
              }
              if (state is ExercrisesError) {
                Message.showToastMessage(context, state.message);
              }
              if (state is ExercrisesLoading) {
                return Center(child: CircularProgressIndicator());
              }
              if (state is ExercrisesDataLoaded) {
                model = state.inputExercrisesModel;
                hasMore = state.hasMore;
                if (hasMore!) {
                  page += 1;
                }
                isLoading = false;
              }
              if (model == null || model.isEmpty) {
                return Center(
                  child: Text(
                    R.string.no_data_available.tr(),
                    style: TextStyle(color: R.color.textDark, fontSize: 16),
                  ),
                );
              }

              return RefreshIndicator(
                  onRefresh: _refresh,
                  child: Container(
                    color: R.color.transparent,
                    child: Container(
                        // decoration: BoxDecoration(
                        //     image: DecorationImage(
                        //   image: AssetImage(R.drawable.bg_detail),
                        //   fit: BoxFit.cover,
                        // )),
                        child: LoadMore(
                            onLoadMore: _loadMore,
                            isFinish: !hasMore!,
                            whenEmptyLoad: false,
                            delegate: CustomLoadMoreDelegate(),
                            textBuilder: DefaultLoadMoreTextBuilder.english,
                            child: ListView.builder(
                              controller: scrollController,
                              physics: AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.only(bottom: 80, top: 10),
                              itemCount: model.length,
                              itemBuilder: (BuildContext context, int index) {
                                if (model == null ||
                                    model.isEmpty ||
                                    model[index].exerciseInput.isEmpty) {
                                  return Center(
                                    child: Text(
                                      R.string.no_data_available.tr(),
                                      style: TextStyle(
                                          color: R.color.textDark,
                                          fontSize: 16),
                                    ),
                                  );
                                }
                                final item = model[index];
                                List<ListExercriseModel> exercises = [];
                                for (var item in item.exerciseInput) {
                                  exercises.addAll(item.exercise);
                                }
                                if (exercises.isEmpty) {
                                  return Center(
                                    child: Text(
                                      R.string.no_data_available.tr(),
                                      style: TextStyle(
                                          color: R.color.textDark,
                                          fontSize: 16),
                                    ),
                                  );
                                }
                                return Padding(
                                  padding: EdgeInsets.only(
                                      top: index == 0 ? 0 : 16,
                                      left: 16,
                                      right: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          convertToSectionTicketDate(
                                              item.date ?? 0, ''),
                                          style: TextStyle(
                                              color: R.color.textDark,
                                              fontSize: 20,
                                              fontFamily: 'sfpro',
                                              fontWeight: FontWeight.w700)),
                                      SizedBox(height: 16),
                                      ...item.exerciseInput.expand((input) {
                                        if (input.exercise.isEmpty) return [];
                                        return _buildExerciseItem(
                                          input.exercise,
                                          input.id ?? '',
                                          model?.length == 1,
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                );
                              },
                            ))),
                  ));
            }),
          ),
        ),
      ],
    );
  }

  _buildExerciseItem(
    List<ListExercriseModel> exercise,
    String exerciseInputId,
    bool isOnlyOne,
  ) {
    return exercise.map((e) {
      bool isFirst = exercise.indexOf(e) == 0;
      bool isLast = exercise.indexOf(e) == exercise.length - 1;

      return InkWell(
          onTap: () {
            debugPrint('Exercise Lenght: ${exercise.length}');
            Navigator.pushNamed(
              context,
              NavigatorName.exercrise_add_v2,
              arguments: {
                'isUpdate': true,
                'exerciseInputId': exerciseInputId,
                'isOnlyOne': isOnlyOne,
              },
            );
          },
          child: Container(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: R.color.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isFirst ? 16 : 0),
                topRight: Radius.circular(isFirst ? 16 : 0),
                bottomLeft: Radius.circular(isLast ? 16 : 0),
                bottomRight: Radius.circular(isLast ? 16 : 0),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(200),
                        child: Container(
                          width: 42.w,
                          height: 42.h,
                          padding: EdgeInsets.all(8),
                          color: R.color.main_1.withOpacity(0.8),
                          child: NetWorkImageWidget(
                            imageUrl: e.imageUrl.url ?? '',
                            width: 42.w,
                            height: 42.h,
                            isSelected: true,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          e.category ?? '',
                          style: TextStyle(
                            color: R.color.textDark,
                            fontSize: 18,
                            fontFamily: 'sfpro',
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.fiber_manual_record,
                            size: 10, color: R.color.primaryGreyColor),
                      ),
                      Text(
                        '${formatNumber(e.burnedCalorie)} ${e.unit}',
                        style: TextStyle(
                          color: R.color.primaryGreyColor,
                          fontSize: 14,
                          fontFamily: 'sfpro',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  formatNumber(e.duration),
                  style: TextStyle(
                    color: R.color.greenGradientBottom,
                    fontSize: 18,
                    fontFamily: 'sfpro',
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  R.string.minute.tr(),
                  style: TextStyle(
                    color: R.color.primaryGreyColor,
                    fontSize: 14,
                    fontFamily: 'sfpro',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ));
    }).toList();
  }
}
