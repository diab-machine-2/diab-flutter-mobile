import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/response/bmi_get_weight_list_response.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_bloc.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_state.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi/revise_weight_page.dart';
import 'package:medical/src/widget/Bmi/views/bmi_on_boarding/widgets/bmi_date_filter_bar.dart';
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

  @override
  void initState() {
    super.initState();
    _bmiBloc = context.read();
    _bmiBloc
      // ..changePeriodTime(
      //   BmiDateFilterType.aWeek,
      //   isStatisticalView: false,
      // )
      ..hasNewData = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                // const SizedBox(height: 12,),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  child: BmiDateFilterBar(
                    onChanged: (filterType) {
                      _bmiBloc.changePeriodTime(
                        filterType,
                        isStatisticalView: false,
                      );
                    },
                  ),
                ),
                Expanded(child: const _HistoricalWeightListView())
              ],
            );
          }),
    );
  }
}

class _HistoricalWeightListView extends StatelessWidget {
  const _HistoricalWeightListView({
    super.key,
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
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            itemBuilder: (context, index) {
              DateTime now = DateTime.now();
              DateTime dateTime = groupedData.keys.elementAt(index);
              String date = _dateFormat.format(dateTime);
              bool isToday = now.year == dateTime.year &&
                  now.month == dateTime.month &&
                  now.day == dateTime.day;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isToday ? R.string.today.tr() : date,
                    style: R.style.boldXLargeStyle,
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  ...groupedData.values.elementAt(index).map(
                        (record) => Column(
                          children: [
                            BmiRecordCard(
                              data: _bmiBloc.historicalWeightList[index],
                              onTap: () async {
                                final updateResult = await Navigator.pushNamed(
                                  context,
                                  NavigatorName.bmiReviseRecordPage,
                                  arguments: {
                                    ReviseWeightPage.bmiBlocKey: _bmiBloc,
                                    ReviseWeightPage.dataKey:
                                        _bmiBloc.historicalWeightList[index],
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
