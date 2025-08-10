import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../res/R.dart';
import 'medicine_add_model.dart';

class DosageInputBottomSheet extends StatefulWidget {
  const DosageInputBottomSheet({Key? key}) : super(key: key);

  @override
  _DosageInputBottomSheetState createState() => _DosageInputBottomSheetState();
}

class _DosageInputBottomSheetState extends State<DosageInputBottomSheet> {
  DraftPrescription _draftPrescription = DraftPrescription();
  String _selectedTimeOfUse = R.string.truoc_an.tr();
  String _selectedFrequency = R.string.everyday.tr();

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
      if (_selectedFrequency == R.string.everyday.tr()) {
        final morningQuantity = double.tryParse(_quantityInMorning.text) ?? 0.0;
        final noonQuantity = double.tryParse(_quantityInNoon.text) ?? 0.0;
        final afternoonQuantity = double.tryParse(_quantityInAfternoon.text) ?? 0.0;
        final eveningQuantity = double.tryParse(_quantityInEvening.text) ?? 0.0;

        _submitBtnEnabled = morningQuantity > 0.0 || noonQuantity > 0.0 || afternoonQuantity > 0.0 || eveningQuantity > 0.0;
      } else if (_selectedFrequency == R.string.ngay_trong_tuan.tr()) {
        _submitBtnEnabled = _selectedDayIndexes.isNotEmpty && _quantityOnDayInWeek > 0;
      } else {
        _submitBtnEnabled = _everyOtherDayNumber > 0 && _quantityOnEveryOtherDay > 0;
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
                            ..._buildEveryDayController()
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
          final isSelected = _selectedTimeOfUse == timing;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTimeOfUse = timing;
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
    ];
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

  Widget _buildConfirmButton() {
    return Container(
      width: double.infinity,
      height: 76,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
      child: GestureDetector(
          onTap: () {
            Dosage dosage;
            if (R.string.every_day.tr() == _selectedFrequency) {
              dosage = Dosage(
                timeOfUse: _selectedTimeOfUse,
                frequency: _selectedFrequency,
                quantityInMorning: double.tryParse(_quantityInMorning.text) ?? 0.0,
                quantityInNoon: double.tryParse(_quantityInNoon.text) ?? 0.0,
                quantityInAfternoon: double.tryParse(_quantityInAfternoon.text) ?? 0.0,
                quantityInNight: double.tryParse(_quantityInEvening.text) ?? 0.0,
              );
            } else if (R.string.ngay_trong_tuan.tr == _selectedFrequency) {
              dosage = Dosage(
                timeOfUse: _selectedTimeOfUse,
                frequency: _selectedFrequency,
                selectedDaysInWeek: _selectedDayIndexes,
                quantityForDaysInWeek: _quantityOnDayInWeek,
              );
            } else {
              dosage = Dosage(
                timeOfUse: _selectedTimeOfUse,
                frequency: _selectedFrequency,
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
