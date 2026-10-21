import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/response/smart_goal_list_reponse.dart';
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

  group('webinar activity (type 36)', () {
    test('is recognised and shown as an event', () {
      final type = ScheduleTypeExtend.getTypeFromIndexWithLessonData(36,
          activityName: 'Sự kiện webinar sdk');
      expect(type, ScheduleType.webinar);
      expect(type.typeIndex, 36);
      expect(Utils.getActivityIconDescription(type), R.string.event.tr());
      expect(Utils.getActivityIconTextColor(type), R.color.event_color);
      expect(type.activityIcon, R.icons.ic_nv_su_kien);
      expect(type.title, R.string.event.tr());
    });

    test('cannot be swiped away — it is assigned by the program', () {
      expect(ScheduleType.webinar.removeAble, isFalse);
    });

    test('keeps the webinar id from the activity payload', () {
      final goal = SmartGoalList.fromJson({
        'id': '8c31d163-9f01-442e-e2a1-08df2e87fb32',
        'name': 'Sự kiện webinar sdk',
        'type': 36,
        'appointmentDate': 1792454400,
        'learningPostId': 'd40959af-5958-4c51-aa77-08deed2660f0',
      });
      expect(goal.learningPostId, 'd40959af-5958-4c51-aa77-08deed2660f0');
      expect(goal.toJson()['learningPostId'], goal.learningPostId);
    });
  });
}
