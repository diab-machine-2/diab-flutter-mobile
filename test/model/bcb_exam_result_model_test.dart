import 'package:flutter_test/flutter_test.dart';
import 'package:medical/src/model/bcb_campaign/bcb_exam_result_model.dart';

// "Hồ sơ" list red dot: a result is unviewed only when the backend sends
// `viewedAt` (BE-2) and it is null. Payloads as staging returns them.
void main() {
  test('viewedAt null from a tracking backend → unviewed', () {
    final r = BcbExamResultModel.fromJson(
        {'id': 'a', 'uploadedAt': 1790578137, 'viewedAt': null, 'type': 5});
    expect(r.tracksViewed, isTrue);
    expect(r.isUnviewed, isTrue);
  });

  test('viewedAt set → viewed', () {
    final r = BcbExamResultModel.fromJson(
        {'id': 'a', 'viewedAt': 1793781289, 'type': 5});
    expect(r.viewedAt, isNotNull);
    expect(r.isUnviewed, isFalse);
  });

  test('older backend without the key → never unviewed', () {
    final r = BcbExamResultModel.fromJson({'id': 'a', 'type': 5});
    expect(r.tracksViewed, isFalse);
    expect(r.isUnviewed, isFalse);
  });

  test('marking locally clears the dot', () {
    final r = BcbExamResultModel.fromJson({'id': 'a', 'viewedAt': null});
    r.viewedAt = DateTime.now();
    expect(r.isUnviewed, isFalse);
  });
}
