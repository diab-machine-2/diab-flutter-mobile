import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/create_calendar_response.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/calendar/calendar_booking_cubit.dart';

import '../../utils/navigator_name.dart';

class CalendarController extends StatefulWidget {
  final CreateCalendarResponse pickSlot;

  CalendarController(this.pickSlot);

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

  List<String> daysOfWeek = [
    "Thứ 2",
    "Thứ 3",
    "Thứ 4",
    "Thứ 5",
    "Thứ 6",
    "Thứ 7",
    "Chủ Nhật",
  ];
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppBar(
                backgroundColor: Colors.transparent,
                title: Text(
                  "Calendar",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: R.color.textDark,
                  ),
                ),
                leadingIcon: IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  icon: Icon(Icons.arrow_back, color: R.color.textDark),
                  onPressed: () {
                    Navigator.pushNamed(context, NavigatorName.tabbar);
                    CalendarBookingCubit.myCalendar = null;
                    CalendarBookingCubit.updateCount = 0;
                  },
                ),
              ),
              _buildCalendarCard(),
              Spacer(), // This pushes the button to the bottom
              _buildBottomButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    double screenWidth = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: (() {
            Navigator.pushNamed(context, NavigatorName.calendar_booking,
                arguments: {"updateSlot": widget.pickSlot});
          }),
          child: Container(
              margin: EdgeInsets.only(top: 16, bottom: 16),
              height: 48,
              width: screenWidth * 0.45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(200),
                border: Border.all(
                  color:
                      R.color.attentionText, // Replace with your border color
                  width: 2, // Adjust border width as needed
                ),
              ),
              child: Center(
                  child: Text("Đổi lịch hẹn",
                      style: TextStyle(
                          color: R.color.attentionText,
                          fontWeight: FontWeight.w600,
                          fontSize: 16)))),
        ),
        SizedBox(
          width: 20,
        ),
        GestureDetector(
          onTap: (() => {Navigator.pushNamed(context, NavigatorName.tabbar)}),
          child: Container(
              margin: EdgeInsets.only(top: 16, bottom: 16),
              height: 48,
              width: screenWidth * 0.45,
              decoration: BoxDecoration(
                  color: R.color.mainColor,
                  borderRadius: BorderRadius.circular(200),
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.centerRight,
                      colors: [
                        R.color.greenGradientTop,
                        R.color.greenGradientBottom
                      ])),
              child: Center(
                  child: Text("Hoàn thành",
                      style: TextStyle(
                          color: R.color.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16)))),
        )
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
    double screenWidth = MediaQuery.of(context).size.width;
    DateTime targetDate = _parseToDateTime(widget.pickSlot.appointmentDate);
    String formattedDate = DateFormat('dd/MM/yyyy').format(targetDate);
    String startTimeFormatted = DateFormat.Hm().format(targetDate);
    targetDate =
        targetDate.add(Duration(seconds: widget.pickSlot.duration ?? 0));
    String endTimeFormatted =
        DateFormat.Hm().format(targetDate.add(Duration(minutes: 30)));

    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(daysOfWeek[targetDate.weekday - 1] + ", " + formattedDate,
                  style: TextStyle(
                      fontSize: 24,
                      color: R.color.mainColor,
                      fontWeight: FontWeight.bold)),
              Text("$startTimeFormatted - $endTimeFormatted",
                  style: TextStyle(
                      fontSize: 24,
                      color: R.color.mainColor,
                      fontWeight: FontWeight.bold)),
              SizedBox(
                height: 16,
              ),
              Text("Buổi phỏng vấn đầu vào",
                  style: TextStyle(
                    fontSize: 16,
                  )),
              SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  Image.network(
                    widget.pickSlot.coachAvatar.isEmpty
                        ? "https://img.freepik.com/free-photo/beautiful-young-female-doctor-looking-camera-office_1301-7807.jpg"
                        : widget.pickSlot.coachAvatar,
                    height: 80,
                    width: 40,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Huấn luyện viên",
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        widget.pickSlot.coachName != ""
                            ? widget.pickSlot.coachName
                            : (widget.pickSlot.updaterName ?? 'Unknown'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 16,
              ),
              GestureDetector(
                onTap: () {
                  // Handle onTap functionality here
                },
                child: Container(
                  width: screenWidth * 0.8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: R.color.mainColor, width: 2),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 7),
                  child: Center(
                    child: Text(
                      "Tham gia",
                      style: TextStyle(
                        color: R.color.mainColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
