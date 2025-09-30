import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../res/R.dart';
import '../../../modal/medicine/medicine_item_model.dart';

class MedicineCard extends StatelessWidget {
  final MedicineItemModel medicine;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const MedicineCard({
    required this.medicine,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0x14016961),
            offset: const Offset(1, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(R.icons.ic_medicine, width: 38),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${medicine.medicationName} ", //${medicine.dosage}",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: R.color.color0xff111515),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "${medicine.amount} ${medicine.unit}  •  ${getMomentNameFromValue(medicine.moment)}  •  ${getFrequencyNameFromValue(medicine.frequency)}",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: R.color.color0xff5E6566),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      if ((medicine.morning ?? 0.0) > 0.0)
                        buildDose(momentName: R.string.the_morning2.tr(), amount: medicine.morning!),
                      if ((medicine.midDay ?? 0.0) > 0.0)
                        buildDose(momentName: R.string.the_noon2.tr(), amount: medicine.midDay!),
                      if ((medicine.afternoon ?? 0.0) > 0.0)
                        buildDose(momentName: R.string.the_afternoon2.tr(), amount: medicine.afternoon!),
                      if ((medicine.night ?? 0.0) > 0.0)
                        buildDose(momentName: R.string.the_night2.tr(), amount: medicine.night!),
                    ],
                  ),
                  if (medicine.note != null) ...[
                    SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: 'Ghi chú: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: medicine.note),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: SvgPicture.asset(R.icons.ic_delete, width: 20),
                  onPressed: onDelete,
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    icon: SvgPicture.asset(R.icons.ic_edit, width: 20),
                    onPressed: onEdit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container buildDose({required String momentName, required double amount}) {
    return Container(
      width: 60,
      height: 52,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: R.color.backgroundColorNew,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            momentName,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: R.color.color0xff5E6566),
          ),
          Text(
            amount.toStringAsFixed(0),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: R.color.color0xff5E6566),
          ),
        ],
      ),
    );
  }

  String getMomentNameFromValue(int? moment) {
    if (moment == null) return '';
    switch (moment) {
      case 1:
        return R.string.truoc_an.tr();
      case 2:
        return R.string.sau_an.tr();
      case 3:
        return R.string.during_meal.tr();
      default:
        return R.string.truoc_an.tr();
    }
  }

  String getFrequencyNameFromValue(int? frequency) {
    if (frequency == null) return '';
    switch (frequency) {
      case 1:
        return R.string.everyday.tr();
      case 2:
        return R.string.ngay_trong_tuan.tr();
      case 3:
        return R.string.every_other_day.tr();
      default:
        return R.string.everyday.tr();
    }
  }
}
