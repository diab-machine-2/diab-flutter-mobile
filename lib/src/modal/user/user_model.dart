import 'package:medical/src/modal/base/images.dart';
import 'package:meta/meta.dart';

@immutable
class UserModel {
  final String? id;
  final String? username;
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
  final ProvinceModel? province;
  final ProvinceModel? district;
  final ProvinceModel? ward;
  final String? address;
  final double? goalWaist;
  final double? goalWeight;
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

  const UserModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.age,
    required this.phoneNumber,
    required this.secondPhoneNumber,
    required this.gender,
    required this.genderType,
    required this.createDatetime,
    required this.isActive,
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
  });

  UserModel copyWith(
          {String? id,
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
          ProvinceModel? province,
          ProvinceModel? district,
          ProvinceModel? ward,
          String? address,
          double? goalWaist,
          double? goalWeight,
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
          List<InfoModel>? workingHourss}) =>
      UserModel(
        id: id ?? this.id,
        username: username ?? this.username,
        fullName: fullName ?? this.fullName,
        age: age ?? this.age,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        secondPhoneNumber: secondPhoneNumber ?? this.secondPhoneNumber,
        gender: gender ?? this.gender,
        genderType: genderType ?? this.genderType,
        createDatetime: createDatetime ?? this.createDatetime,
        isActive: isActive ?? this.isActive,
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
      );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      fullName: json['fullName'],
      age: json['age'],
      phoneNumber: json['phoneNumber'],
      secondPhoneNumber: json['secondPhoneNumber'],
      gender: json['gender'],
      genderType: json['genderType'],
      createDatetime: json['createDatetime'],
      isActive: json['isActive'],
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
      diabetes: json['diabetes'],
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
