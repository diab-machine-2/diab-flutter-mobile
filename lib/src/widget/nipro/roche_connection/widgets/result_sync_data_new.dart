import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/nipro/roche_connection/data/models/GlucoseMeasurementRecord.dart';
import 'package:medical/src/widgets/custom_checkbox_widget.dart';

class ResultSyncDataNew extends StatelessWidget {
  final bool isSelected;
  final Function onTap;
  final GlucoseUnitsFlag glucoseUnits;
  final Map<String, String> glucoseData;
  const ResultSyncDataNew(
    this.glucoseData, {
    Key? key,
    required this.isSelected,
    required this.onTap,
    required this.glucoseUnits,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String unitName = '(mg/dL)';
    dynamic bloodGlucose = double.tryParse(glucoseData['glucose']!)!.round();

    if (glucoseUnits == GlucoseUnitsFlag.mmolPerL) {
      bloodGlucose =
          roundAsFixed(roundDouble(bloodGlucose) / Const.mmollToMgdlFactor);
      unitName = '(mmol/L)';
    }

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
                        text: bloodGlucose.toString(),
                        style: TextStyle(
                          fontSize: 24,
                          color: R.color.textDark,
                          fontWeight: FontWeight.w700,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: ' $unitName',
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
                      convertToUTC(int.tryParse(glucoseData['date']!) ?? 0,
                          'HH:mm - dd-MM-yyyy'),
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
