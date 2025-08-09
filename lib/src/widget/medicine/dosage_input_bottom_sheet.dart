import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../res/R.dart';
import 'medicine_add_model.dart';

class DosageInputBottomSheet extends StatefulWidget {
  const DosageInputBottomSheet({Key? key}) : super(key: key);

  @override
  _DosageInputBottomSheetState createState() => _DosageInputBottomSheetState();
}

class _DosageInputBottomSheetState extends State<DosageInputBottomSheet> {
  DraftPrescription _draftPrescription = DraftPrescription();
  String _selectedTiming = R.string.truoc_an.tr();
  String _selectedFrequency = R.string.everyday.tr();
  int _morningDose = 1;
  int _afternoonDose = 0;
  int _eveningDose = 0;
  int _nightDose = 0;

  // Ngày trong tuần states
  int _dayInWeekQuantity = 0;
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
  int _everyOtherDayCounter = 0;
  int _everyOtherDayQuantity = 0;

  // Confirm Button
  bool _submitBtnEnabled = false;

  final TextEditingController _morningDosageController = TextEditingController();
  final TextEditingController _noonDosageController = TextEditingController();
  final TextEditingController _afternoonDosageController = TextEditingController();
  final TextEditingController _nightDosageController = TextEditingController();

  void _updateCounter(VoidCallback updateFunction) {
    setState(() {
      updateFunction();
    });

    _checkEnableSubmitBtnState();
  }

  void _checkEnableSubmitBtnState() {
    setState(() {
      if (_selectedFrequency == R.string.everyday.tr()) {
        _submitBtnEnabled = _morningDosageController.text.isNotEmpty ||
            _noonDosageController.text.isNotEmpty||
            _afternoonDosageController.text.isNotEmpty ||
            _nightDosageController.text.isNotEmpty;
      } else if (_selectedFrequency == R.string.ngay_trong_tuan.tr()) {
        _submitBtnEnabled = _selectedDayIndexes.isNotEmpty && _dayInWeekQuantity > 0;
      } else {
        _submitBtnEnabled = _everyOtherDayCounter > 0 && _everyOtherDayQuantity > 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight - 90;

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
                    final newSize = scrollController.offset + (details.primaryDelta ?? 0);
                    scrollController.jumpTo(
                      newSize.clamp(0.2, maxHeight/screenHeight),
                    );
                    // scrollController.jumpTo(scrollController.offset + (details.primaryDelta ?? 0));
                    // scrollController.animateTo(scrollController.offset + (details.primaryDelta ?? 0), duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                    print('onVerticalDragUpdate: scrollController.offset ${scrollController.offset}');
                    print('onVerticalDragUpdate: details.primaryDelta  ${details.primaryDelta ?? 0}');
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
                          _buildTimingSelector(),
                          const SizedBox(height: 16),
                          _buildSectionTitle(R.string.frequency_of_use.tr()),
                          _buildFrequencySelector(),
                          const SizedBox(height: 16),
                          if (_selectedFrequency == R.string.everyday.tr())
                            ..._buildDosageController()
                          else if (_selectedFrequency == R.string.ngay_trong_tuan.tr())
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

  Widget _buildTimingSelector() {
    return Row(
      children: [
        const SizedBox(width: 8),
        ...[R.string.truoc_an.tr(), R.string.sau_an.tr(), R.string.during_meal.tr()].map((timing) {
          final isSelected = _selectedTiming == timing;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTiming = timing;
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
                    timing,
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

  Widget _buildFrequencySelector() {
    return Row(
      children: [
        const SizedBox(width: 8),
        ...[R.string.everyday.tr(), R.string.ngay_trong_tuan.tr(), R.string.every_other_day.tr()].map((frequency) {
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
                    frequency,
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

  List<Widget> _buildDosageController() {
    return [
      _buildSectionTitle(R.string.dosage.tr()),
      _buildDosageRow(R.string.morning.tr(), Icons.wb_sunny_outlined, Colors.orange, _morningDose, (value) => _morningDose = value),
      _buildDosageRow(R.string.the_noon.tr(), Icons.sunny, Colors.amber, _afternoonDose, (value) => _afternoonDose = value),
      _buildDosageRow(R.string.the_afternoon.tr(), Icons.nights_stay_outlined, Colors.blue, _eveningDose, (value) => _eveningDose = value),
      _buildDosageRow(R.string.the_evening.tr(), Icons.cloud, Colors.blueGrey, _nightDose, (value) => _nightDose = value),
    ];
  }

  Widget _buildDosageRow(String title, IconData icon, Color iconColor, int value, Function(int) onValueChange) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(title),
          ),
          _buildDosageCounter(value, onValueChange),
        ],
      ),
    );
  }

  Widget _buildDosageCounter(int value, Function(int) onValueChange) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
          onPressed: () {
            if (value > 0) {
              setState(() {
                onValueChange(value - 1);
              });
            }
          },
        ),
        Text(
          value.toStringAsFixed(0),
          style: const TextStyle(fontSize: 16),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Colors.grey),
          onPressed: () {
            setState(() {
              onValueChange(value + 1);
            });
          },
        ),
      ],
    );
  }

  List<Widget> _buildDayInWeekController() {
    List<Widget> chips = [];
    for (int i = 0; i < _weekDays.length; i++) {
      final bool isSelected = _selectedDayIndexes.contains(i);
      final day = _weekDays[i];
      final chip = ChoiceChip(
        label: Text(day),
        selected: isSelected,
        selectedColor: Color(0xFF008479),
        onSelected: (bool selected) {
          setState(() {
            if (selected) {
              _selectedDayIndexes.add(i);
            } else {
              _selectedDayIndexes.remove(day);
            }
            // Optional: Print selected days to console for debugging
            print('Selected Days: $_selectedDayIndexes');
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
          _dayInWeekQuantity,
          () => _updateCounter(() => _dayInWeekQuantity++),
          () => _updateCounter(() => _dayInWeekQuantity--),
      ),
    ];
  }

  List<Widget> _buildEveryOtherDayController() {
    return [
      _buildCounterController(
        R.string.every_other_day.tr(),
        _everyOtherDayCounter,
        () => _updateCounter(() => _everyOtherDayCounter++),
        () => _updateCounter(() => _everyOtherDayCounter--),
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
        _everyOtherDayQuantity,
        () => _updateCounter(() => _everyOtherDayQuantity++),
        () => _updateCounter(() => _everyOtherDayQuantity--),
      ),
      const SizedBox(height: 20),
    ];
  }

  Widget _buildCounterController(String label, int value, VoidCallback onIncrement, VoidCallback onDecrement) {
    return Container(
        height: 36,
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
              // Decrement button
              IconButton(
                icon: const Icon(Icons.remove, size: 20),
                color: Colors.black54,
                onPressed: onDecrement,
                splashRadius: 20,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
              // Counter value text
              Container(
                width: 60,
                height: 36,
                alignment: Alignment.center,
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              // Increment button
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                color: Colors.black54,
                onPressed: onIncrement,
                splashRadius: 20,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        )
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      width: double.infinity,
      height: 76,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
      child: GestureDetector(
          onTap: () {
            // Create a new Dosage object with the entered data
            final newDosage = Dosage(
              timeOfDay: DayTime.morning,
              timing: _selectedTiming,
              frequency: _selectedFrequency,
              quantity: _morningDose.toDouble(), // This should be dynamic
            );
            Navigator.of(context).pop(newDosage);
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
