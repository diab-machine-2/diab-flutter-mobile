import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/widget/nipro/roche_connection/data/models/GlucoseMeasurementRecord.dart';
import 'package:medical/src/widgets/custom_checkbox_widget.dart';

class ResultSyncData extends StatelessWidget {
  final bool isSelected;
  final Function onTap;
  final GlucoseMeasurementRecord glucoseData;
  const ResultSyncData(this.glucoseData,
      {Key? key, required this.isSelected, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            onTap();
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: glucoseData
                            .convertGlucoseConcentrationValueToMilligramsPerDeciliter(),
                        style: TextStyle(
                          fontSize: 24,
                          color: R.color.textDark,
                          fontWeight: FontWeight.w700,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: ' (mg/dL)',
                            style: TextStyle(
                                color: R.color.gray,
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      DateUtil.convertDateTime(
                            glucoseData.calendar.toString(),
                            isShowTime: true,
                            toLocal: false,
                          ) ??
                          "",
                      style: TextStyle(
                        color: Color(0xFF777E90),
                      ),
                    ),
                  ],
                ),
              ),
              CustomCheckboxWidget(
                isChecked: isSelected,
                onTap: () => onTap(),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 30,
          child: Divider(),
        ),
      ],
    );
  }
}
