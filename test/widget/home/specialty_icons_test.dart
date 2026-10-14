import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widgets/specialty_grid.dart';

void main() {
  group('SpecialtyIcons.forImageCode (benefit flow)', () {
    test('every known Docosan image code maps to an existing 3D icon', () {
      for (final code in [
        'cxk',
        'tcbp',
        'tt',
        'tdtd',
        'dtd',
        'dtdtk',
        'rlch',
        'tha',
        'tm',
        'tmt'
      ]) {
        final icon = SpecialtyIcons.forImageCode('clinic_specialty/$code.png');
        expect(icon, isNotNull, reason: code);
        expect(File(icon!).existsSync(), isTrue, reason: icon);
      }
    });

    test('path, extension and case are ignored', () {
      expect(SpecialtyIcons.forImageCode(r'a\b\THA.jpg'),
          R.drawable.ic3d_tang_huyet_ap);
      expect(SpecialtyIcons.forImageCode('tm'), R.drawable.ic3d_tim_mach);
    });

    test('unknown or empty → null (use the API image)', () {
      expect(SpecialtyIcons.forImageCode('xyz.png'), isNull);
      expect(SpecialtyIcons.forImageCode(''), isNull);
      expect(SpecialtyIcons.forImageCode(null), isNull);
    });

    test('name slug fallback for nutrition / exercise', () {
      expect(
          SpecialtyIcons.forNameSlug('dinh-duong'), R.drawable.ic3d_dinh_duong);
      expect(SpecialtyIcons.forNameSlug('van-dong'), R.drawable.ic3d_van_dong);
      expect(SpecialtyIcons.forNameSlug('tang-huyet-ap'),
          R.drawable.ic3d_tang_huyet_ap);
      expect(SpecialtyIcons.forNameSlug('khac'), isNull);
    });
  });
}
