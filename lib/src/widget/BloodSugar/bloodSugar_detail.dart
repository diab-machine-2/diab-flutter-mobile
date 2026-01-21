import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/firebase_tracking/kpi_glycemic_tracking.dart';
import 'package:medical/src/modal/glucose/glucose_input.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/bloc/glucose/glucose_bloc.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/BloodSugar/bloodSugar_detail_tabbar.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/gap_widget.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:easy_localization/easy_localization.dart';

class BloodSugarDetailController extends StatefulWidget {
  BloodSugarDetailController(
      {Key? key,
      this.initPeriodFilterType = 3,
      this.glucoseID,
      this.glucoseDistributionType})
      : super(key: key);
  final int initPeriodFilterType;
  final String? glucoseID;
  final int? glucoseDistributionType;
  @override
  BloodSugarDetailControllerState createState() =>
      BloodSugarDetailControllerState();
}

class BloodSugarDetailControllerState
    extends State<BloodSugarDetailController> {
  late BuildContext currentContext;

  //ScrollController _scrollController = ScrollController();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  int page = 1;
  bool? hasMore = false;
  bool isLoading = false;
  int periodFilterType = 3;

  String? glucoseID;

  @override
  void initState() {
    super.initState();
    periodFilterType =BloodSugarDetailTabbarController.of(context)?.periodFilterType ??
        widget.initPeriodFilterType;
    glucoseID = BloodSugarDetailTabbarController.of(context)?.glucoseID ??
        widget.glucoseID;
    initializeDateFormatting();

    itemPositionsListener.itemPositions.addListener(() {
      final lastIndex = itemPositionsListener.itemPositions.value.last.index;
      final GlucoseState state =
          BlocProvider.of<GlucoseBloc>(currentContext).state;
      if (state is GlucoseAlllLoaded) {
        final model = state.inputGlucoseModel;
        if (model.length - 2 == lastIndex) {
          _loadMore();
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void reloadData(int periodFilter) {
    periodFilterType = periodFilter;
    // itemScrollController.jumpTo(index: 0);
    _refresh();
  }

  void loadDataToID(int periodFilter) {
    periodFilterType = periodFilter;
    if (BloodSugarDetailTabbarController.of(context)!.glucoseID != null) {
      setState(() {});
      _loadMore();
    }
    glucoseID = BloodSugarDetailTabbarController.of(context)!.glucoseID;
  }

  Future<bool> _loadMore() async {
    if (isLoading || !hasMore!) {
      return true;
    } else {
      isLoading = true;
      BlocProvider.of<GlucoseBloc>(currentContext).add(FetchInputGlucose(
        page: page,
        currentDateTime:
            (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
        periodFilterType: periodFilterType.toString(),
        glucoseDistributionType: widget.glucoseDistributionType?.toString(),
      ));
    }
    return true;
  }

  Future<bool> _refresh() async {
    page = 1;
    BlocProvider.of<GlucoseBloc>(currentContext).add(FetchInputGlucose(
      page: 1,
      currentDateTime:
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      periodFilterType: periodFilterType.toString(),
      glucoseDistributionType: widget.glucoseDistributionType?.toString(),
    ));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.glucose_bg_color,
      appBar: AppBar(
        backgroundColor: R.color.greenGradientBottom,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, color: R.color.white),
        ),
        leadingWidth: 30,
        centerTitle: false,
        title: Text(
          R.string.detail.tr(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: R.color.white,
          ),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: InkWell(
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(NavigatorName.glucose_intro_2nd_page);
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    R.string.huong_dan.tr(),
                    style: TextStyle(color: R.color.white, fontSize: 15),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocProvider<GlucoseBloc>(
              create: (context) => GlucoseBloc(),
              child: BlocBuilder<GlucoseBloc, GlucoseState>(
                builder: (BuildContext context, GlucoseState state) {
                  currentContext = context;
                  List<InputGlucoseModel>? model;
                  if (state is GlucoseInitial) {
                    BlocProvider.of<GlucoseBloc>(context).add(FetchInputGlucose(
                        currentDateTime:
                            (DateTime.now().millisecondsSinceEpoch ~/ 1000)
                                .toString(),
                        periodFilterType: periodFilterType.toString(),
                        glucoseDistributionType:
                            widget.glucoseDistributionType?.toString(),
                        page: 1));
                  }
                  if (state is GlucoseError) {
                    Message.showToastMessage(context, state.message);
                  }
                  if (state is GlucoseLoading) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (state is GlucoseAlllLoaded) {
                    model = state.inputGlucoseModel;
                    hasMore = state.hasMore;
                    if (hasMore!) {
                      page += 1;
                    }
                    isLoading = false;

                    Future.delayed(const Duration(milliseconds: 500), () {
                      final model = state.inputGlucoseModel;
                      for (int i = 0; i < model.length; i++) {
                        if (model[i].id == glucoseID) {
                          BloodSugarDetailTabbarController.of(context)
                              ?.glucoseID = null;
                          itemScrollController.jumpTo(index: i);
                          Future.delayed(const Duration(seconds: 3), () {
                            setState(() {
                              glucoseID = null;
                            });
                          });
                        }
                      }
                      if (BloodSugarDetailTabbarController.of(context)
                              ?.glucoseID !=
                          null) {
                        _loadMore();
                      }
                    });
                  }

                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: model == null
                        ? Center(child: CircularProgressIndicator())
                        : Container(
                            child: ScrollablePositionedList.builder(
                              itemPositionsListener: itemPositionsListener,
                              itemScrollController: itemScrollController,
                              physics: AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.only(top: 16, bottom: 100),
                              itemCount: model.length,
                              itemBuilder: (context, _index) {
                                int index = _index.isNegative ? 0 : _index;
                                final element = model![index];

                                return bloodGlucoseItem(
                                  element: element,
                                  index: index,
                                  model: model,
                                );
                              },
                            ),
                          ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget bloodGlucoseItem({
    required InputGlucoseModel element,
    required int index,
    required List<InputGlucoseModel> model,
  }) {
    // int index = _index.isNegative ? 0 : _index;
    // final element = model[index];
    final previousElement = index == 0 ? null : model[index - 1];

    final showDate = previousElement == null
        ? true
        : (convertCustomDate(element.createDate!) !=
            convertCustomDate(previousElement.createDate!));
    return GestureDetector(
        onTap: () {
          KpiGlycemicTracking.clickKpiItem();
          Navigator.pushNamed(context, NavigatorName.add_blood_sugar_new,
              arguments: {'type': 'update', 'id': element.id});
        },
        child: Padding(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              showDate
                  ? Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 10),
                      child: Text(
                        convertCustomDate(element.createDate!),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    )
                  : SizedBox(),
              Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: glucoseID == null
                              ? R.color.white
                              : (glucoseID == element.id
                                  ? R.color.red
                                  : R.color.white),
                          width: 2),
                      borderRadius: BorderRadius.circular(16),
                      color: R.color.white),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(roundNumber(element.glucose ?? 0),
                                      style: TextStyle(
                                          color: R.color.color0xff111515,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700)),
                                  GapW(4),
                                  Text(element.unit,
                                      style: TextStyle(
                                          color: R.color.color0xff5E6566,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400)),
                                ],
                              ),
                              Text(element.type!,
                                  style: TextStyle(
                                      color: element.backgroundColor == 'None'
                                          ? R.color.color0xff111515
                                          : toColor(element.backgroundColor),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                          GapH(8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${element.timeFrame}',
                                  style: TextStyle(
                                      color: R.color.color0xff5E6566,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400)),
                              Text(
                                convertToUTC(element.createDate!, 'HH:mm'),
                                style: TextStyle(
                                    color: R.color.color0xff5E6566,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                          element.byDevice == true && element.modelName != null
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GapH(8),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          child: Text(
                                              R.string.connect_from_device.tr(
                                                  args: [element.modelName!]),
                                              style: TextStyle(
                                                  color:
                                                      R.color.color0xffBFC6C6,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : SizedBox(),
                          element.reason != null
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GapH(16),
                                    Container(
                                        height: 1,
                                        color: R.color.color0xffEEEFF3),
                                    GapH(16),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('${R.string.ly_do.tr()}: ',
                                            style: TextStyle(
                                                color: R.color.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600)),
                                        Expanded(
                                          child: Text(element.reason!,
                                              style: TextStyle(
                                                  color: R.color.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis),
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
  }
}
