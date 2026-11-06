@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical/src/modal/learning/learning_post_model.dart';
import 'package:medical/src/modal/base/images.dart';
import 'package:medical/src/widget/home/home_mock.dart';
import 'package:medical/src/widget/home/widget/home_news.dart';

import '../../helpers/localized_app.dart';

// BE-4: news cards in "Sự kiện & Tin nổi bật" show
// "x phút đọc · N lượt xem" from LearningPost readingTime/viewCount
// (lib/src/widget/home/widget/home_news.dart, HomeNews._statsLine).
// A null part or a 0 reading time is left out; nothing → no line at all.
// These run with HOME_MOCK off (no --dart-define), i.e. real API values.

LearningPostModel _news({int? readingTime, int? viewCount}) =>
    LearningPostModel(
      id: 'news-1',
      title: '5 lưu ý khi ăn sáng giúp đường huyết ổn định cả ngày',
      link: null,
      imageUrl: const ImagesModel(id: null, url: null),
      status: 1,
      enableLink: false,
      createDatetime: '2026-10-30T00:00:00',
      learningPostTagMappings: const [],
      positions: const [1],
      readingTime: readingTime,
      viewCount: viewCount,
    );

Future<void> _pump(WidgetTester tester, LearningPostModel post) async {
  await tester.binding.setSurfaceSize(const Size(375, 812));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await pumpLocalized(
    tester,
    home: Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: HomeNews(items: [post], onNewsTap: (_) {}),
        ),
      ),
    ),
  );
  expect(tester.takeException(), isNull);
}

void main() {
  setUpAll(initTestLocalization);

  test('precondition: HOME_MOCK is off in this run', () {
    expect(HomeMock.enabled, isFalse);
  });

  group('HomeNews stats line (BE-4)', () {
    testWidgets('both null (older backend) => no stats line', (tester) async {
      await _pump(tester, _news());
      expect(find.textContaining('phút đọc'), findsNothing);
      expect(find.textContaining('lượt xem'), findsNothing);
    });

    testWidgets('readingTime 0 and no views => no stats line',
        (tester) async {
      await _pump(tester, _news(readingTime: 0));
      expect(find.textContaining('phút đọc'), findsNothing);
      expect(find.textContaining('lượt xem'), findsNothing);
    });

    testWidgets('readingTime 0 + views => only the views part, no separator',
        (tester) async {
      await _pump(tester, _news(readingTime: 0, viewCount: 12));
      // Exact match => no leading "0 phút đọc · " / dangling separator.
      // (Not asserting "no '·' anywhere": the card's date line uses it too.)
      expect(find.text('12 lượt xem'), findsOneWidget);
      expect(find.textContaining('phút đọc'), findsNothing);
    });

    testWidgets('only views => "N lượt xem"', (tester) async {
      await _pump(tester, _news(viewCount: 7));
      expect(find.text('7 lượt xem'), findsOneWidget);
    });

    testWidgets('views 0 is hidden, reading time kept', (tester) async {
      await _pump(tester, _news(readingTime: 3, viewCount: 0));
      expect(find.text('3 phút đọc'), findsOneWidget);
      expect(find.textContaining('lượt xem'), findsNothing);
    });

    testWidgets('views 0 and no reading time => no stats line',
        (tester) async {
      await _pump(tester, _news(viewCount: 0));
      expect(find.textContaining('lượt xem'), findsNothing);
      expect(find.textContaining('phút đọc'), findsNothing);
    });

    testWidgets('only reading time => "x phút đọc"', (tester) async {
      await _pump(tester, _news(readingTime: 4));
      expect(find.text('4 phút đọc'), findsOneWidget);
      expect(find.textContaining('lượt xem'), findsNothing);
    });

    testWidgets('both => "x phút đọc · N lượt xem"', (tester) async {
      await _pump(tester, _news(readingTime: 4, viewCount: 25));
      expect(find.text('4 phút đọc · 25 lượt xem'), findsOneWidget);
    });

    testWidgets('large view count is compact-formatted', (tester) async {
      await _pump(tester, _news(readingTime: 2, viewCount: 1200));
      final stats = find.textContaining('lượt xem');
      expect(stats, findsOneWidget);
      final text = tester.widget<Text>(stats).data!;
      expect(text, startsWith('2 phút đọc · '));
      expect(text, isNot(contains('1200')),
          reason: 'NumberFormat.compact() should shorten 1200: "$text"');
    });
  });
}
