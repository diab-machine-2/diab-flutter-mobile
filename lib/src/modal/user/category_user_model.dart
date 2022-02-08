import 'package:medical/src/modal/user/category_item_user_model.dart';

class CategoryUserModel {
  final List<CategoryItemUserModel>? jobList;
  final List<CategoryItemUserModel>? educationLevelList;
  final List<CategoryItemUserModel>? lessonTagList;
  final List<CategoryItemUserModel>? genderList;
  final List<CategoryItemUserModel>? levelList;
  final List<CategoryItemUserModel>? typeOfWorkList;
  final List<CategoryItemUserModel>? agencyList;
  final List<CategoryItemUserModel>? roleList;
  final List<CategoryItemUserModel>? positionList;
  final List<CategoryItemUserModel>? managerList;
  final List<CategoryItemUserModel>? genderRuleList;
  final List<CategoryItemUserModel>? personalityRuleList;
  final List<CategoryItemUserModel>? interestRuleList;
  final List<CategoryItemUserModel>? consciousnessPracticeRuleList;
  final List<CategoryItemUserModel>? locallyRuleList;
  final List<CategoryItemUserModel>? languageRuleList;
  final List<CategoryItemUserModel>? vegetarianRuleList;
  final List<CategoryItemUserModel>? workingHourRuleList;
  final List<CategoryItemUserModel>? levelOfDiabetesRuleList;
  final List<CategoryItemUserModel>? depthExperienceRuleList;
  final List<CategoryItemUserModel>? favouriteSportRuleList;
  final List<CategoryItemUserModel>? religionRuleList;

  CategoryUserModel({
    required this.jobList,
    required this.educationLevelList,
    required this.lessonTagList,
    required this.genderList,
    required this.levelList,
    required this.typeOfWorkList,
    required this.agencyList,
    required this.roleList,
    required this.positionList,
    required this.managerList,
    required this.genderRuleList,
    required this.personalityRuleList,
    required this.interestRuleList,
    required this.consciousnessPracticeRuleList,
    required this.locallyRuleList,
    required this.languageRuleList,
    required this.vegetarianRuleList,
    required this.workingHourRuleList,
    required this.levelOfDiabetesRuleList,
    required this.depthExperienceRuleList,
    required this.favouriteSportRuleList,
    required this.religionRuleList,
  });

  factory CategoryUserModel.fromJson(Map<String, dynamic> json) {
    return CategoryUserModel(
      jobList: CategoryItemUserModel.toList(json['jobList']),
      educationLevelList: CategoryItemUserModel.toList(json['educationLevelList']),
      lessonTagList: CategoryItemUserModel.toList(json['lessonTagList']),
      genderList: CategoryItemUserModel.toList(json['genderList']),
      levelList: CategoryItemUserModel.toList(json['levelList']),
      typeOfWorkList: CategoryItemUserModel.toList(json['typeOfWorkList']),
      agencyList: CategoryItemUserModel.toList(json['agencyList']),
      roleList: CategoryItemUserModel.toList(json['roleList']),
      positionList: CategoryItemUserModel.toList(json['positionList']),
      managerList: CategoryItemUserModel.toList(json['managerList']),
      genderRuleList: CategoryItemUserModel.toList(json['genderRuleList']),
      personalityRuleList: CategoryItemUserModel.toList(json['personalityRuleList']),
      interestRuleList: CategoryItemUserModel.toList(json['interestRuleList']),
      consciousnessPracticeRuleList: CategoryItemUserModel.toList(json['consciousnessPracticeRuleList']),
      locallyRuleList: CategoryItemUserModel.toList(json['locallyRuleList']),
      languageRuleList: CategoryItemUserModel.toList(json['languageRuleList']),
      vegetarianRuleList: CategoryItemUserModel.toList(json['vegetarianRuleList']),
      workingHourRuleList: CategoryItemUserModel.toList(json['workingHourRuleList']),
      levelOfDiabetesRuleList: CategoryItemUserModel.toList(json['levelOfDiabetesRuleList']),
      depthExperienceRuleList: CategoryItemUserModel.toList(json['depthExperienceRuleList']),
      favouriteSportRuleList: CategoryItemUserModel.toList(json['favouriteSportRuleList']),
      religionRuleList: CategoryItemUserModel.toList(json['religionRuleList']),
    );
  }

  static List<CategoryUserModel> toList(List<dynamic> items) {
    return items.map((item) => CategoryUserModel.fromJson(item)).toList();
  }
}
