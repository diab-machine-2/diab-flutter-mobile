import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/firebase_tracking/kpi_blood_pressure_tracking.dart';
import 'package:medical/src/bloc/bloodPressure/bloodPressure_bloc.dart';
import 'package:medical/src/modal/blood_pressure/blood_pressure.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/BloodPressure/bloodpressure_result.dto.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'widget/horizontal_selector.dart';

class BloodPressureDetailListingController extends StatefulWidget {
  BloodPressureDetailListingController({
    Key? key,
    required this.initPeriodFilterType,
    this.initBloodPressureID,
    this.initBloodPressureRangeType,
  }) : super(key: key);

  final int initPeriodFilterType;
  final String? initBloodPressureID;
  final int? initBloodPressureRangeType;

  @override
  BloodPressureDetailListingControllerState createState() =>
      BloodPressureDetailListingControllerState();
}

class BloodPressureDetailListingControllerState extends State<BloodPressureDetailListingController>
    with AutomaticKeepAliveClientMixin<BloodPressureDetailListingController>, Observer {
  @override
  bool get wantKeepAlive => true;

  late BuildContext currentContext;
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

  int page = 1;
  bool? hasMore = false;
  bool isLoading = false;
  int _periodFilterType = 1;
  BloodPressureRangeType? _bloodPressureRangeType;

  String? bloodPressureID;

  @override
  void initState() {
    _periodFilterType = widget.initPeriodFilterType;
    bloodPressureID = widget.initBloodPressureID;
    if (widget.initBloodPressureRangeType != null) {
      _bloodPressureRangeType = BloodPressureRangeType.fromInt(widget.initBloodPressureRangeType!);
    }
    super.initState();
    initializeDateFormatting();
    Observable.instance.addObserver(this);
    // DartNotificationCenter.subscribe(
    //     channel: 'BloodPressure_change_data',
    //     observer: this,
    //     onNotification: (_) {
    //       _refresh();
    //     });

    _itemPositionsListener.itemPositions.addListener(() {
      final lastIndex = _itemPositionsListener.itemPositions.value.last.index;
      final BloodPressureState state = BlocProvider.of<BloodPressureBloc>(currentContext).state;
      if (state is BloodPressureDataLoaded) {
        final model = state.bloodPressureModel;
        if (model.length - 2 == lastIndex) {
          _loadMorePage();
        }
      }
    });
  }

  @override
  void update(Observable observable, String? notifyName, Map<dynamic, dynamic>? map) {
    if (notifyName == 'BloodPressure_change_data') {
      _refresh();
    }
  }

  @override
  void dispose() {
    Observable.instance.removeObserver(this);
    // DartNotificationCenter.unsubscribe(
    //     channel: 'BloodPressure_change_data', observer: this);
    // BloodPressureDetailTabbarController.of(context)?.dispose();
    super.dispose();
  }

  void reloadAllByChangeFilter(int periodFilter) {
    _itemScrollController.jumpTo(index: 0);
    _periodFilterType = periodFilter;
    _refresh();
  }

  void loadDataToID(int periodFilter) {
    // periodFilterType = periodFilter;
    // if (BloodPressureDetailTabbarController.of(context)!.bloodPressureID !=
    //     null) {
    //   setState(() {});
    //   _loadMorePage();
    // }
    // bloodPressureID =
    //     BloodPressureDetailTabbarController.of(context)!.bloodPressureID;
  }

  Future<bool> _loadMorePage() async {
    if (isLoading || !hasMore!) {
      return true;
    } else {
      isLoading = true;
      BlocProvider.of<BloodPressureBloc>(currentContext).add(FetchInputBloodPressure(
          page: page,
          currentDateTime: (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
          periodFilterType: _periodFilterType.toString(),
          bloodPressureType: _bloodPressureRangeType?.value.toString()));
    }
    return true;
  }

  Future<bool> _refresh() async {
    page = 1;
    BlocProvider.of<BloodPressureBloc>(currentContext).add(FetchInputBloodPressure(
        page: 1,
        currentDateTime: (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
        periodFilterType: _periodFilterType.toString(),
        bloodPressureType: _bloodPressureRangeType?.value.toString()));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: R.color.glucose_bg_color,
      appBar: AppBar(
        backgroundColor: R.color.greenGradientBottom,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, color: R.color.white),
        ),
        title: Text(
          R.string.detail.tr(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: R.color.white,
          ),
        ),
      ),
      body: BlocProvider<BloodPressureBloc>(
        create: (context) => BloodPressureBloc(),
        child: BlocBuilder<BloodPressureBloc, BloodPressureState>(
          builder: (BuildContext context, BloodPressureState state) {
            currentContext = context;
            List<BloodPressureModel>? model;
            if (state is BloodPressureInitial) {
              BlocProvider.of<BloodPressureBloc>(context).add(FetchInputBloodPressure(
                  currentDateTime: (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
                  periodFilterType: _periodFilterType.toString(),
                  page: 1,
                  bloodPressureType: _bloodPressureRangeType?.value.toString()));
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
              if (hasMore!) {
                page += 1;
              }
              isLoading = false;

              Future.delayed(const Duration(milliseconds: 500), () {
                final model = state.bloodPressureModel;
                for (int i = 0; i < model.length; i++) {
                  if (model[i].id == bloodPressureID) {
                    // BloodPressureDetailTabbarController.of(context)!
                    //     .bloodPressureID = null;
                    _itemScrollController.jumpTo(index: i);
                    Future.delayed(const Duration(seconds: 3), () {
                      setState(() {
                        bloodPressureID = null;
                      });
                    });
                  }
                }
                // if (BloodPressureDetailTabbarController.of(context)!
                //         .bloodPressureID !=
                //     null) {
                //   _loadMorePage();
                // }
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
                          image: AssetImage(R.drawable.bg_detail),
                          fit: BoxFit.cover,
                        )),
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            _buildFilter(),
                            const SizedBox(height: 12),
                            Expanded(child: _buildListing(model)),
                          ],
                        ),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildListing(List<BloodPressureModel> model) {
    return ScrollablePositionedList.builder(
      itemPositionsListener: _itemPositionsListener,
      itemScrollController: _itemScrollController,
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: 16, bottom: 100),
      itemCount: model.length,
      itemBuilder: (context, _index) {
        int index = _index.isNegative ? 0 : _index;
        final element = model[index];
        final previousElement = index == 0 ? null : model[index - 1];

        final showDate = previousElement == null
            ? true
            : (convertCustomDate(element.date!) != convertCustomDate(previousElement.date!));

        return GestureDetector(
            onTap: () {
              KpiBloodPressureTracking.clickKpiItem();
              Navigator.pushNamed(context, NavigatorName.add_blood_pressure,
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
                            convertCustomDate(element.date!),
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        )
                      : SizedBox(),
                  Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: bloodPressureID == null
                                  ? R.color.white
                                  : (bloodPressureID == element.id ? R.color.red : R.color.white),
                              width: 2),
                          borderRadius: BorderRadius.circular(16),
                          color: R.color.white),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${element.systolic!.toInt().toString()}/${element.diastolic!.toInt().toString()}',
                                    style: TextStyle(
                                        fontFamily: 'Viga',
                                        color: Color(0xFF111515),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    R.string.mm_hg.tr(),
                                    style: TextStyle(
                                        color: R.color.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                              Text(
                                element.bloodPressureType!,
                                style: TextStyle(
                                  color: toColor(element.backgroundColor),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                convertToUTC(element.date!, 'HH:mm'),
                                style: TextStyle(
                                    color: R.color.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400),
                              ),
                              Text(', ' + element.timeFrame!,
                                  style: TextStyle(
                                      color: R.color.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400)),
                            ],
                          ),
                          element.reason != '' && element.reason != null
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 16),
                                    Container(height: 1, color: R.color.color0xffEEEFF3),
                                    SizedBox(height: 16),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${R.string.ly_do.tr()}: ',
                                          style: TextStyle(
                                              color: R.color.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        Expanded(
                                          child: Text(
                                            element.reason!,
                                            style: TextStyle(
                                                color: R.color.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
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
    );
  }

  Widget _buildFilter() {
    final List<String> labels = [
      R.string.filter_day.tr(args: ['7']),
      R.string.filter_day.tr(args: ['14']),
      R.string.filter_day.tr(args: ['30']),
      R.string.filter_day.tr(args: ['90']),
    ];
    final List<int> values = [0, 1, 2, 3];
    final int selectedIndex = _periodFilterType - 1;
    return HorizontalSelector(
      onSelected: (value) {
        _periodFilterType = value + 1;
        reloadAllByChangeFilter(_periodFilterType);
      },
      initialValue: selectedIndex,
      values: values,
      labels: labels,
    );
  }
}
