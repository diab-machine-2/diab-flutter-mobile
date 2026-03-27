import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../res/R.dart';
import '../../../modal/medicine/dose_model.dart';

enum FrequencyType { everyday, weekDays, everyOtherDay }

extension FrequencyTypeExt on FrequencyType {
  String get label {
    switch (this) {
      case FrequencyType.everyday:
        return R.string.everyday.tr();
      case FrequencyType.weekDays:
        return R.string.ngay_trong_tuan.tr();
      case FrequencyType.everyOtherDay:
        return R.string.every_other_day.tr();
    }
  }
}

enum MomentType { before_meal, after_meal, during_meal }

extension MomentTypeExt on MomentType {
  String get label {
    switch (this) {
      case MomentType.before_meal:
        return R.string.truoc_an.tr();
      case MomentType.after_meal:
        return R.string.sau_an.tr();
      case MomentType.during_meal:
        return R.string.during_meal.tr();
    }
  }
}

class DosageInputBottomSheet extends StatefulWidget {
  const DosageInputBottomSheet({Key? key, this.dosage, this.maxTotalQuantity})
      : super(key: key);
  final DosageModel? dosage;

  /// Maximum allowed total dosage across all dose rows
  /// (morning + noon + afternoon + night). When null or <= 0, unlimited.
  final double? maxTotalQuantity;

  @override
  _DosageInputBottomSheetState createState() => _DosageInputBottomSheetState();
}

class _DosageInputBottomSheetState extends State<DosageInputBottomSheet> {
  MomentType _selectedMoment = MomentType.before_meal;
  FrequencyType _selectedFrequency = FrequencyType.everyday;

  // Mỗi ngày states
  TextEditingController _quantityInMorning = TextEditingController(text: "0.0");
  TextEditingController _quantityInNoon = TextEditingController(text: "0.0");
  TextEditingController _quantityInAfternoon =
      TextEditingController(text: "0.0");
  TextEditingController _quantityInEvening = TextEditingController(text: "0.0");

  // Ngày trong tuần states
  double _quantityOnDayInWeek = 0;

  // List to hold the currently selected days
  final List<int> _selectedDayIndexes = [];

  // List of all available days
  final List<String> _weekDays = [
    R.string.chip_monday.tr(),
    R.string.chip_tuesday.tr(),
    R.string.chip_wednesday.tr(),
    R.string.chip_thursday.tr(),
    R.string.chip_friday.tr(),
    R.string.chip_saturday.tr(),
    R.string.chip_sunday.tr(),
  ];

  // Cách ngày states
  int _everyOtherDayNumber = 0;
  double _quantityOnEveryOtherDay = 0;

  // Confirm Button
  bool _submitBtnEnabled = false;

  final Map<TextEditingController, String> _lastValidDoseText = {};
  bool _warningDialogShowing = false;

  double get _maxTotalQuantity {
    final v = widget.maxTotalQuantity;
    if (v == null || v <= 0) return double.infinity;
    return v;
  }

  double _parseDoseText(String text) {
    return double.tryParse(text.replaceAll(',', '.')) ?? 0.0;
  }

  double _currentDoseTotal(
      {TextEditingController? overrideController, double? overrideValue}) {
    double val(TextEditingController c) => (overrideController == c)
        ? (overrideValue ?? 0.0)
        : _parseDoseText(c.text);

    return val(_quantityInMorning) +
        val(_quantityInNoon) +
        val(_quantityInAfternoon) +
        val(_quantityInEvening);
  }

  bool _wouldExceedMaxTotal(
      TextEditingController controller, double nextValue) {
    final nextTotal = _currentDoseTotal(
        overrideController: controller, overrideValue: nextValue);
    return nextTotal > _maxTotalQuantity + 1e-9;
  }

  Future<void> _showExceedMaxWarning() async {
    if (_warningDialogShowing) return;
    _warningDialogShowing = true;
    try {
      await showDialog<void>(
        context: context,
        builder: (ctx) {
          return Container(
            child: AlertDialog(
              contentPadding: EdgeInsets.all(0),
              content: Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(R.drawable.ic_dialog_failed,
                            width: 64, height: 64),
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            R.string.exceed_medicine_warning.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(ctx);
                                  },
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
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                        icon: Icon(Icons.close, color: R.color.color0xffBEC0C8),
                        onPressed: () {
                          Navigator.pop(ctx);
                        }),
                  )
                ],
              ),
            ),
          );
        },
      );
    } finally {
      _warningDialogShowing = false;
    }
  }

  void _revertDose(TextEditingController controller) {
    final fallback = _lastValidDoseText[controller] ?? '0.0';
    if (controller.text == fallback) return;
    setState(() {
      controller.text = fallback;
      _checkEnableSubmitBtnState();
    });
  }

  void _acceptDose(TextEditingController controller, String text) {
    _lastValidDoseText[controller] = text;
  }

  bool _validateBeforeSubmit() {
    if (_currentDoseTotal() <= _maxTotalQuantity + 1e-9) {
      return true;
    }

    final doseControllers = <TextEditingController>[
      _quantityInMorning,
      _quantityInNoon,
      _quantityInAfternoon,
      _quantityInEvening,
    ];

    // Revert controllers that have unaccepted text first (typed by keyboard).
    for (final controller in doseControllers) {
      final lastValid = _lastValidDoseText[controller] ?? '0.0';
      if (controller.text != lastValid) {
        _revertDose(controller);
      }
    }

    // If still invalid, keep reverting until valid (fallback safety).
    if (_currentDoseTotal() > _maxTotalQuantity + 1e-9) {
      for (final controller in doseControllers) {
        _revertDose(controller);
        if (_currentDoseTotal() <= _maxTotalQuantity + 1e-9) {
          break;
        }
      }
    }

    _showExceedMaxWarning();
    return false;
  }

  @override
  void initState() {
    if (widget.dosage != null) {
      _quantityInMorning.text =
          (widget.dosage?.quantityInMorning ?? 0).toString();
      _quantityInNoon.text = (widget.dosage?.quantityInNoon ?? 0).toString();
      _quantityInAfternoon.text =
          (widget.dosage?.quantityInAfternoon ?? 0).toString();
      _quantityInEvening.text =
          (widget.dosage?.quantityInNight ?? 0).toString();

      // frequency in DosageModel is 1,2,3 (everyday, weekdays, every other day)
      if (widget.dosage?.frequency == 1) {
        _selectedFrequency = FrequencyType.everyday;
      } else if (widget.dosage?.frequency == 2) {
        _selectedFrequency = FrequencyType.weekDays;
      } else {
        _selectedFrequency = FrequencyType.everyOtherDay;
      }

      // moment in DosageModel is 1,2,3 (before, after, during meal)
      if (widget.dosage?.moment == 1) {
        _selectedMoment = MomentType.before_meal;
      } else if (widget.dosage?.moment == 2) {
        _selectedMoment = MomentType.after_meal;
      } else {
        _selectedMoment = MomentType.during_meal;
      }

      if (widget.dosage?.selectedDaysInWeek != null) {
        _selectedDayIndexes.addAll(widget.dosage!.selectedDaysInWeek);
      }

      if (widget.dosage?.quantityForDaysInWeek != null) {
        _quantityOnDayInWeek = widget.dosage!.quantityForDaysInWeek;
      }

      if (widget.dosage?.everyOtherDayNumber != null) {
        _everyOtherDayNumber = widget.dosage!.everyOtherDayNumber;
        _quantityOnEveryOtherDay = widget.dosage!.quantityForEveryOtherDay;
      }

      // Ensure confirm button reflects existing dosage when editing
      final morningQuantity = double.tryParse(_quantityInMorning.text) ?? 0.0;
      final noonQuantity = double.tryParse(_quantityInNoon.text) ?? 0.0;
      final afternoonQuantity =
          double.tryParse(_quantityInAfternoon.text) ?? 0.0;
      final eveningQuantity = double.tryParse(_quantityInEvening.text) ?? 0.0;

      if (_selectedFrequency == FrequencyType.everyday) {
        _submitBtnEnabled = morningQuantity > 0.0 ||
            noonQuantity > 0.0 ||
            afternoonQuantity > 0.0 ||
            eveningQuantity > 0.0;
      } else if (_selectedFrequency == FrequencyType.weekDays) {
        _submitBtnEnabled =
            (_selectedDayIndexes.isNotEmpty && _quantityOnDayInWeek > 0) &&
                (morningQuantity > 0.0 ||
                    noonQuantity > 0.0 ||
                    afternoonQuantity > 0.0 ||
                    eveningQuantity > 0.0);
      } else {
        _submitBtnEnabled =
            (_everyOtherDayNumber > 0 && _quantityOnEveryOtherDay > 0) &&
                (morningQuantity > 0.0 ||
                    noonQuantity > 0.0 ||
                    afternoonQuantity > 0.0 ||
                    eveningQuantity > 0.0);
      }
    }
    _lastValidDoseText[_quantityInMorning] = _quantityInMorning.text;
    _lastValidDoseText[_quantityInNoon] = _quantityInNoon.text;
    _lastValidDoseText[_quantityInAfternoon] = _quantityInAfternoon.text;
    _lastValidDoseText[_quantityInEvening] = _quantityInEvening.text;
    super.initState();
  }

  void _updateCounter(VoidCallback updateFunction) {
    setState(() {
      updateFunction();
    });

    _checkEnableSubmitBtnState();
  }

  void _checkEnableSubmitBtnState() {
    setState(() {
      final morningQuantity = double.tryParse(_quantityInMorning.text) ?? 0.0;
      final noonQuantity = double.tryParse(_quantityInNoon.text) ?? 0.0;
      final afternoonQuantity =
          double.tryParse(_quantityInAfternoon.text) ?? 0.0;
      final eveningQuantity = double.tryParse(_quantityInEvening.text) ?? 0.0;
      if (_selectedFrequency == FrequencyType.everyday) {
        _submitBtnEnabled = morningQuantity > 0.0 ||
            noonQuantity > 0.0 ||
            afternoonQuantity > 0.0 ||
            eveningQuantity > 0.0;
      } else if (_selectedFrequency == FrequencyType.weekDays) {
        _submitBtnEnabled =
            (_selectedDayIndexes.isNotEmpty && _quantityOnDayInWeek > 0) &&
                (morningQuantity > 0.0 ||
                    noonQuantity > 0.0 ||
                    afternoonQuantity > 0.0 ||
                    eveningQuantity > 0.0);
      } else {
        _submitBtnEnabled =
            (_everyOtherDayNumber > 0 && _quantityOnEveryOtherDay > 0) &&
                (morningQuantity > 0.0 ||
                    noonQuantity > 0.0 ||
                    afternoonQuantity > 0.0 ||
                    eveningQuantity > 0.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    double maxHeight = screenHeight - 90;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: const SizedBox.shrink(),
          ),
        ),
        DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.5,
          maxChildSize: maxHeight / screenHeight,
          builder: (context, scrollController) => Container(
            width: double.infinity,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(),
                              Container(
                                color: Colors.white,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 16),
                                    _buildSectionTitle(
                                        R.string.time_of_use.tr()),
                                    _buildMomentSelector(),
                                    const SizedBox(height: 16),
                                    _buildSectionTitle(
                                        R.string.frequency_of_use.tr()),
                                    _buildFrequencySelector(),
                                    const SizedBox(height: 16),
                                    if (_selectedFrequency ==
                                        FrequencyType.everyday)
                                      ..._buildEveryDayController()
                                    else if (_selectedFrequency ==
                                        FrequencyType.weekDays)
                                      ..._buildDayInWeekController()
                                    else
                                      ..._buildEveryOtherDayController(),
                                    const SizedBox(height: 24),
                                  ],
                                ),
                              ),
                            ],
                          )),
                    ),
                  ),
                  // Keep confirm button above keyboard when visible
                  Padding(
                    padding: EdgeInsets.only(bottom: keyboardHeight),
                    child: _buildConfirmButton(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
        width: double.infinity,
        height: 56,
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF9F7),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          R.string.dosage.tr(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            height: 1.32,
            letterSpacing: 0.2,
          ),
        ));
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4C4C4C),
        ),
      ),
    );
  }

  Widget _buildMomentSelector() {
    return Row(
      children: [
        const SizedBox(width: 8),
        ...MomentType.values.map((moment) {
          final isSelected = _selectedMoment == moment;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMoment = moment;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:
                        isSelected ? const Color(0xFF008D67) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    moment.label,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w400,
                      fontSize: 15,
                      color: isSelected ? Colors.white : Color(0xFF5E6566),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
        const SizedBox(width: 8),
      ],
    );
  }

  // Tần suất dùng
  Widget _buildFrequencySelector() {
    return Row(
      children: [
        const SizedBox(width: 8),
        ...FrequencyType.values.map((frequency) {
          final isSelected = _selectedFrequency == frequency;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedFrequency = frequency;
                  });
                  _checkEnableSubmitBtnState();
                },
                child: AnimatedContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  duration: const Duration(milliseconds: 200),
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:
                        isSelected ? const Color(0xFF008D67) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    frequency.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w400,
                      fontSize: 15,
                      color: isSelected ? Colors.white : Color(0xFF5E6566),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
        const SizedBox(width: 8),
      ],
    );
  }

  // Mỗi ngày counters
  List<Widget> _buildEveryDayController() {
    return [
      _buildSectionTitle(R.string.dosage.tr()),
      _buildDosageRow(
          R.string.the_morning.tr(),
          R.icons.ic_morning,
          _quantityInMorning,
          (value) => setState(() {
                _quantityInMorning.text = value;
                _checkEnableSubmitBtnState();
              })),
      _buildDosageRow(
          R.string.the_noon.tr(),
          R.icons.ic_noon,
          _quantityInNoon,
          (value) => setState(() {
                _quantityInNoon.text = value;
                _checkEnableSubmitBtnState();
              })),
      _buildDosageRow(
          R.string.the_afternoon.tr(),
          R.icons.ic_afternoon,
          _quantityInAfternoon,
          (value) => setState(() {
                _quantityInAfternoon.text = value;
                _checkEnableSubmitBtnState();
              })),
      _buildDosageRow(
          R.string.the_night.tr(),
          R.icons.ic_night,
          _quantityInEvening,
          (value) => setState(() {
                _quantityInEvening.text = value;
                _checkEnableSubmitBtnState();
              })),
      if (getQuantity(_quantityInMorning) == 0.0 &&
          getQuantity(_quantityInNoon) == 0.0 &&
          getQuantity(_quantityInAfternoon) == 0.0 &&
          getQuantity(_quantityInEvening) == 0.0)
        Padding(
          padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Row(children: [
            SvgPicture.asset(
              R.icons.ic_information,
              width: 14,
              height: 14,
              semanticsLabel: 'caution',
            ),
            SizedBox(width: 3),
            Text(
              R.string.please_input_dosage.tr(),
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12,
                height: 1.50,
                letterSpacing: 0.2,
                color: Color(0xFFAF0000),
              ),
            ),
          ]),
        ),
    ];
  }

  double getQuantity(TextEditingController controller) {
    return double.tryParse(controller.text) ?? 0.0;
  }

  Widget _buildDosageRow(String title, String iconRes,
      TextEditingController controller, Function(String) onValueChange) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Row(
        children: [
          SvgPicture.asset(
            iconRes,
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 1.46,
              letterSpacing: 0.4,
              color: Color(0xFF111515),
            ),
          ),
          const Spacer(),
          ..._buildDosageCounter(controller, onValueChange),
        ],
      ),
    );
  }

  List<Widget> _buildDosageCounter(
      TextEditingController controller, Function(String) onValueChange) {
    return [
      GestureDetector(
        onTap: () {
          final parseValue = _parseDoseText(controller.text);
          final nextValue =
              (parseValue - 1.0) >= 0.0 ? (parseValue - 1.0) : 0.0;
          final nextText = nextValue.toString();
          _acceptDose(controller, nextText);
          setState(() {
            onValueChange(nextText);
          });
        },
        child: Container(
          width: 34,
          height: 32,
          decoration: BoxDecoration(
            color: Color(0xFFF4F7F7),
            borderRadius: BorderRadius.horizontal(
                left: Radius.circular(4), right: Radius.zero),
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            R.icons.ic_minus,
            width: 10,
            height: 2,
          ),
        ),
      ),
      Container(
        width: 60,
        height: 36,
        alignment: Alignment.center,
        child: TextField(
          controller: controller,
          textAlign: TextAlign.center,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            TextInputFormatter.withFunction((oldValue, newValue) {
              final text = newValue.text.replaceAll(',', '.');
              return newValue.copyWith(
                text: text,
                selection: TextSelection.collapsed(offset: text.length),
              );
            }),
          ],
          onChanged: (value) {
            _checkEnableSubmitBtnState();
          },
          onSubmitted: (_) {
            final next = _parseDoseText(controller.text);
            if (_wouldExceedMaxTotal(controller, next)) {
              _showExceedMaxWarning();
              _revertDose(controller);
              return;
            }
            _acceptDose(controller, controller.text);
            _checkEnableSubmitBtnState();
          },
          onEditingComplete: () {
            final next = _parseDoseText(controller.text);
            if (_wouldExceedMaxTotal(controller, next)) {
              _showExceedMaxWarning();
              _revertDose(controller);
              FocusScope.of(context).unfocus();
              return;
            }
            _acceptDose(controller, controller.text);
            _checkEnableSubmitBtnState();
            FocusScope.of(context).unfocus();
          },
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: '0.0',
            contentPadding: EdgeInsets.zero,
            isDense: true,
          ),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            height: 1.32,
            letterSpacing: 0.2,
          ),
        ),
      ),
      GestureDetector(
        onTap: () {
          final parseValue = _parseDoseText(controller.text);
          final nextValue = parseValue + 1.0;
          if (_wouldExceedMaxTotal(controller, nextValue)) {
            _showExceedMaxWarning();
            return;
          }
          final nextText = nextValue.toString();
          _acceptDose(controller, nextText);
          setState(() {
            onValueChange(nextText);
          });
        },
        child: Container(
          width: 34,
          height: 32,
          decoration: BoxDecoration(
            color: Color(0xFFF4F7F7),
            borderRadius: BorderRadius.horizontal(
                left: Radius.zero, right: Radius.circular(4)),
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            R.icons.ic_plus,
            width: 12,
            height: 12,
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildDayInWeekController() {
    List<Widget> chips = [];
    for (int i = 0; i < _weekDays.length; i++) {
      final bool isSelected = _selectedDayIndexes.contains(i);
      final day = _weekDays[i];
      final chip = ChoiceChip(
        label: Text(
          day,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 15,
            height: 1.46,
            letterSpacing: 0.4,
            color: isSelected ? Colors.white : Color(0xFF5E6566),
          ),
        ),
        selected: isSelected,
        selectedColor: Color(0xFF008479),
        onSelected: (bool selected) {
          setState(() {
            if (selected) {
              _selectedDayIndexes.add(i);
            } else {
              _selectedDayIndexes.remove(i);
            }
          });
          _checkEnableSubmitBtnState();
        },
        // Optional styling to match the image
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(
            color: isSelected
                ? Colors.teal
                : Colors.grey, // Teal border when selected, grey when not
            width: 1.0,
          ),
        ),
        labelStyle: TextStyle(
          color: isSelected ? Colors.teal.shade800 : Colors.black87,
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      );
      chips.add(chip);
    }

    return [
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFF008479), width: 1.0),
          borderRadius: BorderRadius.circular(16.0),
        ),
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Wrap(
          spacing: 3.0, // horizontal space between chips
          children: chips,
        ),
      ),
      const SizedBox(height: 20),
      const Divider(
        color: Color(0xFFF4F5F6),
        thickness: 1,
        height: 1,
        indent: 12,
        endIndent: 12,
      ),
      const SizedBox(height: 20),
      _buildCounterController(
        R.string.current_medicine_quantity.tr(),
        _quantityOnDayInWeek,
        '0.0',
        () => _updateCounter(() {
          _quantityOnDayInWeek++;
          _quantityOnEveryOtherDay = _quantityOnDayInWeek;
        }),
        () => _updateCounter(() {
          _quantityOnDayInWeek--;
          _quantityOnEveryOtherDay = _quantityOnDayInWeek;
        }),
        (value) => _updateCounter(() {
          final v = double.tryParse(value) ?? 0;
          _quantityOnDayInWeek = v;
          _quantityOnEveryOtherDay = v;
        }),
      ),
      const SizedBox(height: 20),
      _buildSectionTitle(R.string.dosage.tr()),
      _buildDosageRow(
          R.string.the_morning.tr(),
          R.icons.ic_morning,
          _quantityInMorning,
          (value) => setState(() {
                _quantityInMorning.text = value;
                _checkEnableSubmitBtnState();
              })),
      _buildDosageRow(
          R.string.the_noon.tr(),
          R.icons.ic_noon,
          _quantityInNoon,
          (value) => setState(() {
                _quantityInNoon.text = value;
                _checkEnableSubmitBtnState();
              })),
      _buildDosageRow(
          R.string.the_afternoon.tr(),
          R.icons.ic_afternoon,
          _quantityInAfternoon,
          (value) => setState(() {
                _quantityInAfternoon.text = value;
                _checkEnableSubmitBtnState();
              })),
      _buildDosageRow(
          R.string.the_night.tr(),
          R.icons.ic_night,
          _quantityInEvening,
          (value) => setState(() {
                _quantityInEvening.text = value;
                _checkEnableSubmitBtnState();
              })),
      if (getQuantity(_quantityInMorning) == 0.0 &&
          getQuantity(_quantityInNoon) == 0.0 &&
          getQuantity(_quantityInAfternoon) == 0.0 &&
          getQuantity(_quantityInEvening) == 0.0)
        Padding(
          padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Row(children: [
            SvgPicture.asset(
              R.icons.ic_information,
              width: 14,
              height: 14,
              semanticsLabel: 'caution',
            ),
            SizedBox(width: 3),
            Text(
              R.string.please_input_dosage.tr(),
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12,
                height: 1.50,
                letterSpacing: 0.2,
                color: Color(0xFFAF0000),
              ),
            ),
          ]),
        ),
      const SizedBox(height: 20),
    ];
  }

  List<Widget> _buildEveryOtherDayController() {
    return [
      _buildCounterController(
        R.string.every_other_day.tr(),
        _everyOtherDayNumber.toDouble(),
        '00',
        () => _updateCounter(() => _everyOtherDayNumber++),
        () => _updateCounter(() => _everyOtherDayNumber--),
        (value) => _updateCounter(() {
          int validValue;
          if (value.endsWith('.')) {
            validValue =
                int.tryParse(value.substring(0, value.length - 1)) ?? 0;
          } else {
            validValue = int.tryParse(value) ?? 0;
          }
          _everyOtherDayNumber = validValue;
        }),
      ),
      const SizedBox(height: 20),
      const Divider(
        color: Color(0xFFF4F5F6),
        thickness: 1,
        height: 1,
        indent: 12,
        endIndent: 12,
      ),
      const SizedBox(height: 20),
      _buildCounterController(
        R.string.current_medicine_quantity.tr(),
        _quantityOnEveryOtherDay,
        '0.0',
        () => _updateCounter(() {
          _quantityOnEveryOtherDay++;
          _quantityOnDayInWeek = _quantityOnEveryOtherDay;
        }),
        () => _updateCounter(() {
          _quantityOnEveryOtherDay--;
          _quantityOnDayInWeek = _quantityOnEveryOtherDay;
        }),
        (value) => _updateCounter(() {
          final v = double.tryParse(value) ?? 0.0;
          _quantityOnEveryOtherDay = v;
          _quantityOnDayInWeek = v;
        }),
      ),
      const SizedBox(height: 20),
      _buildSectionTitle(R.string.dosage.tr()),
      _buildDosageRow(
          R.string.the_morning.tr(),
          R.icons.ic_morning,
          _quantityInMorning,
          (value) => setState(() {
                _quantityInMorning.text = value;
                _checkEnableSubmitBtnState();
              })),
      _buildDosageRow(
          R.string.the_noon.tr(),
          R.icons.ic_noon,
          _quantityInNoon,
          (value) => setState(() {
                _quantityInNoon.text = value;
                _checkEnableSubmitBtnState();
              })),
      _buildDosageRow(
          R.string.the_afternoon.tr(),
          R.icons.ic_afternoon,
          _quantityInAfternoon,
          (value) => setState(() {
                _quantityInAfternoon.text = value;
                _checkEnableSubmitBtnState();
              })),
      _buildDosageRow(
          R.string.the_night.tr(),
          R.icons.ic_night,
          _quantityInEvening,
          (value) => setState(() {
                _quantityInEvening.text = value;
                _checkEnableSubmitBtnState();
              })),
      if (getQuantity(_quantityInMorning) == 0.0 &&
          getQuantity(_quantityInNoon) == 0.0 &&
          getQuantity(_quantityInAfternoon) == 0.0 &&
          getQuantity(_quantityInEvening) == 0.0)
        Padding(
          padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Row(children: [
            SvgPicture.asset(
              R.icons.ic_information,
              width: 14,
              height: 14,
              semanticsLabel: 'caution',
            ),
            SizedBox(width: 3),
            Text(
              R.string.please_input_dosage.tr(),
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12,
                height: 1.50,
                letterSpacing: 0.2,
                color: Color(0xFFAF0000),
              ),
            ),
          ]),
        ),
      const SizedBox(height: 20),
    ];
  }

  Widget _buildCounterController(
    String label,
    double value,
    String hint,
    VoidCallback onIncrement,
    VoidCallback onDecrement,
    Function(String) onValueChange,
  ) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 12.0),
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Color(0xFF008479), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                height: 1.46,
                color: Color(0xFF111515),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onDecrement,
              child: Container(
                width: 34,
                height: 32,
                decoration: BoxDecoration(
                  color: Color(0xFFF4F7F7),
                  borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(4), right: Radius.zero),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  R.icons.ic_minus,
                  width: 10,
                  height: 2,
                ),
              ),
            ),
            // Counter value text
            Container(
                width: 60,
                height: 36,
                alignment: Alignment.center,
                child: TextField(
                  controller:
                      TextEditingController(text: value.toStringAsFixed(0)),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hint,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  onChanged: (value) {
                    onValueChange(value);
                  },
                )),
            // Increment button
            GestureDetector(
              onTap: onIncrement,
              child: Container(
                width: 34,
                height: 32,
                decoration: BoxDecoration(
                  color: Color(0xFFF4F7F7),
                  borderRadius: BorderRadius.horizontal(
                      left: Radius.zero, right: Radius.circular(4)),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  R.icons.ic_plus,
                  width: 12,
                  height: 12,
                ),
              ),
            )
          ],
        ));
  }

  // Submit button
  Widget _buildConfirmButton() {
    return Container(
      width: double.infinity,
      height: 90,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 30),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        // Shadow on top
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 1,
          blurRadius: 10,
          offset: Offset(0, -1),
        ),
        // Glowing effect
        BoxShadow(
          color: Color(0xFF0DAB9C).withOpacity(0.6),
          spreadRadius: 1,
          blurRadius: 20,
          offset: Offset(0, 12),
        ),
      ]),
      child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            if (!_submitBtnEnabled) return;
            if (!_validateBeforeSubmit()) return;
            DosageModel dosage;
            if (FrequencyType.everyday == _selectedFrequency) {
              dosage = DosageModel(
                momentName: _selectedMoment.label,
                // Store as 1,2,3
                moment: _selectedMoment.index + 1,
                frequencyName: _selectedFrequency.label,
                // Store as 1,2,3
                frequency: _selectedFrequency.index + 1,
                quantityForDaysInWeek: _quantityOnDayInWeek,
                quantityForEveryOtherDay: _quantityOnEveryOtherDay,
                quantityInMorning: _parseDoseText(_quantityInMorning.text),
                quantityInNoon: _parseDoseText(_quantityInNoon.text),
                quantityInAfternoon: _parseDoseText(_quantityInAfternoon.text),
                quantityInNight: _parseDoseText(_quantityInEvening.text),
              );
            } else if (FrequencyType.weekDays == _selectedFrequency) {
              dosage = DosageModel(
                momentName: _selectedMoment.label,
                moment: _selectedMoment.index + 1,
                frequencyName: _selectedFrequency.label,
                frequency: _selectedFrequency.index + 1,
                selectedDaysInWeek: _selectedDayIndexes,
                quantityForDaysInWeek: _quantityOnDayInWeek,
                quantityForEveryOtherDay: _quantityOnEveryOtherDay,
                quantityInMorning: _parseDoseText(_quantityInMorning.text),
                quantityInNoon: _parseDoseText(_quantityInNoon.text),
                quantityInAfternoon: _parseDoseText(_quantityInAfternoon.text),
                quantityInNight: _parseDoseText(_quantityInEvening.text),
              );
            } else {
              dosage = DosageModel(
                momentName: _selectedMoment.label,
                moment: _selectedMoment.index + 1,
                frequencyName: _selectedFrequency.label,
                frequency: _selectedFrequency.index + 1,
                everyOtherDayNumber: _everyOtherDayNumber,
                quantityForDaysInWeek: _quantityOnDayInWeek,
                quantityForEveryOtherDay: _quantityOnEveryOtherDay,
                quantityInMorning: _parseDoseText(_quantityInMorning.text),
                quantityInNoon: _parseDoseText(_quantityInNoon.text),
                quantityInAfternoon: _parseDoseText(_quantityInAfternoon.text),
                quantityInNight: _parseDoseText(_quantityInEvening.text),
              );
            }
            Navigator.of(context).pop(dosage);
          },
          child: Container(
            width: double.infinity,
            height: 44,
            decoration: BoxDecoration(
              color: _submitBtnEnabled
                  ? const Color(0xFF008D67)
                  : Color(0xFFBFC6C6),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Center(
              child: Text(
                R.string.confirm.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  height: 1.46,
                  letterSpacing: 0.4,
                  color: _submitBtnEnabled ? Colors.white : Color(0xFF5E6566),
                ),
              ),
            ),
          )),
    );
  }
}
