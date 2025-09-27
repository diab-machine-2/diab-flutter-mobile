import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/Bmi_temp/bloc/bmi_bloc.dart';
import 'package:medical/src/widget/Bmi_temp/bloc/bmi_state.dart';
import 'package:medical/src/widget/Bmi_temp/enum.dart';
import 'package:medical/src/widget/Bmi_temp/views/bmi_on_boarding/widgets/bmi_date_filter_bar.dart';
import 'package:medical/src/widget/Bmi_temp/views/bmi_statistical_data/widgets/bmi_record_card.dart';
import 'package:medical/src/widget/Bmi_temp/views/bmi_statistical_data/widgets/bmi_statistical_data_app_bar.dart';

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
    _bmiBloc.changePeriodTime(
      BmiDateFilterType.aWeek,
      isStatisticalView: false,
    );
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
                const SizedBox(
                  height: 12,
                ),

                Expanded(child: _HistoricalWeightListView())
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

  @override
  Widget build(BuildContext context) {
    BmiBloc _bmiBloc = context.read();

    return BlocBuilder<BmiBloc, BmiState>(
        buildWhen: (previous, state) => state is BmiGetWeightIndexListState,
        builder: (context, state) {
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemBuilder: (context, index) => BmiRecordCard(
              data: _bmiBloc.historicalWeightList[index],
            ),
            separatorBuilder: (context, index) => const SizedBox(
              height: 12,
            ),
            itemCount: _bmiBloc.historicalWeightList.length,
            shrinkWrap: true,
          );
        });
  }
}
