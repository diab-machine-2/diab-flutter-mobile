import 'package:flutter_test/flutter_test.dart';
import 'package:medical/src/bloc/home/home_bloc.dart';
import 'package:medical/src/model/response/smart_goal_list_reponse.dart';

SmartGoalList _goal(String id, {int state = 0}) =>
    SmartGoalList(id: id, name: id, type: 11, state: state);

List<String?> _ids(List<SmartGoalList> goals) =>
    goals.map((g) => g.id).toList();

void main() {
  group('HomeBloc.todayGoals (same lists as the Program tab)', () {
    test('daily first, then the week\'s not-completed activities', () {
      final goals = HomeBloc.todayGoals(
        daily: [_goal('survey')],
        notCompleteInWeek: [_goal('doc-nhan'), _goal('an-tiec')],
      );
      expect(_ids(goals), ['survey', 'doc-nhan', 'an-tiec']);
    });

    test('completed not-completed-in-week items are left out', () {
      final goals = HomeBloc.todayGoals(
        notCompleteInWeek: [_goal('done', state: 1), _goal('open')],
      );
      expect(_ids(goals), ['open']);
    });

    test('daily keeps completed items (Home shows "done all" from them)', () {
      final goals = HomeBloc.todayGoals(daily: [_goal('d', state: 1)]);
      expect(_ids(goals), ['d']);
    });

    test('duplicates, nulls and missing ids are dropped', () {
      final goals = HomeBloc.todayGoals(
        daily: [_goal('a'), null, SmartGoalList(name: 'no id')],
        notCompleteInWeek: [_goal('a'), _goal('b'), _goal('b')],
      );
      expect(_ids(goals), ['a', 'b']);
    });

    test('nothing => empty', () {
      expect(HomeBloc.todayGoals(), isEmpty);
    });
  });
}
