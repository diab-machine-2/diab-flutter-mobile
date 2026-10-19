import 'package:flutter_test/flutter_test.dart';
import 'package:medical/src/widget/home/widget/home_news.dart';

void main() {
  group('HomeNews.formatDate', () {
    test('day-first string from LearningPost?Position=', () {
      expect(HomeNews.formatDate('04/03/2026 14:10:44'), '04/03/2026');
      expect(HomeNews.formatDate(' 12/04/2025 '), '12/04/2025');
    });

    test('ISO string', () {
      expect(HomeNews.formatDate('2025-04-12T00:00:00'), '12/04/2025');
    });

    test('epoch seconds', () {
      final expected = DateTime.fromMillisecondsSinceEpoch(1744416000 * 1000);
      final dd = expected.day.toString().padLeft(2, '0');
      final mm = expected.month.toString().padLeft(2, '0');
      expect(HomeNews.formatDate('1744416000'), '$dd/$mm/${expected.year}');
    });

    test('empty or unparseable → no date', () {
      expect(HomeNews.formatDate(''), '');
      expect(HomeNews.formatDate('31/02/2026 10:00:00'), '');
      expect(HomeNews.formatDate('soon'), '');
    });
  });
}
