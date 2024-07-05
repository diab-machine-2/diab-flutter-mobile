import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/request/create_calendar_request.dart';
import 'package:medical/src/model/response/create_calendar_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/calendar/calendar_booking_cubit.dart';
import 'package:medical/src/widget/calendar/calendar_booking_state.dart';
import 'package:medical/src/widget/calendar/calendar_model.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/CalendarPicker/custom_date_picker.dart';

import '../../model/repository/app_repository.dart';

class CalendarBookingController extends StatefulWidget {
  @override
  _CalendarBookingControllerState createState() =>
      _CalendarBookingControllerState();
}

class _CalendarBookingControllerState extends State<CalendarBookingController> {
  late CalendarBookingCubit _cubit;

  late List<CalendarCoachModel> pickItems;

  CalendarCoachModel? pickSlot;

  CreateCalendarResponse? myCalendar;

  late DateTime seletedDate;
  final AppRepository repository = AppRepository();

  @override
  void initState() {
    super.initState();
    _cubit = CalendarBookingCubit(repository);
    myCalendar = CalendarBookingCubit.myCalendar;
    seletedDate = myCalendar != null
        ? _parseToDateTime(myCalendar!.appointmentDate)
        : DateTime.now();
    pickSlot = myCalendar != null ? myCalendar!.calendarCoach : null;
    pickItems = [];

    if (myCalendar != null)
      initPickItems();
    else {
      _cubit.getCalendarBooking();
    }
  }

  void initPickItems() async {
    List<CalendarCoachModel> defaultCalendarCoach =
        await _cubit.getCalendarBooking();
    defaultCalendarCoach = defaultCalendarCoach
        .where((calendar) => _isSameDate(
            _parseToDateTime(myCalendar!.appointmentDate),
            _parseToDateTime(calendar.startTime)))
        .toList();
    setState(() {
      pickItems = defaultCalendarCoach;
    });
  }

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
          child: BlocProvider(
              create: (context) => _cubit,
              child: BlocConsumer<CalendarBookingCubit, CalendarBookingState>(
                  listener: (context, state) => {
                        if (state is CalendarBookingFailure)
                          Message.showToastMessage(context, state.error)
                        else if (state is CreateCalendarSuccess)
                          {
                            if (myCalendar != null)
                              CalendarBookingCubit.updateCount += 1,
                            Navigator.pushNamed(context, NavigatorName.calendar,
                                arguments: {"pickSlot": state.response})
                          }
                      },
                  builder: ((context, state) {
                    try {
                      if (state is CalendarBookingLoading) {
                        BotToast.showLoading();
                      } else {
                        BotToast.closeAllLoading();
                      }
                      return _buildPage();
                    } catch (e) {
                      BotToast.closeAllLoading();
                      return _buildPage();
                    }
                  }))),
        ),
      ),
    );
  }

  DateTime _parseToDateTime(int value) {
    return DateTime.fromMillisecondsSinceEpoch(
      value * 1000,
      isUtc: true,
    );
  }

  Widget _buildPage() {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppBar(
              backgroundColor: R.color.transparent,
              title: Text("Đặt lịch chuyên gia",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: R.color.textDark)),
              leadingIcon: IconButton(
                  splashColor: R.color.transparent,
                  highlightColor: R.color.transparent,
                  icon: Icon(Icons.arrow_back, color: R.color.textDark),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Navigator.pushNamed(context, NavigatorName.profile);
                  }),
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
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              "Đặt lịch tư vấn cùng chuyên gia giúp bạn có nhiều kiến thức trong quá trình chữa trị đái tháo đường",
                            ),
                          ),
                          SizedBox(
                            height: 116,
                            child: Image.asset(
                              R.drawable.calendar_theme,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Text(
                        "Ngày đặt lịch",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    _buildSectionCalendarBooking(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Thời gian đặt lịch",
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Bạn hãy chọn thời gian phù hợp để bắt đầu lịch tư vấn nhé! Thời gian cho mỗi buổi tư vấn là 1 giờ.",
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildTimeFrame(),
                    SizedBox(
                      height: 70,
                    )
                  ],
                ),
              ),
            )
          ],
        ),
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {
              if (myCalendar != null && pickSlot != null) {
                // case not change slot
                bool isSameSlot =
                    pickSlot!.startTime == myCalendar!.appointmentDate &&
                        (pickSlot!.endTime - pickSlot!.startTime) ==
                            myCalendar!.duration;
                if (isSameSlot) {
                  Navigator.pushNamed(context, NavigatorName.calendar,
                      arguments: {"pickSlot": myCalendar});
                  return;
                }
                // Case: update
                // If update count is 2 or more, show popup
                if (CalendarBookingCubit.updateCount > 2) {
                  _showPopupOverSwitchTime(onConfirm: () => {});
                  return;
                } else {
                  _cubit.deleteCalendar({
                    "id": myCalendar!.id,
                    "calendarCoachId": myCalendar!.calendarCoach.id,
                    "deleteType": "0",
                  });
                }
              }
              // case create
              if (pickItems.length == 0 && pickSlot == null) return;
              var pickItemsFilter = pickItems
                  .where((item) =>
                      pickSlot != null &&
                      item.startTime == pickSlot!.startTime &&
                      item.endTime == pickSlot!.endTime)
                  .toList();
              // Handle the tap event here
              CalendarAccount account = CalendarAccount(
                accountId: AppSettings.userInfo!.accountId!,
                modelStatus: 3, // ModelStatusEnum => 3  is New
              );
              CreateCalendarRequest request = new CreateCalendarRequest(
                name: "Phỏng vấn đầu vào",
                courseId: "09a1eb10-3781-11ef-a0de-bf2ff70bdfcd",
                performerId: pickSlot!.coachId,
                appointmentDate: pickSlot!.startTime,
                calendarCoachs: pickItemsFilter,
                duration: pickSlot!.endTime - pickSlot!.startTime,
                repeatType: "0", // not repeat
                modelStatus: 3,
                meetingLink: "",
                zoomTypeId: 1, // auto generate link zoom
                type: "1", // CalendarTypeEnums = 1 is DanhGiaDauVao
                calendarAccounts: [account],
                goal: "Phỏng vấn đầu vào",
                trainingGroupIds: [],
              );
              _cubit.createCalendar(request);
            },
            child: Align(
              alignment: Alignment.center,
              child: Container(
                  height: 48,
                  width: 195,
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
                      child: Text(
                          pickItems.length > 0 && myCalendar != null
                              ? "Đổi lịch"
                              : "Đặt lịch",
                          style: TextStyle(
                              color: R.color.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16)))),
            ),
          ),
        ),
      ],
    );
  }

  _showPopupOverSwitchTime({required Function onConfirm}) {
    showDialog(
      context: context,
      builder: (context) {
        return Container(
          child: AlertDialog(
              contentPadding: EdgeInsets.all(0),
              content: Stack(children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(R.drawable.ic_warning, width: 64, height: 64),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text('Bạn đã đến giới hạn đổi lịch hẹn',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 20,
                                fontWeight: FontWeight.w600)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                            'Vui lòng liên hệ 093188832 để được hỗ trợ.',
                            textAlign: TextAlign.center,
                            style: R.style.normalTextStyle),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              onConfirm();
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
                                  'Tôi đã hiểu',
                                  style: TextStyle(
                                    color: R.color.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                      icon: Icon(Icons.close, color: R.color.color0xffBEC0C8),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                )
              ])),
        );
      },
    );
  }

  void _createCalendar(CreateCalendarRequest request,
      List<CalendarCoachModel> calendarCoach, BuildContext context) async {
    final ApiResult<CreateCalendarResponse> apiResult =
        await repository.createCalendar(request);
    apiResult.when(success: (CreateCalendarResponse response) {
      Navigator.pushNamed(context, NavigatorName.calendar,
          arguments: {"pickSlot": calendarCoach});
    }, failure: (NetworkExceptions error) {
      Message.showToastMessage(context, error.toString());
    });
    BotToast.closeAllLoading();
  }

  Widget _buildTimeFrame() {
    List<CalendarCoachModel> coachSchedules = pickItems;
    List<List<Widget>> targets = [];
    Set<String> addedStartTimes = Set<String>();
    Set<String> addedEndTimes = Set<String>();
// Iterate through coachSchedules
    for (int i = 0; i < coachSchedules.length; i++) {
// Extract start and end times for each schedule
      String startTime =
          "${_parseToDateTime(coachSchedules[i].startTime).hour.toString().padLeft(2, '0')} : ${_parseToDateTime(coachSchedules[i].startTime).minute.toString().padLeft(2, '0')}";
      String endTime =
          "${_parseToDateTime(coachSchedules[i].endTime).hour.toString().padLeft(2, '0')} : ${_parseToDateTime(coachSchedules[i].endTime).minute.toString().padLeft(2, '0')}";

      if (!addedStartTimes.contains(startTime) ||
          !addedEndTimes.contains(endTime)) {
        List<Widget> item = [
          _buildItemTimeFrame(startTime, coachSchedules[i].id,
              onTap: () => {
                    setState(() {
                      pickSlot = coachSchedules[i];
                    })
                  }),
          Text(
            "-",
            style: TextStyle(fontSize: 30.0),
          ),
          _buildItemTimeFrame(endTime, coachSchedules[i].id,
              onTap: () => {
                    setState(() {
                      pickSlot = coachSchedules[i];
                    })
                  }),
        ];

        targets.add(item);
      }
      addedStartTimes.add(startTime);
      addedEndTimes.add(endTime);
    }

    return Container(
      child: Column(
        children: List.generate((targets.length / 2).ceil(), (index) {
          int startIndex = index * 2;
          int endIndex = startIndex + 2;
          endIndex = endIndex > targets.length ? targets.length : endIndex;

          List<Widget> rowChildren = targets
              .sublist(startIndex, endIndex)
              .expand((element) => element)
              .toList();
          if (rowChildren.length.isOdd) {
            rowChildren.add(SizedBox(width: 80));
            rowChildren.add(Text(
              "-",
              style: TextStyle(color: R.color.transparent),
            ));
            rowChildren.add(SizedBox(width: 80));
          }
          return Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: rowChildren,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildItemTimeFrame(String time, String id, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 80, // Adjust the width as needed
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: R.color.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                  color: R.color.greenGradientBottom,
                  fontSize: 16,
                  fontWeight: pickSlot != null && pickSlot!.id == id
                      ? FontWeight.bold
                      : FontWeight.normal),
              children: [
                TextSpan(text: time.split(':')[0]), // Hour part
                TextSpan(text: ' : '),
                TextSpan(text: time.split(':')[1]), // Minute part
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget _buildSectionCalendarBooking() {
    List<DateTime> activeDates = _cubit.calendarCoachs
        .map((model) => DateTime.fromMillisecondsSinceEpoch(
              model.startTime * 1000,
              isUtc: true,
            ))
        .map((dateTime) => DateTime(
              dateTime.year,
              dateTime.month,
              dateTime.day,
              dateTime.hour,
              dateTime.minute,
              dateTime.second,
            ))
        .toSet()
        .toList();
    activeDates.sort((a, b) {
      int yearComparison = a.year.compareTo(b.year);
      if (yearComparison != 0) return yearComparison;

      int monthComparison = a.month.compareTo(b.month);
      if (monthComparison != 0) return monthComparison;

      return a.day.compareTo(b.day);
    });

    return Container(
      margin: EdgeInsets.all(16.0),
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: CustomCalendarDatePicker(
        initialDate: seletedDate,
        firstDate: DateTime.parse("1969-07-20 20:18:04Z"),
        activeDates: activeDates,
        lastDate: activeDates.length > 0
            ? activeDates.last
            : DateTime.now().add(Duration(days: 30)),
        onDateChanged: (datetime) {
          if (datetime != null) {
            var targets = _cubit.calendarCoachs
                .where((model) => _isSameDate(
                      DateTime.fromMillisecondsSinceEpoch(
                        model.startTime * 1000,
                        isUtc: true,
                      ),
                      datetime,
                    ))
                .toList();
            setState(() {
              pickItems = targets;
              seletedDate = datetime;
            });
          }
        },
      ),
    );
  }
}
