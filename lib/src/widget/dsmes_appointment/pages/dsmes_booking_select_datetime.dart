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
import 'package:medical/src/widgets/gap_widget.dart';

class DsmesCalendarSection extends StatefulWidget {
  final String? serviceType;
  final String action; // 'create' or 'reschedule'
  final int? appointmentId;
  final bool isMergedSchedule;
  final String bookingType; // 'clinic' or 'center' or 'doctor'

  const DsmesCalendarSection({
    Key? key,
    this.serviceType,
    this.action = 'create',
    this.appointmentId,
    this.isMergedSchedule = false,
    this.bookingType = Const.BOOKING_TYPE_CENTER,
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
  Map<String, bool> isProcessingClinic = {
    'telemedicine': false,
    'atClnic': false,
  };
  bool isAllowReschedule = false;

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

      // Update isMorningSelected based on the schedules time
      // Case restrict only 1 slot per timeframe => current slot will unavailable => show timeframes base on first schedules
      // Case allow multiple slots per timeframe => current slot will available => show timeframes base on current slot
      isMorningSelected = schedules.any((schedule) {
        final scheduleDateTime = DateTime.parse(schedule.startTime);
        return scheduleDateTime.year == selectedDate!.year &&
            scheduleDateTime.month == selectedDate!.month &&
            scheduleDateTime.day == selectedDate!.day &&
            scheduleDateTime.hour == selectedDate!.hour &&
            scheduleDateTime.minute == selectedDate!.minute;
      })
          ? selectedDate!.hour < 12
          : schedules.isNotEmpty
              ? DateTime.parse(schedules.first.startTime).hour < 12
              : true;

      isAllowReschedule = isSelectedScheduleAvailable();
    });
  }

  bool isSelectedScheduleAvailable() {
    if (selectedBookingSchedule == null) return false;

    return fullSchedule.any((schedule) =>
        _cubit.ensureTimeWithSeconds(schedule.startTime) ==
            _cubit.ensureTimeWithSeconds(selectedBookingSchedule!.startTime) &&
        _cubit.ensureTimeWithSeconds(schedule.endTime) ==
            _cubit.ensureTimeWithSeconds(selectedBookingSchedule!.endTime) &&
        schedule.isAvailable == true);
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
    // return widget.isMergedSchedule == false
    //     ? _cubit.selectedClinic?.getBookingSchedules() ?? []
    //     : await _cubit.getDiabClinicsSchedule();
    if (widget.bookingType == Const.BOOKING_TYPE_DOCTOR) {
      return _cubit.selectedDoctor?.getBookingSchedules() ?? [];
    }
    return _cubit.selectedClinic?.getBookingSchedules() ?? [];
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
                        DsmesNavigationMixin.getNavigationKey()
                            .currentState
                            ?.pop(DsmesNavigationMixin.getNavigationKey()
                                .currentState
                                ?.context);
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
                child: _handleActionButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _handleActionButton() {
    if (widget.bookingType == Const.BOOKING_TYPE_CENTER) {
      return _buildBookingDsmesActionButtons();
    } else if (widget.bookingType == Const.BOOKING_TYPE_CLINIC) {
      return _buildBookingClinicActionButtons();
    } else if (widget.bookingType == Const.BOOKING_TYPE_DOCTOR) {
      return _buildBookingDoctorActionButtons();
    }
  }

  List<ServiceAvailable> getFilteredServiceTypes() {
    final listServiceTypes =
        List<ServiceAvailable>.from(_cubit.selectedClinic?.svAvailable ?? []);
    listServiceTypes.removeWhere((element) => element.key == 'at_home');

    if (_cubit.selectedClinic?.profileType == 'premium') {
      return listServiceTypes
          .where((element) => element.key == 'at_clinic')
          .toList();
    }

    return listServiceTypes;
  }

  Widget _buildBookingClinicActionButtons() {
    final listServiceTypes = getFilteredServiceTypes();

    final route = ModalRoute.of(context)?.settings;
    final args = route?.arguments as Map<String, dynamic>?;
    final isEditing = args?['isEditing'] ?? false;

    if (widget.action == 'reschedule' || isEditing) {
      return _buildButton(R.string.tiep_tuc.tr(), () {
        _handleClinicContinueButton();
      }, isDisabled: !isAllowReschedule);
    }

    if (listServiceTypes.length == 2) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _handleBookingClinicTelemedicine();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            R.color.greenGradientTop02,
                            R.color.greenGradientBottom
                          ],
                        ),
                        borderRadius: BorderRadius.circular(200),
                      ),
                      padding: EdgeInsets.all(10),
                      child: Text(
                        R.string.kham_tu_xa.tr(),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: R.color.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            GapH(8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _handleBookingClinicAtClinic();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: 44,
                      decoration: BoxDecoration(
                        color: R.color.color0xffE7FDFB,
                        borderRadius: BorderRadius.circular(200),
                      ),
                      padding: EdgeInsets.all(10),
                      child: Text(
                        R.string.kham_tai_phong_kham.tr(),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: R.color.greenGradientBottom,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else if (listServiceTypes.length == 1) {
      final serviceType = listServiceTypes.first;
      final title = serviceType.key == DsmesAppointmentMode.atClinic.toString()
          ? R.string.kham_tai_phong_kham.tr()
          : R.string.kham_tu_xa.tr();

      return Container(
        color: R.color.white,
        padding: EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: GestureDetector(
          onTap: () {
            serviceType.key == DsmesAppointmentMode.atClinic.toString()
                ? _handleBookingClinicAtClinic()
                : _handleBookingClinicTelemedicine();
          },
          child: Container(
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  R.color.greenGradientTop02,
                  R.color.greenGradientBottom
                ],
              ),
              borderRadius: BorderRadius.circular(200),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: R.color.white,
              ),
            ),
          ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  _handleBookingClinicAtClinic() {
    if (isProcessingClinic['atClinic'] == true) return;

    if (selectedBookingSchedule == null) {
      Message.showToastMessage(context, R.string.vui_long_chon_gio_kham.tr());
      return;
    }

    // When selected booking schedule is before active dates
    if (activeDates.isNotEmpty &&
        DateTime.parse(selectedBookingSchedule!.startTime)
            .isBefore(activeDates.first)) {
      Message.showToastMessage(context, R.string.vui_long_chon_gio_kham.tr());
      return;
    }
    setState(() => isProcessingClinic['atClinic'] = true);

    try {
      _cubit.updateCreateDsmesBookingRequestTime(
          startTime: selectedBookingSchedule!.startTime,
          endTime: selectedBookingSchedule!.endTime);

      // Normal flow
      DsmesNavigationMixin.getNavigationKey()
          .currentState
          ?.pushNamed(NavigatorName.dsmes_confirm_information, arguments: {
        'serviceType': DsmesAppointmentMode.atClinic.toString(),
        'action': widget.action,
        'appointmentId': widget.appointmentId,
        'isMergedSchedule': widget.isMergedSchedule,
        'bookingType': widget.bookingType,
      });
    } finally {
      setState(() => isProcessingClinic['atClinic'] = false);
    }
  }

  _handleBookingClinicTelemedicine() {
    if (isProcessingClinic['telemedicine'] == true) return;

    if (selectedBookingSchedule == null) {
      Message.showToastMessage(context, R.string.vui_long_chon_gio_kham.tr());
      return;
    }

    // When selected booking schedule is before active dates
    if (activeDates.isNotEmpty &&
        DateTime.parse(selectedBookingSchedule!.startTime)
            .isBefore(activeDates.first)) {
      Message.showToastMessage(context, R.string.vui_long_chon_gio_kham.tr());
      return;
    }
    setState(() => isProcessingClinic['telemedicine'] = true);

    try {
      _cubit.updateCreateDsmesBookingRequestTime(
          startTime: selectedBookingSchedule!.startTime,
          endTime: selectedBookingSchedule!.endTime);

      // Normal flow
      DsmesNavigationMixin.getNavigationKey()
          .currentState
          ?.pushNamed(NavigatorName.clinic_select_service, arguments: {
        'clinic': _cubit.selectedClinic,
        'serviceType': DsmesAppointmentMode.telemedicine.toString(),
        'action': widget.action,
        'bookingType': widget.bookingType,
      });
    } finally {
      setState(() => isProcessingClinic['telemedicine'] = false);
    }
  }

  _handleClinicContinueButton() {
    if (selectedBookingSchedule == null) {
      Message.showToastMessage(context, R.string.vui_long_chon_gio_kham.tr());
      return;
    }

    // When selected booking schedule is before active dates
    if (activeDates.isNotEmpty &&
        DateTime.parse(selectedBookingSchedule!.startTime)
            .isBefore(activeDates.first)) {
      Message.showToastMessage(context, R.string.vui_long_chon_gio_kham.tr());
      return;
    }

    // Prevent user from reschedule the same time
    if (widget.action == 'reschedule') {
      final selectedDateTime =
          DateTime.parse(selectedBookingSchedule!.startTime);
      final existingDateTime =
          DateTime.parse(_cubit.createDsmesBookingRequest!.startTime);

      if (selectedDateTime.isSameDayWith(existingDateTime) &&
          selectedDateTime.hour == existingDateTime.hour &&
          selectedDateTime.minute == existingDateTime.minute) {
        Message.showToastMessage(context, R.string.exist_appointment.tr());
        return;
      }
    }

    setState(() => _isProcessing = true);

    try {
      _cubit.updateCreateDsmesBookingRequestTime(
          startTime: selectedBookingSchedule!.startTime,
          endTime: selectedBookingSchedule!.endTime);

      final route = ModalRoute.of(context)?.settings;
      final args = route?.arguments as Map<String, dynamic>?;
      final isEditing = args?['isEditing'] ?? false;
      final bookingType = args?['bookingType'] ?? widget.bookingType;
      final previousRoute =
          args?['previousRoute'] ?? NavigatorName.dsmes_confirm_information;

      if (isEditing) {
        // First pop the current select_date page
        DsmesNavigationMixin.getNavigationKey().currentState?.pop();
        DsmesNavigationMixin.getNavigationKey().currentState?.popUntil(
            (route) =>
                route.settings.name == NavigatorName.dsmes_booking_select_date);

        DsmesNavigationMixin.getNavigationKey()
            .currentState
            ?.pushReplacementNamed(NavigatorName.dsmes_booking_select_date,
                arguments: {
              'serviceType': widget.serviceType,
              'action': widget.action,
              'previousRoute': previousRoute,
              'bookingType': bookingType,
              'isEditing': isEditing,
            });

        // Push confirm info
        DsmesNavigationMixin.getNavigationKey()
            .currentState
            ?.pushNamed(NavigatorName.dsmes_confirm_information, arguments: {
          'serviceType': widget.serviceType,
          'action': widget.action,
          'appointmentId': widget.appointmentId,
          'isMergedSchedule': widget.isMergedSchedule,
          'bookingType': widget.bookingType,
        });
      } else {
        // Normal flow
        DsmesNavigationMixin.getNavigationKey()
            .currentState
            ?.pushNamed(NavigatorName.dsmes_confirm_information, arguments: {
          'serviceType': widget.serviceType,
          'action': widget.action,
          'appointmentId': widget.appointmentId,
          'isMergedSchedule': widget.isMergedSchedule,
          'bookingType': widget.bookingType,
        });
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  _buildBookingDsmesActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildButton(R.string.tiep_tuc.tr(), () async {
            if (_isProcessing) return;

            if (selectedBookingSchedule == null) {
              Message.showToastMessage(
                  context, R.string.vui_long_chon_gio_kham.tr());
              return;
            }

            // When selected booking schedule is before active dates
            if (activeDates.isNotEmpty &&
                DateTime.parse(selectedBookingSchedule!.startTime)
                    .isBefore(activeDates.first)) {
              Message.showToastMessage(
                  context, R.string.vui_long_chon_gio_kham.tr());
              return;
            }

            // Prevent user from reschedule the same time
            if (widget.action == 'reschedule') {
              final selectedDateTime =
                  DateTime.parse(selectedBookingSchedule!.startTime);
              final existingDateTime =
                  DateTime.parse(_cubit.createDsmesBookingRequest!.startTime);

              if (selectedDateTime.isSameDayWith(existingDateTime) &&
                  selectedDateTime.hour == existingDateTime.hour &&
                  selectedDateTime.minute == existingDateTime.minute) {
                Message.showToastMessage(
                    context, R.string.exist_appointment.tr());
                return;
              }
            }

            setState(() => _isProcessing = true);

            try {
              _cubit.updateCreateDsmesBookingRequestTime(
                  startTime: selectedBookingSchedule!.startTime,
                  endTime: selectedBookingSchedule!.endTime);

              final route = ModalRoute.of(context)?.settings;
              final args = route?.arguments as Map<String, dynamic>?;
              final isEditing = args?['isEditing'] ?? false;

              if (isEditing) {
                if (widget.serviceType ==
                    DsmesAppointmentMode.telemedicine.toString()) {
                  // Pop until select_service to rebuild stack with new state
                  DsmesNavigationMixin.getNavigationKey()
                      .currentState
                      ?.popUntil((route) =>
                          route.settings.name ==
                          NavigatorName.dsmes_select_service);

                  // Replace select_service
                  DsmesNavigationMixin.getNavigationKey()
                      .currentState
                      ?.pushReplacementNamed(NavigatorName.dsmes_select_service,
                          arguments: {
                        'serviceType': widget.serviceType,
                        'action': widget.action,
                        'clinic': _cubit.selectedClinic,
                      });

                  // Push new select_date with updated state
                  DsmesNavigationMixin.getNavigationKey()
                      .currentState
                      ?.pushNamed(NavigatorName.dsmes_booking_select_date,
                          arguments: {
                        'serviceType': widget.serviceType,
                        'action': widget.action,
                      });
                } else {
                  // First pop the current select_date page
                  DsmesNavigationMixin.getNavigationKey().currentState?.pop();
                  DsmesNavigationMixin.getNavigationKey()
                      .currentState
                      ?.popUntil((route) =>
                          route.settings.name ==
                          NavigatorName.dsmes_booking_select_date);

                  DsmesNavigationMixin.getNavigationKey()
                      .currentState
                      ?.pushReplacementNamed(
                          NavigatorName.dsmes_booking_select_date,
                          arguments: {
                        'serviceType': widget.serviceType,
                        'action': widget.action,
                      });
                }

                // Push confirm info
                DsmesNavigationMixin.getNavigationKey().currentState?.pushNamed(
                    NavigatorName.dsmes_confirm_information,
                    arguments: {
                      'serviceType': widget.serviceType,
                      'action': widget.action,
                      'appointmentId': widget.appointmentId,
                      'isMergedSchedule': widget.isMergedSchedule,
                    });
              } else {
                // Normal flow
                DsmesNavigationMixin.getNavigationKey().currentState?.pushNamed(
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
          }, isDisabled: !isAllowReschedule),
        ),
      ],
    );
  }

  _buildBookingDoctorActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildButton(R.string.tiep_tuc.tr(), () async {
            if (_isProcessing) return;

            if (selectedBookingSchedule == null) {
              Message.showToastMessage(
                  context, R.string.vui_long_chon_gio_kham.tr());
              return;
            }

            // When selected booking schedule is before active dates
            if (activeDates.isNotEmpty &&
                DateTime.parse(selectedBookingSchedule!.startTime)
                    .isBefore(activeDates.first)) {
              Message.showToastMessage(
                  context, R.string.vui_long_chon_gio_kham.tr());
              return;
            }

            // Prevent user from reschedule the same time
            if (widget.action == 'reschedule') {
              final selectedDateTime =
                  DateTime.parse(selectedBookingSchedule!.startTime);
              final existingDateTime =
                  DateTime.parse(_cubit.createDsmesBookingRequest!.startTime);

              if (selectedDateTime.isSameDayWith(existingDateTime) &&
                  selectedDateTime.hour == existingDateTime.hour &&
                  selectedDateTime.minute == existingDateTime.minute) {
                Message.showToastMessage(
                    context, R.string.exist_appointment.tr());
                return;
              }
            }

            setState(() => _isProcessing = true);

            try {
              _cubit.updateCreateDsmesBookingRequestTime(
                  startTime: selectedBookingSchedule!.startTime,
                  endTime: selectedBookingSchedule!.endTime);

              final route = ModalRoute.of(context)?.settings;
              final args = route?.arguments as Map<String, dynamic>?;
              final isEditing = args?['isEditing'] ?? false;

              if (isEditing) {
                // First pop the current select_date page
                DsmesNavigationMixin.getNavigationKey().currentState?.pop();
                DsmesNavigationMixin.getNavigationKey().currentState?.popUntil(
                    (route) =>
                        route.settings.name ==
                        NavigatorName.dsmes_booking_select_date);

                DsmesNavigationMixin.getNavigationKey()
                    .currentState
                    ?.pushReplacementNamed(
                        NavigatorName.dsmes_booking_select_date,
                        arguments: {
                      'serviceType': widget.serviceType,
                      'action': widget.action,
                      'bookingType': widget.bookingType,
                    });
              }

              // Normal flow
              DsmesNavigationMixin.getNavigationKey().currentState?.pushNamed(
                  NavigatorName.dsmes_confirm_information,
                  arguments: {
                    'serviceType': widget.serviceType,
                    'action': widget.action,
                    'appointmentId': widget.appointmentId,
                    'isMergedSchedule': widget.isMergedSchedule,
                    'bookingType': widget.bookingType,
                  });
            } finally {
              setState(() => _isProcessing = false);
            }
          }, isDisabled: !isAllowReschedule),
        ),
      ],
    );
  }

  Widget _buildButton(String text, VoidCallback onTap,
      {bool isDisabled = false}) {
    return InkWell(
      onTap: isDisabled ? null : onTap,
      child: Container(
        height: 44,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isDisabled
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(200),
                color: R.color.color0xffC2C2C2,
              )
            : BoxDecoration(
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
              color: isDisabled ? R.color.grey200 : R.color.white,
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
              BotToast.showCustomText(
                toastBuilder: (_) => Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  decoration: BoxDecoration(
                    color: R.color.color0xff111515.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    R.string.select_booking_dates_warning.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: R.color.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                align: Alignment.center,
                duration: Duration(seconds: 2),
                clickClose: true,
                crossPage: true,
                onlyOne: true,
              );
            },
            onDateChanged: (datetime) async {
              if (datetime != null) {
                setState(() {
                  selectedDate = datetime;
                  availableBookingSchedule =
                      _filterAvailableSchedules(fullSchedule, datetime);
                  isMorningSelected = availableBookingSchedule.isNotEmpty
                      ? DateTime.parse(availableBookingSchedule.first.startTime)
                              .hour <
                          12
                      : true;
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
              isAllowReschedule = isSelectedScheduleAvailable();
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
                if (widget.bookingType == Const.BOOKING_TYPE_CENTER)
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
                if (widget.bookingType == Const.BOOKING_TYPE_CENTER)
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
