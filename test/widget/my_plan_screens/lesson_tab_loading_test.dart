import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/lesson_filter_request.dart';
import 'package:medical/src/model/response/lesson_section_list_response.dart';
import 'package:medical/src/model/response/my_lesson_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_tab/lesson_tab.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_tab/lesson_tab_skeleton.dart';
import 'package:medical/src/widget/my_plan_screens/my_plan/my_plan.dart';
import 'package:medical/src/widgets/shimmer_box.dart';

/// Each call parks on a completer so a test decides which section answers
/// first.
class _FakeRepo implements AppRepository {
  final lessons = <Completer<ApiResult<MyLessonResponse>>>[];
  final forYou = <Completer<ApiResult<List<LessonSectionListResponseData>>>>[];
  final moduleTypeArgs = <int>[];
  final moduleType =
      <Completer<ApiResult<List<LessonSectionListResponseData>>>>[];

  @override
  Future<ApiResult<MyLessonResponse>> getLessonsList(
      LessonFilterRequest request) {
    final c = Completer<ApiResult<MyLessonResponse>>();
    lessons.add(c);
    return c.future;
  }

  @override
  Future<ApiResult<List<LessonSectionListResponseData>>>
      getRecommendedLessons() {
    final c = Completer<ApiResult<List<LessonSectionListResponseData>>>();
    forYou.add(c);
    return c.future;
  }

  @override
  Future<ApiResult<List<LessonSectionListResponseData>>> getLessonModuleType(
      int type) {
    final c = Completer<ApiResult<List<LessonSectionListResponseData>>>();
    moduleTypeArgs.add(type);
    moduleType.add(c);
    return c.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

ApiResult<MyLessonResponse> _lessons(int count) => ApiResult.success(
    data: MyLessonResponse(data: [
      for (var i = 0; i < count; i++)
        MyLessonResponseData(id: 'l$i', name: 'Lesson $i', module: 'M'),
    ]));

ApiResult<List<LessonSectionListResponseData>> _sections(int count,
        [String prefix = 's']) =>
    ApiResult.success(data: [
      for (var i = 0; i < count; i++)
        LessonSectionListResponseData(id: '$prefix$i', name: 'Section $i'),
    ]);

void main() {
  late _FakeRepo repo;
  late LessonTabCubit cubit;

  setUp(() {
    repo = _FakeRepo();
    cubit = LessonTabCubit(repo, MyPlanCubit(repo, 0));
  });

  tearDown(() => cubit.close());

  test('sections load in parallel; main list stays "loading" until it answers',
      () async {
    final all = Future.wait([
      cubit.getInitData(),
      cubit.getForYouLessons(),
      cubit.getRecommendationLessons(type: 0),
    ]);
    await pumpEventQueue();

    // All three requests are in flight at once.
    expect(repo.lessons, hasLength(1));
    expect(repo.forYou, hasLength(1));
    expect(repo.moduleType, hasLength(1));
    expect(cubit.isLessonsLoading, isTrue);
    expect(cubit.isForYouLoading, isTrue);
    expect(cubit.isRecommendationLoading, isTrue);

    // The side sections answering first must not end the main loading
    // (that used to flash the "no lessons" placeholder).
    repo.forYou.single.complete(_sections(2));
    repo.moduleType.single.complete(_sections(3));
    await pumpEventQueue();
    expect(cubit.isForYouLoading, isFalse);
    expect(cubit.isRecommendationLoading, isFalse);
    expect(cubit.isLessonsLoading, isTrue);
    expect(cubit.lessonsList, isEmpty);

    repo.lessons.single.complete(_lessons(4));
    await all;
    expect(cubit.isLessonsLoading, isFalse);
    expect(cubit.lessonsList, hasLength(4));
  });

  test('a failed main list ends the loading state', () async {
    final load = cubit.getInitData();
    await pumpEventQueue();
    repo.lessons.single.complete(const ApiResult.failure(
        error: NetworkExceptions.requestTimeout()));
    await load;
    expect(cubit.isLessonsLoading, isFalse);
    expect(cubit.lessonsList, isEmpty);
  });

  test('refreshing "Dành cho bạn" keeps the current cards on screen', () async {
    final first = cubit.getForYouLessons();
    await pumpEventQueue();
    repo.forYou.single.complete(_sections(2));
    await first;

    final refresh = cubit.getForYouLessons(emitState: false);
    await pumpEventQueue();
    expect(cubit.isForYouLoading, isFalse,
        reason: 'no skeleton over existing content');
    expect(cubit.forYouLessons, hasLength(2));
    repo.forYou.last.complete(_sections(5));
    await refresh;
    expect(cubit.forYouLessons, hasLength(5));
  });

  test('silent refresh after finishing a lesson does not double the list',
      () async {
    final first = cubit.getInitData();
    await pumpEventQueue();
    repo.lessons.single.complete(_lessons(4));
    await first;

    final refresh = cubit.silentRefreshAll();
    await pumpEventQueue();
    repo.lessons.last.complete(_lessons(4));
    repo.forYou.last.complete(_sections(1));
    repo.moduleType.last.complete(_sections(1));
    await refresh;
    expect(cubit.lessonsList, hasLength(4));
  });

  test('a refresh racing the first load does not double the list', () async {
    final first = cubit.getInitData();
    final refresh = cubit.onRefresh(isRefresh: true);
    await pumpEventQueue();
    for (final c in repo.lessons) {
      c.complete(_lessons(3));
    }
    repo.forYou.last.complete(_sections(1));
    repo.moduleType.last.complete(_sections(1));
    await Future.wait([first, refresh]);
    expect(cubit.lessonsList, hasLength(3));
  });

  group('"Đề xuất" chips', () {
    const timeout =
        ApiResult<List<LessonSectionListResponseData>>.failure(
            error: NetworkExceptions.requestTimeout());

    Future<void> loadChip0() async {
      final first = cubit.getRecommendationLessons(type: 0);
      await pumpEventQueue();
      repo.moduleType.last.complete(_sections(2, 'all'));
      await first;
    }

    test('switching chip shows the skeleton, not the previous chip rows',
        () async {
      await loadChip0();

      final tap = cubit.getRecommendationLessons(type: 4);
      await pumpEventQueue();
      expect(repo.moduleTypeArgs.last, 4);
      expect(cubit.recommendationType, 4);
      expect(cubit.isRecommendationLoading, isTrue);
      expect(cubit.recommendationLessons, isNull);

      repo.moduleType.last.complete(_sections(3, 'food'));
      await tap;
      expect(cubit.isRecommendationLoading, isFalse);
      expect(cubit.recommendationLessons!.first!.id, 'food0');
    });

    test('a slower earlier chip cannot overwrite the chip tapped last',
        () async {
      await loadChip0();

      final a = cubit.getRecommendationLessons(type: 4);
      final b = cubit.getRecommendationLessons(type: 6);
      await pumpEventQueue();
      final reqA = repo.moduleType[repo.moduleType.length - 2];
      final reqB = repo.moduleType.last;

      reqB.complete(_sections(1, 'move'));
      reqA.complete(_sections(1, 'food'));
      await Future.wait([a, b]);
      expect(cubit.recommendationType, 6);
      expect(cubit.recommendationLessons!.single!.id, 'move0');
      expect(cubit.isRecommendationLoading, isFalse);
    });

    test('a chip that fails with nothing to show offers an inline retry',
        () async {
      await loadChip0();

      final states = <LessonTabState>[];
      final sub = cubit.stream.listen(states.add);
      addTearDown(sub.cancel);

      final tap = cubit.getRecommendationLessons(type: 4);
      await pumpEventQueue();
      repo.moduleType.last.complete(timeout);
      await tap;
      await pumpEventQueue();
      expect(cubit.hasRecommendationError, isTrue);
      expect(cubit.isRecommendationLoading, isFalse);
      expect(states, isNot(contains(isA<LessonTabFailure>())),
          reason: 'inline error instead of a toast');

      final retry = cubit.getRecommendationLessons();
      await pumpEventQueue();
      expect(repo.moduleTypeArgs.last, 4);
      expect(cubit.hasRecommendationError, isFalse);
      expect(cubit.isRecommendationLoading, isTrue);
      repo.moduleType.last.complete(_sections(2, 'food'));
      await retry;
      expect(cubit.recommendationLessons, hasLength(2));
    });

    test('a failed refresh keeps the rows already on screen', () async {
      await loadChip0();

      final refresh = cubit.getRecommendationLessons(emitState: false);
      await pumpEventQueue();
      expect(cubit.isRecommendationLoading, isFalse);
      repo.moduleType.last.complete(timeout);
      await refresh;
      expect(cubit.hasRecommendationError, isFalse);
      expect(cubit.recommendationLessons, hasLength(2));
    });

    test('going back to a chip shows its earlier list at once', () async {
      await loadChip0();
      final food = cubit.getRecommendationLessons(type: 4);
      await pumpEventQueue();
      repo.moduleType.last.complete(_sections(3, 'food'));
      await food;

      final back = cubit.getRecommendationLessons(type: 0);
      await pumpEventQueue();
      expect(cubit.isRecommendationLoading, isFalse);
      expect(cubit.recommendationLessons!.first!.id, 'all0');

      // Revalidated in the background.
      repo.moduleType.last.complete(_sections(5, 'all'));
      await back;
      expect(cubit.recommendationLessons, hasLength(5));
    });

    test('an overtaken answer still fills its own chip for later', () async {
      final all = cubit.getRecommendationLessons(type: 0);
      final food = cubit.getRecommendationLessons(type: 4);
      await pumpEventQueue();
      repo.moduleType.first.complete(_sections(2, 'all'));
      repo.moduleType.last.complete(_sections(1, 'food'));
      await Future.wait([all, food]);
      expect(cubit.recommendationLessons!.single!.id, 'food0');

      final back = cubit.getRecommendationLessons(type: 0);
      await pumpEventQueue();
      expect(cubit.isRecommendationLoading, isFalse);
      expect(cubit.recommendationLessons!.first!.id, 'all0');
      repo.moduleType.last.complete(_sections(2, 'all'));
      await back;
    });

    test('a refresh taking over a chip tap drops the skeleton when it answers',
        () async {
      final first = cubit.getInitData();
      await pumpEventQueue();
      repo.lessons.single.complete(_lessons(2));
      await first;
      await loadChip0();

      final tap = cubit.getRecommendationLessons(type: 4);
      final refresh = cubit.silentRefreshAll();
      await pumpEventQueue();
      final states = <LessonTabState>[];
      final sub = cubit.stream.listen(states.add);
      addTearDown(sub.cancel);

      // The tap's own request was overtaken; only the refresh's answer
      // counts. The main list is still pending.
      final overtaken = repo.moduleType[repo.moduleType.length - 2];
      repo.moduleType.last.complete(_sections(3, 'food'));
      await pumpEventQueue();
      overtaken.complete(_sections(3, 'food'));
      await tap;
      await pumpEventQueue();
      expect(cubit.isRecommendationLoading, isFalse);
      expect(cubit.recommendationLessons, hasLength(3));
      expect(states, contains(isA<LessonTabSuccess>()),
          reason: 'screen updates without waiting for the main list');

      repo.lessons.last.complete(_lessons(2));
      repo.forYou.last.complete(_sections(1));
      await refresh;
    });

    test('finishing a lesson updates it in every chip fetched', () async {
      await loadChip0();
      final food = cubit.getRecommendationLessons(type: 4);
      await pumpEventQueue();
      repo.moduleType.last.complete(ApiResult.success(data: [
        LessonSectionListResponseData(id: 'all0', name: 'shared'),
      ]));
      await food;

      await cubit.updateStatusLesson(lessonId: 'all0', percentComplete: 100);

      final back = cubit.getRecommendationLessons(type: 0);
      await pumpEventQueue();
      expect(cubit.recommendationLessons!.first!.percentComplete, 100);
      repo.moduleType.last.complete(_sections(1, 'all'));
      await back;
    });
  });

  testWidgets('skeletons lay out at phone width without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(320, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(children: [
            LessonCardRowSkeleton(),
            LessonModulesSkeleton(),
            LessonRecommendationSkeleton(),
          ]),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 600));

    expect(tester.takeException(), isNull);
    expect(find.byType(ShimmerBox), findsWidgets);
  });
}
