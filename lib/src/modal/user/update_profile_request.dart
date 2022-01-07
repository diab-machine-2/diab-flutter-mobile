import 'package:meta/meta.dart';

@immutable
class UpdateProfileRequest {
  final String? patientId;
  final AccountRule? accountRule;

  UpdateProfileRequest({required this.patientId, required this.accountRule});

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) {
    return UpdateProfileRequest(
      patientId: json['patientId'],
      accountRule: json['accountRule'] == null
          ? null
          : (json['accountRule'] is String ? null : AccountRule.fromJson(json['accountRule'])),
    );
  }

  // Map<String, dynamic> toJson() => _$UpdateProfileRequestToJson(this);

  // Map<String, dynamic> _$UpdateProfileRequestToJson(UpdateProfileRequest instance) => <String, dynamic>{
  //       'patientId': instance.patientId,
  //       'accountRule': instance.accountRule,
  //     };

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['patientId'] = patientId;
    if (accountRule != null) {
      map['accountRule'] = accountRule?.toJson();
    }
    return map;
  }

  static List<UpdateProfileRequest> toList(List<dynamic> items) {
    return items.map((item) => UpdateProfileRequest.fromJson(item)).toList();
  }
}

@immutable
class AccountRule {
  String? id;
  int? fromAge;
  int? toAge;
  int? amount;
  List<AccountRuleTypeMapping>? accountRuleTypeMappings;
  List<AccountRuleTagMapping>? accountRuleTagMappings;
  int? modelStatus;

  AccountRule({
    required this.id,
    required this.fromAge,
    required this.toAge,
    required this.amount,
    required this.accountRuleTypeMappings,
    required this.accountRuleTagMappings,
    required this.modelStatus,
  });

  factory AccountRule.fromJson(Map<String, dynamic> json) {
    return AccountRule(
      id: json['id'],
      fromAge: json['fromAge'],
      toAge: json['toAge'],
      amount: json['amount'],
      accountRuleTypeMappings: json['accountRuleTypeMappings'] == null
          ? null
          : AccountRuleTypeMapping.toList(json['accountRuleTypeMappings']),
      accountRuleTagMappings:
          json['accountRuleTagMappings'] == null ? null : AccountRuleTagMapping.toList(json['accountRuleTagMappings']),
      modelStatus: json['modelStatus'],
    );
  }

  // Map<String, dynamic> toJson() => _$AccountRuleToJson(this);

  // Map<String, dynamic> _$AccountRuleToJson(AccountRule instance) => <String, dynamic>{
  //       'id': instance.id,
  //       'fromAge': instance.fromAge,
  //       'toAge': instance.toAge,
  //       'amount': instance.amount,
  //       'accountRuleTypeMappings': instance.accountRuleTypeMappings,
  //       'accountRuleTagMappings': instance.accountRuleTagMappings,
  //       'modelStatus': instance.modelStatus,
  //     };

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['fromAge'] = fromAge;
    map['toAge'] = toAge;
    map['amount'] = amount;
    if (accountRuleTagMappings != null) {
      map['accountRuleTagMappings'] = accountRuleTagMappings?.map((e) => e.toJson()).toList();
    }
    map['modelStatus'] = modelStatus;
    if (accountRuleTypeMappings != null) {
      map['accountRuleTypeMappings'] = accountRuleTypeMappings?.map((e) => e.toJson()).toList();
    }
    return map;
  }

  static List<AccountRule> toList(List<dynamic> items) {
    return items.map((item) => AccountRule.fromJson(item)).toList();
  }
}

class AccountRuleTypeMapping {
  final String? id;
  final int? ruleType;
  final int? value;
  final String? accountRuleId;
  final int? modelStatus;

  AccountRuleTypeMapping({
    required this.id,
    required this.ruleType,
    required this.value,
    required this.accountRuleId,
    required this.modelStatus,
  });

  factory AccountRuleTypeMapping.fromJson(Map<String, dynamic> json) {
    return AccountRuleTypeMapping(
      id: json['id'],
      ruleType: json['ruleType'],
      value: json['value'],
      accountRuleId: json['accountRuleId'],
      modelStatus: json['modelStatus'],
    );
  }

  // Map<String, dynamic> toJson() => _$AccountRuleTypeMappingToJson(this);

  // Map<String, dynamic> _$AccountRuleTypeMappingToJson(AccountRuleTypeMapping instance) => <String, dynamic>{
  //       'id': instance.id,
  //       'ruleType': instance.ruleType,
  //       'value': instance.value,
  //       'accountRuleType': instance.accountRuleType,
  //       'modelStatus': instance.modelStatus,
  //     };

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['ruleType'] = ruleType;
    map['value'] = value;
    map['accountRuleId'] = accountRuleId;
    map['modelStatus'] = modelStatus;
    return map;
  }

  static List<AccountRuleTypeMapping> toList(List<dynamic> items) {
    return items.map((item) => AccountRuleTypeMapping.fromJson(item)).toList();
  }
}

class AccountRuleTagMapping {
  final String? tagId;
  final Tag? tag;
  final String? accountRuleId;
  final int? modelStatus;

  AccountRuleTagMapping({
    required this.tagId,
    required this.tag,
    required this.accountRuleId,
    required this.modelStatus,
  });

  factory AccountRuleTagMapping.fromJson(Map<String, dynamic> json) {
    return AccountRuleTagMapping(
      tagId: json['tagId'],
      tag: json['tag'] == null ? null : (json['tag'] is String ? null : Tag.fromJson(json['tag'])),
      accountRuleId: json['accountRuleId'],
      modelStatus: json['modelStatus'],
    );
  }

  // Map<String, dynamic> toJson() => _$AccountRuleTypeMappingToJson(this);

  // Map<String, dynamic> _$AccountRuleTypeMappingToJson(AccountRuleTypeMapping instance) => <String, dynamic>{
  //       'id': instance.id,
  //       'ruleType': instance.ruleType,
  //       'value': instance.value,
  //       'accountRuleType': instance.accountRuleType,
  //       'modelStatus': instance.modelStatus,
  //     };

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['tagId'] = tagId;
    if (tag != null) {
      map['tag'] = tag?.toJson();
    }
    map['accountRuleId'] = accountRuleId;
    map['modelStatus'] = modelStatus;
    return map;
  }

  static List<AccountRuleTagMapping> toList(List<dynamic> items) {
    return items.map((item) => AccountRuleTagMapping.fromJson(item)).toList();
  }
}

class Tag {
  final String? id;
  final String? name;
  final int? type;

  Tag({
    required this.id,
    required this.name,
    required this.type,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'],
      name: json['name'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['type'] = type;
    return map;
  }

  static List<Tag> toList(List<dynamic> items) {
    return items.map((item) => Tag.fromJson(item)).toList();
  }
}
