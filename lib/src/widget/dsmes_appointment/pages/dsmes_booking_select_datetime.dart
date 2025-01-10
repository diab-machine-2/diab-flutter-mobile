import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/extention.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_appointment_model.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_clinic_model.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_navigation_mixin.dart';
import 'package:medical/src/widget/dsmes_appointment/widgets/dsmes_empty_widget.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/CalendarPicker/custom_date_picker_horizontal.dart';
import 'package:medical/src/widgets/CalendarPicker/picker_helper.dart';

class DsmesCalendarSection extends StatefulWidget {
  final String serviceType;
  final String action; // 'create' or 'reschedule'
  final int? appointmentId;
  final bool isMergedSchedule;

  const DsmesCalendarSection({
    Key? key,
    required this.serviceType,
    this.action = 'create',
    this.appointmentId,
    this.isMergedSchedule = false,
  }) : super(key: key);

  @override
  State<DsmesCalendarSection> createState() => _DsmesCalendarSectionState();
}

class _DsmesCalendarSectionState extends State<DsmesCalendarSection> {
  late DsmesAppointmentCubit _cubit;
  DateTime? selectedDate;
  bool isMorningSelected = true;
  BookingSchedule? selectedBookingSchedule;
  bool _isProcessing = false;

  late List<BookingSchedule> availableBookingSchedule = [];
  late List<DateTime> activeDates = [];
  late List<BookingSchedule> fullSchedule = [];

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
    _loadInitialData();
  }

  void _loadInitialData() async {
    final scheduleDates = await _getScheduleDates();

    final dates = _getActiveDates(scheduleDates: scheduleDates);

    if (selectedDate != null &&
        !dates.any((date) =>
            date.year == selectedDate!.year &&
            date.month == selectedDate!.month &&
            date.day == selectedDate!.day)) {
      selectedDate = dates.isNotEmpty ? dates.first : DateTime.now();
    } else if (selectedDate == null) {
      selectedDate = dates.isNotEmpty ? dates.first : DateTime.now();
    }

    final schedules =
        _filterAvailableSchedules(scheduleDates, selectedDate ?? dates.first);

    setState(() {
      fullSchedule = scheduleDates; // Store full schedule
      availableBookingSchedule = schedules;
      activeDates = dates;
      isMorningSelected = selectedDate!.hour < 12;
    });
  }

  List<DateTime> _getActiveDates(
      {required List<BookingSchedule> scheduleDates}) {
    if (scheduleDates.isEmpty) {
      return [];
    }

    return scheduleDates
        .where((schedule) => schedule.isAvailable)
        .map((schedule) => DateTime.parse(schedule.startTime))
        .toList()
      ..sort();
  }

  Future<List<BookingSchedule>> _getScheduleDates() async {
    return widget.isMergedSchedule == false
        ? _cubit.selectedClinic?.getBookingSchedules() ?? []
        : await _cubit.getDiabClinicsSchedule();
  }

  List<BookingSchedule> _filterAvailableSchedules(
      List<BookingSchedule> schedules, DateTime date) {
    return schedules.where((schedule) {
      var scheduleDateTime = DateTime.parse(schedule.startTime);
      bool isSameDay = scheduleDateTime.isSameDayWith(date);
      bool isAvailable = schedule.isAvailable == true;
      // bool isMorningSlot = isMorningSelected
      //     ? scheduleDateTime.hour < 12
      //     : scheduleDateTime.hour >= 12;

      return isSameDay && isAvailable;
    }).toList();
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
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        R.color.greenGradientTop02,
                        R.color.greenGradientBottom
                      ],
                      stops: [0.01, 0.99],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  child: CustomAppBar(
                    backgroundColor: R.color.transparent,
                    title: Text(
                      R.string.pick_time.tr(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: R.color.white,
                        fontFamily: 'sfpro',
                      ),
                    ),
                    leadingIcon: IconButton(
                      splashColor: R.color.transparent,
                      highlightColor: R.color.transparent,
                      icon: Icon(Icons.arrow_back, color: R.color.white),
                      onPressed: () {
                        DsmesNavigationMixin.navigationKey.currentState?.pop(
                            DsmesNavigationMixin
                                .navigationKey.currentState?.context);
                      },
                    ),
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
                decoration: BoxDecoration(
                  color: R.color.white,
                  boxShadow: [Utils.getBoxShadowDropButton()],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildButton(R.string.tiep_tuc.tr(), () async {
                        if (_isProcessing) return;

                        if (selectedBookingSchedule == null) {
                          Message.showToastMessage(
                              context, R.string.vui_long_chon_gio_kham.tr());
                          return;
                        }

                        if (DateFormat('yyyy-MM-dd HH:mm')
                            .parse(selectedBookingSchedule!.startTime)
                            .isBefore(activeDates.first)) {
                          Message.showToastMessage(
                              context, R.string.vui_long_chon_gio_kham.tr());
                          return;
                        }

                        setState(() => _isProcessing = true);

                        try {
                          _cubit.updateCreateDsmesBookingRequestTime(
                              startTime: selectedBookingSchedule!.startTime,
                              endTime: selectedBookingSchedule!.endTime);

                          final route = ModalRoute.of(context)?.settings;
                          final args =
                              route?.arguments as Map<String, dynamic>?;
                          final isEditing = args?['isEditing'] ?? false;

                          if (isEditing) {
                            // Pop until select_service to rebuild stack with new state
                            DsmesNavigationMixin.navigationKey.currentState
                                ?.popUntil((route) =>
                                    route.settings.name ==
                                    NavigatorName.dsmes_select_service);

                            // Replace select_service
                            DsmesNavigationMixin.navigationKey.currentState
                                ?.pushReplacementNamed(
                                    NavigatorName.dsmes_select_service,
                                    arguments: {
                                  'serviceType': widget.serviceType,
                                  'action': widget.action,
                                  'clinic': _cubit.selectedClinic,
                                });

                            // Push new select_date with updated state
                            DsmesNavigationMixin.navigationKey.currentState
                                ?.pushNamed(
                                    NavigatorName.dsmes_booking_select_date,
                                    arguments: {
                                  'serviceType': widget.serviceType,
                                  'action': widget.action,
                                });

                            // Push confirm info
                            DsmesNavigationMixin.navigationKey.currentState
                                ?.pushNamed(
                                    NavigatorName.dsmes_confirm_information,
                                    arguments: {
                                  'serviceType': widget.serviceType,
                                  'action': widget.action,
                                  'appointmentId': widget.appointmentId,
                                  'isMergedSchedule': widget.isMergedSchedule,
                                });
                          } else {
                            // Normal flow
                            DsmesNavigationMixin.navigationKey.currentState
                                ?.pushNamed(
                                    NavigatorName.dsmes_confirm_information,
                                    arguments: {
                                  'serviceType': widget.serviceType,
                                  'action': widget.action,
                                  'appointmentId': widget.appointmentId,
                                  'isMergedSchedule': widget.isMergedSchedule,
                                });
                          }
                        } finally {
                          setState(() => _isProcessing = false);
                        }
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
    return Container(
      margin: EdgeInsets.fromLTRB(12, 12, 12, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          Utils.getBoxShadowDropCard(),
        ],
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
            onEndReached: () {
              BotToast.showText(
                text: R.string.select_booking_dates_warning.tr(),
                contentColor: R.color.color0xff111515.withOpacity(0.7),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 25),
                borderRadius: BorderRadius.circular(8),
                textStyle: TextStyle(
                  color: R.color.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                align: Alignment.center,
              );
            },
            onDateChanged: (datetime) async {
              if (datetime != null) {
                // Always start with morning when changing dates
                setState(() {
                  selectedDate = datetime;
                  isMorningSelected = true;
                  availableBookingSchedule =
                      _filterAvailableSchedules(fullSchedule, datetime);
                });

                // If morning is empty, switch to afternoon
                if (availableBookingSchedule.isEmpty) {
                  setState(() {
                    isMorningSelected = false;
                    availableBookingSchedule =
                        _filterAvailableSchedules(fullSchedule, datetime);
                  });
                }
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

    // if (morningTargets.isEmpty && isMorningSelected) {
    //   setState(() {
    //     isMorningSelected = false;
    //   });
    // }

    return LayoutBuilder(builder: (context, constraints) {
      final targets = isMorningSelected ? morningTargets : afternoonTargets;
      return targets.isEmpty
          ? DsmesEmptyWidget(
              imagePath: R.drawable.dsmes_empty,
              title:
                  "Đã hết lịch trống!\nBạn vui lòng chọn khung giờ khác nhé!",
              subtitle: "",
            )
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.spaceBetween,
                children:
                    List.generate((targets.length / 3).ceil() * 3, (index) {
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
                  availableBookingSchedule =
                      _filterAvailableSchedules(fullSchedule, selectedDate!);
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
                  availableBookingSchedule =
                      _filterAvailableSchedules(fullSchedule, selectedDate!);
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

  DateTime _getLastDate() {
    return DateTime.now().add(Duration(days: 30));
  }
}
