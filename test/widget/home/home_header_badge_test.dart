import 'package:flutter_test/flutter_test.dart';
import 'package:medical/src/widget/home/widget/header.dart';

void main() {
  group('HomeHeader.badgeLabel', () {
    test('nothing unread => no badge', () {
      expect(HomeHeader.badgeLabel(null), isNull);
      expect(HomeHeader.badgeLabel(0), isNull);
      expect(HomeHeader.badgeLabel(-1), isNull);
    });

    test('1-9 shown as is', () {
      expect(HomeHeader.badgeLabel(1), '1');
      expect(HomeHeader.badgeLabel(9), '9');
    });

    test('above 9 => 9+', () {
      expect(HomeHeader.badgeLabel(10), '9+');
      expect(HomeHeader.badgeLabel(250), '9+');
    });
  });
}
