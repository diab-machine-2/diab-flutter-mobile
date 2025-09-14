import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../res/R.dart';
import '../../../modal/medicine/dose_model.dart';
import '../../../modal/medicine/medicine_add_model.dart';

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
  const DosageInputBottomSheet({Key? key}) : super(key: key);

  @override
  _DosageInputBottomSheetState createState() => _DosageInputBottomSheetState();
}

class _DosageInputBottomSheetState extends State<DosageInputBottomSheet> {
  MomentType _selectedMoment = MomentType.before_meal;
  FrequencyType _selectedFrequency = FrequencyType.everyday;

  // Mỗi ngày states
  TextEditingController _quantityInMorning = TextEditingController(text: "0.0");
  TextEditingController _quantityInNoon = TextEditingController(text: "0.0");
  TextEditingController _quantityInAfternoon = TextEditingController(text: "0.0");
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

  void _updateCounter(VoidCallback updateFunction) {
    setState(() {
      updateFunction();
    });

    _checkEnableSubmitBtnState();
  }

  void _checkEnableSubmitBtnState() {
    setState(() {
      if (_selectedFrequency == FrequencyType.everyday) {
        final morningQuantity = double.tryParse(_quantityInMorning.text) ?? 0.0;
        final noonQuantity = double.tryParse(_quantityInNoon.text) ?? 0.0;
        final afternoonQuantity = double.tryParse(_quantityInAfternoon.text) ?? 0.0;
        final eveningQuantity = double.tryParse(_quantityInEvening.text) ?? 0.0;

        _submitBtnEnabled = morningQuantity > 0.0 || noonQuantity > 0.0 || afternoonQuantity > 0.0 || eveningQuantity > 0.0;
      } else if (_selectedFrequency == FrequencyType.weekDays) {
        _submitBtnEnabled = _selectedDayIndexes.isNotEmpty && _quantityOnDayInWeek > 0;
      } else {
        _submitBtnEnabled = _everyOtherDayNumber > 0 && _quantityOnEveryOtherDay > 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    double maxHeight = screenHeight - 90;

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.5,
      maxChildSize: maxHeight / screenHeight,
      builder: (context, scrollController) => Container(
        width: double.infinity,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 72,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  // final newSize = scrollController.offset + (details.primaryDelta ?? 0);
                  // scrollController.jumpTo(
                  //   newSize.clamp(0.2, maxHeight/screenHeight),
                  // );
                  scrollController.jumpTo(200);

                  // scrollController.animateTo(100, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  // scrollController.jumpTo(scrollController.offset + (details.primaryDelta ?? 0));
                  // scrollController.animateTo(scrollController.offset + (details.primaryDelta ?? 0), duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                  print('onVerticalDragUpdate: scrollController.offset ${scrollController.offset}');
                  print('onVerticalDragUpdate: details.primaryDelta  ${details.primaryDelta ?? 0}');
                },
                onVerticalDragStart: (details) {
                  print('onVerticalDragStart: scrollController.offset ${scrollController.offset}');
                },
                onVerticalDragDown: (details) {
                  print('onVerticalDragDown: scrollController.offset ${scrollController.offset}');
                },
                onVerticalDragEnd: (details) {
                  print('onVerticalDragEnd: scrollController.offset ${scrollController.offset}');
                },
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 56,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    _buildHeader(),
                  ],
                )
              ),
            ),
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
                        const SizedBox(height: 16),
                        _buildSectionTitle(R.string.time_of_use.tr()),
                        _buildMomentSelector(),
                        const SizedBox(height: 16),
                        _buildSectionTitle(R.string.frequency_of_use.tr()),
                        _buildFrequencySelector(),
                        const SizedBox(height: 16),
                        if (_selectedFrequency == FrequencyType.everyday)
                          ..._buildEveryDayController()
                        else if (_selectedFrequency == FrequencyType.weekDays)
                          ..._buildDayInWeekController()
                        else
                          ..._buildEveryOtherDayController(),
                        const SizedBox(height: 24),
                      ],
                    )
                ),
              )
            ),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 56,
      padding: const EdgeInsets.fromLTRB(0, 15, 0, 17),
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
      )
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
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
                    color: isSelected ? const Color(0xFF008D67) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    moment.label,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                      fontSize: 15,
                      height: 1.46,
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
                  duration: const Duration(milliseconds: 200),
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF008D67) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    frequency.label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
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
      _buildDosageRow(R.string.the_morning.tr(), R.icons.ic_morning, _quantityInMorning, (value) => setState(() {
        _quantityInMorning.text = value;
        _checkEnableSubmitBtnState();
      })),
      _buildDosageRow(R.string.the_noon.tr(), R.icons.ic_noon, _quantityInNoon, (value) => setState(() {
        _quantityInNoon.text = value;
        _checkEnableSubmitBtnState();
      })),
      _buildDosageRow(R.string.the_afternoon.tr(), R.icons.ic_afternoon, _quantityInAfternoon, (value) => setState(() {
        _quantityInAfternoon.text = value;
        _checkEnableSubmitBtnState();
      })),
      _buildDosageRow(R.string.the_evening.tr(), R.icons.ic_night, _quantityInEvening, (value) => setState(() {
        _quantityInEvening.text = value;
        _checkEnableSubmitBtnState();
      })),
      if (getQuantity(_quantityInMorning) == 0.0 &&
          getQuantity(_quantityInNoon) == 0.0 && getQuantity(_quantityInAfternoon) == 0.0 && getQuantity(_quantityInEvening) == 0.0)
        Padding(
          padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Row(
            children: [
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
            ]
          ),
        ),
    ];
  }

  double getQuantity(TextEditingController controller) {
    return double.tryParse(controller.text) ?? 0.0;
  }

  Widget _buildDosageRow(String title, String iconRes, TextEditingController controller, Function(String) onValueChange) {
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

  List<Widget> _buildDosageCounter(TextEditingController controller, Function(String) onValueChange) {
    return [
      GestureDetector(
        onTap: () {
          double parseValue = double.tryParse(controller.text) ?? 0.0;
          if (parseValue >= 1.0) {
            setState(() {
              onValueChange((parseValue - 1.0).toString());
            });
          } else {
            onValueChange('0.0');
          }
        },
        child: Container(
          width: 34,
          height: 32,
          decoration: BoxDecoration(
            color: Color(0xFFF4F7F7),
            borderRadius: BorderRadius.horizontal(left: Radius.circular(4), right: Radius.zero),
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
          keyboardType: TextInputType.number,
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
          double parseValue = double.tryParse(controller.text) ?? 0.0;
          onValueChange((parseValue + 1.0).toString());
        },
        child: Container(
          width: 34,
          height: 32,
          decoration: BoxDecoration(
            color: Color(0xFFF4F7F7),
            borderRadius: BorderRadius.horizontal(left: Radius.zero, right: Radius.circular(4)),
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
        },
        // Optional styling to match the image
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(
            color: isSelected ? Colors.teal : Colors.grey, // Teal border when selected, grey when not
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
          () => _updateCounter(() => _quantityOnDayInWeek++),
          () => _updateCounter(() => _quantityOnDayInWeek--),
          (value) => _updateCounter(() {
            _quantityOnDayInWeek = double.tryParse(value) ?? 0;
          }),
      ),

      const SizedBox(height: 20),
      _buildSectionTitle(R.string.dosage.tr()),
      _buildDosageRow(R.string.the_morning.tr(), R.icons.ic_morning, _quantityInMorning, (value) => setState(() {
        _quantityInMorning.text = value;
        _checkEnableSubmitBtnState();
      })),
      _buildDosageRow(R.string.the_noon.tr(), R.icons.ic_noon, _quantityInNoon, (value) => setState(() {
        _quantityInNoon.text = value;
        _checkEnableSubmitBtnState();
      })),
      _buildDosageRow(R.string.the_afternoon.tr(), R.icons.ic_afternoon, _quantityInAfternoon, (value) => setState(() {
        _quantityInAfternoon.text = value;
        _checkEnableSubmitBtnState();
      })),
      _buildDosageRow(R.string.the_evening.tr(), R.icons.ic_night, _quantityInEvening, (value) => setState(() {
        _quantityInEvening.text = value;
        _checkEnableSubmitBtnState();
      })),
      if (getQuantity(_quantityInMorning) == 0.0 &&
          getQuantity(_quantityInNoon) == 0.0 && getQuantity(_quantityInAfternoon) == 0.0 && getQuantity(_quantityInEvening) == 0.0)
        Padding(
          padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Row(
              children: [
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
              ]
          ),
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
            validValue = int.tryParse(value.substring(0, value.length - 1)) ?? 0;
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
        () => _updateCounter(() => _quantityOnEveryOtherDay++),
        () => _updateCounter(() => _quantityOnEveryOtherDay--),
        (value) => _updateCounter(() => _quantityOnEveryOtherDay = double.tryParse(value) ?? 0.0),
      ),

      const SizedBox(height: 20),
      _buildSectionTitle(R.string.dosage.tr()),
      _buildDosageRow(R.string.the_morning.tr(), R.icons.ic_morning, _quantityInMorning, (value) => setState(() {
        _quantityInMorning.text = value;
        _checkEnableSubmitBtnState();
      })),
      _buildDosageRow(R.string.the_noon.tr(), R.icons.ic_noon, _quantityInNoon, (value) => setState(() {
        _quantityInNoon.text = value;
        _checkEnableSubmitBtnState();
      })),
      _buildDosageRow(R.string.the_afternoon.tr(), R.icons.ic_afternoon, _quantityInAfternoon, (value) => setState(() {
        _quantityInAfternoon.text = value;
        _checkEnableSubmitBtnState();
      })),
      _buildDosageRow(R.string.the_evening.tr(), R.icons.ic_night, _quantityInEvening, (value) => setState(() {
        _quantityInEvening.text = value;
        _checkEnableSubmitBtnState();
      })),
      if (getQuantity(_quantityInMorning) == 0.0 &&
          getQuantity(_quantityInNoon) == 0.0 && getQuantity(_quantityInAfternoon) == 0.0 && getQuantity(_quantityInEvening) == 0.0)
        Padding(
          padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Row(
              children: [
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
              ]
          ),
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
      child: Expanded(
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
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(4), right: Radius.zero),
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
                controller: TextEditingController(text: value.toStringAsFixed(0)),
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
              )
            ),
            // Increment button
            GestureDetector(
              onTap: onIncrement,
              child: Container(
                width: 34,
                height: 32,
                decoration: BoxDecoration(
                  color: Color(0xFFF4F7F7),
                  borderRadius: BorderRadius.horizontal(left: Radius.zero, right: Radius.circular(4)),
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
        ),
      )
    );
  }

  // Submit button
  Widget _buildConfirmButton() {
    return Container(
      width: double.infinity,
      height: 90,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
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
        ]
      ),
      child: GestureDetector(
        onTap: () {
          print("Bottom sheet - morning controller ${_quantityInMorning.text} - parse: ${double.tryParse(_quantityInMorning.text)}");
          DosageModel dosage;
          if (FrequencyType.everyday == _selectedFrequency) {
            dosage = DosageModel(
              momentName: _selectedMoment.label,
              moment: _selectedMoment.index + 1,
              frequencyName: _selectedFrequency.label,
              frequency: _selectedFrequency.index + 1,
              quantityInMorning: double.tryParse(_quantityInMorning.text) ?? 0.0,
              quantityInNoon: double.tryParse(_quantityInNoon.text) ?? 0.0,
              quantityInAfternoon: double.tryParse(_quantityInAfternoon.text) ?? 0.0,
              quantityInNight: double.tryParse(_quantityInEvening.text) ?? 0.0,
            );
          } else if (FrequencyType.weekDays == _selectedFrequency) {
            dosage = DosageModel(
              momentName: _selectedMoment.label,
              moment: _selectedMoment.index + 1,
              frequencyName: _selectedFrequency.label,
              frequency: _selectedFrequency.index + 1,
              selectedDaysInWeek: _selectedDayIndexes,
              quantityForDaysInWeek: _quantityOnDayInWeek,
            );
          } else {
            dosage = DosageModel(
              momentName: _selectedMoment.label,
              moment: _selectedMoment.index + 1,
              frequencyName: _selectedFrequency.label,
              frequency: _selectedFrequency.index + 1,
              everyOtherDayNumber: _everyOtherDayNumber,
              quantityForEveryOtherDay: _quantityOnEveryOtherDay,
            );
          }
          Navigator.of(context).pop(dosage);
        },
        child: Container(
          width: double.infinity,
          height: 44,
          decoration: BoxDecoration(
            color: _submitBtnEnabled ? const Color(0xFF008D67) : Color(0xFFBFC6C6),
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
        )
      ),
    );
  }
}
