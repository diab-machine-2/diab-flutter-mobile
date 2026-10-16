import 'dart:convert';

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

  /// Specialties for a booking flow, picked and ordered by the Remote Config
  /// BOOKING_SPECIALTY_LIST.
  static List<ClinicSpecialty> forBooking(
    List<ClinicSpecialty> specialties, {
    required bool isTelemedicine,
  }) =>
      selected(
        specialties,
        codes: parseBookingList(
          FirebaseRemoteSetting.instance.bookingSpecialtyList,
          isTelemedicine: isTelemedicine,
        ),
      );

  /// BOOKING_SPECIALTY_LIST JSON (`{"at_clinic": [code…], "telemedicine":
  /// [code…]}`) → the codes for one flow. Null when the value is empty,
  /// malformed or has no list for that flow, meaning "show all".
  static List<String>? parseBookingList(
    String? raw, {
    required bool isTelemedicine,
  }) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final list = decoded[isTelemedicine ? 'telemedicine' : 'at_clinic'];
      if (list is! List) return null;
      return [
        for (final code in list)
          if (code is String && code.trim().isNotEmpty)
            code.trim().toLowerCase(),
      ];
    } on FormatException {
      return null;
    }
  }

  /// Keeps only the specialties whose [specialtyCode] is in [codes], in that
  /// order; codes missing from the API are skipped. A specialty without a
  /// matching code (e.g. "dinh-duong" before Docosan adds the `code` field)
  /// also matches by its [canonicalSlug]. When two specialties share a code
  /// only the first is kept. A null [codes] keeps the whole list in API order.
  static List<ClinicSpecialty> selected(
    List<ClinicSpecialty> specialties, {
    List<String>? codes,
  }) {
    if (codes == null) return specialties;
    final byCode = <String, ClinicSpecialty>{};
    final bySlug = <String, ClinicSpecialty>{};
    for (final s in specialties) {
      byCode.putIfAbsent(specialtyCode(s), () => s);
      bySlug.putIfAbsent(canonicalSlug(s), () => s);
    }
    final result = <ClinicSpecialty>[];
    final added = Set<ClinicSpecialty>.identity();
    for (final code in codes) {
      final specialty = byCode[code] ?? bySlug[code];
      if (specialty != null && added.add(specialty)) result.add(specialty);
    }
    return result;
  }

  /// Specialty code: the API `code` field when present, else the image file
  /// name ("images/specialty_icons/diab/tha.png" → "tha").
  static String specialtyCode(ClinicSpecialty specialty) {
    final code = specialty.code?.trim().toLowerCase();
    return code != null && code.isNotEmpty ? code : imageCode(specialty.image);
  }

  /// Specialty code → slug of the Vietnamese name, so name matching and icons
  /// keep working when the API returns English names.
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
    'dinh-duong': 'dinh-duong',
    'van-dong': 'van-dong',
  };

  /// Language-independent slug of a specialty: from its code when known,
  /// else from its (Vietnamese) name.
  static String canonicalSlug(ClinicSpecialty specialty) =>
      _slugByCode[specialtyCode(specialty)] ?? nameToSlug(specialty.name);

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

  /// File path → file name without extension.
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

  /// Grid option: local 3D icon by the specialty code, else by the name
  /// slug, else the API image.
  static SpecialtyGridItem gridItem(
    ClinicSpecialty specialty, {
    required VoidCallback onTap,
  }) {
    final image = specialty.image;
    return SpecialtyGridItem(
      name: specialty.name,
      assetIcon: SpecialtyIcons.forImageCode(specialtyCode(specialty)) ??
          SpecialtyIcons.forNameSlug(canonicalSlug(specialty)),
      networkIcon: image?.isNotEmpty == true
          ? "${Utils.getHostDocosanUrl()}$image"
          : null,
      onTap: onTap,
    );
  }
}
