import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widgets/custom_date_picker.dart';

class CalendarNavigationBar extends StatelessWidget {
  const CalendarNavigationBar({
    Key? key,
    required this.currentDate,
    required this.onPreviousDay,
    required this.onNextDay,
    required this.onTodayPressed,
    required this.onDatePicked,
    this.minDate,
    this.maxDate,
    this.isTodayDisabled = false,
    this.selectedDate,
    this.activeDates,
    this.canNavigatePrevious = true,
    this.canNavigateNext = true,
  }) : super(key: key);

  final DateTime currentDate;
  final VoidCallback onPreviousDay;
  final VoidCallback onNextDay;
  final VoidCallback onTodayPressed;
  final Function(DateTime) onDatePicked;
  final DateTime? minDate;
  final DateTime? maxDate;
  final bool isTodayDisabled;
  final DateTime? selectedDate;
  final List<DateTime>? activeDates;
  final bool canNavigatePrevious;
  final bool canNavigateNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Today button (standalone)
        _buildTodayButton(context),
        const SizedBox(width: 12),

        // Navigation cluster container
        Expanded(
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F6F9),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Row(
              children: [
                // Left arrow (icon only)
                _buildArrowIcon(
                  icon: Icons.chevron_left_rounded,
                  onTap: canNavigatePrevious ? onPreviousDay : null,
                  isEnabled: canNavigatePrevious,
                ),
                const SizedBox(width: 4),

                // Date picker button (calendar icon prefix)
                Expanded(child: _buildDatePickerButton(context)),

                const SizedBox(width: 4),
                // Right arrow (icon only)
                _buildArrowIcon(
                  icon: Icons.chevron_right_rounded,
                  onTap: canNavigateNext ? onNextDay : null,
                  isEnabled: canNavigateNext,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArrowIcon({
    required IconData icon,
    required VoidCallback? onTap,
    required bool isEnabled,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          size: 30,
          color: isEnabled
              ? R.color.greenGradientBottom
              : R.color.captionColorGray,
        ),
      ),
    );
  }

  Widget _buildTodayButton(BuildContext context) {
    final isToday = DateUtil.isSameDate(currentDate, DateTime.now());

    return InkWell(
      onTap: isTodayDisabled ? null : onTodayPressed,
      child: Container(
        height: 42,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isTodayDisabled ? R.color.grayBorder : R.color.greenGradientBottom,
          ),
        ),
        child: Text(
          R.string.today.tr(),
          style: TextStyle(
            color: isTodayDisabled
                ? R.color.captionColorGray
                : (isToday ? R.color.greenGradientBottom : R.color.textDark),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerButton(BuildContext context) {
    return InkWell(
      onTap: () => _showDatePicker(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: const BoxDecoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: R.color.greenGradientBottom,
            ),
            const SizedBox(width: 8),
            MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: MediaQuery.of(context)
                    .textScaler
                    .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3),
              ),
              child: Text(
                '${DateUtil.weekDayToString(currentDate)} - ${convertToUTC(DateUtil.getDayInMillis(currentDate), 'dd/MM')}',
                style: TextStyle(
                  color: R.color.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePicker(BuildContext context) {
    showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
      context: context,
      builder: (_) => CustomDatePicker(
        initDate: currentDate,
        callback: (DateTime date) {
          onDatePicked(date);
        },
        minDate: minDate,
        maxDate: maxDate,
        selectedDate: selectedDate,
        activeDates: activeDates,
      ),
    );
  }
}
