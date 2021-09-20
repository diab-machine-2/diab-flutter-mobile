import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:loadmore/loadmore.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/exercrises/exercrises_bloc.dart';
import 'package:medical/src/modal/exercrises/exercrise_input.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Exercrises/exercrises_detail_tabbar.dart';
import 'package:medical/src/widget/components/load_more.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';

class ExercrisesDetailController extends StatefulWidget {
  ExercrisesDetailController({Key key}) : super(key: key);
  @override
  ExercrisesDetailControllerState createState() =>
      ExercrisesDetailControllerState();
}

class ExercrisesDetailControllerState extends State<ExercrisesDetailController>
    with AutomaticKeepAliveClientMixin<ExercrisesDetailController> {
  @override
  bool get wantKeepAlive => true;

  BuildContext currentContext;
  ScrollController scrollController = ScrollController();

  int page = 1;
  bool hasMore = false;
  bool isLoading = false;
  int periodFilterType = 1;

  @override
  void initState() {
    periodFilterType =
        ExercrisesDetailTabbarController.of(context).periodFilterType;
    super.initState();

    TrackingManager.analytics.setCurrentScreen(screenName: 'Exercise Detail');
  }

  reloadData(int periodFilter) {
    scrollController.jumpTo(0);
    periodFilterType = periodFilter;
    _refresh();
  }

  Future<bool> _loadMore() async {
    if (isLoading || !hasMore) {
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
    super.build(context);
    return BlocProvider<ExercrisesBloc>(
        create: (context) => ExercrisesBloc(),
        child: BlocBuilder<ExercrisesBloc, ExercrisesState>(
            builder: (BuildContext context, ExercrisesState state) {
          currentContext = context;
          List<InputDataExercriseModel> model;
          if (state is ExercrisesInitial) {
            BlocProvider.of<ExercrisesBloc>(context).add(FetchInputExercrises(
                currentDateTime:
                    (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
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
            if (hasMore) {
              page += 1;
            }
            isLoading = false;
          }

          return RefreshIndicator(
              onRefresh: _refresh,
              child: Scaffold(
                backgroundColor: R.color.backgroundColor,
                body: model == null
                    ? Center(child: CircularProgressIndicator())
                    : Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                          image:
                              AssetImage(R.drawable.detail_Background),
                          fit: BoxFit.cover,
                        )),
                        child: LoadMore(
                            onLoadMore: _loadMore,
                            isFinish: !hasMore,
                            whenEmptyLoad: false,
                            delegate: CustomLoadMoreDelegate(),
                            textBuilder: DefaultLoadMoreTextBuilder.english,
                            child: ListView.builder(
                              controller: scrollController,
                              physics: AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.only(bottom: 80, top: 10),
                              itemCount: model.length,
                              itemBuilder: (BuildContext context, int index) {
                                final item = model[index];
                                return Padding(
                                  padding: EdgeInsets.only(
                                      top: 16, left: 16, right: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(convertCustomDate(item.date),
                                          style: TextStyle(
                                              color: R.color.textDark,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700)),
                                      SizedBox(height: 16),
                                      ListView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          padding: EdgeInsets.all(0),
                                          itemCount: item.exerciseInput.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            final itemInput =
                                                item.exerciseInput[index];
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 16),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pushNamed(context,
                                                      NavigatorName.add_exercrises,
                                                      arguments: {
                                                        'type': 'update',
                                                        'id': itemInput.id
                                                      });
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                      color: R.color.white),
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.all(16),
                                                        child: Container(
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                  convertToUTC(
                                                                          itemInput
                                                                              .date,
                                                                          'HH:mm') +
                                                                      ', ' +
                                                                      itemInput
                                                                          .timeFrame,
                                                                  style: TextStyle(
                                                                      color:
                                                                          R.color.textDark,
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600)),
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                      '${formatNumber(itemInput.burnedCalorie)}',
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                              'Viga',
                                                                          color:
                                                                              R.color.green,
                                                                          fontSize:
                                                                              24,
                                                                          fontWeight:
                                                                              FontWeight.w400)),
                                                                  Text(' kcal',
                                                                      style: TextStyle(
                                                                          color: R.color
                                                                              .black,
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.w400))
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      ListView.separated(
                                                          physics:
                                                              NeverScrollableScrollPhysics(),
                                                          shrinkWrap: true,
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 0,
                                                                  right: 0,
                                                                  bottom: 8,
                                                                  top: 0),
                                                          itemCount: itemInput
                                                              .exercise.length,
                                                          separatorBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  int index) {
                                                            return Container(
                                                                height: 1,
                                                                color: R.color.grayBorder);
                                                          },
                                                          itemBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  int index) {
                                                            final itemInputExercrise =
                                                                itemInput
                                                                        .exercise[
                                                                    index];
                                                            print(itemInput
                                                                .exercise[index]
                                                                .imageUrl
                                                                .url);
                                                            return Container(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 16,
                                                                      right: 16,
                                                                      top: 8,
                                                                      bottom:
                                                                          8),
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              0),
                                                                  color: R.color
                                                                      .white),
                                                              child: Row(
                                                                children: [
                                                                  Stack(
                                                                      alignment:
                                                                          AlignmentDirectional
                                                                              .center,
                                                                      children: [
                                                                        Image.asset(
                                                                            R.drawable.bg_activity_empty,
                                                                            width:
                                                                                50,
                                                                            height:
                                                                                50),
                                                                        Image.network(
                                                                            itemInput.exercise[index].imageUrl.url ??
                                                                                '',
                                                                            width:
                                                                                35,
                                                                            height:
                                                                                35)
                                                                      ]),
                                                                  SizedBox(
                                                                    width: 12,
                                                                  ),
                                                                  Expanded(
                                                                      child:
                                                                          Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Text(
                                                                              itemInputExercrise.category,
                                                                              style: TextStyle(color: R.color.textDark, fontSize: 16, fontWeight: FontWeight.w600)),
                                                                          Row(
                                                                            children: [
                                                                              Text(formatNumber(itemInputExercrise.burnedCalorie), style: TextStyle(fontFamily: 'Viga', color: R.color.textDark, fontSize: 20, fontWeight: FontWeight.w400)),
                                                                              Padding(
                                                                                padding: EdgeInsets.only(top: 0, left: 4),
                                                                                child: Text(
                                                                                  itemInputExercrise.unit,
                                                                                  style: TextStyle(color: R.color.textDark, fontWeight: FontWeight.w400, fontSize: 16.0),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              8),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Expanded(
                                                                            child:
                                                                                Text(itemInputExercrise.name, style: TextStyle(color: R.color.primaryGreyColor, fontSize: 12, fontWeight: FontWeight.w400)),
                                                                          ),
                                                                          // SizedBox(
                                                                          //   width: 2,
                                                                          // ),
                                                                          Text(
                                                                            '${itemInputExercrise.duration.toInt().toString()} phút',
                                                                            style: TextStyle(
                                                                                color: R.color.primaryGreyColor,
                                                                                fontWeight: FontWeight.w400,
                                                                                fontSize: 12.0),
                                                                          ),
                                                                        ],
                                                                      )
                                                                    ],
                                                                  )),
                                                                ],
                                                              ),
                                                            );
                                                          }),
                                                      SizedBox(height: 8)
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                    ],
                                  ),
                                );
                              },
                            ))),
              ));
        }));
  }
}
