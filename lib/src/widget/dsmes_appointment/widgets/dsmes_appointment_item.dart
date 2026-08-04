import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/request/create_dsmes_booking_request.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_appointment_model.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_booking_online_join_call_page.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_navigation_mixin.dart';
import 'package:medical/src/widget/home/widget/home_support_functions.dart';
import 'package:medical/src/widgets/gap_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class DsmesAppointmentItem extends StatelessWidget {
  final DsmesAppointment data;
  final VoidCallback onChooseService;
  final DsmesAppointmentCubit cubit;
  final bool displayActionButtons;
  final String bookingType;
  /// When true, only ever shows the "Tham gia ngay" join button for
  /// telemedicine bookings (active/inactive per [_shouldShowJoinButton]) and
  /// nothing otherwise — skips the legacy Hỗ trợ/Đặt lại buttons entirely.
  /// Used by the Benefit flow, which doesn't offer support/rebooking here.
  final bool joinButtonOnly;

  const DsmesAppointmentItem({
    Key? key,
    required this.data,
    required this.onChooseService,
    required this.cubit,
    this.displayActionButtons = true,
    this.bookingType = Const.BOOKING_TYPE_CENTER,
    this.joinButtonOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DsmesAppointmentMode mode = DsmesAppointmentMode.fromString(data.mode);

    final isExaminationAtHome = data.isExaminationAtHome;
    String icon = isExaminationAtHome
        ? R.drawable.ic_examination_at_home
        : (mode == DsmesAppointmentMode.atClinic
            ? R.drawable.ic_at_clinic
            : R.drawable.ic_telemedicine);

    final startDateTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').parse(data.startTime);
    final endDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(data.endTime);

    final formattedDate = DateFormat('dd/MM/yyyy').format(startDateTime);
    final startTime = DateFormat('HH:mm').format(startDateTime);
    final endTime = DateFormat('HH:mm').format(endDateTime);

    final isPast = endDateTime.isBefore(DateTime.now());

    return GestureDetector(
      onTap: onChooseService,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: R.color.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            Utils.getBoxShadowDropCard(),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(mode, icon, isPast: isPast),
            GapH(12),
            _buildClinicInfo(data, bookingType),
            GapH(4),
            _buildDateTime(startDateTime, formattedDate, startTime, endTime),
            if (data.homeAddress != null && data.homeAddress!.isNotEmpty) ...[
              GapH(8),
              _buildHomeAddress(),
            ],
            if (displayActionButtons && _hasActionButtons) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Divider(color: R.color.color0xffEFEFEF),
              ),
              _buildActionButtons(
                  locale: context.locale.languageCode, context: context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(DsmesAppointmentMode mode, String icon,
      {bool isPast = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(icon, width: 20, height: 20),
            SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    cubit.getItemTitle(mode, data: data),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: R.color.color0xff111515,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: cubit.getItemStatusContainerColor(data.status, isPast),
            borderRadius: BorderRadius.circular(2),
          ),
          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 6),
          child: Text(
            cubit.getItemStatus(data.status, isPast),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: cubit.getItemStatusTextColor(data.status, isPast),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClinicInfo(DsmesAppointment data, String bookingType) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
            width: 40,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.network(
                "${Utils.getHostDocosanUrl()}${_getAvatar(data, bookingType)}",
                fit: BoxFit.cover,
              ),
            )),
        GapW(8),
        Flexible(
          child: Text(
            _getName(data, bookingType),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: R.color.color0xff111515,
            ),
          ),
        ),
      ],
    );
  }

  String _getAvatar(DsmesAppointment data, String bookingType) {
    final isBookingDoctor = bookingType == Const.BOOKING_TYPE_DOCTOR;
    if (isBookingDoctor) {
      return data.doctor?.avatar ?? data.clinic.avatar;
    } else {
      return data.clinic.avatar;
    }
  }

  String _getName(DsmesAppointment data, String bookingType) {
    final isBookingDoctor = bookingType == Const.BOOKING_TYPE_DOCTOR;
    if (isBookingDoctor) {
      final doctor = data.doctor;
      if (doctor != null) {
        // Use name if it's not null and not empty
        if (doctor.name.isNotEmpty) {
          return doctor.name;
        }
        // Otherwise, use graduateName + displayName
        final graduateName =
            doctor.graduateName.isNotEmpty ? '${doctor.graduateName} ' : '';
        return '$graduateName${doctor.displayName}';
      }
      return data.clinic.name;
    } else {
      return data.clinic.name;
    }
  }

  Widget _buildDateTime(DateTime startDateTime, String formattedDate,
      String startTime, String endTime) {
    return Row(
      children: [
        GapW(48),
        Text(
          "${DateUtil.weekDayToString(startDateTime, isDisplayfull: true)}, $formattedDate",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: R.color.color0xff111515,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Image.asset(R.drawable.ic_ellipse, width: 6, height: 6),
        ),
        Text(
          '$startTime-$endTime',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: R.color.color0xff111515,
          ),
        ),
      ],
    );
  }

  Widget _buildHomeAddress() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GapW(48),
        Image.asset(R.drawable.ic_map_marker, width: 20, height: 20),
        SizedBox(width: 4),
        Flexible(
          child: Text(
            data.homeAddress ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: R.color.color0xff636A6B,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    final mode = DsmesAppointmentMode.fromString(data.mode);
    return mode == DsmesAppointmentMode.atClinic
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      data.clinic.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: R.color.textDark,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Image.asset(R.drawable.ic_map_marker, width: 12, height: 12),
                  SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      data.clinic.address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: R.color.color0xff777E90,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
        : SizedBox.shrink();
  }

  Widget _buildPrimaryButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        // width: 158,
        margin: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
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
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  /// Mirrors the branching in [_buildActionButtons] to answer whether it
  /// will render actual button content vs. an empty [SizedBox.shrink] —
  /// so the divider above it can be hidden when there's nothing to divide.
  bool get _hasActionButtons {
    final endDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(data.endTime);
    final isPast = endDateTime.isBefore(DateTime.now());

    if (joinButtonOnly) {
      // Completed appointments have nothing left to join.
      return !isPast &&
          DsmesAppointmentMode.fromString(data.mode) ==
              DsmesAppointmentMode.telemedicine;
    }

    if (data.status == DSMES_STATUS_APPROVE && isPast) return true;

    final mode = DsmesAppointmentMode.fromString(data.mode);
    if (mode == DsmesAppointmentMode.atClinic) return true;
    if (data.isExaminationAtHome) return false;
    return true;
  }

  Widget _buildActionButtons(
      {String locale = 'vi', required BuildContext context}) {
    final endDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(data.endTime);
    final isPast = endDateTime.isBefore(DateTime.now());

    if (joinButtonOnly) {
      final mode = DsmesAppointmentMode.fromString(data.mode);
      return (!isPast && mode == DsmesAppointmentMode.telemedicine)
          ? _buildButtonOnline(context)
          : const SizedBox.shrink();
    }

    if (data.status == DSMES_STATUS_APPROVE && isPast) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                HomeSupportFunctions.showModalAddData(context);
              },
              child: Container(
                height: 43,
                // width: 158,
                decoration: BoxDecoration(
                  color: R.color.white,
                  borderRadius: BorderRadius.circular(200),
                  border: Border.all(
                    color: R.color.greenGradientBottom,
                  ),
                ),
                child: Center(
                  child: Text(
                    R.string.support.tr(),
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
          GapW(12),
          Flexible(
            flex: 1,
            child: _buildPrimaryButton(
              R.string.rebooking.tr(),
              () => _handleRebooking(locale: locale),
            ),
          ),
        ],
      );
    }

    final mode = DsmesAppointmentMode.fromString(data.mode);
    if (mode == DsmesAppointmentMode.atClinic) {
      return _buildButtonAtClinic(context);
    }
    if (data.isExaminationAtHome) {
      return const SizedBox.shrink();
    }
    return _buildButtonOnline(context);
  }

  _buildButtonAtClinic(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 1,
          child: _buildPrimaryButton(
            R.string.support.tr(),
            () => () {
              HomeSupportFunctions.showModalAddData(context);
            },
          ),
        ),
      ],
    );
  }

  _handleRebooking({String locale = 'vi'}) async {
    final detailSuccess = await cubit.getClinicDetail(id: data.clinicId);

    if (!detailSuccess || cubit.selectedClinic == null) {
      return;
    }
    final appointment =
        await cubit.getDsmesAppointmentDetail(appointmentId: data.id);
    if (appointment == null) {
      return;
    }

    cubit.initCreateDsmesBookingRequest(locale: locale);
    final rebookingRequest = CreateDsmesBookingRequest(
      startTime: "",
      endTime: "",
      clinicId: appointment.clinic.id,
      doctorId: appointment.doctorId,
      patientPhoneNumber: appointment.patientInfo.phone,
      patientName: appointment.patientInfo.displayName,
      birthday: appointment.patientInfo.birthday,
      patientGender: int.tryParse(appointment.patientInfo.gender) ??
          (AppSettings.userInfo?.gender == 'Male' ? 1 : 0),
      patientEmail: appointment.patientInfo.email,
      bookingForClinic: 1, // 1: Booking phòng khám, 2: Booking bác sĩ
      language: locale,
      symptom: appointment.symptom,
      symptomAttachment:
          appointment.symptomAttachment.map((e) => e.filePath).toList(),
      paymentInfo: PaymentInfo(services: appointment.services),
    );
    cubit.updateCreateDsmesBookingRequest(request: rebookingRequest);

    // Pop until dsmes_booking
    DsmesNavigationMixin.getNavigationKey()
        .currentState
        ?.popUntil((route) => route.isFirst);

    // Handle rebooking for booking dsmes center
    if (bookingType == Const.BOOKING_TYPE_CENTER) {
      // Then push to select date
      if (appointment.mode == DsmesAppointmentMode.atClinic.toString()) {
        await DsmesNavigationMixin.getNavigationKey()
            .currentState
            ?.pushNamed(NavigatorName.dsmes_booking_select_date, arguments: {
          'serviceType': appointment.mode,
          'action': 'create',
        });
      } else {
        DsmesNavigationMixin.getNavigationKey()
            .currentState
            ?.pushNamed(NavigatorName.dsmes_select_service, arguments: {
          'action': 'create',
          'clinic': cubit.selectedClinic,
          'serviceType': appointment.mode,
          'bookingType': bookingType,
        });
      }
    } else {
      // Handle rebooking for booking clinic
      DsmesNavigationMixin.getNavigationKey()
          .currentState
          ?.pushNamed(NavigatorName.dsmes_booking_select_date, arguments: {
        'serviceType': appointment.mode,
        'action': 'create',
        'bookingType': bookingType,
      });
    }
  }

  bool _shouldShowJoinButton() {
    if (data.status != DSMES_STATUS_APPROVE ||
        data.mode != DsmesAppointmentMode.telemedicine.toString()) {
      return false;
    }

    final appointmentStart =
        DateFormat('yyyy-MM-dd HH:mm').parse(data.startTime);
    final now = DateTime.now();

    // 10 minutes before and after start time window
    final windowStart = appointmentStart
        .subtract(Duration(minutes: Const.DSMES_BOOKING_TIME_WINDOW_RANGE));
    final windowEnd = appointmentStart
        .add(Duration(minutes: Const.DSMES_BOOKING_TIME_WINDOW_RANGE));

    return now.isAfter(windowStart) && now.isBefore(windowEnd);
  }

  _buildButtonOnline(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 1,
          child: _shouldShowJoinButton()
              ? _buildPrimaryButton(
                  R.string.join_now.tr(),
                  () => _handleJoinRoom(context),
                )
              : Container(
                  height: 44,
                  // width: 158,
                  // margin: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                  decoration: BoxDecoration(
                    color: R.color.color0xffBFC6C6,
                    borderRadius: BorderRadius.circular(200),
                  ),
                  child: Center(
                    child: Text(
                      R.string.join_now.tr(),
                      style: TextStyle(
                        color: R.color.grey200,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  _handleJoinRoom(BuildContext context) async {
    // Pages outside the DSMES/booking nested-navigator flows (e.g. the
    // Benefit appointment history page) never call
    // DsmesNavigationMixin.setActiveNavigator, and dsmes_booking_online_join_room
    // is only registered on those flows' nested onGenerateRoute (not on the
    // app's root route table) — so pushNamed would fail there too. Push the
    // join-room screen directly in that case instead.
    NavigatorState? navigatorState;
    try {
      navigatorState = DsmesNavigationMixin.getNavigationKey().currentState;
    } catch (_) {
      navigatorState = null;
    }

    if (navigatorState != null) {
      await navigatorState.pushNamed(
          NavigatorName.dsmes_booking_online_join_room, arguments: {
        'telemedicineId': data.teleMedicine?.id,
      });
    } else {
      await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          settings:
              const RouteSettings(name: NavigatorName.dsmes_booking_online_join_room),
          builder: (_) => WebViewScreen(telemedicineId: data.teleMedicine!.id),
        ),
      );
    }
  }
}
