import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/request/create_calendar_request.dart';
import 'package:medical/src/model/request/delete_calendar_request.dart';
import 'package:medical/src/model/response/create_calendar_response.dart';
import 'package:medical/src/utils/app_media_query.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/calendar/calendar_booking_cubit.dart';
import 'package:medical/src/widget/calendar/calendar_booking_state.dart';
import 'package:medical/src/widget/calendar/calendar_model.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/CalendarPicker/custom_date_picker.dart';
import 'package:medical/src/widgets/CalendarPicker/custom_date_picker_horizontal.dart';
import 'package:medical/src/widgets/CalendarPicker/picker_helper.dart';

import '../../model/repository/app_repository.dart';

class CalendarBookingController extends StatefulWidget {
  final String courseId;
  final String endTime;
  const CalendarBookingController(
      {Key? key, required this.courseId, required this.endTime})
      : super(key: key);
  @override
  _CalendarBookingControllerState createState() =>
      _CalendarBookingControllerState();
}

class _CalendarBookingControllerState extends State<CalendarBookingController> {
  late CalendarBookingCubit _cubit;

  late List<CalendarCoachModel> pickSlots = [];

  CalendarCoachModel? pickSlot;
  CalendarCoachModel? pickSlotOld;

  CreateCalendarResponse? myCalendar;
  bool isMorningSelected = true;

  late DateTime seletedDate = DateTime.now();
  final AppRepository repository = AppRepository();

  @override
  void initState() {
    super.initState();
    _cubit = CalendarBookingCubit(repository);
    setUpCalendar();
  }

  Future<void> setUpCalendar() async {
    await _cubit.initializeMyCalendar(
        courseId: widget.courseId,
        endDate: DateTime.fromMillisecondsSinceEpoch(
            int.parse(widget.endTime) * 1000));

    myCalendar = CalendarBookingCubit.myCalendar;
    seletedDate = myCalendar != null
        ? _parseToDateTime(myCalendar!.appointmentDate)
        : seletedDate;

    if (myCalendar != null) {
      // Khi đã có calendar rồi, back lại sẽ render lại slot lịch của calendar đó
      initpickSlots();
    } else {
      // Chưa có calendar nào
      await _cubit.getCalendarCoach(widget.courseId, widget.endTime);
    }
  }

  void initpickSlots() async {
    // optimize thi query string để chỉ cần lấy theo điều kiện mà không phải get lấy về rồi filter
    List<CalendarCoachModel> defaultCalendarCoach = await _cubit
        .getCalendarCoach(widget.courseId, widget.endTime, isAdd1Day: false);
    defaultCalendarCoach = defaultCalendarCoach
        .where((calendar) => DateUtil.isSameDate(
            _parseToDateTime(myCalendar!.appointmentDate),
            _parseToDateTime(calendar.startTime)))
        .toList();

    // handle case when picked slot is before now + 1 day
    // => dont have any CalendarCoachModel.status = 1 => exception
    // Ex: today is Thu, 11:00 am, picked slot is Fri at 10h30 am
    // returned data dont contain any CalendarCoachModel.status = 1 because query startTime is now + 1

    final filteredDefaultCalendarCoach = defaultCalendarCoach.where((calendar) {
      final now = DateTime.now();
      final compareDate = DateTime.utc(now.year, now.month, now.day, now.hour,
                  now.minute, now.second)
              .add(Duration(days: 1))
              .millisecondsSinceEpoch ~/
          1000;
      final validDate = calendar.startTime >= compareDate;
      return validDate;
    }).toList();

    setState(() {
      pickSlots = filteredDefaultCalendarCoach;
      pickSlot = defaultCalendarCoach.firstWhere((p) => p.status == 1);
      pickSlotOld = pickSlot;

      final isMorning = _parseToDateTime(pickSlot!.startTime).hour < 12;
      isMorningSelected = isMorning;
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
                          {
                            Message.showToastMessage(context, state.error),
                            BotToast.closeAllLoading()
                          }
                        else if (state is CreateCalendarSuccess)
                          {
                            if (myCalendar != null)
                              CalendarBookingCubit.updateCount += 1,
                            Navigator.pushNamed(context, NavigatorName.calendar,
                                arguments: {
                                  "pickSlot": state.response,
                                  "courseId": widget.courseId,
                                  "endTime": widget.endTime,
                                  "bookingQuantity":
                                      CalendarBookingCubit.updateCount,
                                })
                          }
                      },
                  builder: ((context, state) {
                    try {
                      if (state is CalendarBookingLoading) {
                        BotToast.showLoading();
                      } else if (state is CalendarBookingCloseLoading) {
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
              title: Text(
                R.string.pick_time.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: R.color.textDark,
                  fontFamily: 'sfpro',
                ),
              ),
              leadingIcon: IconButton(
                  splashColor: R.color.transparent,
                  highlightColor: R.color.transparent,
                  icon: Icon(Icons.arrow_back, color: R.color.textDark),
                  onPressed: () {
                    CalendarBookingCubit.myCalendar = null;
                    CalendarBookingCubit.updateCount = 0;
                    Navigator.of(context).popUntil((route) => route.isFirst);
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
            color: R.color.white,
            child: Row(
              mainAxisAlignment: CalendarBookingCubit.updateCount > 1
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.center,
              children: [
                // if (CalendarBookingCubit.updateCount > 1) ...[
                //   _buildButton(
                //     "Lịch của tôi",
                //     () {
                //       Navigator.pushNamed(context, NavigatorName.calendar,
                //           arguments: {
                //             "pickSlot": myCalendar,
                //             "courseId": widget.courseId,
                //             'endTime': widget.endTime
                //           });
                //     },
                //   ),
                //   SizedBox(
                //     width: 16,
                //   )
                // ],
                Expanded(
                  child: _buildButton(
                    myCalendar != null
                        ? R.string.change_booking.tr()
                        : R.string.submit_booking.tr(),
                    () async {
                      try {
                        BotToast.showLoading();
                        if (myCalendar != null) {
                          // case not change slot
                          bool isSameSlot = pickSlot!.startTime ==
                                  myCalendar!.appointmentDate &&
                              (pickSlot!.endTime - pickSlot!.startTime) ==
                                  myCalendar!.duration;
                          if (isSameSlot) {
                            Navigator.pushNamed(context, NavigatorName.calendar,
                                arguments: {
                                  "pickSlot": myCalendar,
                                  "courseId": widget.courseId,
                                  'endTime': widget.endTime,
                                  "bookingQuantity":
                                      CalendarBookingCubit.updateCount,
                                });
                            BotToast.closeAllLoading();
                            return;
                          }
                          // If update count is 2 or more, show popup
                          if (CalendarBookingCubit.updateCount > 1) {
                            _showPopupOverSwitchTime(
                                onConfirm: () => {},
                                title: 'Bạn đã đến giới hạn đổi lịch hẹn');
                            BotToast.closeAllLoading();
                            return;
                          } else {
                            // _cubit.deleteCalendar({
                            //   "id": myCalendar!.id,
                            //   "calendarCoachId": pickSlotOld!.id,
                            //   "deleteType": "0",
                            // });
                            _showPopupOverSwitchTime(
                              onConfirm: () async {
                                await _cubit.deleteCalendar(
                                  DeleteCalendarRequest(
                                      id: myCalendar!.id,
                                      calendarCoachId: pickSlotOld!.id,
                                      deleteType: "0"),
                                );
                                _createCalendar();
                              },
                              title: R.string.confirm_change_schedule.tr(),
                              subtitle:
                                  R.string.confirm_change_schedule_content.tr(),
                              buttonTitle: R.string.confirm.tr(),
                            );
                            BotToast.closeAllLoading();
                            return;
                          }
                        }
                        // Case: create
                        if (pickSlot == null) {
                          _showPopupOverSwitchTime(
                              onConfirm: () => {},
                              title: "Vui lòng chọn lịch",
                              subtitle:
                                  'Vui lòng liên hệ 093188832 để được hỗ trợ.',
                              isShowImg: true);
                          BotToast.closeAllLoading();
                          return;
                        }
                        _showPopupOverSwitchTime(
                          onConfirm: () {
                            _createCalendar();
                          },
                          title: R.string.confirm_schedule.tr(),
                          subtitle: R.string.confirm_schedule_content.tr(),
                          buttonTitle: R.string.confirm.tr(),
                        );
                      } catch (e) {
                      } finally {
                        BotToast.closeAllLoading();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  _createCalendar() {
    var pickSlotsFilter = pickSlots
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
      name: "Phỏng Vấn Đầu Vào - ${AppSettings.userInfo!.fullName}",
      startTime: pickSlot!.startTime,
      endTime: pickSlot!.endTime,
      courseId: widget.courseId,
      performerId: pickSlot!.coachId,
      appointmentDate: pickSlot!.startTime,
      calendarCoachs: pickSlotsFilter,
      duration: pickSlot!.endTime - pickSlot!.startTime,
      repeatType: "0", // not repeat
      modelStatus: 3,
      meetingLink: "",
      zoomTypeId: 1, // auto generate link zoom
      type: "1", // CalendarTypeEnums = 1 is DanhGiaDauVao
      calendarAccounts: [account],
      goal: "Phỏng vấn đầu vào",
      trainingGroupIds: [],
      zoomUserId: pickSlot!.zoomUserId,
    );
    _cubit.createCalendar(request);
  }

  Widget _buildButton(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 44,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  _showPopupOverSwitchTime({
    required Function onConfirm,
    bool isShowImg = false,
    String? subtitle,
    String? title,
    String buttonTitle = 'Tôi đã hiểu',
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return Container(
          child: AlertDialog(
              contentPadding: EdgeInsets.all(10),
              content: Stack(children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isShowImg)
                        Image.asset(R.drawable.ic_warning,
                            width: 64, height: 64),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Text(
                          title ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: R.color.color0xff141416,
                            fontSize: 20,
                            fontFamily: 'sfpro',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          subtitle ?? "",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: R.color.color0xff777E90,
                            fontSize: 16,
                            fontFamily: 'sfpro',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
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
                                  buttonTitle,
                                  style: TextStyle(
                                    color: R.color.white,
                                    fontSize: 16,
                                    fontFamily: 'sfpro',
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
    List<CalendarCoachModel> coachSchedules =
        pickSlots.where((element) => element.zoomUserId.isNotEmpty).toList();
    List<Widget> morningTargets = [];
    List<Widget> afternoonTargets = [];

    Set<String> addedStartTimes = Set<String>();
    Set<String> addedEndTimes = Set<String>();
    for (int i = 0; i < coachSchedules.length; i++) {
      String startTime =
          "${_parseToDateTime(coachSchedules[i].startTime).hour.toString().padLeft(2, '0')} : ${_parseToDateTime(coachSchedules[i].startTime).minute.toString().padLeft(2, '0')}";
      String endTime =
          "${_parseToDateTime(coachSchedules[i].endTime).hour.toString().padLeft(2, '0')} : ${_parseToDateTime(coachSchedules[i].endTime).minute.toString().padLeft(2, '0')}";
      final isSlotPicked = pickSlot != null &&
          pickSlot!.startTime == coachSchedules[i].startTime &&
          pickSlot!.endTime == coachSchedules[i].endTime;

      if (!addedStartTimes.contains(startTime) ||
          !addedEndTimes.contains(endTime)) {
        Widget item = InkWell(
          onTap: () => {
            setState(() {
              pickSlot = coachSchedules[i];
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
                  coachSchedules[i].id,
                  coachSchedules[i].startTime,
                  coachSchedules[i].endTime,
                ),
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
                _buildItemTimeFrame(
                  endTime,
                  coachSchedules[i].id,
                  coachSchedules[i].startTime,
                  coachSchedules[i].endTime,
                ),
              ],
            ),
          ),
        );

        final isMorning =
            _parseToDateTime(coachSchedules[i].startTime).hour < 12;
        isMorning ? morningTargets.add(item) : afternoonTargets.add(item);
      }
      addedStartTimes.add(startTime);
      addedEndTimes.add(endTime);
    }

    return LayoutBuilder(builder: (context, constraints) {
      final targets = isMorningSelected ? morningTargets : afternoonTargets;
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.spaceBetween,
          children: List.generate((targets.length / 3).ceil() * 3, (index) {
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

  Widget _buildItemTimeFrame(
      String time, String id, int startTime, int endTime) {
    final isSlotPicked = pickSlot != null &&
        pickSlot!.startTime == startTime &&
        pickSlot!.endTime == endTime;
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

  Widget _buildSectionCalendarBooking() {
    List<DateTime> activeDates = _cubit.calendarCoachs
        .map((model) => DateTime.fromMillisecondsSinceEpoch(
              model.startTime * 1000,
              isUtc: true,
            ))
        .where((date) {
          DateTime today = DateTime.now();
          DateTime startOfToday = DateTime(today.year, today.month, today.day);
          DateTime endDate = startOfToday
              .add(Duration(days: 21)); // date start course + 3 weeks
          return date.isAfter(startOfToday) && date.isBefore(endDate);
        })
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
      margin: EdgeInsets.fromLTRB(16, 0, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
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
            initialDate: seletedDate,
            firstDate: DateTime.parse("1969-07-20 20:18:04Z"),
            activeDates: activeDates,
            lastDate:
                activeDates.length > 0 && activeDates.last.isAfter(seletedDate)
                    ? activeDates.last
                    : DateTime.now().add(Duration(days: 30)),
            onDateChanged: (datetime) {
              if (datetime != null) {
                var targets = _cubit.calendarCoachs
                    .where((model) => DateUtil.isSameDate(
                          DateTime.fromMillisecondsSinceEpoch(
                            model.startTime * 1000,
                            isUtc: true,
                          ),
                          datetime,
                        ))
                    .toList();
                setState(() {
                  pickSlots = targets;
                  seletedDate = datetime;
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
}
