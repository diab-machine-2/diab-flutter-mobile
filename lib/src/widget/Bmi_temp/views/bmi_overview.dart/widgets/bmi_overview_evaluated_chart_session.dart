import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/text_styles_extension.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi/bloc/bmi_input_bloc.dart';
import 'package:medical/src/widget/Bmi/views/bmi_overview.dart/widgets/bmi_gauge_chart.dart';

class BmiOverviewEvalutatedChartSession extends StatelessWidget {
  const BmiOverviewEvalutatedChartSession({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    BmiInputBloc _bmiInputBloc = context.read();

    return Container(
      decoration: R.decorationStyle.mediumRadiusCardStyles,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      child: Column(
        children: [
          BmiGaugeChart(),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.boy_rounded),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    _bmiInputBloc.waist == 0
                        ? "--"
                        : _bmiInputBloc.waist.toString(),
                    style: R.style.boldLargeStyle,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    "cm",
                    style: R.style.normalTextStyle.neutral3,
                  )
                ],
              ),
              Row(
                children: [
                  Icon(Icons.boy_rounded),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    _bmiInputBloc.currentHeight.toString(),
                    style: R.style.boldLargeStyle,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    "cm",
                    style: R.style.normalTextStyle.neutral3,
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}


