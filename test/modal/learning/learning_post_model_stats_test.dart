import 'package:flutter_test/flutter_test.dart';
import 'package:medical/src/modal/learning/learning_post_model.dart';

// BE-4: LearningPost gained readingTime (minutes) and viewCount
// (lib/src/modal/learning/learning_post_model.dart, fromJson:
// `(json['readingTime'] as num?)?.toInt()`). An older backend omits them.

Map<String, dynamic> _postJson([Map<String, dynamic> extra = const {}]) => {
      'id': 'post-1',
      'title': 'Ăn sáng thế nào cho đường huyết ổn định',
      'status': 1,
      'createDatetime': '2026-10-30T08:00:00',
      ...extra,
    };

void main() {
  group('LearningPostModel.fromJson BE-4 readingTime / viewCount', () {
    test('absent => both null', () {
      final post = LearningPostModel.fromJson(_postJson());
      expect(post.readingTime, isNull);
      expect(post.viewCount, isNull);
    });

    test('explicit null => both null', () {
      final post = LearningPostModel.fromJson(
          _postJson({'readingTime': null, 'viewCount': null}));
      expect(post.readingTime, isNull);
      expect(post.viewCount, isNull);
    });

    test('ints parsed', () {
      final post = LearningPostModel.fromJson(
          _postJson({'readingTime': 4, 'viewCount': 1234}));
      expect(post.readingTime, 4);
      expect(post.viewCount, 1234);
    });

    test('zero kept as 0 (the UI decides to hide "0 phút đọc")', () {
      final post = LearningPostModel.fromJson(
          _postJson({'readingTime': 0, 'viewCount': 0}));
      expect(post.readingTime, 0);
      expect(post.viewCount, 0);
    });

    test('doubles (e.g. 3.0 from a .NET decimal) truncated to int', () {
      final post = LearningPostModel.fromJson(
          _postJson({'readingTime': 3.0, 'viewCount': 12.7}));
      expect(post.readingTime, 3);
      expect(post.viewCount, 12);
    });

    test('toJson round-trips both fields', () {
      final json = LearningPostModel.fromJson(
              _postJson({'readingTime': 5, 'viewCount': 99}))
          .toJson();
      expect(json['readingTime'], 5);
      expect(json['viewCount'], 99);
    });
  });
}
