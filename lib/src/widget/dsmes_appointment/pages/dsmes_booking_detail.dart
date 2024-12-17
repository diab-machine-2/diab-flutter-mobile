import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_appointment_model.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_navigation_mixin.dart';
import 'package:medical/src/widgets/gap_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class DsmesBookingDetail extends StatefulWidget {
  final String serviceType;
  final DsmesAppointment appointment;

  const DsmesBookingDetail({
    Key? key,
    required this.serviceType,
    required this.appointment,
  }) : super(key: key);

  @override
  _DsmesBookingDetailState createState() => _DsmesBookingDetailState();
}

class _DsmesBookingDetailState extends State<DsmesBookingDetail> {
  late DsmesAppointmentCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<DsmesAppointmentCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: R.color.backgroundColorNew,
        ),
        child: _buildPage(context),
      ),
    );
  }

  Widget _buildPage(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            CustomAppBar(
              backgroundColor: Colors.transparent,
              title: Text(
                R.string.consult_information.tr(),
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    // fontFamily: 'sfpro',
                    color: R.color.textDark),
              ),
              actions: [
                InkWell(
                  onTap: () async {
                    final launchUri =
                        Uri(scheme: 'tel', path: Const.HOTLINE_NUMBER);
                    if (await canLaunchUrl(launchUri)) {
                      await launchUrl(launchUri);
                    } else {
                      throw 'Could not make phone call ${Const.HOTLINE_NUMBER}';
                    }
                  },
                  child: Container(
                    width: 79,
                    height: 33,
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                    margin: EdgeInsets.fromLTRB(0, 8, 16, 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: R.color.color0xffFCF8DA,
                      border: Border.all(
                        color: R.color.color0xffFEDC89,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          R.icons.ic_telephone,
                          width: 16,
                          height: 16,
                          color: R.color.ho_so_color,
                          fit: BoxFit.scaleDown,
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Text(
                          R.string.contact.tr(),
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'sfpro',
                            fontWeight: FontWeight.w700,
                            color: R.color.ho_so_color,
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
                  color: R.color.textDark,
                ),
                onPressed: () {
                  DsmesNavigationMixin.navigationKey.currentState?.pop(context);
                },
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
                      GapH(12),
                      _buildNoticeSymptom(),
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
          child: Container(
            color: R.color.white,
            child: Row(
              children: [
                Expanded(
                  child: _buildButton(R.string.confirm_book_consult.tr(),
                      () async {
                    final token = await AppSettings.getDocosanToken();
                    if (token.isEmpty) {
                      await _cubit.registerDocosanUser();
                      await AppSettings.clearOrganizationApiKey();
                    }
                    final resp = await _cubit.createDsmesBooking();
                    if (resp == null) return;
                    _showPopupBookingSuccess(
                      title2: R.string.congratulation_on.tr(),
                      title: R.string.booking_success.tr(),
                      subtitle:
                          R.string.confirm_booking_subtitle.tr(namedArgs: {
                        'time': DateFormat('HH:mm').format(
                            DateFormat('yyyy-MM-dd HH:mm:ss')
                                .parse(resp.startTime)),
                        'date': DateFormat('dd/MM/yyyy').format(
                            DateFormat('yyyy-MM-dd HH:mm:ss')
                                .parse(resp.startTime)),
                      }),
                      isShowImg: true,
                      primaryButtonTitle: R.string.back_home_page.tr(),
                      secondaryButtonTitle: R.string.recheck_information.tr(),
                      onConfirm: () {
                        // Back to homepage
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      onCancel: () {
                        // Navigate to booking detail
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(12),
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
                  R.string.consult_information.tr().toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: R.color.color0xff141416,
                  ),
                ),
              ],
            ),
            GapH(12),
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
                    color: R.color.color0xff141416,
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
                    color: R.color.color0xff141416,
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
    final endDateTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').parse(widget.appointment.endTime);
    final isPast = endDateTime.isBefore(DateTime.now());

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(12),
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
                  widget.serviceType == DsmesAppointmentMode.atClinic.toString()
                      ? R.string.consult_at_clinic.tr().toUpperCase()
                      : R.string.consult_online.tr().toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: R.color.color0xff141416,
                  ),
                ),
              ],
            ),
            GapH(12),
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
                    color: _cubit.getItemStatusContainerColor(
                        widget.appointment.status, isPast),
                    padding: EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                    child: Text(
                      _cubit.getItemStatus(widget.appointment.status, isPast),
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
                  R.string.consult_time.tr(),
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
            GapH(4),
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
                      color: R.color.color0xff141416,
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
                      color: R.color.color0xff141416,
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

  _buildNoticeSymptom() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(12),
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
                  R.string.notice_symptom.tr(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: R.color.color0xff111515,
                  ),
                ),
              ],
            ),
            GapH(12),
            Container(
              child: TextFormField(
                initialValue: widget.appointment.symptom,
                minLines: 2,
                maxLines: null, // Allows auto-expansion
                maxLength: 250,
                obscureText: false,
                readOnly: true,
                decoration: InputDecoration(
                  fillColor: R.color.textDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: R.color.color0xffDFE4E4,
                      width: 1.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: R.color.color0xffDFE4E4,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: R.color.color0xffDFE4E4,
                      width: 1.0,
                    ),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  hintText: R.string.symptom.tr(),
                ),
              ),
            )
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
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  _showPopupBookingSuccess({
    required Function onConfirm,
    Function? onCancel,
    bool isShowImg = false,
    String? subtitle,
    String? title,
    String? title2,
    String primaryButtonTitle = 'Xác nhận',
    String secondaryButtonTitle = 'Huỷ',
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return Container(
          child: AlertDialog(
            contentPadding: EdgeInsets.all(10),
            content: Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isShowImg)
                        Image.asset(R.drawable.ic_dialog_success,
                            width: 66, height: 66),
                      SizedBox(
                        height: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (title2 != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: Text(
                                title2,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: R.color.color0xff636A6B,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Text(
                              title ?? "",
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: R.color.greenGradientBottom,
                                fontSize: 40,
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
                            fontSize: 13,
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
                              Navigator.pop(context);
                              onCancel?.call();
                            },
                            child: Container(
                              height: 43,
                              width: 163,
                              decoration: BoxDecoration(
                                color: R.color.red,
                                borderRadius: BorderRadius.circular(200),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    R.color.greenGradientTop,
                                    R.color.greenGradientBottom,
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  secondaryButtonTitle,
                                  style: TextStyle(
                                    color: R.color.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          _buildButton(
                            primaryButtonTitle,
                            onConfirm(),
                          ),
                        ],
                      )
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
