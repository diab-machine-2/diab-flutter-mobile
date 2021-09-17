import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:loadmore/loadmore.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/bloodPressure/bloodPressure_bloc.dart';
import 'package:medical/src/modal/blood_pressure/blood_pressure.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:medical/src/widget/BloodPressure/bloodPressure_detail_tabbar.dart';
import 'package:medical/src/widget/components/load_more.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class BloodPressureDetailController extends StatefulWidget {
  BloodPressureDetailController({Key key}) : super(key: key);
  @override
  BloodPressureDetailControllerState createState() =>
      BloodPressureDetailControllerState();
}

class BloodPressureDetailControllerState
    extends State<BloodPressureDetailController>
    with AutomaticKeepAliveClientMixin<BloodPressureDetailController> {
  @override
  bool get wantKeepAlive => true;

  BuildContext currentContext;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  int page = 1;
  bool hasMore = false;
  bool isLoading = false;
  int periodFilterType = 1;

  String bloodPressureID;

  @override
  void initState() {
    periodFilterType =
        BloodPressureDetailTabbarController.of(context).periodFilterType;
    bloodPressureID =
        BloodPressureDetailTabbarController.of(context).bloodPressureID;
    super.initState();
    initializeDateFormatting();
    DartNotificationCenter.subscribe(
        channel: 'BloodPressure_change_data',
        observer: this,
        onNotification: (_) {
          _refresh();
        });

    itemPositionsListener.itemPositions.addListener(() {
      final lastIndex = itemPositionsListener.itemPositions.value.last.index;
      final state = BlocProvider.of<BloodPressureBloc>(currentContext).state;
      if (state is BloodPressureDataLoaded) {
        final model = state.bloodPressureModel;
        if (model.length - 2 == lastIndex) {
          _loadMorePage();
        }
      }
    });

    TrackingManager.analytics
        .setCurrentScreen(screenName: 'Blood Pressure Detail');
  }

  @override
  void dispose() {
    DartNotificationCenter.unsubscribe(
        channel: 'BloodPressure_change_data', observer: this);
    super.dispose();
  }

  reloadData(int periodFilter) {
    itemScrollController.jumpTo(index: 0);
    periodFilterType = periodFilter;
    _refresh();
  }

  loadDataToID(int periodFilter) {
    periodFilterType = periodFilter;
    if (BloodPressureDetailTabbarController.of(context).bloodPressureID !=
        null) {
      setState(() {});
      _loadMorePage();
    }
    bloodPressureID =
        BloodPressureDetailTabbarController.of(context).bloodPressureID;
  }

  Future<bool> _loadMorePage() async {
    if (isLoading || !hasMore) {
      return true;
    } else {
      isLoading = true;
      BlocProvider.of<BloodPressureBloc>(currentContext)
          .add(FetchInputBloodPressure(
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
    BlocProvider.of<BloodPressureBloc>(currentContext)
        .add(FetchInputBloodPressure(
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
    return BlocProvider<BloodPressureBloc>(
        create: (context) => BloodPressureBloc(),
        child: BlocBuilder<BloodPressureBloc, BloodPressureState>(
            builder: (BuildContext context, BloodPressureState state) {
          currentContext = context;
          List<BloodPressureModel> model;
          if (state is BloodPressureInitial) {
            BlocProvider.of<BloodPressureBloc>(context).add(
                FetchInputBloodPressure(
                    currentDateTime:
                        (DateTime.now().millisecondsSinceEpoch ~/ 1000)
                            .toString(),
                    periodFilterType: periodFilterType.toString(),
                    page: 1));
          }
          if (state is BloodPressureError) {
            Message.showToastMessage(context, state.message);
          }
          if (state is BloodPressureLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (state is BloodPressureDataLoaded) {
            model = state.bloodPressureModel;
            hasMore = state.hasMore;
            if (hasMore) {
              page += 1;
            }
            isLoading = false;

            Future.delayed(const Duration(milliseconds: 500), () {
              final model = state.bloodPressureModel;
              for (int i = 0; i < model.length; i++) {
                if (model[i].id == bloodPressureID) {
                  BloodPressureDetailTabbarController.of(context)
                      .bloodPressureID = null;
                  itemScrollController.jumpTo(index: i);
                  Future.delayed(const Duration(seconds: 3), () {
                    setState(() {
                      bloodPressureID = null;
                    });
                  });
                }
              }
              if (BloodPressureDetailTabbarController.of(context)
                      .bloodPressureID !=
                  null) {
                _loadMorePage();
              }
            });
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
                              AssetImage('assets/images/detail_Background.png'),
                          fit: BoxFit.cover,
                        )),
                        child: ScrollablePositionedList.builder(
                          itemPositionsListener: itemPositionsListener,
                          itemScrollController: itemScrollController,
                          physics: AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.only(top: 16, bottom: 100),
                          itemCount: model.length,
                          itemBuilder: (context, index) {
                            final element = model[index];
                            final previousElement =
                                index == 0 ? null : model[index - 1];

                            final showDate = previousElement == null
                                ? true
                                : (convertCustomDate(element.date) !=
                                    convertCustomDate(previousElement.date));

                            return GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, '/add_bloodPressure',
                                      arguments: {
                                        'type': 'update',
                                        'id': element.id
                                      });
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: 16, right: 16, bottom: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      showDate
                                          ? Padding(
                                              padding: EdgeInsets.only(
                                                  top: 8, bottom: 10),
                                              child: Text(
                                                convertCustomDate(element.date),
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            )
                                          : SizedBox(),
                                      Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: bloodPressureID == null
                                                      ? R.color.white
                                                      : (bloodPressureID ==
                                                              element.id
                                                          ? R.color.red
                                                          : R.color.white),
                                                  width: 2),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              color: R.color.white),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.only(
                                                        left: 16,
                                                        right: 16,
                                                        top: 8,
                                                        bottom: 8),
                                                    decoration: BoxDecoration(
                                                        color: toColor(element
                                                            .backgroundColor),
                                                        // borderRadius: BorderRadius.circular(13))
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft:
                                                                    Radius
                                                                        .circular(
                                                                            13),
                                                                topRight: Radius
                                                                    .circular(
                                                                        13),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        13))),
                                                    child: Text(
                                                        element
                                                            .bloodPressureType,
                                                        style: TextStyle(
                                                            color: toColor(
                                                                element
                                                                    .fontColor),
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700)),
                                                  ),
                                                  SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      Text(
                                                          element.systolic
                                                              .toInt()
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Viga',
                                                              color: toColor(
                                                                  element
                                                                      .color),
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400)),
                                                      Text(' / ',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Viga',
                                                              color: toColor(
                                                                  element
                                                                      .color),
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400)),
                                                      Text(
                                                          element.diastolic
                                                              .toInt()
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Viga',
                                                              color: toColor(
                                                                  element
                                                                      .color),
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400)),
                                                      SizedBox(width: 4),
                                                      Text('mmHg',
                                                          style: TextStyle(
                                                              color:
                                                                  R.color.black,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400)),
                                                      SizedBox(width: 8),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                bottom: 10.0),
                                                        child: Text('.',
                                                            style: TextStyle(
                                                                color: R.color
                                                                    .black,
                                                                fontSize: 30,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700)),
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text(
                                                          element.pulseRate
                                                              .toInt()
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Viga',
                                                              color: toColor(
                                                                  element
                                                                      .color),
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400)),
                                                      SizedBox(width: 4),
                                                      Text('lần/phút',
                                                          style: TextStyle(
                                                              color:
                                                                  R.color.black,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400)),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Text(
                                                    convertToUTC(
                                                        element.date, 'HH:mm'),
                                                    style: TextStyle(
                                                        color: R.color.black,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                  Text(', ' + element.timeFrame,
                                                      style: TextStyle(
                                                          color: R.color.black,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w400)),
                                                ],
                                              ),
                                              element.reason != '' &&
                                                      element.reason != null
                                                  ? Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(height: 16),
                                                        Container(
                                                            height: 1,
                                                            color: R.color.color0xffEEEFF3),
                                                        SizedBox(height: 16),
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'Lý do: ',
                                                              style: TextStyle(
                                                                  color: R.color
                                                                      .black,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                element.reason,
                                                                style: TextStyle(
                                                                    color: R.color
                                                                        .black,
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    )
                                                  : SizedBox()
                                            ]),
                                          )),
                                    ],
                                  ),
                                ));
                          },
                        ))),
          );
        }));
  }
}
