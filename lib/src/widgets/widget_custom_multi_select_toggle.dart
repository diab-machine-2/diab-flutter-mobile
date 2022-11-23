import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';

class CustomMultiSelectToggle extends StatelessWidget {
  const CustomMultiSelectToggle({
    required this.toggleList,
    required this.selectedIndex,
    required this.onChange,
  });
  final List<String> toggleList;
  final int selectedIndex;
  final Function(int index) onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32.h,
      decoration: BoxDecoration(
        color: R.color.transparent,
        border: Border.all(color: R.color.greenGradientBottom, width: 1.0),
        borderRadius: const BorderRadius.all(
          Radius.circular(200),
        ),
      ),
      child: Row(
        children: List.generate(
          toggleList.length,
          (index) => _buildToggle(
            currentIndex: index,
            selectedIndex: selectedIndex,
            toggleList: toggleList,
            onSelect: () {
              onChange(index);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildToggle({
    required int currentIndex,
    required int selectedIndex,
    required List<String> toggleList,
    VoidCallback? onSelect,
  }) {
    final bool isSelected = selectedIndex == currentIndex;
    final bool isFirst = currentIndex == 0;
    final bool isLast = currentIndex == toggleList.length - 1;
    return Expanded(
      child: GestureDetector(
        onTap: onSelect,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color:
                isSelected ? R.color.greenGradientBottom : R.color.transparent,
            borderRadius: BorderRadius.horizontal(
              left: isFirst ? const Radius.circular(200) : Radius.zero,
              right: isLast ? const Radius.circular(200) : Radius.zero,
            ),
          ),
          child: Center(
            child: Text(
              toggleList[currentIndex].tr(),
              style: TextStyle(
                color: isSelected ? R.color.white : R.color.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
