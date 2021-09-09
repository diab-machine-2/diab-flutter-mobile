import 'package:medical/modal/base/images.dart';
import 'package:meta/meta.dart';

class UserModel {
  final String id;
  final String username;
  final String fullName;
  final int age;
  final String phoneNumber;
  final String secondPhoneNumber;
  final String gender;
  final int genderType;
  final int createDatetime;
  final bool isActive;
  final String email;
  final double height;
  final double weight;
  final int dateOfBirth;
  final int diabetesStatus;
  final String diabetesName;
  final int diabetesDate;
  final ImagesModel imageUrl;
  final String code;
  final ProvinceModel province;
  final ProvinceModel district;
  final ProvinceModel ward;
  final String address;
  final double goalWaist;
  final double goalWeight;
  final bool isLinkedFacebook;
  final bool isLinkedGoogle;
  final bool isMobileAccount;
  final String firstLinkedAccount;
  final int glucoseUnit;

  UserModel(
      {@required this.id,
      @required this.username,
      @required this.fullName,
      @required this.age,
      @required this.phoneNumber,
      @required this.secondPhoneNumber,
      @required this.gender,
      @required this.genderType,
      @required this.createDatetime,
      @required this.isActive,
      @required this.province,
      @required this.district,
      @required this.height,
      @required this.weight,
      @required this.ward,
      @required this.dateOfBirth,
      @required this.diabetesStatus,
      @required this.diabetesName,
      @required this.diabetesDate,
      @required this.imageUrl,
      @required this.code,
      @required this.email,
      @required this.address,
      @required this.goalWaist,
      @required this.goalWeight,
      @required this.isLinkedFacebook,
      @required this.isLinkedGoogle,
      @required this.isMobileAccount,
      @required this.firstLinkedAccount,
      @required this.glucoseUnit});

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
        ward: json['ward'] == null
            ? null
            : (json['ward'] is String
                ? null
                : ProvinceModel.fromJson(json['ward'])),
        dateOfBirth: json['dateOfBirth'],
        diabetesStatus:
            json['diabetes'] == null ? null : json['diabetes']['status'],
        diabetesName:
            json['diabetes'] == null ? null : json['diabetes']['name'],
        diabetesDate:
            json['diabetes'] == null ? null : json['diabetes']['date'],
        imageUrl: json['imageUrl'] == null
            ? null
            : ImagesModel.fromJson(json['imageUrl']),
        code: json['code'],
        email: json['email'],
        address: json['address'],
        goalWaist: json['goalWaist'],
        goalWeight: json['goalWeight'],
        isLinkedFacebook: json['isLinkedFacebook'],
        isLinkedGoogle: json['isLinkedGoogle'],
        isMobileAccount: json['isMobileAccount'],
        firstLinkedAccount: json['firstLinkedAccount'],
        glucoseUnit: json['glucoseUnit']);
  }

  static List<UserModel> toList(List<dynamic> items) {
    return items.map((item) => UserModel.fromJson(item)).toList();
  }
}

class ProvinceModel {
  final String id;
  final String name;

  ProvinceModel({
    @required this.id,
    @required this.name,
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
