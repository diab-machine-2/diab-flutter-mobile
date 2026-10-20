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

ApiResult<List<LessonSectionListResponseData>> _sections(int count) =>
    ApiResult.success(data: [
      for (var i = 0; i < count; i++)
        LessonSectionListResponseData(id: 's$i', name: 'Section $i'),
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
