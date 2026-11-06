import 'package:flutter_test/flutter_test.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/home/home_model.dart';

import '../../helpers/test_user.dart';

// BE-1 / BE-2: /App/Home gained bundlePartnerLogoUrl, bundleDescription and
// hasUnviewedExamResult (lib/src/modal/home/home_model.dart, fromJson).
// Staging/older backends omit them, so absence must fall back to
// null / null / false, and an unexpected type must not break Home parsing
// (a throw here would blank the whole Home screen).

/// Minimal /App/Home payload HomeModel.fromJson accepts.
Map<String, dynamic> _homeJson([Map<String, dynamic> extra = const {}]) => {
      'glucoseIndex': <String, dynamic>{},
      'bloodPressureIndex': <String, dynamic>{},
      'hbA1CIndex': <String, dynamic>{},
      ...extra,
    };

void main() {
  setUpAll(() {
    // GloucoseIndexModel.fromJson dereferences AppSettings.userInfo!.
    AppSettings.userInfo = buildTestUser();
  });

  group('HomeModel.fromJson BE-1/BE-2 fields', () {
    test('absent (older backend) => null / null / false', () {
      final model = HomeModel.fromJson(_homeJson());
      expect(model.bundlePartnerLogoUrl, isNull);
      expect(model.bundleDescription, isNull);
      expect(model.hasUnviewedExamResult, isFalse);
    });

    test('explicit nulls (current staging) => null / null / false', () {
      final model = HomeModel.fromJson(_homeJson({
        'bundlePartnerLogoUrl': null,
        'bundleDescription': null,
        'hasUnviewedExamResult': null,
      }));
      expect(model.bundlePartnerLogoUrl, isNull);
      expect(model.bundleDescription, isNull);
      expect(model.hasUnviewedExamResult, isFalse);
    });

    test('values sent => parsed as-is', () {
      final model = HomeModel.fromJson(_homeJson({
        'bundlePartnerLogoUrl': 'https://cdn.example.com/logo.png',
        'bundleDescription': 'Chương trình sức khỏe ACME',
        'hasUnviewedExamResult': true,
      }));
      expect(model.bundlePartnerLogoUrl, 'https://cdn.example.com/logo.png');
      expect(model.bundleDescription, 'Chương trình sức khỏe ACME');
      expect(model.hasUnviewedExamResult, isTrue);
    });

    test('wrong types do not throw; only a real `true` lights the dot', () {
      for (final flag in <Object>['true', 1, 'yes', 0, false, <String>[]]) {
        late HomeModel model;
        expect(
            () => model = HomeModel.fromJson(_homeJson({
                  'bundlePartnerLogoUrl': 42,
                  'bundleDescription': 3.5,
                  'hasUnviewedExamResult': flag,
                })),
            returnsNormally,
            reason: 'hasUnviewedExamResult: $flag');
        expect(model.hasUnviewedExamResult, isFalse,
            reason: 'hasUnviewedExamResult: $flag');
        expect(model.bundlePartnerLogoUrl, '42');
        expect(model.bundleDescription, '3.5');
      }
    });

    test('toJson round-trips the new fields (Home cache in prefs)', () {
      final model = HomeModel.fromJson(_homeJson({
        'bundlePartnerLogoUrl': 'https://cdn.example.com/logo.png',
        'bundleDescription': 'Mô tả',
        'hasUnviewedExamResult': true,
      }));
      final json = model.toJson();
      expect(json['bundlePartnerLogoUrl'], 'https://cdn.example.com/logo.png');
      expect(json['bundleDescription'], 'Mô tả');
      expect(json['hasUnviewedExamResult'], isTrue);
    });
  });
}
