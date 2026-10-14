import 'package:flutter_test/flutter_test.dart';
import 'package:medical/src/widget/home/home_remote_config.dart';
import 'package:medical/src/widget/home/home_view_flags.dart';

void main() {
  group('HomeBenefitShortcutsConfig.parse', () {
    test('empty / null => default', () {
      expect(HomeBenefitShortcutsConfig.parse(null),
          HomeBenefitShortcutsConfig.defaultSlugs);
      expect(HomeBenefitShortcutsConfig.parse('  '),
          HomeBenefitShortcutsConfig.defaultSlugs);
    });

    test('valid list keeps order, trims and dedupes', () {
      expect(HomeBenefitShortcutsConfig.parse(' uu-dai, kham-tai-nha,uu-dai'),
          ['uu-dai', 'kham-tai-nha']);
    });

    test('unknown slugs are skipped', () {
      expect(HomeBenefitShortcutsConfig.parse('lich-hen,foo,mua-thuoc'),
          ['lich-hen', 'mua-thuoc']);
    });

    test('only unknown slugs => default', () {
      expect(HomeBenefitShortcutsConfig.parse('foo,bar'),
          HomeBenefitShortcutsConfig.defaultSlugs);
    });

    test('caps at maxCount', () {
      expect(
          HomeBenefitShortcutsConfig.parse(
                  'lich-hen,mua-thuoc,dat-xet-nghiem,kham-tai-nha,uu-dai')
              .length,
          HomeBenefitShortcutsConfig.maxCount);
    });
  });

  group('HomeDailyCareConfig.parse', () {
    test('empty / malformed / non-object => all defaults', () {
      for (final raw in [null, '', 'not json', '[1,2]']) {
        final config = HomeDailyCareConfig.parse(raw);
        expect(config.gridNoBundle, HomeDailyCareConfig.defaultGridNoBundle);
        expect(config.gridBundleNoKpi,
            HomeDailyCareConfig.defaultGridBundleNoKpi);
        expect(config.gridBundleKpi, HomeDailyCareConfig.defaultGridBundleKpi);
        expect(config.all, HomeDailyCareConfig.defaultAll);
      }
    });

    test('valid lists override, unknown slugs and xem-tat-ca dropped', () {
      final config = HomeDailyCareConfig.parse(
          '{"grid_bundle_kpi":["mua-thuoc","foo","xem-tat-ca","kham-tu-xa"],'
          '"all":["moi-ban-be"]}');
      expect(config.gridBundleKpi, ['mua-thuoc', 'kham-tu-xa']);
      expect(config.all, ['moi-ban-be']);
      // Missing keys keep their defaults.
      expect(config.gridNoBundle, HomeDailyCareConfig.defaultGridNoBundle);
    });

    test('a list with only unknown slugs falls back to its default', () {
      final config =
          HomeDailyCareConfig.parse('{"grid_no_bundle":["foo", 3, null]}');
      expect(config.gridNoBundle, HomeDailyCareConfig.defaultGridNoBundle);
    });
  });

  group('HomeDailyCareConfig.gridFor', () {
    const config = HomeDailyCareConfig();

    test('picks the list matching bundle / KPI state', () {
      expect(config.gridFor(const HomeViewFlags()).first,
          HomeDailyCareSlug.atClinic);
      expect(config.gridFor(const HomeViewFlags(hasBundle: true, hasKpi: true)),
          [
            HomeDailyCareSlug.medicineReminder,
            HomeDailyCareSlug.connectDevice,
            HomeDailyCareSlug.sampleMenu,
            HomeDailyCareSlug.glucoseSchedule,
            HomeDailyCareSlug.goalSetting,
          ]);
    });

    test('health profile only when no KPI and a record exists', () {
      const withRecord = HomeViewFlags(hasBundle: true, hasRecord: true);
      final grid = config.gridFor(withRecord);
      expect(grid.first, HomeDailyCareSlug.healthProfile);
      expect(grid.length, HomeDailyCareConfig.gridSize);

      expect(
          config
              .gridFor(const HomeViewFlags(hasBundle: true))
              .contains(HomeDailyCareSlug.healthProfile),
          isFalse);
      expect(
          config
              .allFor(const HomeViewFlags(hasKpi: true, hasRecord: true))
              .contains(HomeDailyCareSlug.healthProfile),
          isFalse);
    });
  });
}
