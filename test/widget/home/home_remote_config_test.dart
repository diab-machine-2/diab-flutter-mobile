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

    test('unavailable slugs are dropped before the cap so others backfill', () {
      expect(
          HomeBenefitShortcutsConfig.parse(
              'kham-tai-nha,lich-hen,mua-thuoc,dat-xet-nghiem,xem-tat-ca',
              isAvailable: (slug) => slug != 'kham-tai-nha'),
          ['lich-hen', 'mua-thuoc', 'dat-xet-nghiem', 'xem-tat-ca']);
      expect(
          HomeBenefitShortcutsConfig.parse('kham-tai-nha',
              isAvailable: (slug) => slug != 'kham-tai-nha'),
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
        expect(
            config.gridBundleNoKpi, HomeDailyCareConfig.defaultGridBundleNoKpi);
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
      expect(
          config.gridFor(const HomeViewFlags(hasBundle: true, hasKpi: true)), [
        HomeDailyCareSlug.medicineReminder,
        HomeDailyCareSlug.connectDevice,
        HomeDailyCareSlug.sampleMenu,
        HomeDailyCareSlug.glucoseSchedule,
        HomeDailyCareSlug.goalSetting,
      ]);
    });

    test('a list emptied by visibility falls back to the default', () {
      final custom = HomeDailyCareConfig.parse(
          '{"grid_bundle_kpi":["ho-so-suc-khoe"],"all":["ho-so-suc-khoe"]}');
      const kpi = HomeViewFlags(hasBundle: true, hasKpi: true);
      expect(custom.gridFor(kpi), config.gridFor(kpi));
      expect(custom.allFor(kpi), config.allFor(kpi));
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

    test('Tư vấn sống khỏe / Mời bạn bè: hidden by default, shown when listed',
        () {
      const flags = HomeViewFlags(hasBundle: true, hasKpi: true);
      final byDefault = config.allFor(flags);
      expect(byDefault, isNot(contains(HomeDailyCareSlug.healthConsulting)));
      expect(byDefault, isNot(contains(HomeDailyCareSlug.referral)));

      final listed = HomeDailyCareConfig.parse(
              '{"all":["nhac-lich-uong-thuoc","tu-van-song-khoe","moi-ban-be"],'
              '"grid_bundle_kpi":["tu-van-song-khoe","moi-ban-be"]}');
      expect(listed.allFor(flags), [
        HomeDailyCareSlug.medicineReminder,
        HomeDailyCareSlug.healthConsulting,
        HomeDailyCareSlug.referral,
      ]);
      expect(listed.gridFor(flags),
          [HomeDailyCareSlug.healthConsulting, HomeDailyCareSlug.referral]);
    });
  });
}
