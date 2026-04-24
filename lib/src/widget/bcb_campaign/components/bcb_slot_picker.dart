import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget chọn slot ngày giờ khám mong muốn cho form đăng ký BCB.
/// Hiển thị label ưu tiên và cho phép KH chọn ngày giờ qua DateTimePicker.
class BcbSlotPicker extends StatelessWidget {
  final int priority; // 1, 2, 3
  final DateTime? selectedDateTime;
  final ValueChanged<DateTime> onDateTimeSelected;

  const BcbSlotPicker({
    Key? key,
    required this.priority,
    required this.selectedDateTime,
    required this.onDateTimeSelected,
  }) : super(key: key);

  String get _priorityLabel {
    switch (priority) {
      case 1:
        return 'Ưu tiên 1';
      case 2:
        return 'Ưu tiên 2';
      case 3:
        return 'Ưu tiên 3';
      default:
        return 'Ưu tiên $priority';
    }
  }

  String get _displayText {
    if (selectedDateTime == null) {
      return 'Chọn ngày và giờ';
    }
    return DateFormat('dd/MM/yyyy HH:mm').format(selectedDateTime!);
  }

  Future<void> _pickDateTime(BuildContext context) async {
    final now = DateTime.now();
    final firstDate = now;
    final lastDate = now.add(const Duration(days: 365));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('vi', 'VN'),
    );

    if (pickedDate == null) return;

    if (!context.mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedDateTime != null
          ? TimeOfDay.fromDateTime(selectedDateTime!)
          : const TimeOfDay(hour: 8, minute: 0),
    );

    if (pickedTime == null) return;

    final result = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    onDateTimeSelected(result);
  }

  @override
  Widget build(BuildContext context) {
    final bool hasValue = selectedDateTime != null;

    return InkWell(
      onTap: () => _pickDateTime(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: hasValue
                ? Theme.of(context).primaryColor
                : Colors.grey.shade400,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _priorityLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _displayText,
                style: TextStyle(
                  fontSize: 14,
                  color: hasValue ? Colors.black87 : Colors.grey.shade500,
                ),
              ),
            ),
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: hasValue
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
