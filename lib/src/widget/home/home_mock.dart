import 'package:medical/src/widget/home/home_view_flags.dart';

/// QA-only sample data for the parts of the Home redesign the backend doesn't
/// serve yet. Off unless the build passes `--dart-define=HOME_MOCK=true`, so
/// release builds never see it.
///
/// `--dart-define=HOME_MOCK_FLAGS=kpi=0,bundle=1,program=0,record=1` (only
/// with HOME_MOCK) forces individual [HomeViewFlags] to reach a Figma state
/// the test account can't. Display only — it doesn't change what the
/// backend allows the account to do.
class HomeMock {
  HomeMock._();

  static const bool enabled = bool.fromEnvironment('HOME_MOCK');
  static const String _flagsOverride =
      String.fromEnvironment('HOME_MOCK_FLAGS');

  static HomeViewFlags applyFlags(HomeViewFlags flags,
      {bool enabled = HomeMock.enabled,
      String override = HomeMock._flagsOverride}) {
    if (!enabled) return flags;
    var result = flags;
    for (final pair in override.split(',')) {
      final parts = pair.split('=');
      if (parts.length != 2) continue;
      final value = parts[1].trim() == '1' || parts[1].trim() == 'true';
      switch (parts[0].trim()) {
        case 'kpi':
          result = result.copyWith(hasKpi: value);
          break;
        case 'bundle':
          result = result.copyWith(hasBundle: value);
          break;
        case 'program':
          result = result.copyWith(hasProgram: value);
          break;
        case 'record':
          result = result.copyWith(hasRecord: value);
          break;
      }
    }
    // BE-2 (viewedAt): pretend every existing record is still unread.
    return result.copyWith(hasUnviewedRecord: result.hasRecord);
  }

  /// BE-4: minutes to read a news post. Stable per post id.
  static int readingMinutes(String? postId) => 2 + _seed(postId) % 6;

  /// BE-4: view count of a news post. Stable per post id.
  static int viewCount(String? postId) => 300 + _seed(postId) % 2000;

  static int _seed(String? id) =>
      (id ?? '').codeUnits.fold(0, (sum, unit) => sum + unit);
}
