import 'package:flutter_test/flutter_test.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/firebase_remote_config.dart';
import 'package:medical/src/widget/booking_clinic/model/clinic_specialty_model.dart';
import 'package:medical/src/widgets/specialty_catalog.dart';

ClinicSpecialty _s(int id, String name,
        {String? banner, String? image, String? code}) =>
    ClinicSpecialty(
        id: id, name: name, banner: banner, image: image, code: code);

void main() {
  group('SpecialtyCatalog.nameToSlug', () {
    test('strips diacritics, slashes and spaces', () {
      expect(SpecialtyCatalog.nameToSlug('Cơ xương khớp'), 'co-xuong-khop');
      expect(SpecialtyCatalog.nameToSlug(' Thừa cân/Béo phì '),
          'thua-can-beo-phi');
      expect(SpecialtyCatalog.nameToSlug('Đái tháo đường thai kỳ'),
          'dai-thao-duong-thai-ky');
    });
  });

  group('SpecialtyCatalog.bannerSlug / specialtyCode', () {
    test('file path → file name without extension', () {
      expect(SpecialtyCatalog.bannerSlug('clinic_specialty/tm.jpg'), 'tm');
      expect(SpecialtyCatalog.bannerSlug(r'a\b\tha.png'), 'tha');
      expect(SpecialtyCatalog.bannerSlug('tha'), 'tha');
    });

    test('API code first, else image file name', () {
      expect(
          SpecialtyCatalog.specialtyCode(
              _s(1, 'x', image: 'a/tm.png', code: ' THA ')),
          'tha');
      expect(SpecialtyCatalog.specialtyCode(_s(1, 'x', image: 'a/TM.png')),
          'tm');
      expect(SpecialtyCatalog.specialtyCode(_s(1, 'x', code: '')), '');
    });
  });

  group('SpecialtyCatalog.parseBookingList', () {
    const raw = '{"at_clinic":["tha"," TM ",1,""],"telemedicine":["dtd"]}';

    test('codes for each flow, trimmed and lowercased', () {
      expect(SpecialtyCatalog.parseBookingList(raw, isTelemedicine: false),
          ['tha', 'tm']);
      expect(SpecialtyCatalog.parseBookingList(raw, isTelemedicine: true),
          ['dtd']);
    });

    test('empty, malformed or missing flow → null (show all)', () {
      for (final value in [null, '', '  ', 'tha,tm', '[]', '{"x":1}',
          '{"at_clinic":"tha"}']) {
        expect(
            SpecialtyCatalog.parseBookingList(value, isTelemedicine: false),
            isNull,
            reason: '$value');
      }
    });

    test('an empty list hides everything', () {
      expect(
          SpecialtyCatalog.parseBookingList('{"at_clinic":[]}',
              isTelemedicine: false),
          isEmpty);
    });
  });

  group('SpecialtyCatalog.selected', () {
    final list = [
      _s(1, 'Cơ xương khớp', image: 'x/cxk.png'),
      _s(2, 'Tim mạch', image: 'x/tm.png'),
      _s(3, 'Tăng huyết áp', image: 'x/tha.png'),
      _s(4, 'Dạ dày/Tiêu hóa', image: 'x/dd.png'),
    ];

    test('null codes → API order', () {
      expect(SpecialtyCatalog.selected(list), list);
    });

    test('only listed codes, in list order; unknown and repeated skipped',
        () {
      expect(
          SpecialtyCatalog.selected(list,
                  codes: ['tha', 'dinh-duong', 'cxk', 'tha'])
              .map((s) => s.id),
          [3, 1]);
    });

    test('no code field: new needs match by name slug', () {
      final noCode = [
        _s(6, 'Vận động', image: 'x/xyz.png'),
        _s(7, 'Dinh dưỡng', image: 'x/abc.png'),
        ...list,
      ];
      expect(
          SpecialtyCatalog.selected(noCode,
                  codes: ['dinh-duong', 'van-dong', 'tm', 'dinh-duong'])
              .map((s) => s.id),
          [7, 6, 2]);
    });

    test('default list hides dd; cxk only at clinic', () {
      final atClinic = SpecialtyCatalog.selected(list,
          codes: SpecialtyCatalog.parseBookingList(
              FirebaseRemoteSetting.defaultBookingSpecialtyList,
              isTelemedicine: false));
      final tele = SpecialtyCatalog.selected(list,
          codes: SpecialtyCatalog.parseBookingList(
              FirebaseRemoteSetting.defaultBookingSpecialtyList,
              isTelemedicine: true));
      expect(atClinic.map((s) => s.id), [3, 2, 1]);
      expect(tele.map((s) => s.id), [3, 2]);
    });

    test('API code field wins over the image name', () {
      final withCode = [_s(5, 'Dinh dưỡng', image: 'x/abc.png', code: 'dinh-duong')];
      expect(
          SpecialtyCatalog.selected(withCode, codes: ['dinh-duong'])
              .map((s) => s.id),
          [5]);
    });
  });

  group('English names (language=en)', () {
    final en = [
      _s(2, 'Musculoskeletal', image: 'images/specialty_icons/diab/cxk.png'),
      _s(0, 'Diabetes', image: 'images/specialty_icons/diab/dtd.png'),
    ];

    test('selection still matches by code', () {
      expect(
          SpecialtyCatalog.selected(en, codes: ['dtd']).map((s) => s.name),
          ['Diabetes']);
    });

    test('new codes get their icon even with an English name', () {
      expect(
          SpecialtyCatalog.gridItem(
                  _s(9, 'Nutrition', image: 'x/abc.png', code: 'dinh-duong'),
                  onTap: () {})
              .assetIcon,
          R.drawable.ic3d_dinh_duong);
    });

    test('a Vietnamese name matches the English item', () {
      expect(SpecialtyCatalog.matchesName(en[1], 'Đái tháo đường'), isTrue);
      expect(SpecialtyCatalog.matchesName(en[1], 'Diabetes'), isTrue);
      expect(SpecialtyCatalog.matchesName(en[0], 'Đái tháo đường'), isFalse);
    });

    test('3D icon by code', () {
      expect(SpecialtyCatalog.gridItem(en[0], onTap: () {}).assetIcon,
          R.drawable.ic3d_co_xuong_khop);
    });
  });

  group('SpecialtyCatalog.gridItem', () {
    test('icon by image code, then name slug, else network image', () {
      var tapped = 0;
      final byCode = SpecialtyCatalog.gridItem(
          _s(1, 'Bất kỳ', image: 'clinic_specialty/tm.png'),
          onTap: () => tapped++);
      expect(byCode.assetIcon, R.drawable.ic3d_tim_mach);
      byCode.onTap();
      expect(tapped, 1);

      final byName = SpecialtyCatalog.gridItem(
          _s(2, 'Dinh dưỡng', image: 'clinic_specialty/xyz.png'),
          onTap: () {});
      expect(byName.assetIcon, R.drawable.ic3d_dinh_duong);

      final network = SpecialtyCatalog.gridItem(
          _s(3, 'Dạ dày/Tiêu hóa', image: 'clinic_specialty/dd.png'),
          onTap: () {});
      expect(network.assetIcon, isNull);
      expect(network.networkIcon, endsWith('clinic_specialty/dd.png'));

      final none = SpecialtyCatalog.gridItem(_s(4, 'Khác'), onTap: () {});
      expect(none.assetIcon, isNull);
      expect(none.networkIcon, isNull);
    });
  });
}
