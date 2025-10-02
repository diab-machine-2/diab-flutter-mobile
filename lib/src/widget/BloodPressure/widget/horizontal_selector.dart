import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class HorizontalSelector extends StatefulWidget {
  final Function(int) onSelected;
  final List<int> values;
  final List<String> labels;
  final int initialValue;
  final double height;

  const HorizontalSelector({
    Key? key,
    required this.onSelected,
    required this.initialValue,
    required this.values,
    required this.labels,
    this.height = 42,
  })  : assert(values.length == labels.length,
            'values and labels must have the same length'),
        super(key: key);
  @override
  _HorizontalSelectorState createState() => _HorizontalSelectorState();
}

class _HorizontalSelectorState extends State<HorizontalSelector> {
  late int _selectedValue = widget.initialValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: _buildItems(),
        ),
      ),
    );
  }

  List<Widget> _buildItems() {
    return widget.labels.asMap().entries.map((entry) {
      final int day = entry.key;
      final bool isSelected = day == _selectedValue;
      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedValue = day;
          });
          widget.onSelected(day);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00867D) : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.center,
          child: Text(
            entry.value,
            style: TextStyle(
              fontFamily: R.font.sfpro,
              color: isSelected ? Colors.white : Colors.grey[700],
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      );
    }).toList();
  }
}
