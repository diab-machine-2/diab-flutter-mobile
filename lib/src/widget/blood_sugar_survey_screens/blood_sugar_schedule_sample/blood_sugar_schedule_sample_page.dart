import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widgets/blood_sugar_recommand_layout_widget.dart';
import 'package:medical/src/widgets/button_widget.dart';

class BloodScheduleSamplePage extends StatelessWidget {
  const BloodScheduleSamplePage();

  @override
  Widget build(BuildContext context) {
    return BloodSugarRecommandLayoutWidget(
      title: 'Mẫu cơ bản',
      child: Container(
        color: R.color.white,
        child: SafeArea(
          top: false,
          child: _buildSampleDaySchedule(),
        ),
      ),
    );
  }
}

Widget _buildSampleWeekSchedule() {
  return Padding(
    padding: const EdgeInsets.only(right: 16),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 19, bottom: 7),
          child: Row(
            children: [
              const SizedBox(width: 68),
              Expanded(
                child: Center(
                  child: Text(
                    'Sáng',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: R.color.textDark,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Trưa',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: R.color.textDark,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Tối',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: R.color.textDark,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    R.string.sleep_time.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: R.color.textDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Expanded(child: _buildDayInWeekSchedule()),
              const SizedBox(height: 4),
              Expanded(child: _buildDayInWeekSchedule()),
              const SizedBox(height: 4),
              Expanded(child: _buildDayInWeekSchedule()),
              const SizedBox(height: 4),
              Expanded(child: _buildDayInWeekSchedule()),
              const SizedBox(height: 4),
              Expanded(child: _buildDayInWeekSchedule()),
              const SizedBox(height: 4),
              Expanded(child: _buildDayInWeekSchedule()),
              const SizedBox(height: 4),
              Expanded(child: _buildDayInWeekSchedule()),
            ],
          ),
        ),
        _buildButtons(),
      ],
    ),
  );
}

Widget _buildSampleDaySchedule() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
    child: Column(
      children: [
        _buildFoodItem(title: R.string.the_morning.tr()),
        _buildFoodItem(title: R.string.the_noon.tr()),
        _buildFoodItem(title: R.string.the_evening.tr()),
        _buildSleepTimeItem(),
        _buildButtons(),
      ],
    ),
  );
}

Widget _buildDayInWeekSchedule() {
  return Row(
    children: [
      Container(
        width: 68,
        alignment: Alignment.center,
        child: Text(
          'T2',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: R.color.textDark,
          ),
        ),
      ),
      Expanded(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: R.color.color0xffE5B440),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildTestTimeItem(
                        testTime: 'Trước ăn',
                        isSelected: false,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8))),
                    Container(
                      height: 1,
                      color: R.color.color0xffE5B440,
                    ),
                    _buildTestTimeItem(
                        testTime: 'Sau ăn',
                        isSelected: true,
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8))),
                  ],
                ),
              ),
              Container(
                width: 1,
                color: R.color.color0xffE5B440,
              ),
              Expanded(
                child: Column(
                  children: [
                    _buildTestTimeItem(
                      testTime: 'Trước ăn',
                      isSelected: false,
                    ),
                    Container(
                      height: 1,
                      color: R.color.color0xffE5B440,
                    ),
                    _buildTestTimeItem(
                      testTime: 'Sau ăn',
                      isSelected: true,
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                color: R.color.color0xffE5B440,
              ),
              Expanded(
                child: Column(
                  children: [
                    _buildTestTimeItem(
                      testTime: 'Trước ăn',
                      isSelected: true,
                    ),
                    Container(
                      height: 1,
                      color: R.color.color0xffE5B440,
                    ),
                    _buildTestTimeItem(
                      testTime: 'Sau ăn',
                      isSelected: false,
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                color: R.color.color0xffE5B440,
              ),
              _buildTestTimeItem(
                testTime: 'Sau ăn',
                isSelected: false,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
            ],
          ),
        ),
      )
    ],
  );
}

Widget _buildTestTimeItem({
  required String testTime,
  bool isSelected = false,
  BorderRadius? borderRadius,
}) {
  return Expanded(
    child: Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 9),
      decoration: BoxDecoration(
          color: isSelected ? R.color.color0xffF4DBBD : R.color.white,
          borderRadius: borderRadius),
      child: Text(
        testTime,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: isSelected ? R.color.main_1 : R.color.gray,
        ),
      ),
    ),
  );
}

Widget _buildButtons() {
  return Column(
    children: [
      const SizedBox(height: 32),
      SizedBox(
        width: 208,
        child: ButtonWidget(
          title: 'Đặt làm lịch của tôi',
          onPressed: () {},
        ),
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: 208,
        child: ButtonWidget(
          title: 'Đặt lại lịch gợi ý',
          onPressed: () {},
          backgroundColor: R.color.white,
          borderColor: R.color.gray,
          textColor: R.color.gray,
        ),
      ),
    ],
  );
}

Widget _buildFoodItem({
  required String title,
  VoidCallback? onSelectBefore,
}) {
  return Padding(
    padding: const EdgeInsets.only(top: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                color: R.color.black,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Row(
          children: [
            _buildSingleFoodItem(isBeforeEat: true, isSelected: true),
            const SizedBox(width: 16),
            _buildSingleFoodItem(isBeforeEat: false, isSelected: false),
          ],
        ),
      ],
    ),
  );
}

Widget _buildSingleFoodItem({
  required bool isBeforeEat,
  required bool isSelected,
  VoidCallback? onSelect,
}) {
  return Expanded(
    child: GestureDetector(
      onTap: onSelect,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
            color:
                isSelected ? R.color.color0xffF4DBBD : R.color.color0xffF5F7FA,
            border: Border.all(
                color: isSelected
                    ? R.color.color0xffE5B440
                    : R.color.color0xffF5F7FA),
            borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
                isBeforeEat
                    ? R.drawable.ic_before_eat
                    : R.drawable.ic_after_eat,
                width: 51,
                height: 34),
            const SizedBox(width: 8),
            Text(
              isBeforeEat ? R.string.truoc_an.tr() : R.string.sau_an.tr(),
              style: TextStyle(
                  color: isSelected ? R.color.mainColor : R.color.gray,
                  fontSize: 16),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildSleepTimeItem() {
  return Padding(
    padding: const EdgeInsets.only(top: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Giờ ngủ',
            style: TextStyle(
                color: R.color.black,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () {},
          child: Container(
            height: 60,
            decoration: BoxDecoration(
                color: true ? R.color.color0xffF4DBBD : R.color.color0xffF5F7FA,
                border: Border.all(
                    color: true
                        ? R.color.color0xffE5B440
                        : R.color.color0xffF5F7FA),
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                    // R.drawable.ic_before_sleep,
                    R.drawable.ic_before_sleep_selected,
                    width: 51,
                    height: 34),
                const SizedBox(width: 8),
                Text(
                  true ? R.string.truoc_an.tr() : R.string.sau_an.tr(),
                  style: TextStyle(
                      color: true ? R.color.mainColor : R.color.gray,
                      fontSize: 16),
                ),
              ],
            ),
          ),
        )
      ],
    ),
  );
}
