import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/extention.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_appointment_model.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_clinic_model.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_navigation_mixin.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/CalendarPicker/custom_date_picker_horizontal.dart';
import 'package:medical/src/widgets/CalendarPicker/picker_helper.dart';

class DsmesCalendarSection extends StatefulWidget {
  final String serviceType;
  final String action; // 'create' or 'reschedule'
  final int? appointmentId;

  const DsmesCalendarSection({
    Key? key,
    required this.serviceType,
    this.action = 'create',
    this.appointmentId,
  }) : super(key: key);

  @override
  State<DsmesCalendarSection> createState() => _DsmesCalendarSectionState();
}

class _DsmesCalendarSectionState extends State<DsmesCalendarSection> {
  late DsmesAppointmentCubit _cubit;
  DateTime? selectedDate;
  bool isMorningSelected = true;
  BookingSchedule? selectedBookingSchedule;

  late List<BookingSchedule> availableBookingSchedule = [];

  @override
  void initState() {
    super.initState();
    _cubit = context.read<DsmesAppointmentCubit>();
    if (_cubit.createDsmesBookingRequest != null) {
      final startTime = _cubit.createDsmesBookingRequest!.startTime;
      final endTime = _cubit.createDsmesBookingRequest!.endTime;
      if (startTime.isNotEmpty && endTime.isNotEmpty) {
        selectedBookingSchedule = BookingSchedule(
            startTime: startTime, endTime: endTime, isAvailable: true);
        selectedDate = DateTime.parse(startTime);
      }
      // Set initial morning/afternoon based on currentAppointment if exists
      if (selectedBookingSchedule != null) {
        isMorningSelected =
            DateTime.parse(selectedBookingSchedule!.startTime).hour < 12;
      }
    }
    availableBookingSchedule =
        _getAvailableBookingSchedule(bookingDate: selectedDate);
  }

  List<BookingSchedule> _getAvailableBookingSchedule({DateTime? bookingDate}) {
    if (bookingDate == null) {
      bookingDate = DateTime.now();
    }
    if (widget.serviceType == DsmesAppointmentMode.atClinic.toString()) {
      final scheduleDates = _cubit.selectedClinic?.getBookingSchedules() ?? [];
      if (scheduleDates.isEmpty) {
        return [];
      }
      return scheduleDates
          .where((schedule) =>
              schedule.isAvailable == true &&
              DateTime.parse(schedule.startTime)
                  .isSameDayWith(bookingDate!)) // Only get available slots
          .toList();
    } else {
      // Handle case for online booking
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: R.color.backgroundColorNew,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomAppBar(
                  backgroundColor: R.color.transparent,
                  title: Text(
                    R.string.pick_time.tr(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: R.color.color0xff111515,
                      fontFamily: 'sfpro',
                    ),
                  ),
                  leadingIcon: IconButton(
                    splashColor: R.color.transparent,
                    highlightColor: R.color.transparent,
                    icon: Icon(Icons.arrow_back, color: R.color.textDark),
                    onPressed: () {
                      DsmesNavigationMixin.navigationKey.currentState
                          ?.pop(context);
                    },
                  ),
                ),
                Expanded(
                  child: SafeArea(
                    top: false,
                    bottom: false,
                    child: ListView(
                      padding: EdgeInsets.zero,
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      children: [
                        _buildSectionCalendarBooking(),
                      ],
                    ),
                  ),
                )
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: R.color.white,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildButton(R.string.tiep_tuc.tr(), () async {
                        if (selectedBookingSchedule == null) {
                          Message.showToastMessage(
                              context, R.string.vui_long_chon_gio_kham.tr());
                          return;
                        }

                        _cubit.updateCreateDsmesBookingRequestTime(
                            startTime: selectedBookingSchedule!.startTime,
                            endTime: selectedBookingSchedule!.endTime);

                        DsmesNavigationMixin.navigationKey.currentState
                            ?.pushNamed(NavigatorName.dsmes_confirm_information,
                                arguments: {
                              'serviceType': widget.serviceType,
                              'action': widget.action,
                              'appointmentId': widget.appointmentId,
                            });
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 44,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: R.color.mainColor,
          borderRadius: BorderRadius.circular(200),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.centerRight,
            colors: [
              R.color.greenGradientTop,
              R.color.greenGradientMid,
              R.color.greenGradientBottom,
            ],
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: R.color.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  _buildSectionCalendarBooking() {
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
            initialDate: selectedDate == null ? DateTime.now() : selectedDate!,
            firstDate: DateTime.parse("1969-07-20 20:18:04Z"),
            activeDates: activeDates,
            lastDate: _getLastDate(),
            datesRange: Const.MAX_DAY_RANGE_DSMES_BOOKING,
            onDateChanged: (datetime) {
              if (datetime != null) {
                var targets =
                    _getAvailableBookingSchedule(bookingDate: datetime)
                        .where((schedule) =>
                            schedule.isAvailable == true &&
                            DateTime.parse(schedule.startTime).isSameDayWith(
                                datetime)) // Only get available slots
                        .toList();
                setState(() {
                  availableBookingSchedule = targets;
                  selectedDate = datetime;
                  isMorningSelected = true;
                });
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  R.string.select_hour.tr(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'sfpro',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          _buildTimePeriodSwitch(),
          SizedBox(height: 16),
          _buildTimeFrame(),
          SizedBox(
            height: 16,
          )
        ],
      ),
    );
  }

  Widget _buildTimeFrame() {
    List<Widget> morningTargets = [];
    List<Widget> afternoonTargets = [];

    Set<String> addedStartTimes = Set<String>();
    Set<String> addedEndTimes = Set<String>();
    for (int i = 0; i < availableBookingSchedule.length; i++) {
      String startTime =
          "${availableBookingSchedule[i].startTime.split(' ')[1]}";
      String endTime = "${availableBookingSchedule[i].endTime.split(' ')[1]}";

      final isSlotPicked = selectedBookingSchedule != null &&
          DateTime.parse(selectedBookingSchedule!.startTime).isAtSameMomentAs(
              DateTime.parse(availableBookingSchedule[i].startTime)) &&
          DateTime.parse(selectedBookingSchedule!.endTime).isAtSameMomentAs(
              DateTime.parse(availableBookingSchedule[i].endTime));

      if (!addedStartTimes.contains(startTime) ||
          !addedEndTimes.contains(endTime)) {
        Widget item = InkWell(
          onTap: () => {
            setState(() {
              selectedBookingSchedule = availableBookingSchedule[i];
            })
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 7, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                  color: PickerHelper.getBorderColorByState(
                      isSelected: isSlotPicked, hasSlot: true)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildItemTimeFrame(
                  startTime,
                  availableBookingSchedule[i].startTime,
                  availableBookingSchedule[i].endTime,
                ),
                Text(
                  "-",
                  style: TextStyle(
                      fontSize: 14.0,
                      fontFamily: 'sfpro',
                      fontWeight: PickerHelper.getTextFontWeightByState(
                        isSelected: isSlotPicked,
                      ),
                      color: PickerHelper.getTextColorByState(
                        isSelected: isSlotPicked,
                        hasSlot: true,
                      )),
                ),
                _buildItemTimeFrame(
                  endTime,
                  availableBookingSchedule[i].startTime,
                  availableBookingSchedule[i].endTime,
                ),
              ],
            ),
          ),
        );

        final isMorning =
            DateTime.parse(availableBookingSchedule[i].startTime).hour < 12;
        isMorning ? morningTargets.add(item) : afternoonTargets.add(item);
      }
      addedStartTimes.add(startTime);
      addedEndTimes.add(endTime);
    }

    return LayoutBuilder(builder: (context, constraints) {
      final targets = isMorningSelected ? morningTargets : afternoonTargets;
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.spaceBetween,
          children: List.generate((targets.length / 3).ceil() * 3, (index) {
            if (index < targets.length) {
              return Container(
                width: (constraints.maxWidth - 48) /
                    3, // Total width minus padding divided by 3
                height: 41,
                child: targets[index],
              );
            }
            return SizedBox(
              width: (constraints.maxWidth - 48) / 3,
              height: 41,
            );
          }),
        ),
      );
    });
  }

  Widget _buildItemTimeFrame(String time, String startTime, String endTime) {
    final isSlotPicked = selectedBookingSchedule != null &&
        DateTime.parse(selectedBookingSchedule!.startTime)
            .isAtSameMomentAs(DateTime.parse(startTime)) &&
        DateTime.parse(selectedBookingSchedule!.endTime)
            .isAtSameMomentAs(DateTime.parse(endTime));
    return Container(
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "${time.split(':')[0].trim()}:${time.split(':')[1].trim()}",
        style: TextStyle(
          color: PickerHelper.getTextColorByState(
              isSelected: isSlotPicked, hasSlot: true),
          fontSize: 14,
          fontFamily: 'sfpro',
          fontWeight:
              PickerHelper.getTextFontWeightByState(isSelected: isSlotPicked),
        ),
      ),
    );
  }

  Widget _buildTimePeriodSwitch() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: R.color.color0xffF4F4F5,
        borderRadius: BorderRadius.circular(8),
      ),
      height: 43,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isMorningSelected = true;
                });
              },
              child: Container(
                height: 35,
                margin: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isMorningSelected
                      ? R.color.white
                      : R.color.color0xffF4F4F5,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    R.string.the_morning.tr(),
                    style: TextStyle(
                      color: PickerHelper.getTextColorByState(
                          isSelected: isMorningSelected, hasSlot: true),
                      fontSize: 16,
                      fontFamily: 'sfpro',
                      fontWeight: PickerHelper.getTextFontWeightByState(
                        isSelected: isMorningSelected,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isMorningSelected = false;
                });
              },
              child: Container(
                height: 35,
                margin: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: !isMorningSelected ? R.color.white : Color(0xfff4f4f5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    R.string.the_afternoon.tr(),
                    style: TextStyle(
                      color: PickerHelper.getTextColorByState(
                          isSelected: !isMorningSelected, hasSlot: true),
                      fontSize: 16,
                      fontFamily: 'sfpro',
                      fontWeight: PickerHelper.getTextFontWeightByState(
                          isSelected: !isMorningSelected),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<DateTime> _getActiveDates() {
    if (widget.serviceType == DsmesAppointmentMode.atClinic.toString()) {
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

  DateTime _getLastDate() {
    return DateTime.now().add(Duration(days: 30));
  }
}
