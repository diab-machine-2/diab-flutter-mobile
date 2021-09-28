import 'meta.dart';

/// meta : {"success":true,"total":1,"pageCount":1,"page":1,"size":10,"canNext":false,"canPrev":false}
/// data : [{"id":"b4ee4752-789e-42aa-965f-2e3359f8328c","code":"premiumcode11057","accountId":"07b4370b-2118-4747-9c70-d84fb3edf18c","packageId":"1682e9d6-a23c-4aff-9003-d8ad98971def","packagePriceId":"277478ac-e93a-4545-964d-abe55ab0c039","packageName":"Gói diaB Pro","isPackageSuspended":"1","monthUsed":6,"totalPrice":600000,"startDate":"09/20/2021 17:54:56","endDate":"03/20/2022 17:54:56","isExpired":"Đang diễn ra"}]

class ListTransactionResponse {
  ListTransactionResponse({
    Meta? meta,
    List<TransactionData>? data,
  }) {
    _meta = meta;
    _data = data;
  }

  ListTransactionResponse.fromJson(dynamic json) {
    _meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(TransactionData.fromJson(v));
      });
    }
  }

  Meta? _meta;
  List<TransactionData>? _data;

  Meta? get meta => _meta;

  List<TransactionData>? get data => _data;

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

/// id : "b4ee4752-789e-42aa-965f-2e3359f8328c"
/// code : "premiumcode11057"
/// accountId : "07b4370b-2118-4747-9c70-d84fb3edf18c"
/// packageId : "1682e9d6-a23c-4aff-9003-d8ad98971def"
/// packagePriceId : "277478ac-e93a-4545-964d-abe55ab0c039"
/// packageName : "Gói diaB Pro"
/// isPackageSuspended : "1"
/// monthUsed : 6
/// totalPrice : 600000
/// startDate : "09/20/2021 17:54:56"
/// endDate : "03/20/2022 17:54:56"
/// isExpired : "Đang diễn ra"

class TransactionData {
  TransactionData({
    String? id,
    String? code,
    String? accountId,
    String? packageId,
    String? packagePriceId,
    String? packageName,
    String? packageCode,
    bool? isPackageSuspended,
    int? monthUsed,
    num? totalPrice,
    String? startDate,
    String? endDate,
    bool? isExpired,
  }) {
    _id = id;
    _code = code;
    _accountId = accountId;
    _packageId = packageId;
    _packagePriceId = packagePriceId;
    _packageName = packageName;
    _packageCode = packageCode;
    _isPackageSuspended = isPackageSuspended;
    _monthUsed = monthUsed;
    _totalPrice = totalPrice;
    _startDate = startDate;
    _endDate = endDate;
    _isExpired = isExpired;
  }

  TransactionData.fromJson(dynamic json) {
    _id = json['id'];
    _code = json['code'];
    _accountId = json['accountId'];
    _packageId = json['packageId'];
    _packagePriceId = json['packagePriceId'];
    _packageName = json['packageName'];
    _packageCode = json['packageCode'];
    _isPackageSuspended = json['isPackageSuspended'];
    _monthUsed = json['monthUsed'];
    _totalPrice = json['totalPrice'];
    _startDate = json['startDate'];
    _endDate = json['endDate'];
    _isExpired = json['isExpired'];
  }

  String? _id;
  String? _code;
  String? _accountId;
  String? _packageId;
  String? _packagePriceId;
  String? _packageName;
  String? _packageCode;
  bool? _isPackageSuspended;
  int? _monthUsed;
  num? _totalPrice;
  String? _startDate;
  String? _endDate;
  bool? _isExpired;

  String? get id => _id;

  String? get code => _code;

  String? get accountId => _accountId;

  String? get packageId => _packageId;

  String? get packagePriceId => _packagePriceId;

  String? get packageName => _packageName;

  String? get packageCode => _packageCode;

  bool? get isPackageSuspended => _isPackageSuspended;

  int? get monthUsed => _monthUsed;

  num? get totalPrice => _totalPrice;

  String? get startDate => _startDate;

  String? get endDate => _endDate;

  bool? get isExpired => _isExpired;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['code'] = _code;
    map['accountId'] = _accountId;
    map['packageId'] = _packageId;
    map['packagePriceId'] = _packagePriceId;
    map['packageName'] = _packageName;
    map['packageCode'] = _packageCode;
    map['isPackageSuspended'] = _isPackageSuspended;
    map['monthUsed'] = _monthUsed;
    map['totalPrice'] = _totalPrice;
    map['startDate'] = _startDate;
    map['endDate'] = _endDate;
    map['isExpired'] = _isExpired;
    return map;
  }
}
