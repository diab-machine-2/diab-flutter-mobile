import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medical/res/R.dart';
import '../models/goal_record_type.dart';

class EnterTimeWidget extends StatefulWidget {
  const EnterTimeWidget({
    required this.title,
    required this.type,
    this.selectable = true,
    required this.onChangedTime,
    this.onChangeUnit,
    this.controller,
  });
  final String title;
  final GoalRecordType type;
  final bool selectable;
  final Function(String text) onChangedTime;
  final Function(GoalRecordType type)? onChangeUnit;
  final TextEditingController? controller;

  @override
  State<EnterTimeWidget> createState() => _EnterTimeWidgetState();
}

class _EnterTimeWidgetState extends State<EnterTimeWidget> {
  late GoalRecordType _type;

  @override
  void initState() {
    super.initState();
    _type = widget.type;
  }

  @override
  Widget build(BuildContext context) {
    return _buildItemLayout(
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                R.drawable.ic_clock,
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    color: R.color.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                color: R.color.transparent,
                width: 70,
                child: TextField(
                    controller: widget.controller,
                    autofocus: false,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: R.color.textFieldGrey,
                      fontSize: 40,
                      fontWeight: FontWeight.w400,
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 3,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9]'),
                      ),
                    ],
                    decoration: const InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      hintText: '-',
                      contentPadding: EdgeInsets.only(
                        left: 0,
                        bottom: 0,
                        top: 8,
                        right: 0,
                      ),
                    ),
                    onChanged: widget.onChangedTime),
              ),
              if (widget.selectable)
                DropdownButtonHideUnderline(
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButton<GoalRecordType>(
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                        color: R.color.textDark,
                      ),
                      hint: Text(
                        _type.unit,
                        style: TextStyle(
                          color: R.color.textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      items: <GoalRecordType>[
                        GoalRecordType.time,
                        GoalRecordType.frequency
                      ].map((GoalRecordType value) {
                        return DropdownMenuItem<GoalRecordType>(
                          value: value,
                          child: Text(value.unit),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _type = value;
                          if (widget.onChangeUnit != null) {
                            widget.onChangeUnit!(_type);
                          }
                          setState(() {});
                        }
                      },
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: Text(
                    widget.type.unit,
                    style: TextStyle(
                      color: R.color.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
            ],
          ),
          Container(height: 1, width: 90, color: R.color.color0xffE5E5E5),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildItemLayout(
      {required Widget child,
      EdgeInsetsGeometry? margin,
      bool isValid = true}) {
    return Container(
      margin: margin ?? const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(16),
        border: isValid ? null : Border.all(color: Colors.red),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      child: child,
    );
  }
}
