import 'package:medical/src/model/response/lesson_module_response.dart';

class QuestionModel {
  QuestionModel({
    this.id,
    this.status,
    this.originalStatus,
    this.body,
    this.createDateTime,
    this.creator,
    this.accountId,
    this.lessonModuleId,
    this.lessonModule,
    this.professor,
    this.answers,
    this.creatorId,
    this.creatorUrl,
  });

  String? id;
  int? status;
  int? originalStatus;
  String? body;
  int? createDateTime;
  String? creator;
  String? accountId;
  String? lessonModuleId;
  LessonModuleItem? lessonModule;
  Account? professor;
  List<Answer>? answers;
  String? creatorId;
  Avatar? creatorUrl;

  QuestionModel copyWith({
    String? id,
    int? status,
    int? originalStatus,
    String? body,
    int? createDateTime,
    String? creator,
    String? accountId,
    String? lessonModuleId,
    LessonModuleItem? lessonModule,
    Account? professor,
    List<Answer>? answers,
    String? creatorId,
    Avatar? creatorUrl,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      status: status ?? this.status,
      originalStatus: originalStatus ?? this.originalStatus,
      body: body ?? this.body,
      createDateTime: createDateTime ?? this.createDateTime,
      creator: creator ?? this.creator,
      accountId: accountId ?? this.accountId,
      lessonModule: lessonModule ?? this.lessonModule,
      lessonModuleId: lessonModuleId ?? this.lessonModuleId,
      professor: professor ?? this.professor,
      answers: answers ?? this.answers,
      creatorId: creatorId ?? this.creatorId,
      creatorUrl: creatorUrl ?? this.creatorUrl,
    );
  }


  factory QuestionModel.fromJson(Map<String, dynamic> json) => QuestionModel(
        id: json["id"],
        status: json["status"],
        originalStatus: json['status'],
        body: json["body"],
        createDateTime: json["createDateTime"],
        creator: json["creator"],
        accountId: json["accountId"],
        lessonModuleId: json["lessonModuleId"],
        lessonModule: json["lessonModule"] != null ? LessonModuleItem.fromJson(json["lessonModule"]) : null,
        creatorId: json["creatorId"],
        professor: json["professor"] != null ? Account.fromJson(json["professor"]) : null,
        creatorUrl: json["creatorUrl"] != null ? Avatar.fromJson(json["creatorUrl"]) : null,
        answers: json["answers"] == null ? [] : List<Answer>.from(json["answers"].map((x) => Answer.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
        "body": body,
        "createDateTime": createDateTime,
        "creator": creator,
        "accountId": accountId,
        "lessonModuleId": lessonModuleId,
        "creatorId": creatorId,
        "lessonModule": lessonModule == null ? null : lessonModule!.toJson(),
        "professor": professor == null ? null : professor!.toJson(),
        "creatorUrl": creatorUrl == null ? null : creatorUrl!.toJson(),
        "answers": answers == null ? null : List<dynamic>.from(answers!.map((x) => x.toJson())),
      };
}

class Answer {
  Answer({
    this.id,
    this.body,
    this.createDateTime,
    this.account,
    this.questionId,
    this.accountId,
  });

  String? id;
  String? body;
  int? createDateTime;
  Account? account;
  String? questionId;
  String? accountId;

  factory Answer.fromJson(Map<String, dynamic> json) => Answer(
        id: json["id"],
        body: json["body"],
        createDateTime: json["createDateTime"],
        account: json["account"] != null ? Account.fromJson(json["account"]) : null,
        questionId: json["questionId"],
        accountId: json["accountId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "body": body,
        "createDateTime": createDateTime,
        "account": account == null ? null : account!.toJson(),
        "questionId": questionId,
        "accountId": accountId,
      };
}

class Account {
  Account({
    this.id,
    this.patientId,
    this.username,
    this.fullName,
    this.age,
    this.phoneNumber,
    this.secondPhoneNumber,
    this.gender,
    this.createDatetime,
    this.active,
    this.nation,
    this.province,
    this.district,
    this.ward,
    this.weight,
    this.height,
    this.coverId,
    this.code,
    this.email,
    this.dateOfBirth,
    this.address,
    this.education,
    this.level,
    this.typeOfWork,
    this.firstLogin,
    this.accountRoles,
    this.accountRule,
    this.accountPositionMappings,
    this.roles,
    this.avatar,
  });

  String? id;
  String? patientId;
  String? username;
  String? fullName;
  int? age;
  String? phoneNumber;
  String? secondPhoneNumber;
  int? gender;
  int? createDatetime;
  bool? active;
  String? nation;
  String? province;
  String? district;
  String? ward;
  double? weight;
  double? height;
  String? coverId;
  String? code;
  String? email;
  String? dateOfBirth;
  String? address;
  String? education;
  int? level;
  int? typeOfWork;
  bool? firstLogin;
  List<AccountRole>? accountRoles;
  AccountRule? accountRule;
  List<AccountPositionMapping>? accountPositionMappings;
  List<String>? roles;
  Avatar? avatar;

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        id: json["id"],
        patientId: json["patientId"],
        username: json["username"],
        fullName: json["fullName"],
        age: json["age"],
        phoneNumber: json["phoneNumber"],
        secondPhoneNumber: json["secondPhoneNumber"],
        gender: json["gender"],
        createDatetime: json["createDatetime"],
        active: json["active"],
        nation: json["nation"],
        province: json["province"],
        district: json["district"],
        ward: json["ward"],
        weight: json["weight"],
        height: json["height"],
        coverId: json["coverId"],
        code: json["code"],
        email: json["email"],
        dateOfBirth: json["dateOfBirth"],
        address: json["address"],
        education: json["education"],
        level: json["level"],
        typeOfWork: json["typeOfWork"],
        firstLogin: json["firstLogin"],
        accountRoles: json["accountRoles"] == null
            ? null
            : List<AccountRole>.from(json["accountRoles"].map((x) => AccountRole.fromJson(x))),
        accountRule: json["accountRule"] == null ? null : AccountRule.fromJson(json["accountRule"]),
        accountPositionMappings: json["accountPositionMappings"] == null
            ? null
            : List<AccountPositionMapping>.from(
                json["accountPositionMappings"].map((x) => AccountPositionMapping.fromJson(x))),
        roles: json["roles"] == null ? null : List<String>.from(json["roles"].map((x) => x)),
        avatar: json["avatar"] == null ? null : Avatar.fromJson(json["avatar"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "patientId": patientId,
        "username": username,
        "fullName": fullName,
        "age": age,
        "phoneNumber": phoneNumber,
        "secondPhoneNumber": secondPhoneNumber,
        "gender": gender,
        "createDatetime": createDatetime,
        "active": active,
        "nation": nation,
        "province": province,
        "district": district,
        "ward": ward,
        "weight": weight,
        "height": height,
        "coverId": coverId,
        "code": code,
        "email": email,
        "dateOfBirth": dateOfBirth,
        "address": address,
        "education": education,
        "level": level,
        "typeOfWork": typeOfWork,
        "firstLogin": firstLogin,
        "accountRoles": accountRoles == null ? null : List<dynamic>.from(accountRoles!.map((x) => x.toJson())),
        "accountRule": accountRule == null ? null : accountRule!.toJson(),
        "accountPositionMappings": accountPositionMappings == null
            ? null
            : List<dynamic>.from(accountPositionMappings!.map((x) => x.toJson())),
        "roles": roles == null ? null : List<String>.from(roles!.map((x) => x)),
        "avatar": avatar == null ? null : avatar!.toJson(),
      };
}

class AccountPositionMapping {
  AccountPositionMapping({
    this.id,
    this.accountId,
    this.positionId,
    this.position,
  });

  String? id;
  String? accountId;
  String? positionId;
  Position? position;

  factory AccountPositionMapping.fromJson(Map<String, dynamic> json) => AccountPositionMapping(
        id: json["id"],
        accountId: json["accountId"],
        positionId: json["positionId"],
        position: json["position"] == null ? null : Position.fromJson(json["position"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "accountId": accountId,
        "positionId": positionId,
        "position": position == null ? null : position!.toJson(),
      };
}

class Position {
  Position({
    this.id,
    this.code,
    this.name,
  });

  String? id;
  String? code;
  String? name;

  factory Position.fromJson(Map<String, dynamic> json) => Position(
        id: json["id"],
        code: json["code"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "code": code,
        "name": name,
      };
}

class AccountRole {
  AccountRole({
    this.accountId,
    this.roleId,
    this.role,
    this.modelStatus,
  });

  String? accountId;
  String? roleId;
  Role? role;
  int? modelStatus;

  factory AccountRole.fromJson(Map<String, dynamic> json) => AccountRole(
        accountId: json["accountId"],
        roleId: json["roleId"],
        role: json["role"] == null ? null : Role.fromJson(json["role"]),
        modelStatus: json["modelStatus"],
      );

  Map<String, dynamic> toJson() => {
        "accountId": accountId,
        "roleId": roleId,
        "role": role == null ? null : role!.toJson(),
        "modelStatus": modelStatus,
      };
}

class Role {
  Role({
    this.id,
    this.name,
    this.code,
    this.isSystem,
    this.accountRoles,
  });

  String? id;
  String? name;
  String? code;
  bool? isSystem;
  List<dynamic>? accountRoles;

  factory Role.fromJson(Map<String, dynamic> json) => Role(
        id: json["id"],
        name: json["name"],
        code: json["code"],
        isSystem: json["isSystem"],
        accountRoles: json["accountRoles"] == null ? null : List<dynamic>.from(json["accountRoles"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "code": code,
        "isSystem": isSystem,
        "accountRoles": accountRoles == null ? null : List<dynamic>.from(accountRoles!.map((x) => x)),
      };
}

class AccountRule {
  AccountRule({
    this.id,
    this.fromAge,
    this.toAge,
    this.amount,
    this.accountRuleTypeMappings,
    this.accountRuleTagMappings,
  });

  String? id;
  int? fromAge;
  int? toAge;
  double? amount;
  List<AccountRuleTypeMapping>? accountRuleTypeMappings;
  List<AccountRuleTagMapping>? accountRuleTagMappings;

  factory AccountRule.fromJson(Map<String, dynamic> json) => AccountRule(
        id: json["id"],
        fromAge: json["fromAge"],
        toAge: json["toAge"],
        amount: json["amount"],
        accountRuleTypeMappings: json["accountRuleTypeMappings"] == null
            ? null
            : List<AccountRuleTypeMapping>.from(
                json["accountRuleTypeMappings"].map((x) => AccountRuleTypeMapping.fromJson(x))),
        accountRuleTagMappings: json["accountRuleTagMappings"] == null
            ? null
            : List<AccountRuleTagMapping>.from(
                json["accountRuleTagMappings"].map((x) => AccountRuleTagMapping.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "fromAge": fromAge,
        "toAge": toAge,
        "amount": amount,
        "accountRuleTypeMappings": accountRuleTypeMappings == null
            ? null
            : List<dynamic>.from(accountRuleTypeMappings!.map((x) => x.toJson())),
        "accountRuleTagMappings":
            accountRuleTagMappings == null ? null : List<dynamic>.from(accountRuleTagMappings!.map((x) => x.toJson())),
      };
}

class AccountRuleTagMapping {
  AccountRuleTagMapping({
    this.id,
    this.code,
    this.accountRuleId,
    this.tagId,
    this.tag,
    this.modelStatus,
  });

  String? id;
  String? code;
  String? accountRuleId;
  String? tagId;
  Tag? tag;
  int? modelStatus;

  factory AccountRuleTagMapping.fromJson(Map<String, dynamic> json) => AccountRuleTagMapping(
        id: json["id"],
        code: json["code"],
        accountRuleId: json["accountRuleId"],
        tagId: json["tagId"],
        tag: json["tag"] == null ? null : Tag.fromJson(json["tag"]),
        modelStatus: json["modelStatus"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "code": code,
        "accountRuleId": accountRuleId,
        "tagId": tagId,
        "tag": tag == null ? null : tag!.toJson(),
        "modelStatus": modelStatus,
      };
}

class Tag {
  Tag({
    this.id,
    this.name,
    this.type,
  });

  String? id;
  String? name;
  int? type;

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
        id: json["id"],
        name: json["name"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "type": type,
      };
}

class AccountRuleTypeMapping {
  AccountRuleTypeMapping({
    this.id,
    this.ruleType,
    this.value,
    this.accountRuleId,
  });

  String? id;
  int? ruleType;
  double? value;
  String? accountRuleId;

  factory AccountRuleTypeMapping.fromJson(Map<String, dynamic> json) => AccountRuleTypeMapping(
        id: json["id"],
        ruleType: json["ruleType"],
        value: json["value"],
        accountRuleId: json["accountRuleId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "ruleType": ruleType,
        "value": value,
        "accountRuleId": accountRuleId,
      };
}

class Avatar {
  Avatar({
    this.id,
    this.url,
  });

  String? id;
  String? url;

  factory Avatar.fromJson(Map<String, dynamic> json) => Avatar(
        id: json["id"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "url": url,
      };
}
