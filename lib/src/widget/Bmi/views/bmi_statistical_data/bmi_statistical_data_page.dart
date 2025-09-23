import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/bmi/views/bmi_on_boarding/widgets/bmi_date_filter_bar.dart';
import 'package:medical/src/widget/bmi/views/bmi_statistical_data/widgets/bmi_record_card.dart';
import 'package:medical/src/widget/bmi/views/bmi_statistical_data/widgets/bmi_statistical_data_app_bar.dart';

class BmiStatisticalDataPage extends StatefulWidget {
  const BmiStatisticalDataPage({super.key});

  @override
  State<BmiStatisticalDataPage> createState() => _BmiStatisticalDataPageState();
}

class _BmiStatisticalDataPageState extends State<BmiStatisticalDataPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.glucose_bg_color,
      resizeToAvoidBottomInset: true,
      appBar: const BmiStatisticalDataAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const SizedBox(height: 12,),
           BmiDateFilterBar(),
           const SizedBox(height: 12,),
           BmiRecordCard()

          ],
        ),
      ),
    );
  }
}

