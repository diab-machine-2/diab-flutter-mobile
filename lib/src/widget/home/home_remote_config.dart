import 'dart:convert';

import 'package:medical/src/widget/home/home_view_flags.dart';

/// Slugs of the Home "Chăm sóc hằng ngày" catalog. Remote Config lists are
/// written in these; anything else is ignored so an older app never breaks on
/// a slug added for a newer one.
class HomeDailyCareSlug {
  HomeDailyCareSlug._();

  static const healthProfile = 'ho-so-suc-khoe';
  static const atClinic = 'kham-tai-phong-kham';
  static const telemedicine = 'kham-tu-xa';
  static const labTest = 'dat-xet-nghiem';
  static const buyMedicine = 'mua-thuoc';
  static const medicineReminder = 'nhac-lich-uong-thuoc';
  static const connectDevice = 'ket-noi-thiet-bi';
  static const sampleMenu = 'thuc-don-mau';
  static const glucoseSchedule = 'lich-do-duong-huyet';
  static const goalSetting = 'thiet-lap-muc-tieu';
  static const reminder = 'lich-nhac-nho';
  static const homeVisit = 'kham-tai-nha';
  static const healthConsulting = 'tu-van-song-khoe';
  static const referral = 'moi-ban-be';
  static const viewAll = 'xem-tat-ca';

  static const all = {
    healthProfile,
    atClinic,
    telemedicine,
    labTest,
    buyMedicine,
    medicineReminder,
    connectDevice,
    sampleMenu,
    glucoseSchedule,
    goalSetting,
    reminder,
    homeVisit,
    healthConsulting,
    referral,
  };
}

/// Remote Config `HOME_DAILY_CARE_CONFIG`, a JSON object:
/// `{"grid_no_bundle": [...], "grid_bundle_no_kpi": [...],
///   "grid_bundle_kpi": [...], "all": [...]}`.
///
/// A missing, malformed or (after dropping unknown slugs) empty list falls
/// back to that list's default below. `xem-tat-ca` is never listed: the grid
/// always appends it itself.
///
/// Deliberately a new key: the legacy `UTILITIES_ORDER` is still read by
/// app versions already in the store.
class HomeDailyCareConfig {
  static const int gridSize = 5;

  static const defaultGridNoBundle = [
    HomeDailyCareSlug.healthProfile,
    HomeDailyCareSlug.atClinic,
    HomeDailyCareSlug.telemedicine,
    HomeDailyCareSlug.labTest,
    HomeDailyCareSlug.buyMedicine,
    HomeDailyCareSlug.medicineReminder,
  ];
  static const defaultGridBundleNoKpi = [
    HomeDailyCareSlug.healthProfile,
    HomeDailyCareSlug.medicineReminder,
    HomeDailyCareSlug.connectDevice,
    HomeDailyCareSlug.sampleMenu,
    HomeDailyCareSlug.glucoseSchedule,
    HomeDailyCareSlug.goalSetting,
  ];
  static const defaultGridBundleKpi = [
    HomeDailyCareSlug.healthProfile,
    HomeDailyCareSlug.medicineReminder,
    HomeDailyCareSlug.connectDevice,
    HomeDailyCareSlug.sampleMenu,
    HomeDailyCareSlug.glucoseSchedule,
    HomeDailyCareSlug.goalSetting,
  ];
  static const defaultAll = [
    HomeDailyCareSlug.healthProfile,
    HomeDailyCareSlug.medicineReminder,
    HomeDailyCareSlug.connectDevice,
    HomeDailyCareSlug.sampleMenu,
    HomeDailyCareSlug.glucoseSchedule,
    HomeDailyCareSlug.goalSetting,
    HomeDailyCareSlug.reminder,
    HomeDailyCareSlug.telemedicine,
    HomeDailyCareSlug.homeVisit,
    HomeDailyCareSlug.labTest,
    HomeDailyCareSlug.buyMedicine,
    HomeDailyCareSlug.atClinic,
  ];

  final List<String> gridNoBundle;
  final List<String> gridBundleNoKpi;
  final List<String> gridBundleKpi;
  final List<String> all;

  const HomeDailyCareConfig({
    this.gridNoBundle = defaultGridNoBundle,
    this.gridBundleNoKpi = defaultGridBundleNoKpi,
    this.gridBundleKpi = defaultGridBundleKpi,
    this.all = defaultAll,
  });

  factory HomeDailyCareConfig.parse(String? raw) {
    Map<String, dynamic> json = const {};
    if (raw != null && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) json = decoded;
      } catch (_) {
        // Malformed config → every list keeps its default.
      }
    }
    return HomeDailyCareConfig(
      gridNoBundle: _slugs(json['grid_no_bundle'], defaultGridNoBundle),
      gridBundleNoKpi:
          _slugs(json['grid_bundle_no_kpi'], defaultGridBundleNoKpi),
      gridBundleKpi: _slugs(json['grid_bundle_kpi'], defaultGridBundleKpi),
      all: _slugs(json['all'], defaultAll),
    );
  }

  /// Up to [gridSize] slugs for the Home grid ("Xem tất cả" not included).
  List<String> gridFor(HomeViewFlags flags) {
    final List<String> source;
    final List<String> fallback;
    if (!flags.hasBundle) {
      source = gridNoBundle;
      fallback = defaultGridNoBundle;
    } else if (flags.hasKpi) {
      source = gridBundleKpi;
      fallback = defaultGridBundleKpi;
    } else {
      source = gridBundleNoKpi;
      fallback = defaultGridBundleNoKpi;
    }
    return _visible(source, fallback, flags).take(gridSize).toList();
  }

  /// Every slug for the "Xem tất cả" screen.
  List<String> allFor(HomeViewFlags flags) => _visible(all, defaultAll, flags);

  /// [source] filtered by [isVisible]; a config list that ends up empty
  /// (e.g. only "ho-so-suc-khoe" for a KPI user) falls back to the default.
  static List<String> _visible(
      List<String> source, List<String> fallback, HomeViewFlags flags) {
    final visible = source.where((slug) => isVisible(slug, flags)).toList();
    return visible.isNotEmpty
        ? visible
        : fallback.where((slug) => isVisible(slug, flags)).toList();
  }

  /// "Hồ sơ sức khoẻ" only earns a tile when the KPI card (which carries its
  /// own "Hồ sơ" button) isn't shown and there is a record to open.
  static bool isVisible(String slug, HomeViewFlags flags) {
    if (slug == HomeDailyCareSlug.healthProfile) {
      return !flags.hasKpi && flags.hasRecord;
    }
    return true;
  }

  static List<String> _slugs(dynamic value, List<String> fallback) {
    if (value is! List) return fallback;
    final result = <String>[];
    for (final item in value) {
      if (item is! String) continue;
      final slug = item.trim();
      if (HomeDailyCareSlug.all.contains(slug) && !result.contains(slug)) {
        result.add(slug);
      }
    }
    return result.isEmpty ? fallback : result;
  }
}

/// Slugs of the shortcut row inside the "Quyền lợi" section.
class HomeBenefitShortcutSlug {
  HomeBenefitShortcutSlug._();

  static const appointments = 'lich-hen';
  static const buyMedicine = 'mua-thuoc';
  static const labTest = 'dat-xet-nghiem';
  static const homeVisit = 'kham-tai-nha';
  static const promotion = 'uu-dai';
  static const viewAll = 'xem-tat-ca';

  static const all = {
    appointments,
    buyMedicine,
    labTest,
    homeVisit,
    promotion,
    viewAll,
  };
}

/// Remote Config `HOME_BENEFIT_SHORTCUTS`: comma separated slugs, at most
/// [maxCount] shown. Unknown slugs are skipped; nothing usable → default.
class HomeBenefitShortcutsConfig {
  static const int maxCount = 4;
  static const defaultSlugs = [
    HomeBenefitShortcutSlug.appointments,
    HomeBenefitShortcutSlug.buyMedicine,
    HomeBenefitShortcutSlug.labTest,
    HomeBenefitShortcutSlug.viewAll,
  ];

  /// [isAvailable] drops shortcuts that can't open right now (e.g. Khám tại
  /// nhà without its config) before the [maxCount] cut, so the next slug
  /// backfills the row.
  static List<String> parse(String? raw,
      {bool Function(String slug)? isAvailable}) {
    bool usable(String slug) => isAvailable?.call(slug) ?? true;
    final result = <String>[];
    for (final item in (raw ?? '').split(',')) {
      final slug = item.trim();
      if (HomeBenefitShortcutSlug.all.contains(slug) &&
          !result.contains(slug) &&
          usable(slug)) {
        result.add(slug);
      }
    }
    final list = result.isEmpty ? defaultSlugs.where(usable).toList() : result;
    return list.take(maxCount).toList();
  }
}
