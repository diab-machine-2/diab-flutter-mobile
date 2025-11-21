import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/response/bmi_get_weight_list_response.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_bloc.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_state.dart';
import 'package:medical/src/widget/Bmi/enum.dart';
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

  @override
  void initState() {
    super.initState();
    _bmiBloc = context.read();
    _bmiBloc
      ..changePeriodTime(
        BmiDateFilterType.threeMonths,
        isStatisticalView: false,
      )
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
              children: [Expanded(child: const _HistoricalWeightListView())],
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
