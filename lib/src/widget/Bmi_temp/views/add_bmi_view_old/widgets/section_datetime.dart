import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/Bmi_temp/views/add_bmi_view_old/add_bmi_cubit.dart';
import 'package:medical/src/widget/Bmi_temp/widget/add_bmi.dart';
import 'package:medical/src/widget/helper/helper.dart';

class SectionDateTime extends StatelessWidget {
  final AddBmiCubit cubit;
  const SectionDateTime({Key? key, required this.cubit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          GestureDetector(
            onTap: () async {
              showDialog(
                barrierColor: R.color.color0xff003F38.withOpacity(0.5),
                context: context,
                builder: (_) => DateMultiPicker(
                  initDate: cubit.selectedDate,
                  callback: (date) {
                    cubit.infoChanged(selectedDate: date);
                  },
                ),
              );
            },
            child: Container(
              color: R.color.transparent,
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      convertToUTC(
                          cubit.selectedDate.millisecondsSinceEpoch ~/ 1000,
                          'HH:mm - dd/MM/yyyy'),
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                    ),
                    SizedBox(width: 8),
                    Text(
                      R.string.chinh_sua.tr(), // Chỉnh sửa
                      style: TextStyle(
                        fontSize: 16,
                        color: R.color.accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  ],
                ),
                SizedBox(height: 16),
                Container(height: 1, color: R.color.color0xffE5E5E5),
                SizedBox(height: 8),
              ]),
            ),
          )
        ],
      ),
    );
  }
}
