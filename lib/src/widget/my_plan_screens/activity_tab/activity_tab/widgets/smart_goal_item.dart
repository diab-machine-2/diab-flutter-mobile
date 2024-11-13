import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/button_widget.dart';

import '../models/schedule_state.dart';
import '../models/schedule_type.dart';

class SmartGoalItem extends StatelessWidget {
  const SmartGoalItem(
      {required this.type,
      required this.name,
      required this.frequency,
      required this.subject,
      this.appointmentDate,
      required this.isDone,
      required this.onTap,
      required this.state,
      required this.onRemove});
  final ScheduleType type;
  final String name;
  final String frequency;
  final String subject;
  final bool isDone;
  final int state;
  final int? appointmentDate;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Slidable(
        actionPane: const SlidableDrawerActionPane(),
        enabled: type.removeAble,
        secondaryActions: [
          Container(
            margin: const EdgeInsets.only(left: 4),
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: IconSlideAction(
              color: R.color.color0xffFF5552,
              iconWidget: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(R.drawable.ic_trash2, width: 24, height: 24),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(R.string.cancel_smart_goal.tr(),
                          style: TextStyle(
                              color: R.color.white,
                              fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center),
                    ),
                  ]),
              onTap: () async {
                bool isUnableToRemove = DateUtil.isBefore(
                        appointmentDate, AppSettings.currentDateTime) ??
                    false;
                if (isUnableToRemove) {
                  Message.showToastMessage(
                      context, 'Không thể hủy mục tiêu trong quá khứ!');
                } else {
                  _showDeletePopup(context);
                }
              },
            ),
          ),
        ],
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(7, 15, 15, 15),
            decoration: BoxDecoration(
              color: R.color.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: R.color.color0xffE5E5E5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Container(
                //   width: 60,
                //   height: 60,
                //   alignment: Alignment.center,
                //   decoration: BoxDecoration(
                //     color: R.color.grey_6,
                //     shape: BoxShape.circle,
                //   ),
                //   child: Image.asset(
                //     type.icon,
                //     width: 40,
                //     height: 40,
                //   ),
                // ),
                Container(
                  width: 60,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        type.icon,
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Utils.getActivityIconDescription(type),
                        style: TextStyle(
                          fontSize: 10,
                          color: Utils.getActivityIconTextColor(type),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (type != ScheduleType.lesson &&
                          type != ScheduleType.survey)
                        Text(
                          (type == ScheduleType.custom ||
                                  type == ScheduleType.io_evaluate ||
                                  type == ScheduleType.output_assessment ||
                                  type == ScheduleType.book_1_1 ||
                                  type == ScheduleType.book_1_n)
                              ? name
                              : type.title,
                          style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                      if (type == ScheduleType.lesson ||
                          type == ScheduleType.survey)
                        Text(
                          frequency,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: R.color.textDark,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                        ),
                      if (frequency.isNotEmpty) const SizedBox(height: 4),
                      if (frequency.isNotEmpty)
                        Text(
                          getSubtitle(type),
                          style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        ),
                    ],
                  ),
                ),
                state == ScheduleState.in_progress.stateIndex
                    ? Image.asset(R.drawable.ic_learning,
                        width: 24, height: 24, color: R.color.mainColor)
                    : Container(
                        margin: EdgeInsets.only(left: 10),
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isDone
                              ? R.color.greenGradientBottom
                              : R.color.white,
                          border: isDone
                              ? null
                              : Border.all(color: R.color.grey_2, width: 1.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          color: isDone ? R.color.white : R.color.grey_2,
                          size: 20,
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getSubtitle(ScheduleType type) {
    if (type == ScheduleType.lesson) {
      return subject;
    }

    if (type == ScheduleType.survey) {
      return name.isEmpty ? type.title : name;
    }

    return frequency;
  }

  Future<void> _showDeletePopup(BuildContext context) async {
    final dynamic result = await showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
      context: context,
      barrierDismissible: true,
      builder: (_) => GestureDetector(
        onTap: () {
          NavigationUtil.pop(context);
        },
        child: Scaffold(
          backgroundColor: R.color.transparent,
          body: Center(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      R.color.white,
                      R.color.main_6,
                    ],
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 57, vertical: 10),
                        child: Image.asset(R.drawable.img_smart_goal_remove),
                      ),
                      Text(
                        R.string.confirm_cancel_smart_goal.tr(),
                        style: TextStyle(
                            color: R.color.textDark,
                            fontSize: 20,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        R.string.confirm_cancel_smart_goal_description.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: R.color.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(
                            width: 140.w,
                            height: 43,
                            child: ButtonWidget(
                              title: R.string.cancel.tr(),
                              textSize: 14,
                              backgroundColor: R.color.grayBorder,
                              textColor: R.color.textDark,
                              onPressed: () {
                                NavigationUtil.pop(context);
                              },
                            ),
                          ),
                          SizedBox(
                            width: 140.w,
                            height: 43,
                            child: ButtonWidget(
                              title: R.string.confirm.tr(),
                              textSize: 14,
                              onPressed: () {
                                NavigationUtil.pop(context, result: true);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (result is bool && result) {
      onRemove.call();
    }
  }
}
