import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/request/create_dsmes_booking_request.dart';
import 'package:medical/src/model/request/dsmes_cancel_booking_request.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/benefit/benefit_reschedule_flow.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_appointment_model.dart';
import 'package:medical/src/widget/dsmes_appointment/widgets/section_add_symptom.dart';
import 'package:medical/src/widget/home/widget/home_support_functions.dart';
import 'package:medical/src/widgets/gap_widget.dart';

/// Benefit-flow booking detail page.
///
/// Cloned from [DsmesBookingDetail] but stripped of all DSMES-specific
/// navigation (Observable, BranchioLinkConfig, DsmesNavigationMixin,
/// bookingType center/doctor distinction) and wired to the benefit
/// navigator stack instead.
class BenefitBookingDetailPage extends StatefulWidget {
  final String serviceType;
  final DsmesAppointment appointment;
  final String bookingType;
  /// The route that navigated here. When non-null, back pops instead of
  /// clearing the stack to tabbar (supports the history-entry back flow).
  final String? previousRoute;

  const BenefitBookingDetailPage({
    Key? key,
    required this.serviceType,
    required this.appointment,
    this.bookingType = Const.BENEFIT_BOOKING_AT_CLINIC,
    this.previousRoute,
  }) : super(key: key);

  @override
  _BenefitBookingDetailPageState createState() =>
      _BenefitBookingDetailPageState();
}

class _BenefitBookingDetailPageState extends State<BenefitBookingDetailPage> {
  late DsmesAppointmentCubit _cubit;
  FocusNode symptomFocusNode = FocusNode();
  late TextEditingController symptomController;
  final GlobalKey<SectionAddSymptomState> _sectionAddSymptomKey =
      GlobalKey<SectionAddSymptomState>();

  @override
  void initState() {
    super.initState();
    _cubit = context.read<DsmesAppointmentCubit>();
    symptomController =
        TextEditingController(text: widget.appointment.symptom);
  }

  void _navigateBack() {
    if (widget.previousRoute != null) {
      Navigator.of(context, rootNavigator: true).pop();
    } else {
      Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
        NavigatorName.tabbar,
        (route) => false,
      );
    }
  }

  bool _isExamination() => widget.appointment.isExaminationAtHome;

  bool _shouldShowJoinButton() {
    if (widget.appointment.status != DSMES_STATUS_APPROVE ||
        widget.appointment.mode !=
            DsmesAppointmentMode.telemedicine.toString()) {
      return false;
    }

    final appointmentStart =
        DateFormat('yyyy-MM-dd HH:mm').parse(widget.appointment.startTime);
    final now = DateTime.now();

    // 10 minutes before and after start time window
    final windowStart = appointmentStart.subtract(const Duration(minutes: 10));
    final windowEnd = appointmentStart.add(const Duration(minutes: 10));

    return now.isAfter(windowStart) && now.isBefore(windowEnd);
  }

  bool isCompletedAppointment() {
    final endDateTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').parse(widget.appointment.endTime);
    final isPast = endDateTime.isBefore(DateTime.now());

    return isPast && widget.appointment.status == DSMES_STATUS_APPROVE;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        FocusScope.of(context).unfocus();
        _navigateBack();
        return false;
      },
      child: Scaffold(
        drawerEnableOpenDragGesture: false,
        body: Container(
          decoration: BoxDecoration(
            color: R.color.backgroundColorNew,
          ),
          child: _buildPage(context),
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    R.color.greenGradientTop02,
                    R.color.greenGradientBottom
                  ],
                  stops: const [0.01, 0.99],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: CustomAppBar(
                backgroundColor: Colors.transparent,
                title: Text(
                  R.string.schedule_information.tr(),
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: R.color.white),
                ),
                actions: [
                  InkWell(
                    onTap: () async {
                      HomeSupportFunctions.showModalAddData(context);
                    },
                    child: Container(
                      height: 36,
                      padding:
                          EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      margin: EdgeInsets.fromLTRB(0, 12, 16, 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: R.color.color0xffCAFAF5,
                        border: Border.all(
                          color: R.color.color0xff8FEBE0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            R.icons.ic_telephone,
                            width: 16,
                            height: 16,
                            color: R.color.greenGradientBottom,
                            fit: BoxFit.scaleDown,
                          ),
                          GapW(8),
                          MediaQuery(
                            data: MediaQuery.of(context).copyWith(
                              textScaler: MediaQuery.of(context)
                                  .textScaler
                                  .clamp(
                                      minScaleFactor: 1.0,
                                      maxScaleFactor: 1.3),
                            ),
                            child: Text(
                              R.string.contact.tr(),
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'sfpro',
                                fontWeight: FontWeight.w700,
                                color: R.color.greenGradientBottom,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                leadingIcon: IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  icon: Icon(
                    Icons.arrow_back,
                    color: R.color.white,
                  ),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    _navigateBack();
                  },
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildPatientInformation(),
                      GapH(12),
                      _buildConsultingInformation(),
                      if (widget.serviceType ==
                          DsmesAppointmentMode.telemedicine.toString())
                        GapH(12),
                      if (widget.serviceType ==
                          DsmesAppointmentMode.telemedicine.toString())
                        _buildSelectedServiceInformation(),
                      if (widget.appointment.symptom.isNotEmpty) GapH(12),
                      if (widget.appointment.symptom.isNotEmpty ||
                          widget.appointment.symptomAttachment.isNotEmpty)
                        _selectImageSection(),
                      GapH(12),
                      if (isCompletedAppointment() == false &&
                          widget.appointment.status != DSMES_STATUS_REJECT)
                        _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _isExamination()
              ? const SizedBox.shrink()
              : _shouldShowJoinButton()
                  ? Container(
                      decoration: BoxDecoration(
                        color: R.color.white,
                        boxShadow: [Utils.getBoxShadowDropButton()],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildPrimaryButton(
                              R.string.join_now.tr(),
                              () async {
                                _handleJoinRoom();
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  : isCompletedAppointment()
                      ? _builCompletedAppointmentActionButtons()
                      : const SizedBox.shrink(),
        ),
      ],
    );
  }

  _handleJoinRoom() async {
    // Benefit flow uses the root navigator for all routes.
    // Telemedicine room joining would need its own route registration.
  }

  String getTimeRange(String startTime, String endTime) {
    final start = DateFormat('HH:mm')
        .format(DateFormat('yyyy-MM-dd HH:mm').parse(startTime));
    final end = DateFormat('HH:mm')
        .format(DateFormat('yyyy-MM-dd HH:mm').parse(endTime));
    return '$start-$end';
  }

  String getFormattedDate(String startTime) {
    final date = DateFormat('yyyy-MM-dd HH:mm').parse(startTime);
    final weekDay = DateUtil.weekDayToString(date, isDisplayfull: true);
    return '$weekDay, ${DateFormat('dd/MM/yyyy').format(date)}';
  }

  _buildPatientInformation() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          Utils.getBoxShadowDropCard(),
        ],
      ),
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  R.string.consult_information.tr(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: R.color.color0xff111515,
                  ),
                ),
              ],
            ),
            GapH(16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  R.string.name.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: R.color.color0xff777E90,
                  ),
                ),
                Text(
                  widget.appointment.patientInfo.displayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: R.color.color0xff111515,
                  ),
                ),
              ],
            ),
            GapH(4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  R.string.so_dien_thoai.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: R.color.color0xff777E90,
                  ),
                ),
                Text(
                  widget.appointment.patientInfo.phone,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: R.color.color0xff111515,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _buildConsultingInformation() {
    final endDate =
        DateFormat('yyyy-MM-dd HH:mm:ss').parse(widget.appointment.endTime);
    final isPast = endDate.isBefore(DateTime.now());

    final isExaminationAtHome = widget.appointment.isExaminationAtHome;

    String _getConsultTitle() {
      if (isExaminationAtHome) {
        return R.string.xet_nghiem_tai_nha.tr();
      }

      return widget.serviceType == DsmesAppointmentMode.atClinic.toString()
          ? R.string.consult_at_clinic.tr()
          : R.string.consult_online.tr();
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          Utils.getBoxShadowDropCard(),
        ],
      ),
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getConsultTitle(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: R.color.color0xff111515,
                  ),
                ),
              ],
            ),
            GapH(16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 3,
                  child: Text(
                    R.string.status.tr(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: R.color.color0xff777E90,
                    ),
                  ),
                ),
                Flexible(
                  flex: 7,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: _cubit.getItemStatusContainerColor(
                          widget.appointment.status, isPast),
                    ),
                    padding:
                        EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                    child: Text(
                      _cubit.getItemStatus(
                          widget.appointment.status, isPast),
                      maxLines: 2,
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _cubit.getItemStatusTextColor(
                            widget.appointment.status, isPast),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            GapH(4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isExaminationAtHome
                      ? R.string.thoi_gian.tr()
                      : R.string.consult_time.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: R.color.color0xff777E90,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      getTimeRange(widget.appointment.startTime,
                          widget.appointment.endTime),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: R.color.color0xffA36E2A,
                      ),
                    ),
                    Text(
                      getFormattedDate(widget.appointment.startTime),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: R.color.color0xffA36E2A,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (isExaminationAtHome) GapH(4),
            if (isExaminationAtHome)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 3,
                    child: Text(
                      R.string.address.tr(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: R.color.color0xff777E90,
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 7,
                    child: Text(
                      widget.appointment.homeAddress!,
                      maxLines: 2,
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: R.color.color0xff111515,
                      ),
                    ),
                  ),
                ],
              ),
            if (widget.appointment.mode ==
                DsmesAppointmentMode.atClinic.toString())
              GapH(4),
            if (widget.appointment.mode ==
                DsmesAppointmentMode.atClinic.toString())
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 3,
                    child: Text(
                      R.string.center_name.tr(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: R.color.color0xff777E90,
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 7,
                    child: Text(
                      widget.appointment.clinic.name,
                      maxLines: 2,
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: R.color.color0xff111515,
                      ),
                    ),
                  ),
                ],
              ),
            if (widget.appointment.mode ==
                DsmesAppointmentMode.atClinic.toString())
              GapH(4),
            if (widget.appointment.mode ==
                DsmesAppointmentMode.atClinic.toString())
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 3,
                    child: Text(
                      R.string.address.tr(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: R.color.color0xff777E90,
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 7,
                    child: Text(
                      widget.appointment.clinic.address,
                      maxLines: 2,
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: R.color.color0xff111515,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  _buildSelectedServiceInformation() {
    if (widget.appointment.services.isEmpty) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          Utils.getBoxShadowDropCard(),
        ],
      ),
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  R.string.consult_demand.tr(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: R.color.color0xff111515,
                  ),
                ),
              ],
            ),
            GapH(6),
            Column(
              children: [
                ...widget.appointment.services.map((e) {
                  final service = _cubit.selectedClinic?.serviceList.categories
                      .expand((category) => category.data)
                      .firstWhere((service) => service.id == e.id);

                  final isLastItem =
                      e == widget.appointment.services.last;

                  return Column(
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10),
                              child: Text(
                                service?.name ?? '',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: R.color.color0xff111515,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (!isLastItem)
                        Divider(color: R.color.color0xffE6E8EC)
                    ],
                  );
                }),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _selectImageSection() {
    return SectionAddSymptom(
      focusNode: symptomFocusNode,
      controllerNote: symptomController,
      maxMedia: 5,
      key: _sectionAddSymptomKey,
      initialFiles: widget.appointment.symptomAttachment
          .map((e) => e.filePath)
          .toList(),
      isDisplayRemove: false,
      readOnly: true,
      isDisplayTextField: widget.appointment.symptom.isNotEmpty,
    );
  }

  _buildActionButtons() {
    final startTime = DateFormat('HH:mm').format(
        DateFormat('yyyy-MM-dd HH:mm').parse(widget.appointment.startTime));
    final isReschedule = widget.appointment.rescheduledAt != null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Flexible(
          flex: 1,
          child: GestureDetector(
            onTap: () {
              _showPopupBookingAction(
                title: R.string.confirm_cancel_schedule.tr(),
                subtitle: R.string.confirm_cancel_schedule_content
                    .tr(args: [startTime]),
                onConfirm: () async {
                  await _cubit.cancelDsmesAppointment(
                    request: DsmesCancelBookingRequest(
                      id: widget.appointment.id,
                      reason: [],
                    ),
                  );

                  Navigator.of(context).pop();
                  if (_isExamination()) {
                    Navigator.of(context, rootNavigator: true).pop();
                  } else {
                    Navigator.of(context, rootNavigator: true)
                        .pushNamedAndRemoveUntil(
                      NavigatorName.tabbar,
                      (route) => false,
                    );
                  }
                },
              );
            },
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: R.color.color0xffFFE9E9,
                borderRadius: BorderRadius.circular(200),
                border: Border.all(
                  color: R.color.color0xffDC0000,
                ),
              ),
              child: Center(
                child: Text(
                  R.string.cancel_booking.tr(),
                  style: TextStyle(
                    color: R.color.color0xffDC0000,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (!isReschedule) GapW(12),
        if (!isReschedule)
          Flexible(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                _showPopupBookingAction(
                    title: R.string.confirm_change_schedule.tr(),
                    subtitle: R.string
                        .confirm_change_booking_content
                        .tr(),
                    hasGradient: true,
                    onConfirm: () async {
                      await _cubit.getClinicDetail(
                          id: widget.appointment.clinicId);

                      _cubit.initCreateDsmesBookingRequest(
                          locale: context.locale.languageCode);
                      final rescheduleRequest =
                          CreateDsmesBookingRequest(
                        startTime: widget.appointment.startTime,
                        endTime: widget.appointment.endTime,
                        clinicId: widget.appointment.clinicId,
                        doctorId: widget.appointment.doctorId,
                        patientPhoneNumber:
                            widget.appointment.patientInfo.phone,
                        patientName:
                            widget.appointment.patientInfo.displayName,
                        birthday:
                            widget.appointment.patientInfo.birthday,
                        patientGender:
                            widget.appointment.patientInfo.gender ==
                                        'Nam' ||
                                    widget.appointment.patientInfo
                                            .gender ==
                                        'Male' ||
                                    widget.appointment.patientInfo
                                            .gender ==
                                        '1'
                                ? 1
                                : 2,
                        patientEmail:
                            widget.appointment.patientInfo.email,
                        bookingForClinic: 1,
                        language: context.locale.languageCode,
                        symptom: widget.appointment.symptom,
                        symptomAttachment:
                            widget.appointment.symptomAttachment
                                .map((e) => e.filePath)
                                .toList(),
                        paymentInfo: PaymentInfo(
                            services: widget.appointment.services),
                      );
                      _cubit.updateCreateDsmesBookingRequest(
                          request: rescheduleRequest);

                      if (!mounted) return;
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute<void>(
                          builder: (_) => BenefitRescheduleFlow(
                            cubit: _cubit,
                            serviceType: widget.serviceType,
                            appointmentId: widget.appointment.id,
                            bookingType: widget.bookingType,
                            previousRoute: widget.previousRoute,
                          ),
                        ),
                      );
                    });
              },
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: R.color.white,
                  borderRadius: BorderRadius.circular(200),
                  border: Border.all(
                    color: R.color.greenGradientBottom,
                  ),
                ),
                child: Center(
                  child: Text(
                    R.string.change_booking.tr(),
                    style: TextStyle(
                      color: R.color.greenGradientBottom,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  _builCompletedAppointmentActionButtons() {
    final isExaminationAtHome = widget.appointment.isExaminationAtHome;
    return Container(
      color: R.color.white,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context, rootNavigator: true)
                    .pushNamedAndRemoveUntil(
                  NavigatorName.tabbar,
                  (route) => false,
                );
              },
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: R.color.color0xffE7FDFB,
                  borderRadius: BorderRadius.circular(200),
                ),
                child: Center(
                  child: Text(
                    R.string.back_home_page.tr(),
                    style: TextStyle(
                      color: R.color.greenGradientBottom,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (!isExaminationAtHome) GapW(12),
          if (!isExaminationAtHome)
            Flexible(
              flex: 1,
              child: GestureDetector(
                onTap: () async {
                  final locale = context.locale.languageCode;
                  _cubit.initCreateDsmesBookingRequest(locale: locale);
                  final rebookingRequest = CreateDsmesBookingRequest(
                      startTime: "",
                      endTime: "",
                      clinicId: widget.appointment.clinic.id,
                      doctorId: widget.appointment.doctorId,
                      patientPhoneNumber:
                          widget.appointment.patientInfo.phone,
                      patientName:
                          widget.appointment.patientInfo.displayName,
                      birthday:
                          widget.appointment.patientInfo.birthday,
                      patientGender: int.tryParse(
                              widget.appointment.patientInfo.gender) ??
                          (AppSettings.userInfo?.gender == 'Male'
                              ? 1
                              : 0),
                      patientEmail:
                          widget.appointment.patientInfo.email,
                      bookingForClinic: 1,
                      language: locale,
                      symptom: widget.appointment.symptom,
                      symptomAttachment:
                          widget.appointment.symptomAttachment
                              .map((e) => e.filePath)
                              .toList(),
                      paymentInfo: PaymentInfo(
                        paymentType: null,
                        services: widget.appointment.services,
                      ));
                  _cubit.updateCreateDsmesBookingRequest(
                      request: rebookingRequest);

                  Navigator.of(context, rootNavigator: true)
                      .pushNamedAndRemoveUntil(
                    NavigatorName.tabbar,
                    (route) => false,
                  );

                  // Push select date for rebooking
                  Navigator.of(context, rootNavigator: true)
                      .pushNamed(
                    NavigatorName.dsmes_booking_select_date,
                    arguments: {
                      'serviceType': widget.appointment.mode,
                      'action': 'create',
                      'bookingType': widget.bookingType,
                    },
                  );
                },
                child: Container(
                  height: 42,
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
                  child: Center(
                    child: Text(
                      R.string.rebooking.tr(),
                      style: TextStyle(
                        color: R.color.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
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

  Widget _buildPrimaryButton(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 44,
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

  _showPopupBookingAction({
    required Function onConfirm,
    bool isShowImg = false,
    String? subtitle,
    String? title,
    String primaryButtonTitle = 'Xác nhận',
    bool hasGradient = false,
  }) {
    showDialog<bool>(
      context: context,
      builder: (context) {
        return Container(
          child: AlertDialog(
            contentPadding: EdgeInsets.all(0),
            titlePadding: EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  width: 350,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop(false);
                            },
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: Icon(
                                Icons.close,
                                color: R.color.color0xff636A6B,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (isShowImg)
                        Image.asset(R.drawable.ic_dialog_success,
                            width: 66, height: 66),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Text(
                              title ?? '',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: R.color.color0xff111515,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          subtitle ?? "",
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: R.color.color0xff777E90,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pop(true);
                              onConfirm();
                            },
                            child: Container(
                              height: 43,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(200),
                                color: hasGradient ? null : R.color.white,
                                gradient: hasGradient
                                    ? LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          R.color.greenGradientTop02,
                                          R.color.greenGradientBottom,
                                        ],
                                      )
                                    : null,
                                border: Border.all(
                                  color: hasGradient
                                      ? Colors.transparent
                                      : R.color.greenGradientBottom,
                                ),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 40),
                              child: Center(
                                child: Text(
                                  primaryButtonTitle,
                                  style: TextStyle(
                                    color: hasGradient
                                        ? R.color.white
                                        : R.color.greenGradientBottom,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}