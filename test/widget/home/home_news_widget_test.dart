import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical/src/widget/home/home_mock.dart';
import 'package:medical/src/widget/home/widget/home_news.dart';

import '../../helpers/localized_app.dart';

void main() {
  setUpAll(initTestLocalization);

  testWidgets(
      'events & news carousel lays out event and news cards without errors',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpLocalized(
      tester,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: HomeNews(
              items: HomeMock.samplePosts(),
              onNewsTap: (_) {},
            ),
          ),
        ),
      ),
    );

    // IntrinsicHeight + the image's LayoutBuilder used to assert here.
    expect(tester.takeException(), isNull);
    expect(find.text('Trực tuyến'), findsOneWidget);
    expect(find.textContaining('12/04/2025'), findsWidgets);
    final card = tester.getSize(find.byType(Material).at(1));
    expect(card.height, greaterThan(HomeNews.imageHeight));
  });

  test('isEvent needs a real host account and an event type', () {
    final posts = HomeMock.samplePosts();
    expect(HomeNews.isEvent(posts[0]), isTrue); // offline event
    expect(HomeNews.isEvent(posts[1]), isFalse); // news
    expect(HomeNews.isEvent(posts[2]), isTrue); // online event
  });
}
