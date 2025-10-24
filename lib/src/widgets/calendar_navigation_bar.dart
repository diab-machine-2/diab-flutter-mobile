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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: R.color.grayBorder),
      ),
      child: Row(
        children: [
          // Previous day button
          _buildNavigationButton(
            icon: Icons.chevron_left_rounded,
            onTap: canNavigatePrevious ? onPreviousDay : null,
            isEnabled: canNavigatePrevious,
          ),
          const SizedBox(width: 12),

          // Today button
          _buildTodayButton(context),
          const SizedBox(width: 12),

          // Date picker button
          Expanded(
            child: _buildDatePickerButton(context),
          ),
          const SizedBox(width: 12),

          // Next day button
          _buildNavigationButton(
            icon: Icons.chevron_right_rounded,
            onTap: canNavigateNext ? onNextDay : null,
            isEnabled: canNavigateNext,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool isEnabled,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isEnabled
              ? R.color.gray.withOpacity(0.1)
              : R.color.gray.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isEnabled
                ? R.color.grayBorder
                : R.color.grayBorder.withOpacity(0.5),
          ),
        ),
        child: Icon(
          icon,
          size: 20,
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
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isTodayDisabled
              ? R.color.gray.withOpacity(0.1)
              : R.color.gray.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isTodayDisabled ? R.color.grayBorder : R.color.grayBorder,
          ),
        ),
        child: Text(
          R.string.today.tr(),
          style: TextStyle(
            color: isTodayDisabled
                ? R.color.captionColorGray
                : (isToday ? R.color.greenGradientBottom : R.color.textDark),
            fontSize: 14,
            fontWeight: FontWeight.w500,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: R.color.gray.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: R.color.grayBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              convertToUTC(
                DateUtil.getDayInMillis(currentDate),
                'dd/MM/yyyy',
              ),
              style: TextStyle(
                color: R.color.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: R.color.greenGradientBottom,
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
