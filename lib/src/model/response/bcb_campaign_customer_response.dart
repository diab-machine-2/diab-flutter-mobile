import 'meta.dart';

class BcbCampaignCustomerResponse {
  BcbCampaignCustomerResponse({Meta? meta, BcbCampaignCustomerData? data}) {
    _meta = meta;
    _data = data;
  }

  BcbCampaignCustomerResponse.fromJson(dynamic json) {
    _meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    _data = json['data'] != null
        ? BcbCampaignCustomerData.fromJson(json['data'])
        : null;
  }

  Meta? _meta;
  BcbCampaignCustomerData? _data;

  Meta? get meta => _meta;
  BcbCampaignCustomerData? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_meta != null) map['meta'] = _meta?.toJson();
    if (_data != null) map['data'] = _data?.toJson();
    return map;
  }
}

class BcbCampaignCustomerData {
  String? id;
  String? code;
  int? isDeleted;
  String? creatorId;
  String? updaterId;
  String? campaignId;
  String? campaignName;
  String? companyName;
  String? department;
  String? fullName;
  int? gender;
  int? dateOfBirth;
  String? phone;
  String? email;
  String? noteImport;
  int? status;
  String? accountId;
  int? createDatetime;

  BcbCampaignCustomerData({
    this.id,
    this.code,
    this.isDeleted,
    this.creatorId,
    this.updaterId,
    this.campaignId,
    this.campaignName,
    this.companyName,
    this.department,
    this.fullName,
    this.gender,
    this.dateOfBirth,
    this.phone,
    this.email,
    this.noteImport,
    this.status,
    this.accountId,
    this.createDatetime,
  });

  BcbCampaignCustomerData.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    code = json['code']?.toString();
    isDeleted = json['isDeleted'];
    creatorId = json['creatorId']?.toString();
    updaterId = json['updaterId']?.toString();
    campaignId = json['campaignId']?.toString();
    campaignName = json['campaignName']?.toString();
    companyName = json['companyName']?.toString();
    department = json['department']?.toString();
    fullName = json['fullName']?.toString();
    gender = json['gender'];
    dateOfBirth = json['dateOfBirth'];
    phone = json['phone']?.toString();
    email = json['email']?.toString();
    noteImport = json['noteImport']?.toString();
    status = json['status'];
    accountId = json['accountId']?.toString();
    createDatetime = json['createDatetime'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
    data['isDeleted'] = isDeleted;
    data['creatorId'] = creatorId;
    data['updaterId'] = updaterId;
    data['campaignId'] = campaignId;
    data['campaignName'] = campaignName;
    data['companyName'] = companyName;
    data['department'] = department;
    data['fullName'] = fullName;
    data['gender'] = gender;
    data['dateOfBirth'] = dateOfBirth;
    data['phone'] = phone;
    data['email'] = email;
    data['noteImport'] = noteImport;
    data['status'] = status;
    data['accountId'] = accountId;
    data['createDatetime'] = createDatetime;
    return data;
  }
}
