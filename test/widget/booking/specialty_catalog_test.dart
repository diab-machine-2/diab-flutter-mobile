import 'package:flutter_test/flutter_test.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/booking_clinic/model/clinic_specialty_model.dart';
import 'package:medical/src/widgets/specialty_catalog.dart';

ClinicSpecialty _s(int id, String name, {String? banner, String? image}) =>
    ClinicSpecialty(id: id, name: name, banner: banner, image: image);

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

  group('SpecialtyCatalog.parseSlugs / bannerSlug', () {
    test('trims and drops empty slugs', () {
      expect(SpecialtyCatalog.parseSlugs(' a, b ,,c,'), ['a', 'b', 'c']);
      expect(SpecialtyCatalog.parseSlugs(null), isEmpty);
      expect(SpecialtyCatalog.parseSlugs(''), isEmpty);
    });

    test('banner path → file name without extension', () {
      expect(SpecialtyCatalog.bannerSlug('clinic_specialty/tm.jpg'), 'tm');
      expect(SpecialtyCatalog.bannerSlug(r'a\b\tha.png'), 'tha');
      expect(SpecialtyCatalog.bannerSlug('tha'), 'tha');
    });
  });

  group('SpecialtyCatalog.ordered', () {
    final list = [
      _s(1, 'Cơ xương khớp', banner: 'x/cxk.png'),
      _s(2, 'Tim mạch', banner: 'x/tm.png'),
      _s(3, 'Tăng huyết áp', banner: 'x/tha.png'),
    ];

    test('no exclusions / order → API order', () {
      expect(SpecialtyCatalog.ordered(list), list);
    });

    test('drops excluded name slugs', () {
      expect(
          SpecialtyCatalog.ordered(list, excludeSlugs: ['co-xuong-khop'])
              .map((s) => s.id),
          [2, 3]);
    });

    test('ordered banner slugs first, the rest in API order', () {
      expect(
          SpecialtyCatalog.ordered(list, order: ['tha', 'unknown', 'tha'])
              .map((s) => s.id),
          [3, 1, 2]);
    });

    test('legacy daily-care slugs match nothing → API order', () {
      expect(
          SpecialtyCatalog.ordered(list,
              order: ['cao-huyet-ap', 'tieu-duong', 'benh-khac']),
          list);
    });
  });

  group('English names (language=en)', () {
    final en = [
      _s(2, 'Musculoskeletal', image: 'images/specialty_icons/diab/cxk.png'),
      _s(0, 'Diabetes', image: 'images/specialty_icons/diab/dtd.png'),
    ];

    test('exclusions still match by code', () {
      expect(
          SpecialtyCatalog.ordered(en, excludeSlugs: ['co-xuong-khop'])
              .map((s) => s.name),
          ['Diabetes']);
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
