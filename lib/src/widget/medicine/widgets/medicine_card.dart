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

  /// When true, show [MedicineItemModel.amount] (original quantity).
  /// When false, show [MedicineItemModel.remain] (left after use). Used for create vs edit.
  final bool showAmountInsteadOfRemain;

  const MedicineCard({
    required this.medicine,
    this.onDelete,
    this.onEdit,
    this.showAmountInsteadOfRemain = false,
  });

  double get _quantityDisplayValue => medicine.displayQuantityValue(
        showAmountInsteadOfRemain: showAmountInsteadOfRemain,
      );

  bool get _isMedicineDetailsIncomplete => medicine.isMedicineDetailsIncomplete(
        showAmountInsteadOfRemain: showAmountInsteadOfRemain,
      );

  String get _displayQuantityText {
    final double value = _quantityDisplayValue;

    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  Future<void> _showIncompleteMedicineDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(R.drawable.ic_dialog_failed, width: 64, height: 64),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        R.string.medicine_prescription_data_incomplete.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: R.color.textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          height: 43,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(200),
                            color: R.color.grayBorder,
                          ),
                          child: Center(
                            child: Text(
                              R.string.close.tr(),
                              style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: R.font.sfpro,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.close, color: R.color.color0xffBEC0C8),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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
                    "${_displayQuantityText} ${medicine.unit ?? ''}  •  ${getMomentNameFromValue(medicine.moment)}  •  ${getFrequencyNameFromValue(medicine.frequency)}",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: R.color.color0xff5E6566),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      if ((medicine.morning ?? 0.0) > 0.0)
                        buildDose(
                            momentName: R.string.the_morning2.tr(),
                            amount: medicine.morning!,
                            context: context),
                      if ((medicine.midDay ?? 0.0) > 0.0)
                        buildDose(
                            momentName: R.string.the_noon2.tr(),
                            amount: medicine.midDay!,
                            context: context),
                      if ((medicine.afternoon ?? 0.0) > 0.0)
                        buildDose(
                            momentName: R.string.the_afternoon2.tr(),
                            amount: medicine.afternoon!,
                            context: context),
                      if ((medicine.night ?? 0.0) > 0.0)
                        buildDose(
                            momentName: R.string.the_night2.tr(),
                            amount: medicine.night!,
                            context: context),
                    ],
                  ),
                  if (medicine.note != null) ...[
                    SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                              text: '${R.string.ghi_chu.tr()}: ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
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
                    icon: SvgPicture.asset(
                      R.icons.ic_edit,
                      width: 20,
                      color: R.color.greenGradientBottom,
                    ),
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

  Container buildDose(
      {required String momentName,
      required double amount,
      required BuildContext context}) {
    return Container(
      width: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: R.color.backgroundColorNew,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: MediaQuery.of(context)
                  .textScaler
                  .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3),
            ),
            child: Text(
              momentName,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: R.color.color0xff5E6566),
            ),
          ),
          MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: MediaQuery.of(context)
                  .textScaler
                  .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3),
            ),
            child: Text(
              amount.toStringAsFixed(1),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: TextStyle(
                fontSize: 14,
                height: 1,
                fontWeight: FontWeight.bold,
                color: R.color.color0xff5E6566,
              ),
            ),
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
