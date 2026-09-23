import 'package:flutter_test/flutter_test.dart';
import 'package:medical/src/modal/home/home_model.dart';

// Mirrors the derivation added to `_HomeControllerState`'s `BlocBuilder` in
// lib/src/widget/home/home_v2.dart (fix for the duplicate `/App/Home` call
// on Home landing): `_hasExerciseData = model?.exercise?.isDataNotEmpty ?? false;`
// Keep this in sync if that line changes.
bool deriveHasExerciseData(HomeModel? model) =>
    model?.exercise?.isDataNotEmpty ?? false;

ExerciseIndexModel _exercise({bool? isDataNotEmpty}) => ExerciseIndexModel(
      index: null,
      indexChange: null,
      facExercise: null,
      targetExercise: null,
      unit: null,
      createDateTime: null,
      color: null,
      icon: null,
      isDataNotEmpty: isDataNotEmpty,
    );

HomeModel _buildHomeModel({ExerciseIndexModel? exercise}) {
  return HomeModel(
    glucoseIndex: GloucoseIndexModel(
      index: null,
      indexChange: null,
      unit: '',
      createDateTime: null,
      color: null,
      icon: null,
    ),
    bloodPressureIndex: BloodPressureIndexModel(
      systolic: null,
      colorSystolic: null,
      systolicChange: null,
      diastolic: null,
      colorDiastolic: null,
      diastolicChange: null,
      color: null,
      unit: null,
      icon: null,
      createDateTime: null,
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
  );
}

void main() {
  group(
      'Home _hasExerciseData derivation (bug fix: duplicate /App/Home call on landing)',
      () {
    test('no model yet (state not HomeLoaded) => false', () {
      expect(deriveHasExerciseData(null), isFalse);
    });

    test('model with null exercise => false', () {
      final model = _buildHomeModel(exercise: null);
      expect(deriveHasExerciseData(model), isFalse);
    });

    test('model with exercise.isDataNotEmpty == null => false', () {
      final model =
          _buildHomeModel(exercise: _exercise(isDataNotEmpty: null));
      expect(deriveHasExerciseData(model), isFalse);
    });

    test('model with exercise.isDataNotEmpty == false => false', () {
      final model =
          _buildHomeModel(exercise: _exercise(isDataNotEmpty: false));
      expect(deriveHasExerciseData(model), isFalse);
    });

    test('model with exercise.isDataNotEmpty == true => true', () {
      final model =
          _buildHomeModel(exercise: _exercise(isDataNotEmpty: true));
      expect(deriveHasExerciseData(model), isTrue);
    });
  });
}
