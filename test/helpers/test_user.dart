import 'package:medical/src/modal/user/user_model.dart';

/// Minimal [UserModel] accepted by `UserModel.fromJson` (which requires the
/// rule lists to be present). Several production paths dereference
/// `AppSettings.userInfo!` (e.g. GloucoseIndexModel.fromJson,
/// DsmesAppointmentCubit.initCreateDsmesBookingRequest -> dateOfBirth).
UserModel buildTestUser({Map<String, dynamic> overrides = const {}}) {
  return UserModel.fromJson({
    'id': 'test-user',
    'fullName': 'Test User',
    'phoneNumber': '0900000000',
    'gender': 'Male',
    // Microseconds since epoch (production divides by 1000 to get ms).
    'dateOfBirth': DateTime.utc(1990, 1, 1).microsecondsSinceEpoch,
    for (final k in const [
      'jobList',
      'educationLevelList',
      'lessonTagList',
      'interestRuleList',
      'consciousnessPracticeRuleList',
      'vegetarianRuleList',
      'workingHourRuleList',
      'levelOfDiabetesRuleList',
      'favouriteSportRuleList',
      'religionRuleList',
      'personalityRuleList',
    ])
      k: <dynamic>[],
    ...overrides,
  });
}
