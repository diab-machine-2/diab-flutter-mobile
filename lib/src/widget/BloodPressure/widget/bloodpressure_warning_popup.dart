import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/base/keyvalue.dart';

class BloodPressureWarningPopupWidget extends StatefulWidget {
  BloodPressureWarningPopupWidget(
      {super.key, required this.reasons, this.initValue = const []});

  final List<KeyValue> reasons;

  final List<String>? initValue;
  @override
  State<BloodPressureWarningPopupWidget> createState() =>
      _BloodPressureWarningPopupWidgetState();
}

class _BloodPressureWarningPopupWidgetState
    extends State<BloodPressureWarningPopupWidget> {
  BloodPressureWarningPopupStep _step = BloodPressureWarningPopupStep.warning;

  final List<KeyValue> _selectedReasons = [];
  bool get _isConfirmEnable {
    return _selectedReasons.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();

    final initKeys = widget.initValue ?? [];

    if (initKeys.length == 0) return;

    for (final reason in widget.reasons) {
      if (initKeys.contains(reason.value)) {
        _selectedReasons.add(reason);
      }
    }
  }

  void _inputtedReason() {
    setState(() {
      _step = BloodPressureWarningPopupStep.confirm;
    });
  }

  void _reInput() {
    _selectedReasons.clear();
    Navigator.of(context).pop(false);
  }

  void _confirm() {
    Navigator.of(context).pop(_selectedReasons);
  }

  // Linear gradient for buttons: linear-gradient(139deg, #0FB4A5 -7.19%, #008479 68.38%, #008479 99.99%)
  // 139 degrees in CSS = approximately -0.7547, 0.6561 in Flutter Alignment coordinates
  static const LinearGradient _buttonGradient = LinearGradient(
    begin: Alignment(-0.7547, 0.6561), // 139 degrees from CSS
    end: Alignment(0.7547, -0.6561), // Opposite direction
    colors: [
      Color(0xFF0FB4A5), // #0FB4A5
      Color(0xFF008479), // #008479
      Color(0xFF008479), // #008479
    ],
    stops: [0.0, 0.6838, 1.0], // -7.19% -> 0.0, 68.38% -> 0.6838, 99.99% -> 1.0
  );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: R.color.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // close button at top right
              Transform.translate(
                offset: const Offset(12, 0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: _reInput,
                    icon: const Icon(Icons.close),
                  ),
                ),
              ),
              Image.asset(
                R.drawable.ic_bloodpressure_warning,
                width: 43,
                height: 43,
              ),
              const SizedBox(height: 12),
              Text(
                'Huyết áp trong ngưỡng',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: R.color.color0xff636A6B,
                  fontFamily: R.font.sfpro,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Không an toàn',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  height: 1.22,
                  color: R.color.color0xff111515,
                  fontFamily: R.font.sfpro,
                ),
              ),
              const SizedBox(height: 40),
              if (_step == BloodPressureWarningPopupStep.warning) ...[
                Text(
                  'Vui lòng cho biết lý do',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: R.font.sfpro,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 5,
                  runSpacing: 0,
                  alignment: WrapAlignment.center,
                  runAlignment: WrapAlignment.center,
                  children:
                      // Chip when unselect will think-text and light gray color
                      // Chip when selected will bold-text and background mainColor and text white
                      widget.reasons.map(
                    (reason) {
                      final selected = _selectedReasons.contains(reason);
                      return ChoiceChip(
                        elevation: 0,
                        pressElevation: 0.1,
                        label: Text(
                          reason.value,
                          style: TextStyle(
                            color: selected ? R.color.white : Color(0xFF636A6B),
                            fontWeight:
                                selected ? FontWeight.bold : FontWeight.normal,
                            fontFamily: R.font.sfpro,
                          ),
                        ),
                        selected: selected,
                        selectedColor: R.color.mainColor,
                        backgroundColor: Color(0xFFF7F8F8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        onSelected: (bool selected) {
                          // Handle selection
                          if (selected) {
                            _selectedReasons.add(reason);
                          } else {
                            _selectedReasons.remove(reason);
                          }
                          setState(() {});
                        },
                      );
                    },
                  ).toList(),
                ),
                const SizedBox(height: 52),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: const StadiumBorder(),
                          side: BorderSide(color: R.color.greenGradientBottom),
                          minimumSize: Size(double.infinity, 48),
                        ),
                        onPressed: _reInput,
                        child: Text(
                          R.string.re_type.tr(),
                          style: TextStyle(
                            color: R.color.greenGradientBottom,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            fontFamily: R.font.sfpro,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _isConfirmEnable ? _inputtedReason : null,
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: _isConfirmEnable ? _buttonGradient : null,
                            color: _isConfirmEnable ? null : R.color.grey200,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Center(
                            child: Text(
                              "Lưu",
                              style: TextStyle(
                                color: _isConfirmEnable
                                    ? R.color.white
                                    : R.color.grey,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                fontFamily: R.font.sfpro,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (_step == BloodPressureWarningPopupStep.confirm) ...[
                Column(
                  children: [
                    Text(
                      'Nếu có các triệu chứng thở nhanh, đau bụng, nôn ói,.. gặp bác sĩ sớm để được tư vấn và điều chỉnh toa thuốc',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        color: R.color.color0xff111515,
                        height: 1.46,
                        fontFamily: R.font.sfpro,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: InkWell(
                        onTap: _confirm,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 10,
                          ),
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: _buttonGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              R.string.i_understand.tr(),
                              style: TextStyle(
                                fontFamily: R.font.sfpro,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: R.color.white,
                                height: 1.46,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

enum BloodPressureWarningPopupStep {
  warning,
  confirm,
}
