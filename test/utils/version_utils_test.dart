import 'package:flutter_test/flutter_test.dart';
import 'package:medical/src/utils/version_utils.dart';

// Covers lib/src/utils/version_utils.dart — the pure comparison used by the
// force-update check (ForceUpdateCubit.check).
void main() {
  group('isUpdateRequired(current, required)', () {
    // [current, required, expected]
    const cases = <List<Object?>>[
      ['2.5.1', '2.6.0', true],
      ['2.6.0', '2.6.0', false], // equal
      ['2.7.0', '2.6.0', false], // installed is newer
      ['1.9.9', '1.10.0', true], // numeric, not lexicographic
      ['1.10.0', '1.9.9', false],
      ['2.5.100', '2.5.99', false],
      ['2.5.1', '2.6', true], // missing trailing segment == 0
      ['2.6.0', '2.6', false],
      ['2.5.1', '2.5.1.1', true], // extra segment
      ['2.5.1', '2.6.0+210', true], // build suffix ignored on required
      ['2.5.1+201', '2.5.1', false], // build suffix ignored on current
      ['2.5.1', 'v2.6.0', true], // leading v
      ['2.5.1', ' 2.6.0 ', true], // surrounding whitespace
      // Invalid / empty required version never forces an update.
      ['2.5.1', '', false],
      ['2.5.1', ' ', false],
      ['2.5.1', null, false],
      ['2.5.1', 'abc', false],
      ['2.5.1', '1..2', false],
      ['2.5.1', '9.x', false],
      // Unknown installed version never forces an update.
      ['', '9.9.9', false],
      [null, '9.9.9', false],
    ];

    for (final c in cases) {
      test('current=${_q(c[0])} required=${_q(c[1])} => ${c[2]}', () {
        expect(
          isUpdateRequired(
            currentVersion: c[0] as String?,
            requiredVersion: c[1] as String?,
          ),
          c[2],
        );
      });
    }
  });

  group('parseVersion', () {
    test('valid inputs', () {
      expect(parseVersion('2.6.0'), [2, 6, 0]);
      expect(parseVersion('V1.2'), [1, 2]);
      expect(parseVersion('3.0.0-beta.1'), [3, 0, 0]);
      expect(parseVersion('10'), [10]);
    });

    test('invalid inputs return null', () {
      for (final raw in [null, '', '   ', 'abc', '1..2', '1.x', '.1', '1.']) {
        expect(parseVersion(raw), isNull, reason: 'raw=${_q(raw)}');
      }
    });
  });

  group('compareVersions', () {
    test('sign of result', () {
      expect(compareVersions('1.0.0', '1.0.1'), lessThan(0));
      expect(compareVersions('1.0.1', '1.0.0'), greaterThan(0));
      expect(compareVersions('1.0', '1.0.0'), 0);
      expect(compareVersions('1.0', 'bad'), isNull);
    });
  });
}

String _q(Object? v) => v == null ? 'null' : '"$v"';
