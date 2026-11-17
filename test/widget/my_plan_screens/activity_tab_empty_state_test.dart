import 'package:flutter_test/flutter_test.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/smart_goal_list_reponse.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/activity_tab/activity_tab_cubit.dart';
import 'package:medical/src/widget/my_plan_screens/my_plan/my_plan.dart';

import '../../helpers/test_user.dart';

class _Repo implements AppRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

void main() {
  late ActivityTabCubit cubit;

  setUp(() {
    // The cubit reads the signed-in user when it is created.
    AppSettings.userInfo = buildTestUser();
    final repo = _Repo();
    cubit = ActivityTabCubit(repo, MyPlanCubit(repo, 0));
  });

  tearDown(() => cubit.close());

  group('ActivityTabCubit.showNoActivity (Program > Hoạt động)', () {
    test('not before the first list has arrived', () {
      expect(cubit.showNoActivity, isFalse);
    });

    test('loaded with no daily and no not-completed activity', () {
      cubit.smartGoalsLoaded = true;
      expect(cubit.showNoActivity, isTrue);
    });

    test('hidden when the day has its own activity', () {
      cubit
        ..smartGoalsLoaded = true
        ..smartGoalDayList = [SmartGoalList(id: 'a', name: 'PM54')];
      expect(cubit.showNoActivity, isFalse);
    });

    test('hidden when only not-completed activities of the week remain', () {
      cubit
        ..smartGoalsLoaded = true
        ..smartGoalNotCompleteInWeekly = [SmartGoalList(id: 'b', name: 'HbA1C')];
      expect(cubit.showNoActivity, isFalse);
    });
  });
}
