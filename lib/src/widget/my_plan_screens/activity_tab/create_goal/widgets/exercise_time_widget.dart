import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medical/res/R.dart';

class ExerciseTimeWidget extends StatefulWidget {
  const ExerciseTimeWidget({
    required this.totalMinutes,
    required this.onChangedTime,
  });

  final int totalMinutes;
  final Function(int totalMinutes) onChangedTime;

  @override
  State<ExerciseTimeWidget> createState() => _ExerciseTimeWidgetState();
}

class _ExerciseTimeWidgetState extends State<ExerciseTimeWidget> {
  int _hour = 0;
  int _minute = 0;

  final TextEditingController _hourController = TextEditingController();
  final TextEditingController _minuteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _hour = widget.totalMinutes ~/ 60;
    _minute = widget.totalMinutes - (_hour * 60);
    _hourController.text = _hour.toString();
    _minuteController.text = _minute.toString();
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
              Text(
                R.string.so_phut_van_dong_moi_ngay.tr(),
                style: TextStyle(
                  color: R.color.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTextField(
                controller: _hourController,
                unit: 'giờ',
                onChanged: (newValue) {
                  try {
                    _hour = int.parse(newValue);
                  } catch (_) {
                    _hour = 0;
                  }
                  widget.onChangedTime(totalMinutes);
                },
              ),
              const SizedBox(width: 32),
              _buildTextField(
                controller: _minuteController,
                unit: 'phút',
                onChanged: (newValue) {
                  try {
                    _minute = int.parse(newValue);
                  } catch (_) {
                    _minute = 0;
                  }
                  widget.onChangedTime(totalMinutes);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String unit,
    required Function(String value) onChanged,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              color: R.color.transparent,
              width: 70,
              child: TextField(
                controller: controller,
                autofocus: false,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: R.color.textFieldGrey,
                  fontSize: 40,
                  fontWeight: FontWeight.w400,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[0-9]'),
                  ),
                ],
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  hintText: '-',
                  counterText: '',
                  contentPadding: EdgeInsets.only(
                    left: 0,
                    bottom: 0,
                    top: 8,
                    right: 0,
                  ),
                ),
                onChanged: onChanged,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 14.0),
              child: Text(
                unit,
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
      ],
    );
  }

  int get totalMinutes => _hour * 60 + _minute;

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
