import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:medical/src/widgets/CalendarPicker/custom_date_picker_horizontal.dart';

class DsmesCalendarSection extends StatefulWidget {
  final String serviceType;
  final Function(DateTime?) onDateChanged;

  const DsmesCalendarSection({
    Key? key,
    required this.serviceType,
    required this.onDateChanged,
  }) : super(key: key);

  @override
  State<DsmesCalendarSection> createState() => _DsmesCalendarSectionState();
}

class _DsmesCalendarSectionState extends State<DsmesCalendarSection> {
  late DsmesAppointmentCubit _cubit;
  DateTime? selectedDate;
  bool isMorningSelected = true;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<DsmesAppointmentCubit>();
    if (_cubit.createDsmesBookingRequest != null) {
      final startTime = _cubit.createDsmesBookingRequest!.startTime;
      if (startTime.isNotEmpty) {
        selectedDate = DateTime.parse(startTime);
      }
      // Set initial morning/afternoon based on currentAppointment if exists
      if (selectedDate != null) {
        isMorningSelected = selectedDate!.hour < 12;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> activeDates = _getActiveDates();

    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              R.string.pick_date.tr(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'sfpro',
              ),
            ),
          ),
          CustomHorizontalDatePicker(
            initialDate: selectedDate ?? activeDates.first,
            firstDate: DateTime.parse("1969-07-20 20:18:04Z"),
            activeDates: activeDates,
            lastDate: _getLastDate(activeDates),
            onDateChanged: widget.onDateChanged,
          ),
          // ... rest of the existing calendar section UI code
        ],
      ),
    );
  }

  List<DateTime> _getActiveDates() {
    if (widget.serviceType == 'offline') {
      final scheduleDates = _cubit.selectedClinic?.getBookingSchedules() ?? [];
      if (scheduleDates.isEmpty) {
        return [];
      }
      return scheduleDates
          .where((schedule) =>
              schedule.isAvailable == true) // Only get available slots
          .map((schedule) => DateTime.parse(schedule.startTime))
          .toList()
        ..sort();
    } else {
      return [];
    }
  }

  DateTime _getLastDate(List<DateTime> activeDates) {
    return activeDates.length > 0
        ? activeDates.last
        : DateTime.now().add(Duration(days: 30));
  }
}
