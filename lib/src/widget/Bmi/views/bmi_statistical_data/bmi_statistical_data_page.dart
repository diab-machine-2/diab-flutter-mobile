import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/response/bmi_get_weight_list_response.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_bloc.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_event.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_state.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi/revise_weight_page.dart';
import 'package:medical/src/widget/Bmi/views/bmi_statistical_data/widgets/bmi_record_card.dart';
import 'package:medical/src/widget/Bmi/views/bmi_statistical_data/widgets/bmi_statistical_data_app_bar.dart';

class BmiStatisticalDataPage extends StatefulWidget {
  const BmiStatisticalDataPage({super.key});

  @override
  State<BmiStatisticalDataPage> createState() => _BmiStatisticalDataPageState();

  static const bmiBlocKey = "bmi_bloc_key";
}

class _BmiStatisticalDataPageState extends State<BmiStatisticalDataPage> {
  late BmiBloc _bmiBloc;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _bmiBloc = context.read();
    _bmiBloc
      ..savePeriodTypeForStatisticalView()
      ..changePeriodTime(
        _bmiBloc.periodType,
        isStatisticalView: false,
      )
      ..hasNewData = false;

    // Explicitly fetch weight records with size 10 for the statistical data page
    _bmiBloc.add(const BmiGetWeightRecordsEvent(page: 1, size: 10));

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll - 200) {
      // Load more when within 200 pixels of the bottom
      if (!_bmiBloc.isLoadingMoreHistoricalWeight &&
          _bmiBloc.hasMoreHistoricalWeight) {
        _bmiBloc.loadMoreHistoricalWeight();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _bmiBloc.restorePeriodTypeAndRefetch();
        return true;
      },
      child: Scaffold(
        backgroundColor: R.color.glucose_bg_color,
        resizeToAvoidBottomInset: true,
        appBar: const BmiStatisticalDataAppBar(),
        body: BlocBuilder<BmiBloc, BmiState>(
            buildWhen: (previous, current) =>
                current is BmiGetWeightIndexListState,
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _HistoricalWeightListView(
                      scrollController: _scrollController,
                    ),
                  )
                ],
              );
            }),
      ),
    );
  }
}

class _HistoricalWeightListView extends StatelessWidget {
  final ScrollController scrollController;

  const _HistoricalWeightListView({
    super.key,
    required this.scrollController,
  });

  static final _dateFormat = DateFormat(Const.DATE_FORMAT);

  @override
  Widget build(BuildContext context) {
    BmiBloc _bmiBloc = context.read();

    return BlocBuilder<BmiBloc, BmiState>(
        buildWhen: (previous, state) => state is BmiGetWeightIndexListState,
        builder: (context, state) {
          Map<DateTime, List<BmiGetWeightRecord>> groupedData =
              _bmiBloc.getGroupedWeightRecords();

          return ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            itemBuilder: (context, index) {
              DateTime now = DateTime.now();
              DateTime today = DateTime(now.year, now.month, now.day);
              DateTime yesterday = today.subtract(const Duration(days: 1));
              DateTime dateTime = groupedData.keys.elementAt(index);
              DateTime itemDate =
                  DateTime(dateTime.year, dateTime.month, dateTime.day);
              String date = _dateFormat.format(dateTime);

              String displayText;
              if (itemDate == today) {
                displayText = R.string.today.tr();
              } else if (itemDate == yesterday) {
                displayText = R.string.yesterday.tr();
              } else {
                displayText = date;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayText,
                    style: R.style.boldXLargeStyle,
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  ...groupedData.values.elementAt(index).map(
                        (record) => Column(
                          children: [
                            BmiRecordCard(
                              data: record,
                              onTap: () async {
                                final updateResult = await Navigator.pushNamed(
                                  context,
                                  NavigatorName.bmiReviseRecordPage,
                                  arguments: {
                                    ReviseWeightPage.bmiBlocKey: _bmiBloc,
                                    ReviseWeightPage.dataKey: record,
                                  },
                                );

                                if (updateResult == true) {
                                  _bmiBloc
                                    ..fetchHistoricalWeight()
                                    ..refresh();
                                }
                              },
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                          ],
                        ),
                      )
                ],
              );
            },
            itemCount: groupedData.length,
            shrinkWrap: true,
          );
        });
  }
}
