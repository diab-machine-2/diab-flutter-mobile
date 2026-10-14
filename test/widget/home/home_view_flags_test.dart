import 'package:flutter_test/flutter_test.dart';
import 'package:medical/src/model/bcb_campaign/bcb_exam_result_model.dart';
import 'package:medical/src/modal/home/home_model.dart';
import 'package:medical/src/widget/home/home_mock.dart';
import 'package:medical/src/widget/home/home_view_flags.dart';

HomeModel _model({
  double? glucose,
  double? systolic,
  double? diastolic,
  int? bpDate,
  ExerciseIndexModel? exercise,
  bool hasBundle = false,
  String? programName,
}) {
  return HomeModel(
    glucoseIndex: GloucoseIndexModel(
      index: glucose,
      indexChange: null,
      unit: '',
      createDateTime: null,
      color: null,
      icon: null,
    ),
    bloodPressureIndex: BloodPressureIndexModel(
      systolic: systolic,
      colorSystolic: null,
      systolicChange: null,
      diastolic: diastolic,
      colorDiastolic: null,
      diastolicChange: null,
      color: null,
      unit: null,
      icon: null,
      createDateTime: bpDate,
    ),
    exercise: exercise,
    hbA1CIndex: HbA1CIndexModel(
      index: null,
      indexChange: null,
      createDateTime: null,
      color: null,
      icon: null,
    ),
    weightCard: null,
    emotionCard: null,
    energyCard: null,
    energyExerciseCard: null,
    processCard: null,
    packageAccount: null,
    bmiCard: null,
    hasBundle: hasBundle,
    tranServicePackageName: programName,
  );
}

ExerciseIndexModel _exercise({double? index, bool? isDataNotEmpty}) =>
    ExerciseIndexModel(
      index: index,
      indexChange: null,
      facExercise: null,
      targetExercise: null,
      unit: null,
      createDateTime: null,
      color: null,
      icon: null,
      isDataNotEmpty: isDataNotEmpty,
    );

void main() {
  group('HomeViewFlags.computeHasKpi', () {
    test('no glucose, blood pressure or exercise => false', () {
      expect(HomeViewFlags.computeHasKpi(_model()), isFalse);
    });

    test('zero values count as no data', () {
      expect(
          HomeViewFlags.computeHasKpi(
              _model(glucose: 0, systolic: 0, exercise: _exercise(index: 0))),
          isFalse);
    });

    test('glucose only => true', () {
      expect(HomeViewFlags.computeHasKpi(_model(glucose: 108)), isTrue);
    });

    test('blood pressure with a record date => true', () {
      expect(
          HomeViewFlags.computeHasKpi(
              _model(systolic: 120, diastolic: 80, bpDate: 1760000000)),
          isTrue);
    });

    test('blood pressure defaults without a record date => false', () {
      expect(HomeViewFlags.computeHasKpi(_model(systolic: 120, diastolic: 90)),
          isFalse);
    });

    test('exercise isDataNotEmpty or index > 0 => true', () {
      expect(
          HomeViewFlags.computeHasKpi(
              _model(exercise: _exercise(isDataNotEmpty: true))),
          isTrue);
      expect(
          HomeViewFlags.computeHasKpi(_model(exercise: _exercise(index: 45))),
          isTrue);
    });
  });

  group('HomeViewFlags.from', () {
    test('null model => all false', () {
      expect(HomeViewFlags.from(model: null), const HomeViewFlags());
    });

    test('bundle and program come from the model / user package', () {
      expect(
          HomeViewFlags.from(model: _model(hasBundle: true)).hasBundle, isTrue);
      expect(
          HomeViewFlags.from(model: _model(programName: 'Health Foundation'))
              .hasProgram,
          isTrue);
      expect(
          HomeViewFlags.from(model: _model(), userPackageName: 'DiaB 360')
              .hasProgram,
          isTrue);
      expect(
          HomeViewFlags.from(
                  model: _model(programName: '  '), userPackageName: '')
              .hasProgram,
          isFalse);
    });

    test('hasRecord follows exam results', () {
      expect(HomeViewFlags.from(model: _model()).hasRecord, isFalse);
      expect(
          HomeViewFlags.from(
              model: _model(),
              examResults: [BcbExamResultModel(id: '1')]).hasRecord,
          isTrue);
    });

    test('unviewed dot stays off until the backend supports viewedAt', () {
      final results = [BcbExamResultModel(id: '1')];
      expect(
          HomeViewFlags.from(model: _model(), examResults: results)
              .hasUnviewedRecord,
          isFalse);
      expect(
          HomeViewFlags.from(
                  model: _model(),
                  examResults: results,
                  viewedAtSupported: true)
              .hasUnviewedRecord,
          isTrue);
      expect(
          HomeViewFlags.from(
                  model: _model(),
                  examResults: [
                    BcbExamResultModel(id: '1', viewedAt: DateTime(2026, 10, 1))
                  ],
                  viewedAtSupported: true)
              .hasUnviewedRecord,
          isFalse);
    });
  });

  group('HomeMock.applyFlags', () {
    const flags = HomeViewFlags(hasKpi: true, hasRecord: true);

    test('disabled => flags unchanged', () {
      expect(
          HomeMock.applyFlags(flags, enabled: false, override: 'kpi=0'), flags);
    });

    test('enabled => overrides apply and records show as unviewed', () {
      final result = HomeMock.applyFlags(flags,
          enabled: true, override: 'kpi=0,bundle=1,program=true,bogus=1');
      expect(
          result,
          const HomeViewFlags(
              hasKpi: false,
              hasBundle: true,
              hasProgram: true,
              hasRecord: true,
              hasUnviewedRecord: true));
    });

    test('enabled without records => no unviewed dot', () {
      final result =
          HomeMock.applyFlags(flags, enabled: true, override: 'record=0');
      expect(result.hasRecord, isFalse);
      expect(result.hasUnviewedRecord, isFalse);
    });
  });
}
