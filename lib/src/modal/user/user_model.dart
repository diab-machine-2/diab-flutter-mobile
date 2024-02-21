import 'package:medical/src/modal/base/images.dart';
import 'package:medical/src/modal/user/update_profile_request.dart';
import 'package:meta/meta.dart';

import '../../model/response/statistic_data.dart';
import '../../model/response/user_info_response.dart';
import 'category_item_user_model.dart';

@immutable
class UserModel {
  final String? id;
  final int? curentWeekPregnancy;
  final String? accountId;
  final String? creatorId;
  final String? userName;
  final String? fullName;
  final int? age;
  final PackageAccountModel? packageAccount;
  final String? packageName;
  final String? phoneNumber;
  final String? secondPhoneNumber;
  final String? gender;
  final int? genderType;
  final int? createDatetime;
  final bool? isActive;
  final String? email;
  final double? height;
  final double? weight;
  final double? weightPregnancy;
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
  final bool? checked;
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
  final List<TrainingGroupModel>? trainingGroups;

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

  final String? nameOfAgency;
  final String? nameOfDoctor;
  final UserInfoResponseDataOwnPackage? ownPackage;
  final bool? isShare;
  final String? shareRefCode;
  final StatisticData? statistict;
  final bool? sharedProfile;

  bool get isUserFree {
    return ownPackage == null;
  }

  bool get isUserSubcription {
    if (ownPackage != null) {
      if (ownPackage!.ownRoadmap == null) {
        return true;
      }
    }
    return false;
  }

  bool get isUserHasRoadmap {
    if (ownPackage != null) {
      if (ownPackage!.ownRoadmap != null) {
        return true;
      }
    }
    return false;
  }

  PackageType get packageType {
    if (this.ownPackage == null) return PackageType.free;
    if (this.ownPackage?.ownRoadmap == null) return PackageType.no_road_map;
    return PackageType.has_road_map;
  }

  const UserModel({
    required this.id,
    required this.accountId,
    required this.curentWeekPregnancy,
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
    required this.packageAccount,
    required this.packageName,
    required this.trainingGroups,
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
    required this.weightPregnancy,
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
    required this.nameOfAgency,
    required this.nameOfDoctor,
    required this.ownPackage,
    required this.isShare,
    required this.shareRefCode,
    required this.statistict,
    required this.sharedProfile,
    required this.checked,
  });

  UserModel copyWith({
    int? curentWeekPregnancy,
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
    String? package,
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
    PackageAccountModel? packageAccount,
    String? packageName,
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
    List<TrainingGroupModel>? trainingGroups,
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
    String? nameOfAgency,
    String? nameOfDoctor,
    UserInfoResponseDataOwnPackage? ownPackage,
    bool? isShare,
    String? shareRefCode,
    StatisticData? statistict,
    bool? sharedProfile,
    bool? Checked,
  }) =>
      UserModel(
        id: id ?? this.id,
        curentWeekPregnancy: curentWeekPregnancy ?? this.curentWeekPregnancy,
        accountId: accountId ?? this.accountId,
        creatorId: creatorId ?? this.creatorId,
        userName: username ?? this.userName,
        fullName: fullName ?? this.fullName,
        age: age ?? this.age,
        packageAccount: packageAccount ?? this.packageAccount,
        packageName: packageName ?? this.packageName,
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
        weightPregnancy: weightPregnancy ?? this.weightPregnancy,
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
        consciousnessPractice:
            consciousnessPractice ?? this.consciousnessPractice,
        religion: religion ?? this.religion,
        vegetarian: vegetarian ?? this.vegetarian,
        caredTopic: caredTopic ?? this.caredTopic,
        personalInterests: personalInterests ?? this.personalInterests,
        favouriteSports: favouriteSports ?? this.favouriteSports,
        workingHourss: workingHourss ?? this.workingHourss,
        trainingGroups: trainingGroups ?? this.trainingGroups,
        jobList: jobList ?? this.jobList,
        educationLevelList: educationLevelList ?? this.educationLevelList,
        lessonTagList: lessonTagList ?? this.lessonTagList,
        personalityRuleList: personalityRuleList ?? this.personalityRuleList,
        interestRuleList: interestRuleList ?? this.interestRuleList,
        consciousnessPracticeRuleList:
            consciousnessPracticeRuleList ?? this.consciousnessPracticeRuleList,
        vegetarianRuleList: vegetarianRuleList ?? this.vegetarianRuleList,
        workingHourRuleList: workingHourRuleList ?? this.workingHourRuleList,
        levelOfDiabetesRuleList:
            levelOfDiabetesRuleList ?? this.levelOfDiabetesRuleList,
        favouriteSportRuleList:
            favouriteSportRuleList ?? this.favouriteSportRuleList,
        religionRuleList: religionRuleList ?? this.religionRuleList,
        accountRule: accountRule ?? this.accountRule,
        nameOfAgency: nameOfAgency ?? this.nameOfAgency,
        nameOfDoctor: nameOfDoctor ?? this.nameOfDoctor,
        ownPackage: ownPackage ?? this.ownPackage,
        isShare: isShare ?? this.isShare,
        shareRefCode: shareRefCode ?? this.shareRefCode,
        statistict: statistict ?? this.statistict,
        sharedProfile: sharedProfile ?? this.sharedProfile,
        checked: Checked ?? this.checked,
      );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      curentWeekPregnancy: json['curentWeekPregnancy'],
      accountId: json['accountId'],
      creatorId: json['creatorId'],
      userName: json['userName'],
      packageAccount: json['packageAccount'] == null
          ? null
          : PackageAccountModel.fromJson(json['packageAccount']),
      packageName: json['packageName'],
      fullName: json['fullName'],
      age: json['age'],
      phoneNumber: json['phoneNumber'],
      secondPhoneNumber: json['secondPhoneNumber'],
      gender: json['gender'],
      genderType: json['genderType'],
      createDatetime: json['createDatetime'],
      isActive: json['isActive'],
      nation: json['nation'] == null
          ? null
          : (json['nation'] is String
              ? null
              : ProvinceModel.fromJson(json['nation'])),
      province: json['province'] == null
          ? null
          : (json['province'] is String
              ? null
              : ProvinceModel.fromJson(json['province'])),
      district: json['district'] == null
          ? null
          : (json['district'] is String
              ? null
              : ProvinceModel.fromJson(json['district'])),
      height: json['height'],
      weight: json['weight'],
      weightPregnancy: json['weightPregnancy'],
      ward: json['ward'] == null
          ? null
          : (json['ward'] is String
              ? null
              : ProvinceModel.fromJson(json['ward'])),
      dateOfBirth: json['dateOfBirth'],
      diabetesStatus:
          json['diabetes'] == null ? null : json['diabetes']['status'],
      diabetesName: json['diabetes'] == null ? null : json['diabetes']['name'],
      diabetesDate: json['diabetes'] == null ? null : json['diabetes']['date'],
      imageUrl: json['imageUrl'] == null
          ? null
          : ImagesModel.fromJson(json['imageUrl']),
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
      diabetes: json['diabetes'] == null
          ? null
          : DiabeteModel.fromJson(json['diabetes']),
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
      trainingGroups: json['trainingGroups'] == null
          ? []
          : TrainingGroupModel.toList(json['trainingGroups']),
      educationLevelList:
          CategoryItemUserModel.toList(json['educationLevelList']),
      lessonTagList: CategoryItemUserModel.toList(json['lessonTagList']),
      interestRuleList: CategoryItemUserModel.toList(json['interestRuleList']),
      consciousnessPracticeRuleList:
          CategoryItemUserModel.toList(json['consciousnessPracticeRuleList']),
      vegetarianRuleList:
          CategoryItemUserModel.toList(json['vegetarianRuleList']),
      workingHourRuleList:
          CategoryItemUserModel.toList(json['workingHourRuleList']),
      levelOfDiabetesRuleList:
          CategoryItemUserModel.toList(json['levelOfDiabetesRuleList']),
      favouriteSportRuleList:
          CategoryItemUserModel.toList(json['favouriteSportRuleList']),
      religionRuleList: CategoryItemUserModel.toList(json['religionRuleList']),
      accountRule: json['accountRule'] == null
          ? null
          : AccountRule.fromJson(json['accountRule']),
      personalityRuleList:
          CategoryItemUserModel.toList(json['personalityRuleList']),
      nameOfAgency: json['nameOfAgency'],
      nameOfDoctor: json['nameOfDoctor'],
      ownPackage: json['ownPackage'] == null
          ? null
          : UserInfoResponseDataOwnPackage.fromJson(json['ownPackage']),
      isShare: json['isShare'],
      shareRefCode: json['shareRefCode'],
      sharedProfile: json['sharedProfile'],
      statistict: json['statistict'] == null
          ? null
          : StatisticData.fromJson(json['statistict']),
      checked: json['checked'],
    );
  }

  static List<UserModel> toList(List<dynamic> items) {
    return items.map((item) => UserModel.fromJson(item)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isShare'] = this.isShare;
    data['curentWeekPregnancy'] = this.curentWeekPregnancy;
    data['nameOfAgency'] = this.nameOfAgency;
    data['nameOfDoctor'] = this.nameOfDoctor;
    if (this.packageAccount != null) {
      data['packageAccount'] = this.packageAccount!.toJson();
    }

    if (this.caredTopic != null) {
      data['caredTopic'] = this.caredTopic!.map((v) => v.toJson()).toList();
    }
    if (this.personalInterests != null) {
      data['personalInterests'] =
          this.personalInterests!.map((v) => v.toJson()).toList();
    }
    if (this.favouriteSports != null) {
      data['favouriteSports'] =
          this.favouriteSports!.map((v) => v.toJson()).toList();
    }
    if (this.workingHourss != null) {
      data['workingHourss'] =
          this.workingHourss!.map((v) => v.toJson()).toList();
    }
    if (this.profession != null) {
      data['profession'] = this.profession!.toJson();
    }
    if (this.educationLevel != null) {
      data['educationLevel'] = this.educationLevel!.toJson();
    }
    if (this.personality != null) {
      data['personality'] = this.personality!.toJson();
    }
    if (this.consciousnessPractice != null) {
      data['consciousnessPractice'] = this.consciousnessPractice!.toJson();
    }
    if (this.religion != null) {
      data['religion'] = this.religion!.toJson();
    }
    if (this.vegetarian != null) {
      data['vegetarian'] = this.vegetarian!.toJson();
    }

    if (this.personalityRuleList != null) {
      data['personalityRuleList'] =
          this.personalityRuleList!.map((v) => v.toJson()).toList();
    }
    if (this.interestRuleList != null) {
      data['interestRuleList'] =
          this.interestRuleList!.map((v) => v.toJson()).toList();
    }
    if (this.consciousnessPracticeRuleList != null) {
      data['consciousnessPracticeRuleList'] =
          this.consciousnessPracticeRuleList!.map((v) => v.toJson()).toList();
    }
    if (this.vegetarianRuleList != null) {
      data['vegetarianRuleList'] =
          this.vegetarianRuleList!.map((v) => v.toJson()).toList();
    }
    if (this.workingHourRuleList != null) {
      data['workingHourRuleList'] =
          this.workingHourRuleList!.map((v) => v.toJson()).toList();
    }
    if (this.favouriteSportRuleList != null) {
      data['favouriteSportRuleList'] =
          this.favouriteSportRuleList!.map((v) => v.toJson()).toList();
    }
    if (this.religionRuleList != null) {
      data['religionRuleList'] =
          this.religionRuleList!.map((v) => v.toJson()).toList();
    }
    if (this.jobList != null) {
      data['jobList'] = this.jobList!.map((v) => v.toJson()).toList();
    }
    if (this.educationLevelList != null) {
      data['educationLevelList'] =
          this.educationLevelList!.map((v) => v.toJson()).toList();
    }
    if (this.lessonTagList != null) {
      data['lessonTagList'] =
          this.lessonTagList!.map((v) => v.toJson()).toList();
    }
    if (this.accountRule != null) {
      data['accountRule'] = this.accountRule!.toJson();
    }
    if (this.trainingGroups != null) {
      data['trainingGroups'] =
          this.trainingGroups!.map((v) => v.toJson()).toList();
    }
    if (this.statistict != null) {
      data['statistict'] = this.statistict!.toJson();
    }
    data['id'] = this.id;
    data['accountId'] = this.accountId;
    data['code'] = this.code;
    data['userName'] = this.userName;
    data['age'] = this.age;
    data['dateOfBirth'] = this.dateOfBirth;
    data['genderType'] = this.genderType;
    data['gender'] = this.gender;
    data['creatorId'] = this.creatorId;
    data['createDatetime'] = this.createDatetime;
    data['fullName'] = this.fullName;
    data['phoneNumber'] = this.phoneNumber;
    data['secondPhoneNumber'] = this.secondPhoneNumber;
    data['email'] = this.email;
    if (this.nation != null) {
      data['nation'] = this.nation!.toJson();
    }
    if (this.province != null) {
      data['province'] = this.province!.toJson();
    }
    if (this.district != null) {
      data['district'] = this.district!.toJson();
    }
    if (this.ward != null) {
      data['ward'] = this.ward!.toJson();
    }
    data['address'] = this.address;
    if (this.diabetes != null) {
      data['diabetes'] = this.diabetes!.toJson();
    }
    data['height'] = this.height;
    data['weight'] = this.weight;
    data['weightPregnancy'] = this.weightPregnancy;
    data['goalWaist'] = this.goalWaist;
    data['goalWeight'] = this.goalWeight;
    data['energyGoal'] = this.energyGoal;
    data['activityLevelRate'] = this.activityLevelRate;
    data['isLinkedFacebook'] = this.isLinkedFacebook;
    data['isLinkedGoogle'] = this.isLinkedGoogle;
    data['isMobileAccount'] = this.isMobileAccount;
    data['firstLinkedAccount'] = this.firstLinkedAccount;
    if (this.imageUrl != null) {
      data['imageUrl'] = this.imageUrl!.toJson();
    }
    data['glucoseUnit'] = this.glucoseUnit;
    data['hasBreakfastSnack'] = this.hasBreakfastSnack;
    data['hasLunchSnack'] = this.hasLunchSnack;
    data['hasDinnerSnack'] = this.hasDinnerSnack;
    data['roadMapId'] = this.roadMapId;
    data['googleEmail'] = this.googleEmail;
    data['packageName'] = this.packageName;
    if (this.ownPackage != null) {
      data['ownPackage'] = this.ownPackage!.toJson();
    }
    data['sharedProfile'] = this.sharedProfile;
    if (this.levelOfDiabetesRuleList != null) {
      data['levelOfDiabetesRuleList'] =
          this.levelOfDiabetesRuleList!.map((v) => v.toJson()).toList();
    }
    data['checked'] = this.checked;

    return data;
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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['keyEnum'] = this.keyEnum;
    data['keyGuid'] = this.keyGuid;
    data['value'] = this.value;
    return data;
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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['date'] = this.date;
    data['name'] = this.name;
    return data;
  }
}

class TrainingGroupModel {
  final String? trainingGroupId;
  final String? patientId;
  final String? id;
  final String? coachPhoneNumber;
  final String? zaloUrl;
  final String? nameTrainingGroup;
  final TrainingGroup? trainingGroup;
  final String? accountId;

  TrainingGroupModel({
    required this.trainingGroupId,
    required this.patientId,
    required this.trainingGroup,
    required this.nameTrainingGroup,
    required this.id,
    required this.coachPhoneNumber,
    required this.zaloUrl,
    required this.accountId,
  });

  factory TrainingGroupModel.fromJson(Map<String, dynamic> json) {
    return TrainingGroupModel(
      trainingGroupId: json['trainingGroupId'],
      patientId: json['patientId'],
      id: json['id'],
      coachPhoneNumber: json['coachPhoneNumber'],
      nameTrainingGroup: json['nameTrainingGroup'],
      zaloUrl: json['zaloUrl'],
      accountId: json['accountId'],
      trainingGroup: json['trainingGroup'] == null
          ? null
          : TrainingGroup.fromJson(json['trainingGroup']),
    );
  }

  static List<TrainingGroupModel> toList(List<dynamic> items) {
    return items.map((item) => TrainingGroupModel.fromJson(item)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['trainingGroupId'] = this.trainingGroupId;
    data['accountId'] = this.accountId;
    data['nameTrainingGroup'] = this.nameTrainingGroup;
    data['zaloUrl'] = this.zaloUrl;
    data['coachPhoneNumber'] = this.coachPhoneNumber;
    return data;
  }
}

class TrainingGroup {
  final String? name;
  final String? description;
  final int? status;
  final String? accountId;
  final String? coverId;
  final String? linkZalo;
  final int? maxMember;
  final AccountCoach? account;

  TrainingGroup({
    required this.name,
    required this.description,
    required this.status,
    required this.accountId,
    required this.coverId,
    required this.linkZalo,
    required this.maxMember,
    required this.account,
  });

  factory TrainingGroup.fromJson(Map<String, dynamic> json) {
    return TrainingGroup(
      name: json['name'],
      description: json['description'],
      status: json['status'],
      accountId: json['accountId'],
      coverId: json['coverId'],
      linkZalo: json['linkZalo'],
      maxMember: json['maxMember'],
      account: json['account'] == null
          ? null
          : AccountCoach.fromJson(json['account']),
    );
  }

  static List<TrainingGroup> toList(List<dynamic> items) {
    return items.map((item) => TrainingGroup.fromJson(item)).toList();
  }
}

class AccountCoach {
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? fullNameSearch;
  final String? phoneNumber;
  final String? secondPhoneNumber;

  AccountCoach({
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.fullNameSearch,
    required this.phoneNumber,
    required this.secondPhoneNumber,
  });

  factory AccountCoach.fromJson(Map<String, dynamic> json) {
    return AccountCoach(
      username: json['username'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      fullNameSearch: json['lastName'],
      phoneNumber: json['phoneNumber'],
      secondPhoneNumber: json['secondPhoneNumber'],
    );
  }

  static List<AccountCoach> toList(List<dynamic> items) {
    return items.map((item) => AccountCoach.fromJson(item)).toList();
  }
}
