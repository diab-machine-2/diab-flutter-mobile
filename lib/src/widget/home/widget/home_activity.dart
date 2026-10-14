import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/activity_tab/models/schedule_type.dart';

import '../schema/home_schema.dart';

typedef OnActivityTap = void Function(HomeActivityData activity);
typedef OnReminderTap = void Function(HomeReminderData reminder);

/// Home "Hoạt động hôm nay" card (Figma 22514:9600): today's activities, then
/// reminders, in one list.
///
/// Collapsed it shows at most [maxActivities] activities and [maxReminders]
/// reminders. "Xem tất cả" opens the Program tab when the user has a program
/// ([hasProgram]); otherwise it expands / collapses the list in place.
class HomeActivity extends StatelessWidget {
  const HomeActivity({
    super.key,
    required this.activities,
    required this.reminders,
    required this.hasProgram,
    required this.expanded,
    required this.onToggleExpanded,
    required this.onViewProgram,
    required this.onAddActivity,
    required this.onActivityTap,
    required this.onReminderTap,
    this.loading = false,
  });

  static const int maxActivities = 3;
  static const int maxReminders = 2;

  final List<HomeActivityData> activities;
  final List<HomeReminderData> reminders;
  final bool hasProgram;
  final bool expanded;
  final bool loading;

  final VoidCallback onToggleExpanded;
  final VoidCallback onViewProgram;
  final VoidCallback onAddActivity;
  final OnActivityTap onActivityTap;
  final OnReminderTap onReminderTap;

  @override
  Widget build(BuildContext context) {
    final pending = activities.where((e) => e.smartGoal.state != 1).toList();
    final isFinishedAll = pending.isEmpty && activities.isNotEmpty;
    final isEmpty = pending.isEmpty && reminders.isEmpty;
    final hasMore =
        pending.length > maxActivities || reminders.length > maxReminders;
    // With a program the full list lives in the Program tab, never here.
    final showAll = expanded && !hasProgram;
    final visibleActivities =
        showAll ? pending : pending.take(maxActivities).toList();
    final visibleReminders =
        showAll ? reminders : reminders.take(maxReminders).toList();

    final items = <Widget>[
      for (final activity in visibleActivities) _buildActivityItem(activity),
      for (final reminder in visibleReminders) _buildReminderItem(reminder),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            _buildHeader(hasMore),
            if (loading && isEmpty) const SizedBox(height: 64),
            if (!loading && isEmpty) _buildEmpty(isFinishedAll),
            for (final item in items) ...[
              const SizedBox(height: 12),
              item,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool hasMore) {
    Widget? action;
    if (loading) {
      action = const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else if (hasProgram) {
      action = _headerAction(
        R.string.view_all.tr(),
        SvgPicture.asset(R.icons.ic_home_chevron, width: 14, height: 14),
        onViewProgram,
      );
    } else if (hasMore) {
      action = _headerAction(
        expanded ? R.string.show_less.tr() : R.string.view_all.tr(),
        Icon(
          expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          size: 16,
          color: R.color.homeAccentTeal,
        ),
        onToggleExpanded,
      );
    }
    return Row(
      children: [
        Expanded(
          child: Text(
            R.string.goal_of_day.tr(),
            style: TextStyle(
              color: R.color.color0xff111515,
              fontSize: 18,
              height: 1.32,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (action != null) action,
      ],
    );
  }

  Widget _headerAction(String label, Widget icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: R.color.homeAccentTeal,
                fontSize: 13,
                height: 1.5,
                letterSpacing: 0.4,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 2),
            icon,
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(bool isFinishedAll) {
    return Column(
      children: [
        Image.asset(
          isFinishedAll
              ? R.drawable.im_activity_complete
              : R.drawable.im_activity_empty,
          width: 140,
          height: 140,
        ),
        Text(
          (isFinishedAll ? "complete_activity" : "empty_activity").tr(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 20 / 14,
            color: R.color.color0xff5E6566,
          ),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: onAddActivity,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: R.color.color0xff95682E,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(R.icons.ic_home_plus, width: 17, height: 17),
                const SizedBox(width: 7),
                Text(
                  R.string.goal_setting.tr(),
                  style: TextStyle(
                    color: R.color.white,
                    fontSize: 15,
                    height: 1.46,
                    letterSpacing: 0.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(HomeActivityData activity) {
    final type = activity.type;
    final usesDescription = type == ScheduleType.lesson ||
        type == ScheduleType.survey ||
        type == ScheduleType.quiz;
    final title = usesDescription
        ? (activity.description?.isNotEmpty == true
            ? activity.description!
            : activity.title)
        : activity.title;
    return _buildItem(
      icon: activityIcon(type),
      title: title,
      maxLines: 2,
      onTap: () => onActivityTap(activity),
    );
  }

  Widget _buildReminderItem(HomeReminderData reminder) {
    return _buildItem(
      icon: R.icons.ic_nv_nhac_nho,
      title: reminder.title,
      maxLines: 1,
      trailing: reminder.time,
      onTap: () => onReminderTap(reminder),
    );
  }

  Widget _buildItem({
    required String icon,
    required String title,
    required int maxLines,
    required VoidCallback onTap,
    String? trailing,
  }) {
    return Material(
      color: R.color.color0xffF4F7F7,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: Center(
                    child: SvgPicture.asset(icon, width: 32, height: 32)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: R.color.color0xff111515,
                    fontSize: 15,
                    height: 1.46,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12),
                // Time can carry a long frame name ("08:00 buổi tối").
                Flexible(
                  child: Text(
                    trailing,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: R.color.color0xff5E6566,
                      fontSize: 13,
                      height: 1.5,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// "Nhiệm vụ" icon (Figma icon system) for an activity type.
  static String activityIcon(ScheduleType type) {
    switch (type) {
      case ScheduleType.blood_sugar:
      case ScheduleType.blood_sugar_recommend:
      case ScheduleType.schedule_glucose_recommend:
        return R.icons.ic_nv_duong_huyet;
      case ScheduleType.blood_pressure:
      case ScheduleType.blood_pressure_recommend:
        return R.icons.ic_nv_huyet_ap;
      case ScheduleType.weight:
      case ScheduleType.weight_recommend:
      case ScheduleType.height_recommend:
        return R.icons.ic_nv_can_nang;
      case ScheduleType.emotion:
        return R.icons.ic_nv_cam_xuc;
      case ScheduleType.food:
      case ScheduleType.food_recommend:
      case ScheduleType.food_menu:
        return R.icons.ic_nv_dinh_duong;
      case ScheduleType.exercise:
      case ScheduleType.exercise_movement:
      case ScheduleType.exercise_recommend:
        return R.icons.ic_nv_van_dong;
      case ScheduleType.book_1_1:
      case ScheduleType.screening_interview:
      case ScheduleType.evaluate_interview:
      case ScheduleType.booking_solo:
        return R.icons.ic_ti_kham_tu_xa;
      case ScheduleType.book_1_n:
        return R.icons.ic_nv_su_kien;
      case ScheduleType.survey:
      case ScheduleType.io_evaluate:
      case ScheduleType.output_assessment:
        return R.icons.ic_nv_khao_sat;
      case ScheduleType.lesson:
      case ScheduleType.lesson_recommend:
        return R.icons.ic_nv_bai_hoc;
      case ScheduleType.infographic:
        return R.icons.ic_nv_kien_thuc;
      case ScheduleType.quiz:
        return R.icons.ic_nv_cau_hoi;
      case ScheduleType.update_profile:
      case ScheduleType.update_profile_recommend:
        return R.icons.ic_ti_ho_so_suc_khoe;
      case ScheduleType.hba1c_recommend:
        return R.icons.ic_nv_hba1c;
      case ScheduleType.schedule_recommend:
        return R.icons.ic_nv_nhac_nho;
      case ScheduleType.peripheral_recommend:
        return R.icons.ic_nv_ket_noi;
      case ScheduleType.examination:
        return R.icons.ic_ti_dat_lich_kham;
      case ScheduleType.goal_setting_recommend:
      case ScheduleType.custom:
      case ScheduleType.completed:
        return R.icons.ic_nv_muc_tieu;
    }
  }
}
