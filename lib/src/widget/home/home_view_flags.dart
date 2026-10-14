import 'package:medical/src/model/bcb_campaign/bcb_exam_result_model.dart';
import 'package:medical/src/modal/home/home_model.dart';
import 'package:medical/src/widget/home/home_mock.dart';

/// Which variant of each Home section to render (Figma section 22514:10901).
///
/// Pure derivation from data Home already loads — kept out of `HomeBloc` so
/// it can be unit tested and reused by every section widget.
class HomeViewFlags {
  /// Glucose, blood pressure or exercise has a value → KPI card, otherwise the
  /// "Theo dõi chỉ số mỗi ngày" empty card.
  final bool hasKpi;

  /// User owns a benefit bundle (`HomeModel.hasBundle`) → "Quyền lợi" section.
  final bool hasBundle;

  /// User is enrolled in a program → "Xem tất cả" of today's activities opens
  /// the Program tab instead of expanding in place.
  final bool hasProgram;

  /// User has at least one exam result (`BcbExamResultModel`).
  final bool hasRecord;

  /// At least one exam result hasn't been opened yet (red dot on "Hồ sơ").
  final bool hasUnviewedRecord;

  const HomeViewFlags({
    this.hasKpi = false,
    this.hasBundle = false,
    this.hasProgram = false,
    this.hasRecord = false,
    this.hasUnviewedRecord = false,
  });

  /// BE-2: the backend doesn't set `viewedAt` yet, so every result would look
  /// unviewed. Until it does, the red dot only shows with `HOME_MOCK`.
  static const bool viewedAtSupported = false;

  factory HomeViewFlags.from({
    required HomeModel? model,
    String? userPackageName,
    List<BcbExamResultModel> examResults = const [],
    bool viewedAtSupported = HomeViewFlags.viewedAtSupported,
  }) {
    final hasRecord = examResults.isNotEmpty;
    final flags = HomeViewFlags(
      hasKpi: model != null && computeHasKpi(model),
      hasBundle: model?.hasBundle ?? false,
      hasProgram: _notBlank(model?.tranServicePackageName) ||
          _notBlank(userPackageName),
      hasRecord: hasRecord,
      hasUnviewedRecord: viewedAtSupported &&
          examResults.any((result) => result.viewedAt == null),
    );
    return HomeMock.applyFlags(flags);
  }

  static bool computeHasKpi(HomeModel model) {
    // Same "has data" rules as HomeBloc._castMeasurements, so the KPI card
    // and its values agree. Blood pressure also needs a record date: the
    // backend can return default values for an account that never measured.
    final glucose = model.glucoseIndex.index ?? 0;
    final bp = model.bloodPressureIndex;
    final hasBloodPressure = (bp.systolic ?? 0) > 0 &&
        (bp.diastolic ?? 0) > 0 &&
        (bp.createDateTime ?? 0) > 0;
    final exercise = model.exercise;
    final hasExercise =
        exercise?.isDataNotEmpty == true || (exercise?.index ?? 0) > 0;
    return glucose > 0 || hasBloodPressure || hasExercise;
  }

  static bool _notBlank(String? value) => value?.trim().isNotEmpty == true;

  HomeViewFlags copyWith({
    bool? hasKpi,
    bool? hasBundle,
    bool? hasProgram,
    bool? hasRecord,
    bool? hasUnviewedRecord,
  }) {
    return HomeViewFlags(
      hasKpi: hasKpi ?? this.hasKpi,
      hasBundle: hasBundle ?? this.hasBundle,
      hasProgram: hasProgram ?? this.hasProgram,
      hasRecord: hasRecord ?? this.hasRecord,
      hasUnviewedRecord: hasUnviewedRecord ?? this.hasUnviewedRecord,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is HomeViewFlags &&
      other.hasKpi == hasKpi &&
      other.hasBundle == hasBundle &&
      other.hasProgram == hasProgram &&
      other.hasRecord == hasRecord &&
      other.hasUnviewedRecord == hasUnviewedRecord;

  @override
  int get hashCode =>
      Object.hash(hasKpi, hasBundle, hasProgram, hasRecord, hasUnviewedRecord);

  @override
  String toString() => 'HomeViewFlags(kpi: $hasKpi, bundle: $hasBundle, '
      'program: $hasProgram, record: $hasRecord, unviewed: $hasUnviewedRecord)';
}
