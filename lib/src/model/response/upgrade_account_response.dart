import 'meta.dart';

/// meta : {"success":true}
/// data : [{"id":"6b9771f8-81da-4b03-818e-f033033d236d","code":"1","name":"Nhật ký chỉ số sinh học","description":"Nhật ký chỉ số sinh học","toggleStatus":{"isEnableBasic":true,"isEnablePro":true,"isEnablePremium":true}},{"id":"556bae62-1f99-4cfc-af74-1826108ad86f","code":"2","name":"Thiết lập mục tiêu","description":"Thiết lập mục tiêu","toggleStatus":{"isEnableBasic":true,"isEnablePro":true,"isEnablePremium":true}},{"id":"41534cea-1dd3-4d3f-87e7-e4516e0f10a9","code":"3","name":"Bài học cơ bản","description":"Bài học cơ bản","toggleStatus":{"isEnableBasic":true,"isEnablePro":true,"isEnablePremium":true}},{"id":"ad42e6a0-dfd8-4698-a90d-154073dc5ba0","code":"4","name":"Đánh giá lối sống tổng quan","description":"Đánh giá lối sống tổng quan","toggleStatus":{"isEnableBasic":false,"isEnablePro":true,"isEnablePremium":true}},{"id":"2df05c5f-0521-4fd1-8751-a9dc89356f99","code":"5","name":"Tư vấn xây dựng & hoàn thành mục tiêu","description":"Tư vấn xây dựng & hoàn thành mục tiêu","toggleStatus":{"isEnableBasic":false,"isEnablePro":true,"isEnablePremium":true}},{"id":"0dd22b60-733c-47bf-a8e9-6651f423b485","code":"6","name":"Đánh giá lối sống toàn diện","description":"Đánh giá lối sống toàn diện","toggleStatus":{"isEnableBasic":false,"isEnablePro":true,"isEnablePremium":true}},{"id":"7f1cd0e3-4fc4-4ffb-8d6a-4d48a0e68f69","code":"7","name":"Cá nhân hoá bài học chuyên sâu","description":"Cá nhân hoá bài học chuyên sâu","toggleStatus":{"isEnableBasic":false,"isEnablePro":true,"isEnablePremium":true}},{"id":"75f765f6-9971-4f39-ac91-3e88f3899801","code":"8","name":"Coaching 1:1","description":"Coaching 1:1","toggleStatus":{"isEnableBasic":false,"isEnablePro":false,"isEnablePremium":true}}]

class UpgradeAccountResponse {
  UpgradeAccountResponse({
      Meta? meta, 
      List<UpgradeAccountData>? data,}){
    _meta = meta;
    _data = data;
}

  UpgradeAccountResponse.fromJson(dynamic json) {
    _meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(UpgradeAccountData.fromJson(v));
      });
    }
  }
  Meta? _meta;
  List<UpgradeAccountData>? _data;

  Meta? get meta => _meta;
  List<UpgradeAccountData>? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_meta != null) {
      map['meta'] = _meta?.toJson();
    }
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// id : "6b9771f8-81da-4b03-818e-f033033d236d"
/// code : "1"
/// name : "Nhật ký chỉ số sinh học"
/// description : "Nhật ký chỉ số sinh học"
/// toggleStatus : {"isEnableBasic":true,"isEnablePro":true,"isEnablePremium":true}

class UpgradeAccountData {
  UpgradeAccountData({
      String? id, 
      String? code, 
      String? name, 
      String? description, 
      ToggleStatus? toggleStatus,}){
    _id = id;
    _code = code;
    _name = name;
    _description = description;
    _toggleStatus = toggleStatus;
}

  UpgradeAccountData.fromJson(dynamic json) {
    _id = json['id'];
    _code = json['code'];
    _name = json['name'];
    _description = json['description'];
    _toggleStatus = json['toggleStatus'] != null ? ToggleStatus.fromJson(json['toggleStatus']) : null;
  }
  String? _id;
  String? _code;
  String? _name;
  String? _description;
  ToggleStatus? _toggleStatus;

  String? get id => _id;
  String? get code => _code;
  String? get name => _name;
  String? get description => _description;
  ToggleStatus? get toggleStatus => _toggleStatus;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['code'] = _code;
    map['name'] = _name;
    map['description'] = _description;
    if (_toggleStatus != null) {
      map['toggleStatus'] = _toggleStatus?.toJson();
    }
    return map;
  }

}

/// isEnableBasic : true
/// isEnablePro : true
/// isEnablePremium : true

class ToggleStatus {
  ToggleStatus({
      bool? isEnableBasic, 
      bool? isEnablePro, 
      bool? isEnablePremium,}){
    _isEnableBasic = isEnableBasic;
    _isEnablePro = isEnablePro;
    _isEnablePremium = isEnablePremium;
}

  ToggleStatus.fromJson(dynamic json) {
    _isEnableBasic = json['isEnableBasic'];
    _isEnablePro = json['isEnablePro'];
    _isEnablePremium = json['isEnablePremium'];
  }
  bool? _isEnableBasic;
  bool? _isEnablePro;
  bool? _isEnablePremium;

  bool? get isEnableBasic => _isEnableBasic;
  bool? get isEnablePro => _isEnablePro;
  bool? get isEnablePremium => _isEnablePremium;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['isEnableBasic'] = _isEnableBasic;
    map['isEnablePro'] = _isEnablePro;
    map['isEnablePremium'] = _isEnablePremium;
    return map;
  }

}