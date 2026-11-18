import 'package:flutter_test/flutter_test.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/notification/notification_sent_label.dart';

void main() {
  group('notificationSentLabel', () {
    test('null when the backend sends no sentDateTime', () {
      expect(notificationSentLabel(null), isNull);
    });

    test('null for 0 instead of "01/01/1970"', () {
      expect(notificationSentLabel(0), isNull);
      expect(notificationSentLabel(-62135596800), isNull);
    });

    test('formats a real send time like the list did before', () {
      const sent = 1789122000;
      expect(notificationSentLabel(sent),
          convertToUTC(sent, 'HH:mm - dd/MM/yyyy'));
      expect(notificationSentLabel(sent), isNot(contains('1970')));
    });
  });
}
