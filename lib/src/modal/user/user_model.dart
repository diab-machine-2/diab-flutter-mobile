import 'package:medical/src/modal/base/images.dart';
import 'package:medical/src/modal/user/update_profile_request.dart';
import 'package:meta/meta.dart';

import 'category_item_user_model.dart';

@immutable
class UserModel {
  final String? id;
  final String? accountId;
  final String? creatorId;
  final String? userName;
  final String? fullName;
  final int? age;
  final String? phoneNumber;
  final String? secondPhoneNumber;
  final String? gender;
  final int? genderType;
  final int? createDatetime;
  final bool? isActive;
  final String? email;
  final double? height;
  final double? weight;
  final int? dateOfBirth;
  final int? diabetesStatus;
  final String? diabetesName;
  final int? diabetesDate;
  final ImagesModel? imageUrl;
  final String? code;
  final ProvinceModel? nation;
  final ProvinceModel? province;
  final ProvinceModel? district;
  final ProvinceModel? ward;
  final String? address;
  final double? goalWaist;
  final double? goalWeight;
  final double? energyGoal;
  final bool? isLinkedFacebook;
  final bool? isLinkedGoogle;
  final bool? isMobileAccount;
  final String? firstLinkedAccount;
  final int? glucoseUnit;
  final String? googleEmail;
  final double? activityLevelRate;

  final String? roadMapId;

  final bool? hasBreakfastSnack;
  final bool? hasLunchSnack;
  final bool? hasDinnerSnack;

  final DiabeteModel? diabetes;
  final InfoModel? profession;
  final InfoModel? educationLevel;
  final InfoModel? personality;
  final InfoModel? consciousnessPractice;
  final InfoModel? religion;
  final InfoModel? vegetarian;
  final List<InfoModel>? caredTopic;
  final List<InfoModel>? personalInterests;
  final List<InfoModel>? favouriteSports;
  final List<InfoModel>? workingHourss;

  final List<CategoryItemUserModel>? jobList;
  final List<CategoryItemUserModel>? educationLevelList;
  final List<CategoryItemUserModel>? lessonTagList;
  final List<CategoryItemUserModel>? personalityRuleList;
  final List<CategoryItemUserModel>? interestRuleList;
  final List<CategoryItemUserModel>? consciousnessPracticeRuleList;
  final List<CategoryItemUserModel>? vegetarianRuleList;
  final List<CategoryItemUserModel>? workingHourRuleList;
  final List<CategoryItemUserModel>? levelOfDiabetesRuleList;
  final List<CategoryItemUserModel>? favouriteSportRuleList;
  final List<CategoryItemUserModel>? religionRuleList;
  final AccountRule? accountRule;

  const UserModel({
    required this.id,
    required this.accountId,
    required this.creatorId,
    required this.userName,
    required this.fullName,
    required this.age,
    required this.phoneNumber,
    required this.secondPhoneNumber,
    required this.gender,
    required this.genderType,
    required this.createDatetime,
    required this.isActive,
    required this.nation,
    required this.province,
    required this.district,
    required this.height,
    required this.weight,
    required this.ward,
    required this.dateOfBirth,
    required this.diabetesStatus,
    required this.diabetesName,
    required this.diabetesDate,
    required this.imageUrl,
    required this.code,
    required this.email,
    required this.address,
    required this.goalWaist,
    required this.goalWeight,
    required this.energyGoal,
    required this.isLinkedFacebook,
    required this.isLinkedGoogle,
    required this.isMobileAccount,
    required this.firstLinkedAccount,
    required this.googleEmail,
    required this.glucoseUnit,
    required this.activityLevelRate,
    required this.roadMapId,
    required this.hasBreakfastSnack,
    required this.hasLunchSnack,
    required this.hasDinnerSnack,
    required this.diabetes,
    required this.profession,
    required this.educationLevel,
    required this.personality,
    required this.consciousnessPractice,
    required this.religion,
    required this.vegetarian,
    required this.caredTopic,
    required this.personalInterests,
    required this.favouriteSports,
    required this.workingHourss,
    required this.jobList,
    required this.educationLevelList,
    required this.lessonTagList,
    required this.personalityRuleList,
    required this.interestRuleList,
    required this.consciousnessPracticeRuleList,
    required this.vegetarianRuleList,
    required this.workingHourRuleList,
    required this.levelOfDiabetesRuleList,
    required this.favouriteSportRuleList,
    required this.religionRuleList,
    required this.accountRule,
  });

  UserModel copyWith({
    String? id,
    String? accountId,
    String? creatorId,
    String? username,
    String? fullName,
    int? age,
    String? phoneNumber,
    String? secondPhoneNumber,
    String? gender,
    int? genderType,
    int? createDatetime,
    bool? isActive,
    String? email,
    double? height,
    double? weight,
    int? dateOfBirth,
    int? diabetesStatus,
    String? diabetesName,
    int? diabetesDate,
    ImagesModel? imageUrl,
    String? code,
    ProvinceModel? nation,
    ProvinceModel? province,
    ProvinceModel? district,
    ProvinceModel? ward,
    String? address,
    double? goalWaist,
    double? goalWeight,
    double? energyGoal,
    bool? isLinkedFacebook,
    bool? isLinkedGoogle,
    bool? isMobileAccount,
    String? firstLinkedAccount,
    int? glucoseUnit,
    String? googleEmail,
    double? activityLevelRate,
    String? roadMapId,
    bool? hasBreakfastSnack,
    bool? hasLunchSnack,
    bool? hasDinnerSnack,
    DiabeteModel? diabetes,
    InfoModel? profession,
    InfoModel? educationLevel,
    InfoModel? personality,
    InfoModel? consciousnessPractice,
    InfoModel? religion,
    InfoModel? vegetarian,
    List<InfoModel>? caredTopic,
    List<InfoModel>? personalInterests,
    List<InfoModel>? favouriteSports,
    List<InfoModel>? workingHourss,
    List<CategoryItemUserModel>? jobList,
    List<CategoryItemUserModel>? educationLevelList,
    List<CategoryItemUserModel>? lessonTagList,
    List<CategoryItemUserModel>? personalityRuleList,
    List<CategoryItemUserModel>? interestRuleList,
    List<CategoryItemUserModel>? consciousnessPracticeRuleList,
    List<CategoryItemUserModel>? vegetarianRuleList,
    List<CategoryItemUserModel>? workingHourRuleList,
    List<CategoryItemUserModel>? levelOfDiabetesRuleList,
    List<CategoryItemUserModel>? favouriteSportRuleList,
    List<CategoryItemUserModel>? religionRuleList,
    AccountRule? accountRule,
  }) =>
      UserModel(
        id: id ?? this.id,
        accountId: accountId ?? this.accountId,
        creatorId: creatorId ?? this.creatorId,
        userName: username ?? this.userName,
        fullName: fullName ?? this.fullName,
        age: age ?? this.age,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        secondPhoneNumber: secondPhoneNumber ?? this.secondPhoneNumber,
        gender: gender ?? this.gender,
        genderType: genderType ?? this.genderType,
        createDatetime: createDatetime ?? this.createDatetime,
        isActive: isActive ?? this.isActive,
        nation: nation ?? this.nation,
        province: province ?? this.province,
        district: district ?? this.district,
        height: height ?? this.height,
        weight: weight ?? this.weight,
        ward: ward ?? this.ward,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        diabetesStatus: diabetesStatus ?? this.diabetesStatus,
        diabetesName: diabetesName ?? this.diabetesName,
        diabetesDate: diabetesDate ?? this.diabetesDate,
        imageUrl: imageUrl ?? this.imageUrl,
        code: code ?? this.code,
        email: email ?? this.email,
        address: address ?? this.address,
        goalWaist: goalWaist ?? this.goalWaist,
        goalWeight: goalWeight ?? this.goalWeight,
        energyGoal: energyGoal ?? this.energyGoal,
        isLinkedFacebook: isLinkedFacebook ?? this.isLinkedFacebook,
        isLinkedGoogle: isLinkedGoogle ?? this.isLinkedGoogle,
        isMobileAccount: isMobileAccount ?? this.isMobileAccount,
        firstLinkedAccount: firstLinkedAccount ?? this.firstLinkedAccount,
        googleEmail: googleEmail ?? this.googleEmail,
        glucoseUnit: glucoseUnit ?? this.glucoseUnit,
        activityLevelRate: activityLevelRate ?? this.activityLevelRate,
        roadMapId: roadMapId ?? this.roadMapId,
        hasBreakfastSnack: hasBreakfastSnack ?? this.hasBreakfastSnack,
        hasLunchSnack: hasLunchSnack ?? this.hasLunchSnack,
        hasDinnerSnack: hasDinnerSnack ?? this.hasDinnerSnack,
        diabetes: diabetes ?? this.diabetes,
        profession: profession ?? this.profession,
        educationLevel: educationLevel ?? this.educationLevel,
        personality: personality ?? this.personality,
        consciousnessPractice: consciousnessPractice ?? this.consciousnessPractice,
        religion: religion ?? this.religion,
        vegetarian: vegetarian ?? this.vegetarian,
        caredTopic: caredTopic ?? this.caredTopic,
        personalInterests: personalInterests ?? this.personalInterests,
        favouriteSports: favouriteSports ?? this.favouriteSports,
        workingHourss: workingHourss ?? this.workingHourss,
        jobList: jobList ?? this.jobList,
        educationLevelList: educationLevelList ?? this.educationLevelList,
        lessonTagList: lessonTagList ?? this.lessonTagList,
        personalityRuleList: personalityRuleList ?? this.personalityRuleList,
        interestRuleList: interestRuleList ?? this.interestRuleList,
        consciousnessPracticeRuleList: consciousnessPracticeRuleList ?? this.consciousnessPracticeRuleList,
        vegetarianRuleList: vegetarianRuleList ?? this.vegetarianRuleList,
        workingHourRuleList: workingHourRuleList ?? this.workingHourRuleList,
        levelOfDiabetesRuleList: levelOfDiabetesRuleList ?? this.levelOfDiabetesRuleList,
        favouriteSportRuleList: favouriteSportRuleList ?? this.favouriteSportRuleList,
        religionRuleList: religionRuleList ?? this.religionRuleList,
        accountRule: accountRule ?? this.accountRule,
      );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      accountId: json['accountId'],
      creatorId: json['creatorId'],
      userName: json['userName'],
      fullName: json['fullName'],
      age: json['age'],
      phoneNumber: json['phoneNumber'],
      secondPhoneNumber: json['secondPhoneNumber'],
      gender: json['gender'],
      genderType: json['genderType'],
      createDatetime: json['createDatetime'],
      isActive: json['isActive'],
      nation:
          json['nation'] == null ? null : (json['nation'] is String ? null : ProvinceModel.fromJson(json['nation'])),
      province: json['province'] == null
          ? null
          : (json['province'] is String ? null : ProvinceModel.fromJson(json['province'])),
      district: json['district'] == null
          ? null
          : (json['district'] is String ? null : ProvinceModel.fromJson(json['district'])),
      height: json['height'],
      weight: json['weight'],
      ward: json['ward'] == null ? null : (json['ward'] is String ? null : ProvinceModel.fromJson(json['ward'])),
      dateOfBirth: json['dateOfBirth'],
      diabetesStatus: json['diabetes'] == null ? null : json['diabetes']['status'],
      diabetesName: json['diabetes'] == null ? null : json['diabetes']['name'],
      diabetesDate: json['diabetes'] == null ? null : json['diabetes']['date'],
      imageUrl: json['imageUrl'] == null ? null : ImagesModel.fromJson(json['imageUrl']),
      code: json['code'],
      email: json['email'],
      address: json['address'],
      goalWaist: json['goalWaist'],
      goalWeight: json['goalWeight'],
      energyGoal: json['energyGoal'],
      isLinkedFacebook: json['isLinkedFacebook'],
      isLinkedGoogle: json['isLinkedGoogle'],
      isMobileAccount: json['isMobileAccount'],
      firstLinkedAccount: json['firstLinkedAccount'],
      googleEmail: json['googleEmail'],
      glucoseUnit: json['glucoseUnit'],
      activityLevelRate: json['activityLevelRate'],
      roadMapId: json['roadMapId'],
      hasBreakfastSnack: json['hasBreakfastSnack'],
      hasLunchSnack: json['hasLunchSnack'],
      hasDinnerSnack: json['hasDinnerSnack'],
      diabetes: json['diabetes'] == null ? null : DiabeteModel.fromJson(json['diabetes']),
      profession: json['profession'],
      educationLevel: json['educationLevel'],
      personality: json['personality'],
      consciousnessPractice: json['consciousnessPractice'],
      religion: json['religion'],
      vegetarian: json['vegetarian'],
      caredTopic: json['caredTopic'],
      personalInterests: json['personalInterests'],
      favouriteSports: json['favouriteSports'],
      workingHourss: json['workingHourss'],
      jobList: CategoryItemUserModel.toList(json['jobList']),
      educationLevelList: CategoryItemUserModel.toList(json['educationLevelList']),
      lessonTagList: CategoryItemUserModel.toList(json['lessonTagList']),
      interestRuleList: CategoryItemUserModel.toList(json['interestRuleList']),
      consciousnessPracticeRuleList: CategoryItemUserModel.toList(json['consciousnessPracticeRuleList']),
      vegetarianRuleList: CategoryItemUserModel.toList(json['vegetarianRuleList']),
      workingHourRuleList: CategoryItemUserModel.toList(json['workingHourRuleList']),
      levelOfDiabetesRuleList: CategoryItemUserModel.toList(json['levelOfDiabetesRuleList']),
      favouriteSportRuleList: CategoryItemUserModel.toList(json['favouriteSportRuleList']),
      religionRuleList: CategoryItemUserModel.toList(json['religionRuleList']),
      accountRule: json['accountRule'] == null ? null : AccountRule.fromJson(json['accountRule']),
      personalityRuleList: CategoryItemUserModel.toList(json['personalityRuleList']),
    );
  }

  static List<UserModel> toList(List<dynamic> items) {
    return items.map((item) => UserModel.fromJson(item)).toList();
  }
}

class ProvinceModel {
  final String? id;
  final String? name;

  ProvinceModel({
    required this.id,
    required this.name,
  });

  factory ProvinceModel.fromJson(Map<String, dynamic> json) {
    return ProvinceModel(
      id: json['id'],
      name: json['name'],
    );
  }

  static List<ProvinceModel> toList(List<dynamic> items) {
    return items.map((item) => ProvinceModel.fromJson(item)).toList();
  }
}

class InfoModel {
  final int? keyEnum;
  final String? keyGuid;
  final String? value;

  InfoModel({
    required this.keyEnum,
    required this.keyGuid,
    required this.value,
  });

  factory InfoModel.fromJson(Map<String, dynamic> json) {
    return InfoModel(
      keyEnum: json['keyEnum'],
      keyGuid: json['keyGuid'],
      value: json['value'],
    );
  }

  static List<InfoModel> toList(List<dynamic> items) {
    return items.map((item) => InfoModel.fromJson(item)).toList();
  }
}

class DiabeteModel {
  final int? status;
  final int? date;
  final String? name;

  DiabeteModel({
    required this.status,
    required this.date,
    required this.name,
  });

  factory DiabeteModel.fromJson(Map<String, dynamic> json) {
    return DiabeteModel(
      status: json['status'],
      date: json['date'],
      name: json['name'],
    );
  }

  static List<DiabeteModel> toList(List<dynamic> items) {
    return items.map((item) => DiabeteModel.fromJson(item)).toList();
  }
}
