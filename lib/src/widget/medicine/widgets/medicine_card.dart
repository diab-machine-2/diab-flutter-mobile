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
                    "${medicine.amount} Viên  •  ", //${medicine.mealTime}  •  ${medicine.frequency}",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: R.color.color0xff5E6566),
                  ),
                  SizedBox(height: 12),
                  Container(
                    width: 48,
                    height: 52,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: R.color.backgroundColorNew,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '', //medicine.times[0],
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: R.color.color0xff5E6566),
                        ),
                        Text(
                          '', //medicine.dose.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: R.color.color0xff5E6566),
                        ),
                      ],
                    ),
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
}