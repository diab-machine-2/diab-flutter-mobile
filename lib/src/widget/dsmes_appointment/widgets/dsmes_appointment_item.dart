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
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_navigation_mixin.dart';
import 'package:medical/src/widget/home/widget/home_support_functions.dart';
import 'package:medical/src/widgets/gap_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class DsmesAppointmentItem extends StatelessWidget {
  final DsmesAppointment data;
  final VoidCallback onChooseService;
  final DsmesAppointmentCubit cubit;
  final bool displayActionButtons;

  const DsmesAppointmentItem({
    Key? key,
    required this.data,
    required this.onChooseService,
    required this.cubit,
    this.displayActionButtons = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DsmesAppointmentMode mode = DsmesAppointmentMode.fromString(data.mode);
    String icon = mode == DsmesAppointmentMode.atClinic
        ? R.drawable.ic_at_clinic
        : R.drawable.ic_telemedicine;

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
            _buildClinicInfo(data),
            _buildDateTime(startDateTime, formattedDate, startTime, endTime),
            if (displayActionButtons)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: R.color.color0xffEFEFEF),
              ),
            // _buildDescription(),
            // if (data.mode == DsmesAppointmentMode.atClinic.toString()) GapH(12),
            if (displayActionButtons)
              _buildActionButtons(
                  locale: context.locale.languageCode, context: context),
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
                    cubit.getItemTitle(mode),
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

  Widget _buildClinicInfo(DsmesAppointment data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
            width: 40,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.network(
                "${Utils.getHostDocosanUrl()}${data.clinic.avatar}",
                fit: BoxFit.cover,
              ),
            )),
        GapW(8),
        Flexible(
          child: Text(
            data.clinic.name,
            maxLines: 2,
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
          padding: EdgeInsets.symmetric(horizontal: 8),
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

  Widget _buildActionButtons(
      {String locale = 'vi', required BuildContext context}) {
    final endDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(data.endTime);
    final isPast = endDateTime.isBefore(DateTime.now());
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
    return mode == DsmesAppointmentMode.atClinic
        ? _buildButtonAtClinic(context)
        : _buildButtonOnline();
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

    if (appointment.mode == DsmesAppointmentMode.atClinic.toString()) {
      DsmesNavigationMixin.getNavigationKey()
          .currentState
          ?.popUntil((route) => route.isFirst);

      await DsmesNavigationMixin.getNavigationKey()
          .currentState
          ?.pushNamed(NavigatorName.dsmes_booking_select_date, arguments: {
        'serviceType': appointment.mode,
        'action': 'create',
      });
    } else {
      DsmesNavigationMixin.getNavigationKey()
          .currentState
          ?.popUntil((route) => route.isFirst);

      DsmesNavigationMixin.getNavigationKey()
          .currentState
          ?.pushNamed(NavigatorName.dsmes_select_service, arguments: {
        'action': 'create',
        'clinic': cubit.selectedClinic,
        'serviceType': appointment.mode,
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

  _buildButtonOnline() {
    return Row(
      children: [
        Flexible(
          flex: 1,
          child: _shouldShowJoinButton()
              ? _buildPrimaryButton(
                  R.string.join_now.tr(),
                  () => _handleJoinRoom(),
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

  _handleJoinRoom() async {
    await DsmesNavigationMixin.getNavigationKey()
        .currentState
        ?.pushNamed(NavigatorName.dsmes_booking_online_join_room, arguments: {
      'telemedicineId': data.teleMedicine?.id,
    });
  }
}
