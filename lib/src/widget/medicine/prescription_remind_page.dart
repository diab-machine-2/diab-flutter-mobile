import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../res/R.dart';
import '../../utils/navigator_name.dart';
import '../../modal/medicine/medicine_add_model.dart';

class PrescriptionRemindPage extends StatefulWidget {
  const PrescriptionRemindPage({super.key});

  @override
  State<PrescriptionRemindPage> createState() => _PrescriptionRemindPageState();
}

class _PrescriptionRemindPageState extends State<PrescriptionRemindPage> {
  List<DayTimeSchedule> _schedules = [
    DayTimeSchedule(dayTime: DayTime.morning, time: TimeOfDay(hour: 9, minute: 0)),
    DayTimeSchedule(dayTime: DayTime.night, time: TimeOfDay(hour: 20, minute: 30)),
  ];
  final TextEditingController _daysController = TextEditingController();

  @override
  void initState() {
    _daysController.text = '1';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: R.color.backgroundColorNew,
      appBar: AppBar(
        leading: IconButton(
            splashColor: R.color.transparent,
            highlightColor: R.color.transparent,
            icon: Icon(Icons.arrow_back, color: R.color.white),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
                NavigatorName.tabbar,
                (route) => false,
              );
            }),
        title: Transform(
          transform: Matrix4.translationValues(-20, 0.0, 0.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              R.string.set_time.tr(),
              style: TextStyle(color: R.color.white, fontSize: 20, fontWeight: FontWeight.w400),
            ),
          ),
        ),
        actions: [
          Center(
            child: InkWell(
              onTap: () => Navigator.of(context).pushNamed(NavigatorName.medicine_tutorial),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  R.string.tutorial.tr(),
                  style: TextStyle(color: R.color.white, fontSize: 15, fontWeight: FontWeight.w400),
                ),
              ),
            ),
          ),
        ],
        backgroundColor: R.color.transparent,
        //No more green
        elevation: 0.0,
        //Shadow gone
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [R.color.greenGradientMid, R.color.greenGradientBottom],
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildReminderList(),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          child: Divider(color: Colors.grey, height: 1),
        ),
        _buildRemindGetMoreMedicine(),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          child: Divider(color: Colors.grey, height: 1),
        ),
        _buildEnableNotification(),
        const Spacer(),
        _buildConfirmButton(),
      ],
    );
  }

  Widget _buildReminderList() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      child: DayTimeList(
        schedules: _schedules,
        onPickTime: (schedule) async {
          final picked = await showCustomTimePicker(
            context: context,
            initialTime: schedule.time,
          );
          if (picked != null) {
            // update schedule
          }
        },
      ),
    );
  }

  Widget _buildRemindGetMoreMedicine() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                R.string.reminder_get_more_medicine.tr(),
                style: TextStyle(color: R.color.color0xff111515, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              _buildDaysSelector(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            R.string.reminder_get_more_medicine_description.tr(),
            style: TextStyle(color: R.color.color0xff5E6566, fontSize: 12, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  Widget _buildDaysSelector() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          // onTap: _decrementQuantity,
          child: Container(
            width: 34,
            height: 32,
            decoration: BoxDecoration(
              color: Color(0xFFF4F7F7),
              borderRadius: BorderRadius.horizontal(left: Radius.circular(4), right: Radius.zero),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              width: 10,
              height: 2,
              R.icons.ic_minus,
            ),
          ),
        ),
        Container(
            width: 80,
            height: 36,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  '5',
                  style: TextStyle(color: R.color.color0xff008479, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'ngày',
                  style: TextStyle(color: R.color.color0xff5E6566, fontSize: 15, fontWeight: FontWeight.w400),
                ),
              ],
            )),
        GestureDetector(
          // onTap: _incrementQuantity,
          child: Container(
            width: 34,
            height: 32,
            decoration: BoxDecoration(
              color: Color(0xFFF4F7F7),
              borderRadius: BorderRadius.horizontal(left: Radius.zero, right: Radius.circular(4)),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              R.icons.ic_plus,
              width: 14,
              height: 14,
            ),
          ),
        ),
        SizedBox(width: 12.0),
      ],
    );
  }

  Widget _buildEnableNotification() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                R.string.enable_medicine_notification.tr(),
                style: TextStyle(color: R.color.color0xff111515, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Switch(value: true, onChanged: (_) {}),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            R.string.enable_medicine_notification_description.tr(),
            style: TextStyle(color: R.color.color0xff5E6566, fontSize: 12, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, NavigatorName.prescription),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: R.color.mainColor,
            borderRadius: BorderRadius.circular(200),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.centerRight,
              colors: [R.color.greenGradientTop, R.color.greenGradientBottom],
            ),
          ),
          child: Center(
            child: Text(
              R.string.confirm.tr(),
              style: TextStyle(color: R.color.white, fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  Future<TimeOfDay?> showCustomTimePicker({required BuildContext context, required TimeOfDay initialTime}) {
    int selectedHour = initialTime.hour;
    int selectedMinute = initialTime.minute;

    return showModalBottomSheet<TimeOfDay>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SizedBox(
          height: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min, // quan trọng
            children: [
              const SizedBox(height: 16),
              const Text(
                "Chọn giờ",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Picker giờ
                    Flexible(
                      flex: 1,
                      child: CupertinoPicker(
                        itemExtent: 40,
                        scrollController: FixedExtentScrollController(initialItem: selectedHour),
                        onSelectedItemChanged: (value) {
                          selectedHour = value;
                        },
                        children: List.generate(24, (i) => Center(child: Text(i.toString().padLeft(2, '0')))),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Picker phút
                    Flexible(
                      flex: 1,
                      child: CupertinoPicker(
                        itemExtent: 40,
                        scrollController: FixedExtentScrollController(initialItem: selectedMinute),
                        onSelectedItemChanged: (value) {
                          selectedMinute = value;
                        },
                        children: List.generate(60, (i) => Center(child: Text(i.toString().padLeft(2, '0')))),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Huỷ"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00A78E), // màu xanh gradient thì cần thêm
                      ),
                      onPressed: () {
                        Navigator.pop(context, TimeOfDay(hour: selectedHour, minute: selectedMinute));
                      },
                      child: const Text("Đồng ý"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class DayTimeHelper {
  static String getLabel(DayTime dayTime) {
    switch (dayTime) {
      case DayTime.morning:
        return R.string.the_morning.tr();
      case DayTime.noon:
        return R.string.the_noon.tr();
      case DayTime.afternoon:
        return R.string.the_afternoon.tr();
      case DayTime.night:
        return R.string.the_evening.tr();
    }
  }

  static Widget getIcon(DayTime dayTime) {
    switch (dayTime) {
      case DayTime.morning:
        return SvgPicture.asset(
          R.icons.ic_morning,
          width: 24,
        );
      case DayTime.noon:
        return SvgPicture.asset(
          R.icons.ic_noon,
          width: 24,
        );
      case DayTime.afternoon:
        return SvgPicture.asset(
          R.icons.ic_afternoon,
          width: 24,
        );
      case DayTime.night:
        return SvgPicture.asset(
          R.icons.ic_night,
          width: 24,
        );
    }
  }
}

class DayTimeList extends StatelessWidget {
  final List<DayTimeSchedule> schedules;
  final void Function(DayTimeSchedule schedule) onPickTime;

  const DayTimeList({
    super.key,
    required this.schedules,
    required this.onPickTime,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  DayTimeHelper.getIcon(schedule.dayTime),
                  SizedBox(width: 8),
                  Text(
                    DayTimeHelper.getLabel(schedule.dayTime),
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  shape: StadiumBorder(),
                  side: BorderSide(color: Colors.teal),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
                onPressed: () => onPickTime(schedule),
                icon: Icon(Icons.access_time, size: 16, color: Colors.teal),
                label: Text(
                  schedule.time.format(context),
                  style: TextStyle(color: Colors.teal),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
