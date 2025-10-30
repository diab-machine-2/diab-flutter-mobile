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
  void didUpdateWidget(HorizontalSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update selected value when initialValue changes from parent
    if (widget.initialValue != oldWidget.initialValue) {
      setState(() {
        _selectedValue = widget.initialValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: _buildItems(),
      ),
    );
  }

  List<Widget> _buildItems() {
    return widget.labels.asMap().entries.map((entry) {
      final int day = entry.key;
      final bool isSelected = day == _selectedValue;
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedValue = day;
              });
              widget.onSelected(day);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: widget.height,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isSelected ? const Color(0xFF00867D) : Colors.transparent,
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
          ),
        ),
      );
    }).toList();
  }
}
