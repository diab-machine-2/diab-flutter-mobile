import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/activity_tab/models/schedule_type.dart';

void main() {
  test('webinar / event activity (book_1_n) is labelled "Sự kiện"', () {
    expect(Utils.getActivityIconDescription(ScheduleType.book_1_n),
        R.string.event.tr());
    expect(Utils.getActivityIconTextColor(ScheduleType.book_1_n),
        R.color.event_color);
    expect(ScheduleType.book_1_n.title, R.string.event.tr());
    expect(ScheduleType.book_1_n.activityIcon, R.icons.ic_nv_su_kien);
  });

  test('lessons keep the "Bài học" label', () {
    expect(Utils.getActivityIconDescription(ScheduleType.lesson),
        R.string.lesson.tr());
    expect(Utils.getActivityIconTextColor(ScheduleType.lesson),
        R.color.lesson_color);
  });
}
