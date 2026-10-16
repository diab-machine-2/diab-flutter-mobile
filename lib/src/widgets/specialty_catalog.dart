import 'package:flutter/widgets.dart';
import 'package:medical/src/app_setting/firebase_remote_config.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/booking_clinic/model/clinic_specialty_model.dart';
import 'package:medical/src/widgets/specialty_grid.dart';

/// Filtering, ordering and grid mapping of the Docosan
/// `diseases-configuration-diab` specialties, shared by the benefit and the
/// Home daily-care booking flows.
class SpecialtyCatalog {
  SpecialtyCatalog._();

  /// Specialties for a booking flow: drops the Remote Config
  /// EXCLUDE_SPECIALTY_CLINIC / _TELEMEDICINE slugs, then orders by
  /// SPECIALTIES_ORDER.
  static List<ClinicSpecialty> forBooking(
    List<ClinicSpecialty> specialties, {
    required bool isTelemedicine,
  }) {
    final remote = FirebaseRemoteSetting.instance;
    return ordered(
      specialties,
      excludeSlugs: parseSlugs(isTelemedicine
          ? remote.excludeSpecialtyTelemedicine
          : remote.excludeSpecialtyClinic),
      order: parseSlugs(remote.specialtyOrder),
    );
  }

  /// Drops specialties whose name slug is in [excludeSlugs], then puts the
  /// ones whose banner slug is in [order] first (in that order), followed by
  /// the rest in API order.
  static List<ClinicSpecialty> ordered(
    List<ClinicSpecialty> specialties, {
    Iterable<String> excludeSlugs = const [],
    List<String> order = const [],
  }) {
    final exclude = excludeSlugs.toSet();
    final kept = exclude.isEmpty
        ? specialties
        : specialties
            .where((s) => !exclude.contains(canonicalSlug(s)))
            .toList();
    if (order.isEmpty) return kept;

    final byBanner = {for (final s in kept) bannerSlug(s.banner ?? ''): s};
    final result = <ClinicSpecialty>[];
    for (final slug in order) {
      final specialty = byBanner[slug];
      if (specialty != null && !result.contains(specialty)) {
        result.add(specialty);
      }
    }
    for (final s in kept) {
      if (!result.contains(s)) result.add(s);
    }
    return result;
  }

  /// Docosan image code → slug of the Vietnamese name, so exclusions and
  /// matching keep working when the API returns English names.
  static const Map<String, String> _slugByCode = {
    'cxk': 'co-xuong-khop',
    'tcbp': 'thua-can-beo-phi',
    'dd': 'da-day-tieu-hoa',
    'tha': 'tang-huyet-ap',
    'tdtd': 'tien-dai-thao-duong',
    'dtd': 'dai-thao-duong',
    'tm': 'tim-mach',
    'rlch': 'roi-loan-chuyen-hoa',
    'tmt': 'than-man-tinh',
    'tt': 'tinh-than',
    'dtdtk': 'dai-thao-duong-thai-ky',
  };

  /// Language-independent slug of a specialty: from its image code when
  /// known, else from its (Vietnamese) name.
  static String canonicalSlug(ClinicSpecialty specialty) =>
      _slugByCode[imageCode(specialty.image)] ?? nameToSlug(specialty.name);

  /// "images/specialty_icons/diab/tha.png" → "tha" (lowercase).
  static String imageCode(String? image) =>
      bannerSlug(image ?? '').toLowerCase();

  /// Whether [name] (e.g. a Vietnamese name from my-benefit) refers to
  /// [specialty], whatever language the list was loaded in.
  static bool matchesName(ClinicSpecialty specialty, String name) {
    final target = name.toLowerCase().trim();
    return specialty.name.toLowerCase().trim() == target ||
        canonicalSlug(specialty) == nameToSlug(name);
  }

  /// Comma-separated Remote Config value → trimmed, non-empty slugs.
  static List<String> parseSlugs(String? raw) => [
        for (final slug in (raw ?? '').split(','))
          if (slug.trim().isNotEmpty) slug.trim(),
      ];

  /// API banner path/slug → slug used for ordering.
  /// "clinic_specialty/tien-dai-thao-duong.jpg" → "tien-dai-thao-duong".
  static String bannerSlug(String banner) {
    final fileName = banner.replaceAll('\\', '/').split('/').last;
    final dot = fileName.lastIndexOf('.');
    return dot > 0 ? fileName.substring(0, dot) : fileName;
  }

  static final Map<String, String> _baseLetter = {
    for (final entry in const {
      'a': 'àáạãảâấầậẫẩăắằặẵẳ',
      'd': 'đ',
      'e': 'èéẹẽẻêếềệễể',
      'i': 'ìíịĩỉ',
      'o': 'òóọõỏôốồộỗổơớờợỡở',
      'u': 'ùúụũủưứừựữử',
      'y': 'ýỳỵỹỷ',
    }.entries)
      for (final c in entry.value.split('')) c: entry.key,
  };

  /// Vietnamese specialty name → slug used for exclusion and icons.
  /// "Cơ xương khớp" → "co-xuong-khop", "Thừa cân/Béo phì" → "thua-can-beo-phi".
  static String nameToSlug(String name) {
    return name
        .toLowerCase()
        .trim()
        .split('')
        .map((c) => _baseLetter[c] ?? c)
        .join()
        .replaceAll('/', '-')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'[^a-z0-9-]'), '')
        .replaceAll(RegExp(r'-{2,}'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  /// Grid option: local 3D icon by the API image code, else by the name
  /// slug, else the API image.
  static SpecialtyGridItem gridItem(
    ClinicSpecialty specialty, {
    required VoidCallback onTap,
  }) {
    final image = specialty.image;
    return SpecialtyGridItem(
      name: specialty.name,
      assetIcon: SpecialtyIcons.forImageCode(image) ??
          SpecialtyIcons.forNameSlug(canonicalSlug(specialty)),
      networkIcon: image?.isNotEmpty == true
          ? "${Utils.getHostDocosanUrl()}$image"
          : null,
      onTap: onTap,
    );
  }
}
