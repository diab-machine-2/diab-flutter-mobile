import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:loadmore/loadmore.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/weight/weight_bloc.dart';
import 'package:medical/src/modal/bmi/weight_input.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Bmi/bmi_detail_tabbar.dart';
import 'package:medical/src/widget/components/load_more.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../utils/utils.dart';

class BmiDetailController extends StatefulWidget {
  BmiDetailController({Key? key}) : super(key: key);
  @override
  BmiDetailControllerState createState() => BmiDetailControllerState();
}

class BmiDetailControllerState extends State<BmiDetailController>
    with AutomaticKeepAliveClientMixin<BmiDetailController> {
  @override
  bool get wantKeepAlive => true;

  late BuildContext currentContext;
  ScrollController _scrollController = ScrollController();

  int page = 1;
  bool? hasMore = false;
  bool isLoading = false;
  int periodFilterType = 1;

  @override
  void initState() {
    periodFilterType = BmiDetailTabbarController.of(context)!.periodFilterType;
    super.initState();
    initializeDateFormatting();
  }

  reloadData(int periodFilter) {
    _scrollController.jumpTo(0);
    periodFilterType = periodFilter;
    _refresh();
  }

  Future<bool> _loadMorePage() async {
    if (isLoading || !hasMore!) {
      return true;
    } else {
      isLoading = true;
      BlocProvider.of<WeightBloc>(currentContext).add(FetchInputWeight(
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
    BlocProvider.of<WeightBloc>(currentContext).add(FetchInputWeight(
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
    return BlocProvider<WeightBloc>(
        create: (context) => WeightBloc(),
        child: BlocBuilder<WeightBloc, WeightState>(
            builder: (BuildContext context, WeightState state) {
          currentContext = context;
          List<InputWeightModel>? model;
          if (state is WeightInitial) {
            BlocProvider.of<WeightBloc>(context).add(FetchInputWeight(
                currentDateTime:
                    (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
                periodFilterType: periodFilterType.toString(),
                page: 1));
          }
          if (state is WeightError) {
            Message.showToastMessage(context, state.message);
          }
          if (state is WeightLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (state is WeightAllLoaded) {
            model = state.inputWeightModel;
            hasMore = state.hasMore;
            if (hasMore!) {
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
                          image: AssetImage(R.drawable.bg_detail),
                          fit: BoxFit.cover,
                        )),
                        child: LoadMore(
                            onLoadMore: _loadMorePage,
                            isFinish: !hasMore!,
                            whenEmptyLoad: false,
                            delegate: CustomLoadMoreDelegate(),
                            textBuilder: DefaultLoadMoreTextBuilder.english,
                            child: ListView.builder(
                              controller: _scrollController,
                              physics: AlwaysScrollableScrollPhysics(),
                              itemCount: model.length,
                              itemBuilder: (BuildContext context, int index) {
                                final element = model![index];
                                final previousElement =
                                    index == 0 ? null : model[index - 1];

                                final showDate = previousElement == null
                                    ? true
                                    : (convertCustomDate(element.date!) !=
                                        convertCustomDate(
                                            previousElement.date!));
                                return GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, NavigatorName.add_bmi,
                                          arguments: {
                                            'type': 'update',
                                            'id': element.id,
                                          });
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        showDate
                                            ? Padding(
                                                padding: EdgeInsets.only(
                                                    left: 16,
                                                    right: 16,
                                                    top: 16),
                                                child: Text(
                                                  convertCustomDate(
                                                      model[index].date!),
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              )
                                            : SizedBox(),
                                        Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  color: R.color.white),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Column(children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top:
                                                                            6.0),
                                                                child: Text(
                                                                    '${R.string.bmi.tr()}: ',
                                                                    style: TextStyle(
                                                                        color: R
                                                                            .color
                                                                            .textDark,
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.w400)),
                                                              ),
                                                              Text(
                                                                  roundNumber(model[
                                                                          index]
                                                                      .bmi!),
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Viga',
                                                                      color: toColor(
                                                                          model[index]
                                                                              .bmiColorCode),
                                                                      fontSize:
                                                                          24,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400)),
                                                            ],
                                                          ),
                                                          Container(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 16,
                                                                    right: 16,
                                                                    top: 8,
                                                                    bottom: 8),
                                                            decoration: BoxDecoration(
                                                                color: toColor(
                                                                    model[index]
                                                                        .bmiBackgroundColorCode),
                                                                borderRadius: BorderRadius.only(
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            13),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            13),
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                            13))),
                                                            child: Text(
                                                                '${element.bmiText}',
                                                                style: TextStyle(
                                                                    color: toColor(
                                                                        model[index]
                                                                            .bmiTextColorCode),
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700)),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 8),
                                                      Row(
                                                        children: [
                                                          Text('${R.string.can_nang.tr()}:',
                                                              style: TextStyle(
                                                                  color: R.color
                                                                      .black,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400)),
                                                          SizedBox(width: 4),
                                                          Text(
                                                              Utils.showValue(
                                                                  model[index]
                                                                      .weight ?? 0),
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Viga',
                                                                  color: R.color
                                                                      .black,
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400)),
                                                          SizedBox(width: 4),
                                                          Text(R.string.kg.tr(),
                                                              style: TextStyle(
                                                                  color: R.color
                                                                      .black,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400)),
                                                          SizedBox(width: 8),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    bottom:
                                                                        10.0),
                                                            child: Text('.',
                                                                style: TextStyle(
                                                                    color: R
                                                                        .color
                                                                        .black,
                                                                    fontSize:
                                                                        30,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700)),
                                                          ),
                                                          SizedBox(width: 8),
                                                          Text('${R.string.waist.tr()}:',
                                                              style: TextStyle(
                                                                  color: R.color
                                                                      .black,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400)),
                                                          SizedBox(width: 4),
                                                          Text(
                                                              '${model[index].waist!.toInt()}',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Viga',
                                                                  color: toColor(
                                                                      model[index]
                                                                          .waistColorCode),
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400)),
                                                          SizedBox(width: 4),
                                                          Text(R.string.cm.tr(),
                                                              style: TextStyle(
                                                                  color: R.color
                                                                      .black,
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
                                                                element.date!,
                                                                'HH:mm') +
                                                            ',',
                                                        style: TextStyle(
                                                            color:
                                                                R.color.black,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                                      SizedBox(width: 4),
                                                      Text(
                                                          element.timeFrameText!,
                                                          style: TextStyle(
                                                              color:
                                                                  R.color.black,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400)),
                                                    ],
                                                  ),
                                                  element.note != '' &&
                                                          element.note != null
                                                      ? Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SizedBox(
                                                                height: 16),
                                                            Container(
                                                                height: 1,
                                                                color: R.color
                                                                    .color0xffEEEFF3),
                                                            SizedBox(
                                                                height: 16),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                    '${R.string.ghi_chu.tr()}: ',
                                                                    style: TextStyle(
                                                                        color: R
                                                                            .color
                                                                            .black,
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.w700)),
                                                                Text(
                                                                    element
                                                                        .note!,
                                                                    style: TextStyle(
                                                                        color: R
                                                                            .color
                                                                            .black,
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.w400)),
                                                              ],
                                                            ),
                                                          ],
                                                        )
                                                      : SizedBox()
                                                ]),
                                              )),
                                        ),
                                      ],
                                    ));
                              },
                            ))),
              ));
        }));
  }
}
