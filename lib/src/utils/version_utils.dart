/// Pure helpers for comparing app versions (used by the force-update check).
///
/// Accepts `MAJOR.MINOR.PATCH` with any number of numeric segments, an
/// optional leading `v`, and ignores a build/pre-release suffix
/// (`+123`, `-beta`). Missing trailing segments count as 0, so
/// `"2.6" == "2.6.0"`.

/// Returns the numeric segments of [raw], or `null` when it is empty or not a
/// valid version (e.g. `""`, `"abc"`, `"1..2"`, `"1.x"`).
List<int>? parseVersion(String? raw) {
  if (raw == null) return null;
  var s = raw.trim();
  if (s.startsWith('v') || s.startsWith('V')) s = s.substring(1);
  final suffixAt = s.indexOf(RegExp(r'[+\-\s]'));
  if (suffixAt >= 0) s = s.substring(0, suffixAt);
  if (s.isEmpty) return null;
  final segments = <int>[];
  for (final part in s.split('.')) {
    final n = int.tryParse(part);
    if (n == null || n < 0) return null;
    segments.add(n);
  }
  return segments;
}

/// Segment-by-segment comparison. Returns a negative number if [a] < [b],
/// 0 if equal, positive if [a] > [b], or `null` if either is invalid.
int? compareVersions(String? a, String? b) {
  final va = parseVersion(a);
  final vb = parseVersion(b);
  if (va == null || vb == null) return null;
  final length = va.length > vb.length ? va.length : vb.length;
  for (var i = 0; i < length; i++) {
    final x = i < va.length ? va[i] : 0;
    final y = i < vb.length ? vb[i] : 0;
    if (x != y) return x.compareTo(y);
  }
  return 0;
}

/// `true` only when [requiredVersion] is a valid version strictly greater
/// than [currentVersion]. Empty/invalid input on either side never forces an
/// update.
bool isUpdateRequired({
  required String? currentVersion,
  required String? requiredVersion,
}) {
  final result = compareVersions(requiredVersion, currentVersion);
  return result != null && result > 0;
}
