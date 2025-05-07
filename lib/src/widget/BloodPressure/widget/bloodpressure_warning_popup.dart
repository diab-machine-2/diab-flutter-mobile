import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/base/keyvalue.dart';

class BloodPressureWarningPopupWidget extends StatefulWidget {
  BloodPressureWarningPopupWidget({super.key, required this.reasons});

  final List<KeyValue> reasons;

  @override
  State<BloodPressureWarningPopupWidget> createState() => _BloodPressureWarningPopupWidgetState();
}

class _BloodPressureWarningPopupWidgetState extends State<BloodPressureWarningPopupWidget> {
  BloodPressureWarningPopupStep _step = BloodPressureWarningPopupStep.warning;

  final List<KeyValue> _selectedReasons = [];
  bool get _isConfirmEnable {
    return _selectedReasons.isNotEmpty;
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: R.color.color0xff636A6B,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Không an toàn',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 40),
              if (_step == BloodPressureWarningPopupStep.warning) ...[
                Text(
                  'Vui lòng cho biết lý do',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
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
                        ),
                        onPressed: _reInput,
                        child: Text(R.string.re_type.tr()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                        ),
                        onPressed: _isConfirmEnable ? _inputtedReason : null,
                        child: Text(R.string.confirm.tr()),
                      ),
                    ),
                  ],
                ),
              ],
              if (_step == BloodPressureWarningPopupStep.confirm) ...[
                Column(
                  children: [
                    const Text(
                      'Nếu có các triệu chứng thở nhanh, đau bụng, nôn ói,.. gặp bác sĩ sớm để được tư vấn và điều chỉnh toa thuốc',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 52),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ElevatedButton(
                        onPressed: _confirm,
                        style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                          minimumSize: Size(double.infinity, 48), // Full width button
                        ),
                        child: Text(R.string.i_understand.tr()),
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
