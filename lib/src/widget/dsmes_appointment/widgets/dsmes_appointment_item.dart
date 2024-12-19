import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_appointment_model.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:medical/src/widgets/gap_widget.dart';

class DsmesAppointmentItem extends StatelessWidget {
  final DsmesAppointment data;
  final VoidCallback onChooseService;
  final DsmesAppointmentCubit cubit;

  const DsmesAppointmentItem({
    Key? key,
    required this.data,
    required this.onChooseService,
    required this.cubit,
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
            BoxShadow(
              color: R.color.shadowColorNew.withOpacity(0.08),
              spreadRadius: 0,
              blurRadius: 8,
              offset: Offset(1, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(mode, icon, isPast: isPast),
            SizedBox(height: 14),
            _buildDateTime(startDateTime, formattedDate, startTime, endTime),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: R.color.color0xffEFEFEF),
            ),
            _buildDescription(),
            if (data.mode == DsmesAppointmentMode.atClinic.toString())
              GapH(12),
            _buildActionButtons(),
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
            Image.asset(icon, width: 26, height: 26),
            SizedBox(width: 10),
            Text(
              cubit.getItemTitle(mode),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: R.color.textDark,
              ),
            ),
          ],
        ),
        Container(
          color: cubit.getItemStatusContainerColor(data.status, isPast),
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

  Widget _buildDateTime(DateTime startDateTime, String formattedDate,
      String startTime, String endTime) {
    return Row(
      children: [
        Text(
          "${DateUtil.weekDayToString(startDateTime, isDisplayfull: true)}, $formattedDate",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: R.color.textDark,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Image.asset(R.drawable.ic_ellipse, width: 6, height: 6),
        ),
        Text(
          '$startTime-$endTime',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: R.color.textDark,
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
                  Text(
                    data.clinic.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: R.color.textDark,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Image.asset(R.drawable.ic_map_marker, width: 12, height: 12),
                  SizedBox(width: 5),
                  Text(
                    data.clinic.address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: R.color.color0xff777E90,
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

  Widget _buildActionButtons() {
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
                // TODO: Handle support
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
              () => () {
                //TODO: Handle rebooking
              },
            ),
          ),
        ],
      );
    }

    final mode = DsmesAppointmentMode.fromString(data.mode);
    return mode == DsmesAppointmentMode.atClinic
        ? _buildButtonAtClinic()
        : _buildButtonOnline();
  }

  _buildButtonAtClinic() {
    return Row(
      children: [
        Flexible(
          flex: 1,
          child: _buildPrimaryButton(
            R.string.support.tr(),
            () => () {
              //TODO: Handle rebooking
            },
          ),
        ),
      ],
    );
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
    final windowStart = appointmentStart.subtract(Duration(minutes: 10));
    final windowEnd = appointmentStart.add(Duration(minutes: 10));

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
                  () => () {
                    //TODO: Handle join now
                  },
                )
              : Container(
                  height: 44,
                  // width: 158,
                  margin: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                  decoration: BoxDecoration(
                    color: R.color.color0xffBFC6C6,
                    borderRadius: BorderRadius.circular(200),
                  ),
                  child: Center(
                    child: Text(
                      R.string.join_now.tr(),
                      style: TextStyle(
                        color: R.color.color0xffEDEEEE,
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
}
