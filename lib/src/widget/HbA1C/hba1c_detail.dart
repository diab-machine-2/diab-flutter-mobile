import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:loadmore/loadmore.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/bloc/HbA1C/HbA1C_bloc.dart';
import 'package:medical/src/modal/HbA1C/HbA1C_Input.dart';
import 'package:medical/src/widget/HbA1C/hba1c_detail_tabbar.dart';
import 'package:medical/src/widget/components/load_more.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';

class HbA1CDetailController extends StatefulWidget {
  HbA1CDetailController({Key key}) : super(key: key);
  @override
  HbA1CDetailControllerState createState() => HbA1CDetailControllerState();
}

class HbA1CDetailControllerState extends State<HbA1CDetailController>
    with AutomaticKeepAliveClientMixin<HbA1CDetailController> {
  @override
  bool get wantKeepAlive => true;

  ScrollController _scrollController = ScrollController();

  BuildContext currentContext;

  int periodFilterType = 1;

  int page = 1;
  bool hasMore = false;
  bool isLoading = false;

  @override
  void initState() {
    periodFilterType = Hba1cDetailTabbarController.of(context).periodFilterType;
    super.initState();
    TrackingManager.analytics.setCurrentScreen(screenName: 'HbA1C Detail');
  }

  reloadData(int periodFilter) {
    _scrollController.jumpTo(0);
    periodFilterType = periodFilter;
    refresh();
  }

  Future<bool> _loadMore() async {
    if (isLoading || !hasMore) {
      return true;
    } else {
      isLoading = true;
      BlocProvider.of<HbA1CBloc>(currentContext).add(FetchInputHbA1C(
          currentDateTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          periodFilterType: periodFilterType,
          page: page));
    }
    return true;
  }

  Future<bool> refresh() async {
    page = 1;
    BlocProvider.of<HbA1CBloc>(currentContext).add(FetchInputHbA1C(
        currentDateTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        periodFilterType: periodFilterType,
        page: 1));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider<HbA1CBloc>(
        create: (context) => HbA1CBloc(),
        child: BlocBuilder<HbA1CBloc, HbA1CState>(
            builder: (BuildContext context, HbA1CState state) {
          currentContext = context;
          List<InputHbA1CModel> model;
          if (state is HbA1CInitial) {
            BlocProvider.of<HbA1CBloc>(context).add(FetchInputHbA1C(
                currentDateTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                periodFilterType: periodFilterType,
                page: 1));
          }
          if (state is HbA1CError) {
            Message.showToastMessage(context, state.message);
          }
          if (state is HbA1CDetailLoaded) {
            model = state.inputHbA1CModel;
            hasMore = state.hasMore;
            if (hasMore) {
              page += 1;
            }
            isLoading = false;
          }
          return RefreshIndicator(
              onRefresh: refresh,
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
                              controller: _scrollController,
                              physics: AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.only(bottom: 100, top: 10),
                              itemCount: model.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    print(model[index]);
                                    Navigator.pushNamed(context, '/add_hba1c',
                                        arguments: {
                                          'type': 'update',
                                          'id': model[index].id
                                        });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: 16, left: 16, top: 16),
                                    child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            color: R.color.white),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                    convertToUTC(
                                                        model[index].date,
                                                        'dd/MM/yyyy'),
                                                    style: TextStyle(
                                                        fontFamily: 'Viga',
                                                        color: R.color.textDark,
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w400)),
                                                Container(
                                                    height: 26,
                                                    padding: EdgeInsets.only(
                                                        left: 14, right: 14),
                                                    decoration: BoxDecoration(
                                                        color: toColor(model[index]
                                                            .backgroundColor),
                                                        border: Border.all(
                                                            color: model[index].borderColor ==
                                                                    'None'
                                                                ? R.color
                                                                    .transparent
                                                                : toColor(model[index]
                                                                    .borderColor),
                                                            width: model[index]
                                                                        .borderColor ==
                                                                    'None'
                                                                ? 0
                                                                : 1),
                                                        borderRadius: BorderRadius.only(
                                                            topLeft: Radius.circular(13),
                                                            topRight: Radius.circular(13),
                                                            bottomLeft: Radius.circular(13))),
                                                    child: Center(
                                                      child: Text(
                                                          model[index].type,
                                                          style: TextStyle(
                                                              color: toColor(
                                                                  model[index]
                                                                      .fontColor),
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600)),
                                                    ))
                                              ],
                                            ),
                                            SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text('HbA1C',
                                                    style: TextStyle(
                                                        color: R.color.black,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w400)),
                                                Row(
                                                  children: [
                                                    Text(
                                                        model[index]
                                                            .hbA1C
                                                            .toString()
                                                            .split('.')
                                                            .join(','),
                                                        style: TextStyle(
                                                            fontFamily: 'Viga',
                                                            color: toColor(model[
                                                                    index]
                                                                .percentColor),
                                                            fontSize: 24,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400)),
                                                    Text(' %',
                                                        style: TextStyle(
                                                            color: toColor(model[
                                                                    index]
                                                                .percentColor),
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500))
                                                  ],
                                                )
                                              ],
                                            ),
                                            SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text('Đuờng huyết',
                                                    style: TextStyle(
                                                        color: R.color.black,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w400)),
                                                Row(
                                                  children: [
                                                    Text(
                                                        model[index]
                                                            .glucose
                                                            .round()
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontFamily: 'Viga',
                                                            color: R.color.black,
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400)),
                                                    SizedBox(
                                                      width: 2,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 2.0),
                                                      child: Text(
                                                          '(' +
                                                              model[index]
                                                                  .unit
                                                                  .toString() +
                                                              ')',
                                                          style: TextStyle(
                                                              color:
                                                                  R.color.black,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400)),
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                            model[index].description != null
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
                                                          Text('Ghi chú: ',
                                                              style: TextStyle(
                                                                  color:
                                                                      R.color.textDark,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700)),
                                                          Expanded(
                                                            child: Text(
                                                                model[index]
                                                                    .description,
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
                                                                        .ellipsis),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  )
                                                : SizedBox()
                                          ]),
                                        )),
                                  ),
                                );
                              },
                            ))),
              ));
        }));
  }
}
