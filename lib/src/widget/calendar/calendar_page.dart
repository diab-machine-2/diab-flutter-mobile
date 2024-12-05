import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/create_calendar_response.dart';
import 'package:medical/src/service/zoom_service.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/utils/extention.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/calendar/calendar_booking_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/navigator_name.dart';

class CalendarController extends StatefulWidget {
  final CreateCalendarResponse pickSlot;
  final String courseId;
  final String endTime;
  final int bookingQuantity;
  CalendarController(
      this.pickSlot, this.courseId, this.endTime, this.bookingQuantity);

  @override
  _CalendarControllerState createState() => _CalendarControllerState();
}

class _CalendarControllerState extends State<CalendarController> {
  late CalendarBookingCubit _cubit;
  final AppRepository repository = AppRepository();

  @override
  void initState() {
    super.initState();
    _cubit = CalendarBookingCubit(repository);
  }

  String getCalendarType(int type) {
    switch (type) {
      case 0:
        return "Phân loại đầu ra";
      case 1:
        return "Buổi phỏng vấn đầu vào";
      case 2:
        return "Huấn luyện 1:1";
      case 3:
        return "Huấn luyện 1:n";
      case 4:
        return "Tư vấn bác sĩ";
      case 5:
        return "Khác";
      case 6:
        return "Livestream";
      default:
        return "Khác";
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await Navigator.pushNamed(context, NavigatorName.calendar_booking,
            arguments: {
              "updateSlot": widget.pickSlot,
              'courseId': widget.courseId,
              'endTime': widget.endTime
            });
        return false;
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  R.color.color0xFFFDC798.withOpacity(0.3),
                  R.color.greenbg.withOpacity(0.9),
                ],
                begin: FractionalOffset(1, 1),
                end: FractionalOffset(0.9, 0.5),
                stops: [0.0, 1.0],
              ),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomAppBar(
                      backgroundColor: Colors.transparent,
                      title: Text(
                        "",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: R.color.textDark,
                        ),
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
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 6),
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
                          Navigator.pushNamed(context, NavigatorName.tabbar);
                          CalendarBookingCubit.myCalendar = null;
                          CalendarBookingCubit.updateCount = 0;
                        },
                      ),
                    ),
                    _builScreeningInfoCard(),
                    _buildCalendarCard(),
                    // Spacer(), // This pushes the button to the bottom
                  ],
                ),
                _buildBottomButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    bool isAppointmentDate =
        _parseToDateTime(widget.pickSlot.appointmentDate).isSameDayWith(
      DateTime.now(),
    );
    final now = DateTime.now();
    final currentDate = DateTime.utc(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    );
    final availableTime = _parseToDateTime(widget.pickSlot.appointmentDate)
        .subtract(Duration(minutes: 15));

    bool isAbleToJoinRoom = currentDate.isAfter(availableTime);
    bool isCompleted = widget.pickSlot.complete;

    return Stack(
      children: [
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            color: R.color.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.bookingQuantity < 2 && isAppointmentDate == false)
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: (() {
                        Navigator.pushNamed(
                            context, NavigatorName.calendar_booking,
                            arguments: {
                              "updateSlot": widget.pickSlot,
                              'courseId': widget.courseId,
                              'endTime': widget.endTime
                            });
                      }),
                      child: Container(
                        margin: EdgeInsets.fromLTRB(16, 8, 0, 8),
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(200),
                          border: Border.all(
                            color: R.color.color0xff008479,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            R.string.change_booking.tr(),
                            style: TextStyle(
                              color: R.color.color0xff008479,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              fontFamily: 'sfpro',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (!isAppointmentDate || isCompleted)
                  Expanded(
                    child: InkWell(
                      onTap: (() => {
                            // _cubit.completedCalendar(widget.pickSlot.id, widget.courseId),
                            Navigator.pushNamed(context, NavigatorName.tabbar)
                          }),
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        height: 44,
                        decoration: BoxDecoration(
                          color: R.color.color0xffd0f1ef,
                          borderRadius: BorderRadius.circular(200),
                        ),
                        child: Center(
                          child: Text(
                            R.string.back_home_page.tr(),
                            style: TextStyle(
                              color: R.color.color0xff008479,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              fontFamily: 'sfpro',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (isAppointmentDate && !isCompleted)
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        if (isAbleToJoinRoom == false) return;

                        final meetingId = widget.pickSlot.roomId ?? '';
                        final meetingPassword =
                            widget.pickSlot.meetingPassword ?? '';

                        if (meetingId.isEmpty || meetingPassword.isEmpty)
                          return;

                        ZoomService()
                            .launchZoomMeeting(meetingId, meetingPassword);
                      },
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        height: 44,
                        decoration: BoxDecoration(
                          color:
                              isAbleToJoinRoom ? null : R.color.color0xffd0f1ef,
                          gradient: isAbleToJoinRoom
                              ? LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                      R.color.greenGradientTop,
                                      R.color.greenGradientMid,
                                      R.color.greenGradientBottom
                                    ])
                              : null,
                          borderRadius: BorderRadius.circular(200),
                        ),
                        child: Center(
                          child: Text(
                            R.string.join_now.tr(),
                            style: TextStyle(
                              color: isAbleToJoinRoom
                                  ? R.color.white
                                  : R.color.color0xffF4F4F5,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              fontFamily: 'sfpro',
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ],
    );
  }

  DateTime _parseToDateTime(int value) {
    return DateTime.fromMillisecondsSinceEpoch(
      value * 1000,
      isUtc: true,
    );
  }

  Widget _buildCalendarCard() {
    DateTime targetDate = _parseToDateTime(widget.pickSlot.appointmentDate);
    String formattedDate = DateFormat('dd/MM/yyyy').format(targetDate);
    String startTimeFormatted = DateFormat.Hm().format(targetDate);
    targetDate =
        targetDate.add(Duration(seconds: widget.pickSlot.duration ?? 0));
    String endTimeFormatted = DateFormat.Hm().format(targetDate);

    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                R.string.schedule_information.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'sfpro',
                  color: R.color.color0xff27272A,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  Image.network(
                    widget.pickSlot.coachAvatar.isEmpty
                        ? Const.DEFAULT_BG_COACH
                        : widget.pickSlot.coachAvatar,
                    height: 118,
                    width: 98,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.network(
                        Const.DEFAULT_BG_COACH,
                        height: 118,
                        width: 98,
                      );
                    },
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getCalendarType(widget.pickSlot.type),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'sfpro',
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        R.string.coach.tr(),
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'sfpro',
                          color: R.color.color0xff52525B.withOpacity(0.85),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        widget.pickSlot.updaterName ?? "Chưa có tên",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'sfpro',
                          color: R.color.color0xff52525B,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "$startTimeFormatted - $endTimeFormatted",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'sfpro',
                          color: R.color.color0xffBE8B0E,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "${DateUtil.weekDayToString(targetDate)}, $formattedDate",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'sfpro',
                          color: R.color.color0xffBE8B0E,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _builScreeningInfoCard() {
    DateTime targetDate = _parseToDateTime(widget.pickSlot.appointmentDate);
    targetDate =
        targetDate.add(Duration(seconds: widget.pickSlot.duration ?? 0));

    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                R.string.customer_information.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: R.color.color0xff27272A,
                  fontFamily: 'sfpro',
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    R.string.status.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: R.color.color0xff888892,
                      fontFamily: 'sfpro',
                    ),
                  ),
                  Text(
                    widget.pickSlot.complete
                        ? R.string.completed.tr()
                        : R.string.confirmed.tr(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: widget.pickSlot.complete
                          ? R.color.color0xff009D0D
                          : R.color.color0xff004ED5,
                      fontFamily: 'sfpro',
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    R.string.name.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: R.color.color0xff888892,
                      fontFamily: 'sfpro',
                    ),
                  ),
                  Text(
                    AppSettings.userInfo?.fullName ??
                        AppSettings.userInfo?.userName ??
                        '',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: R.color.color0xff27272A,
                      fontFamily: 'sfpro',
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    R.string.phone_number.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: R.color.color0xff888892,
                      fontFamily: 'sfpro',
                    ),
                  ),
                  Text(
                    AppSettings.userInfo?.phoneNumber ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: R.color.color0xff27272A,
                      fontFamily: 'sfpro',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
