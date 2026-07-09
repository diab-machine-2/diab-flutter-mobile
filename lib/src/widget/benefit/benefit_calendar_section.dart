import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/request/create_dsmes_booking_request.dart';
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

/// Dedicated calendar/schedule page for the Benefit booking flow.
///
/// Supports both at-clinic and telemedicine benefit types with a simplified
/// single "Confirm" button. For telemedicine, auto-selects the first free
/// service and skips [NavigatorName.clinic_select_service].
class BenefitCalendarSection extends StatefulWidget {
  final String serviceType;
  final String action;
  final int? appointmentId;
  final String bookingType;
  final String? specialtyName;
  /// When provided, overrides the default DsmesNavigationMixin back behaviour.
  /// Used by [BenefitRescheduleFlow] to pop the root route instead.
  final VoidCallback? onBack;

  const BenefitCalendarSection({
    Key? key,
    required this.serviceType,
    this.action = 'create',
    this.appointmentId,
    required this.bookingType,
    this.specialtyName,
    this.onBack,
  }) : super(key: key);

  @override
  State<BenefitCalendarSection> createState() => _BenefitCalendarSectionState();
}

class _BenefitCalendarSectionState extends State<BenefitCalendarSection> {
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
      fullSchedule = scheduleDates;
      availableBookingSchedule = schedules;
      activeDates = dates;
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
    });
    BotToast.closeAllLoading();
  }

  Future<List<BookingSchedule>> _getScheduleDates() async {
    return _cubit.selectedClinic?.getBookingSchedules() ?? [];
  }

  List<BookingSchedule> _filterAvailableSchedules(
      List<BookingSchedule> schedules, DateTime date) {
    return schedules.where((schedule) {
      var scheduleDateTime = DateTime.parse(schedule.startTime);
      bool isSameDay = scheduleDateTime.isSameDayWith(date);
      bool isAvailable = schedule.isAvailable == true;
      return isSameDay && isAvailable;
    }).toList();
  }

  List<DateTime> _getActiveDates(
      {required List<BookingSchedule> scheduleDates}) {
    if (scheduleDates.isEmpty) return [];
    return scheduleDates
        .where((schedule) => schedule.isAvailable)
        .map((schedule) => DateTime.parse(schedule.startTime))
        .toList()
      ..sort();
  }

  DateTime _getLastDate() {
    return DateTime.now().add(const Duration(days: 30));
  }

  void _handleConfirm() {
    if (_isProcessing) return;
    if (selectedBookingSchedule == null) {
      Message.showToastMessage(context, R.string.vui_long_chon_gio_kham.tr());
      return;
    }
    if (activeDates.isNotEmpty &&
        DateTime.parse(selectedBookingSchedule!.startTime)
            .isBefore(activeDates.first)) {
      Message.showToastMessage(context, R.string.vui_long_chon_gio_kham.tr());
      return;
    }

    setState(() => _isProcessing = true);
    try {
      _cubit.updateCreateDsmesBookingRequestTime(
          startTime: selectedBookingSchedule!.startTime,
          endTime: selectedBookingSchedule!.endTime);

      final clinic = _cubit.selectedClinic;
      if (clinic == null) return;

      if (widget.serviceType == DsmesAppointmentMode.telemedicine.toString()) {
        // ── Telemedicine: select service(s) ──
        final allServices =
            clinic.serviceList.categories.expand((c) => c.data).toList();

        if (allServices.length == 1) {
          // Single service: auto-select and go straight to confirm.
          // If clinic has a voucher for this service, use sale_services payload.
          final serviceId = allServices.first.id;
          final saleItem = clinic.saleServiceList?.findByServiceId(serviceId);

          if (saleItem != null) {
            // Voucher flow: use saleServices
            _cubit.createDsmesBookingRequest =
                _cubit.createDsmesBookingRequest?.copyWith(
              paymentInfo: PaymentInfo(
                paymentType: 'local_banking',
                services: [],
                saleServices: [
                  ServiceItem(id: saleItem.serviceItemId, quantity: 1),
                ],
              ),
              voucherCode: saleItem.voucherCode,
            );
          } else {
            // No voucher: use regular services
            _cubit.updateCreateDsmesBookingRequestServiceList(
              selectedServices: [
                ServiceItem(id: serviceId, quantity: 1),
              ],
            );
          }

          DsmesNavigationMixin.getNavigationKey().currentState?.pushNamed(
            NavigatorName.benefit_confirm_information,
            arguments: {
              'serviceType': widget.serviceType,
              'action': widget.action,
              'appointmentId': widget.appointmentId,
              'isMergedSchedule': false,
              'bookingType': widget.bookingType,
              'specialtyName': widget.specialtyName,
              'branchName': _cubit.selectedClinic?.name ?? '',
            },
          );
        } else {
          // Multiple services: let the user pick
          DsmesNavigationMixin.getNavigationKey().currentState?.pushNamed(
            NavigatorName.benefit_select_service,
            arguments: {
              'serviceType': widget.serviceType,
              'action': widget.action,
              'appointmentId': widget.appointmentId,
              'bookingType': widget.bookingType,
              'specialtyName': widget.specialtyName,
              'branchName': _cubit.selectedClinic?.name ?? '',
            },
          );
        }
      } else {
        // ── At-clinic: pick up voucher from saleServiceList if present ──
        final saleServiceList = clinic.saleServiceList;
        if (saleServiceList != null && saleServiceList.services.isNotEmpty) {
          final saleItem = saleServiceList.services.first;
          _cubit.createDsmesBookingRequest =
              _cubit.createDsmesBookingRequest?.copyWith(
            paymentInfo: PaymentInfo(
              paymentType: 'local_banking',
              services: [],
              saleServices: [
                ServiceItem(id: saleItem.serviceItemId, quantity: 1),
              ],
            ),
            voucherCode: saleItem.voucherCode,
          );
        }

        DsmesNavigationMixin.getNavigationKey().currentState?.pushNamed(
          NavigatorName.benefit_confirm_information,
          arguments: {
            'serviceType': widget.serviceType,
            'action': widget.action,
            'appointmentId': widget.appointmentId,
            'isMergedSchedule': false,
            'bookingType': widget.bookingType,
            'specialtyName': widget.specialtyName,
            'branchName': _cubit.selectedClinic?.name ?? '',
          },
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: R.color.backgroundColorNew),
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
                        if (widget.onBack != null) {
                          widget.onBack!();
                        } else {
                          DsmesNavigationMixin.getNavigationKey()
                              .currentState
                              ?.pop();
                        }
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
                      children: [_buildSectionCalendarBooking()],
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
                child: _buildConfirmButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    final isEnabled = selectedBookingSchedule != null && !_isProcessing;
    return Container(
      color: R.color.white,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: GestureDetector(
        onTap: isEnabled ? _handleConfirm : null,
        child: Container(
          height: 44,
          decoration: isEnabled
              ? BoxDecoration(
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
                )
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(200),
                  color: R.color.color0xffC2C2C2,
                ),
          child: Center(
            child: Text(
              R.string.confirm.tr(),
              style: TextStyle(
                color: isEnabled ? R.color.white : R.color.grey200,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCalendarBooking() {
    return Container(
      margin: EdgeInsets.fromLTRB(12, 12, 12, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [Utils.getBoxShadowDropCard()],
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
                  selectedBookingSchedule = null;
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
          SizedBox(height: 16),
        ],
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
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
                      width: (constraints.maxWidth - 48) / 3,
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
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.of(context)
                .textScaler
                .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3)),
        child: Text(
          "${time.split(':')[0].trim()}:${time.split(':')[1].trim()}",
          style: TextStyle(
            color: PickerHelper.getTextColorByState(
                isSelected: isSlotPicked, hasSlot: true),
            fontSize: 13,
            fontFamily: 'sfpro',
            fontWeight:
                PickerHelper.getTextFontWeightByState(isSelected: isSlotPicked),
          ),
        ),
      ),
    );
  }
}
