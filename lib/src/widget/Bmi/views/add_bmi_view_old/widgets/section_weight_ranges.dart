import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/app_media_query.dart';
import 'package:medical/src/widget/bmi/models/weight_ranger_model.dart';
import 'package:medical/src/widget/bmi/views/add_bmi_view_old/add_bmi_cubit.dart';
import 'package:medical/src/widget/bmi/views/add_bmi_view_old/widgets/add_bmi_mixin.dart';
import 'package:medical/src/widgets/spacing_row.dart';

class SectionWeightRanges extends StatelessWidget with AddBmiMixin {
  final AddBmiCubit cubit;
  const SectionWeightRanges({Key? key, required this.cubit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<WeightRangeModel>? weightRanges = cubit.weightRanges;
    if (weightRanges == null || weightRanges.isEmpty) return SizedBox();
    num widthRange = (AppMediaQuery.deviceWidth - 60) / (weightRanges.length);
    int indexRange = findIndexInRanges(cubit: cubit);
    num width = cubit.selectedWeight == 0 ? 0 : widthRange * (indexRange);

    num min = cubit.rangeValue[indexRange];
    print('hihi min: $min');
    num max = indexRange + 1 >= cubit.rangeValue.length
        ? cubit.rangeValue[indexRange] + min
        : cubit.rangeValue[indexRange + 1];
    print('hihi max: $max');
    // giá trị từ 0 -> 55 sẽ nằm ở mức 0

    // sau đó tính toán mỗi px trên 1 mức value
    num maximumValue = max - min;
    print('hihi maximumValue: $maximumValue');
    num pxPerValue = widthRange / maximumValue;
    print('hihi pxPerValue: $pxPerValue');
    num widthPlus = pxPerValue * (cubit.selectedWeight- min);
    print('hihi widthPlus: $widthPlus');
    width += widthPlus;

    width = width > (widthRange * cubit.rangeValue.length)
        ? widthRange * cubit.rangeValue.length
        : width;

    //   print('hihi number: $number');

    return SpacingColumn(
      spacing: 40,
      children: [
        // RichText(
        //   text: TextSpan(
        //     text: 'Đường huyết đang ở mức ',
        //     style: TextStyle(
        //         color: R.color.textDark,
        //         fontWeight: FontWeight.w400,
        //         fontSize: 16),
        //     children: <TextSpan>[
        //       TextSpan(
        //         text: '“${rangeLabel[indexRange]}”',
        //         style: TextStyle(
        //           color: colorList[indexRange],
        //           fontWeight: FontWeight.w700,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Row(
                  children: weightRanges.map(
                    (range) {
                      return Container(
                        height: 8,
                        width: widthRange.toDouble(),
                        color: parseColor(range.backgroundColorCode!),
                      );
                    },
                  ).toList(),
                ),
              ),
            ),
            Positioned(
              left: width.toDouble() - 20,
              bottom: 40,
              child: Container(
                  child: Icon(Icons.arrow_drop_down_rounded, size: 40)),
            ),
            Positioned(
              left: -5,
              right: 0,
              bottom: 17,
              child: Row(
                  children: cubit.rangeValue
                      .map(
                        (e) => Stack(
                          clipBehavior: Clip.none,
                          children: [
                            SizedBox(width: widthRange.toDouble()),
                            Positioned(
                              left: e.toString().length == 3 ? -10 : -7,
                              child: Text(
                                '${e == 0 ? '' : e.toStringAsFixed(1)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF7E828B),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                      .toList()),
            ),
            Positioned(
              left: -2,
              right: 0,
              bottom: 25,
              child: Row(
                  children: cubit.rangeValue
                      .map(
                        (e) => Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              color: e == 0
                                  ? Colors.transparent
                                  : Color(0xFF7E828B),
                              width: 1,
                              height: 5,
                            ),
                          ),
                        ),
                      )
                      .toList()),
            ),
            Positioned(
              left: -10,
              right: 0,
              bottom: 5,
              child: Text(
                R.string.can_nang.tr(), // Cân nặng can_nang
                style: TextStyle(
                  fontSize: 10,
                  color: R.color.textDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color parseColor(String colorCode) {
    // Kiểm tra và loại bỏ ký tự '#'
    if (colorCode[0] == '#') {
      colorCode = colorCode.substring(1);
    }

    // Kiểm tra xem chuỗi có đúng 6 hoặc 8 ký tự không
    if (colorCode.length == 6 || colorCode.length == 8) {
      // Thêm ký tự 'FF' nếu chuỗi chỉ có 6 ký tự (không có giá trị alpha)
      if (colorCode.length == 6) {
        colorCode = 'FF' + colorCode;
      }

      // Chuyển đổi chuỗi hex sang giá trị int
      int colorValue = int.parse(colorCode, radix: 16);

      // Tạo đối tượng Color từ giá trị int
      return Color(colorValue);
    } else {
      // Trả về màu đen nếu chuỗi không hợp lệ
      return Colors.black;
    }
  }
}
