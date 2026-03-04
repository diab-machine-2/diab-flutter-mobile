import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../res/R.dart';
import '../../../modal/medicine/medicine_item_model.dart';

class MedicineList extends StatefulWidget {
  final List<MedicineItemModel> medications;

  const MedicineList({super.key, required this.medications});

  @override
  State<MedicineList> createState() => _MedicineListState();
}

class _MedicineListState extends State<MedicineList> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final meds = widget.medications;

    // Nếu > 3 thuốc thì khi gọn chỉ hiện 1; ngược lại hiện hết
    final bool needToggle = meds.length > 3;
    final int collapsedCount = needToggle ? 1 : meds.length;

    final Iterable<MedicineItemModel> visible =
    _expanded ? meds : meds.take(collapsedCount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (final med in visible) _MedicineRow(med: med),

        if (needToggle)
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _expanded
                        ? "Thu gọn "
                        : "Xem thêm (${meds.length - collapsedCount} loại thuốc khác) ",
                    style: TextStyle(
                      fontSize: 13,
                      color: R.color.color0xffB4802D,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  _expanded
                    ? Icon(Icons.arrow_upward, size: 16, color: R.color.color0xffB4802D)
                    : Icon(Icons.arrow_downward, size: 16, color: R.color.color0xffB4802D)
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _MedicineRow extends StatelessWidget {
  final MedicineItemModel med;
  const _MedicineRow({required this.med});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SvgPicture.asset(R.icons.ic_medicine, width: 38),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              med.medicationName ?? "",
              style: TextStyle(
                fontSize: 15,
                color: R.color.color0xff111515,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (med.remain != null || med.amount != null)
            Text(
              _formatQuantity(med.remain ?? med.amount ?? 0),
              style: TextStyle(
                fontSize: 15,
                color: R.color.color0xff5E6566,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  String _formatQuantity(double quantity) {
    final unit = med.unit ?? '';
    if (quantity == quantity.roundToDouble()) {
      return "${quantity.toInt()} $unit";
    }
    return "${quantity.toStringAsFixed(1)} $unit";
  }
}

