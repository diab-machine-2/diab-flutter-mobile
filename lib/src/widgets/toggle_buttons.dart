import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class ToggleButtonsHorizontal extends StatelessWidget {
  const ToggleButtonsHorizontal({
    required this.names,
    required this.selectedIndex,
    required this.onChange,
    this.radius = 8,
    this.backgroundColor = Colors.transparent,
    this.height = 32,
    this.flexes,
  }) : assert(
          flexes == null || flexes.length == names.length,
          'flexes must be null or have the same length as names',
        );
  final List<String> names;
  final int selectedIndex;
  final Function(int index) onChange;
  final double radius;
  final Color backgroundColor;
  final double height;
  final List<int>? flexes;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(radius)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        children: List.generate(
          names.length,
          (index) => _buildToggle(
            currentIndex: index,
            selectedIndex: selectedIndex,
            names: names,
            onSelect: () => onChange(index),
          ),
        ),
      ),
    );
  }

  Widget _buildToggle({
    required int currentIndex,
    required int selectedIndex,
    required List<String> names,
    VoidCallback? onSelect,
  }) {
    final bool isSelected = selectedIndex == currentIndex;
    // final bool isFirst = currentIndex == 0;
    // final bool isLast = currentIndex == names.length - 1;
    return Expanded(
      flex: flexes?[currentIndex] ?? 1,
      child: GestureDetector(
        onTap: onSelect,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: isSelected ? R.color.greenGradientBottom : R.color.transparent,
            // borderRadius: BorderRadius.horizontal(
            //   left: isFirst ? Radius.circular(radius) : Radius.zero,
            //   right: isLast ? Radius.circular(radius) : Radius.zero,
            // ),
          ),
          child: Center(
            child: Text(
              names[currentIndex].tr(),
              style: TextStyle(
                color: isSelected ? R.color.white : R.color.primaryGreyColor,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ToggleButtonsVertical extends StatelessWidget {
  const ToggleButtonsVertical({
    required this.names,
    required this.selectedIndex,
    required this.onChange,
    required this.width,
    this.radius = 8,
    this.backgroundColor = Colors.transparent,
  });
  final List<String> names;
  final int selectedIndex;
  final Function(int index) onChange;
  final double radius;
  final Color backgroundColor;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(radius)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: List.generate(
          names.length,
          (index) => _buildToggle(
            currentIndex: index,
            selectedIndex: selectedIndex,
            names: names,
            onSelect: () => onChange(index),
          ),
        ),
      ),
    );
  }

  Widget _buildToggle({
    required int currentIndex,
    required int selectedIndex,
    required List<String> names,
    VoidCallback? onSelect,
  }) {
    final bool isSelected = selectedIndex == currentIndex;
    // final bool isFirst = currentIndex == 0;
    // final bool isLast = currentIndex == names.length - 1;
    return Expanded(
      child: GestureDetector(
        onTap: onSelect,
        child: Container(
          height: width,
          decoration: BoxDecoration(
            color: isSelected ? R.color.greenGradientBottom : R.color.transparent,
            // borderRadius: BorderRadius.horizontal(
            //   left: isFirst ? Radius.circular(radius) : Radius.zero,
            //   right: isLast ? Radius.circular(radius) : Radius.zero,
            // ),
          ),
          child: Center(
            child: Text(
              names[currentIndex].tr(),
              style: TextStyle(
                color: isSelected ? R.color.white : R.color.primaryGreyColor,
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
