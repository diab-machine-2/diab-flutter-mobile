/// id : "3fa85f64-5717-4562-b3fc-2c963f66afa6"
/// code : "string"
/// name : "string"
/// description : "string"
/// detail : "string"
/// price : 0
/// level : 0
/// coverId : "string"
/// coverPath : "string"
/// prices : [{"name":"string","monthUsed":0,"monthPrice":0,"totalPrice":0,"discount":"string","highlight":"string"}]
/// enableFeatures : [{"featureId":"3fa85f64-5717-4562-b3fc-2c963f66afa6","featureName":"string"}]
/// successStories : [{"avatarPath":"string","name":"string","job":"string","story":"string"}]

class DetailPackageData {
  DetailPackageData({
    String? id,
    String? code,
    String? name,
    String? description,
    String? detail,
    num? price,
    int? level,
    String? coverId,
    String? coverPath,
    List<Price>? prices,
    List<EnableFeature>? enableFeatures,
    List<SuccessStory>? successStories,}){
    _id = id;
    _code = code;
    _name = name;
    _description = description;
    _detail = detail;
    _price = price;
    _level = level;
    _coverId = coverId;
    _coverPath = coverPath;
    _prices = prices;
    _enableFeatures = enableFeatures;
    _successStories = successStories;
  }

  DetailPackageData.fromJson(dynamic json) {
    _id = json['id'];
    _code = json['code'];
    _name = json['name'];
    _description = json['description'];
    _detail = json['detail'];
    _price = json['price'];
    _level = json['level'];
    _coverId = json['coverId'];
    _coverPath = json['coverPath'];
    if (json['prices'] != null) {
      _prices = [];
      json['prices'].forEach((v) {
        _prices?.add(Price.fromJson(v));
      });
    }
    if (json['enableFeatures'] != null) {
      _enableFeatures = [];
      json['enableFeatures'].forEach((v) {
        _enableFeatures?.add(EnableFeature.fromJson(v));
      });
    }
    if (json['successStories'] != null) {
      _successStories = [];
      json['successStories'].forEach((v) {
        _successStories?.add(SuccessStory.fromJson(v));
      });
    }
  }
  String? _id;
  String? _code;
  String? _name;
  String? _description;
  String? _detail;
  num? _price;
  int? _level;
  String? _coverId;
  String? _coverPath;
  List<Price>? _prices;
  List<EnableFeature>? _enableFeatures;
  List<SuccessStory>? _successStories;

  String? get id => _id;
  String? get code => _code;
  String? get name => _name;
  String? get description => _description;
  String? get detail => _detail;
  num? get price => _price;
  int? get level => _level;
  String? get coverId => _coverId;
  String? get coverPath => _coverPath;
  List<Price>? get prices => _prices;
  List<EnableFeature>? get enableFeatures => _enableFeatures;
  List<SuccessStory>? get successStories => _successStories;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['code'] = _code;
    map['name'] = _name;
    map['description'] = _description;
    map['detail'] = _detail;
    map['price'] = _price;
    map['level'] = _level;
    map['coverId'] = _coverId;
    map['coverPath'] = _coverPath;
    if (_prices != null) {
      map['prices'] = _prices?.map((v) => v.toJson()).toList();
    }
    if (_enableFeatures != null) {
      map['enableFeatures'] = _enableFeatures?.map((v) => v.toJson()).toList();
    }
    if (_successStories != null) {
      map['successStories'] = _successStories?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// avatarPath : "string"
/// name : "string"
/// job : "string"
/// story : "string"

class SuccessStory {
  SuccessStory({
    String? avatarPath,
    String? name,
    String? job,
    String? story,}){
    _avatarPath = avatarPath;
    _name = name;
    _job = job;
    _story = story;
  }

  SuccessStory.fromJson(dynamic json) {
    _avatarPath = json['avatarPath'];
    _name = json['name'];
    _job = json['job'];
    _story = json['story'];
  }
  String? _avatarPath;
  String? _name;
  String? _job;
  String? _story;

  String? get avatarPath => _avatarPath;
  String? get name => _name;
  String? get job => _job;
  String? get story => _story;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['avatarPath'] = _avatarPath;
    map['name'] = _name;
    map['job'] = _job;
    map['story'] = _story;
    return map;
  }

}

/// featureId : "3fa85f64-5717-4562-b3fc-2c963f66afa6"
/// featureName : "string"

class EnableFeature {
  EnableFeature({
    String? featureId,
    String? featureName,}){
    _featureId = featureId;
    _featureName = featureName;
  }

  EnableFeature.fromJson(dynamic json) {
    _featureId = json['featureId'];
    _featureName = json['featureName'];
  }
  String? _featureId;
  String? _featureName;

  String? get featureId => _featureId;
  String? get featureName => _featureName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['featureId'] = _featureId;
    map['featureName'] = _featureName;
    return map;
  }

}

/// name : "string"
/// monthUsed : 0
/// monthPrice : 0
/// totalPrice : 0
/// discount : "string"
/// highlight : "string"

class Price {
  Price({
    String? name,
    int? monthUsed,
    num? monthPrice,
    num? totalPrice,
    String? discount,
    String? highlight,}){
    _name = name;
    _monthUsed = monthUsed;
    _monthPrice = monthPrice;
    _totalPrice = totalPrice;
    _discount = discount;
    _highlight = highlight;
  }

  Price.fromJson(dynamic json) {
    _name = json['name'];
    _monthUsed = json['monthUsed'];
    _monthPrice = json['monthPrice'];
    _totalPrice = json['totalPrice'];
    _discount = json['discount'];
    _highlight = json['highlight'];
  }
  String? _name;
  int? _monthUsed;
  num? _monthPrice;
  num? _totalPrice;
  String? _discount;
  String? _highlight;

  String? get name => _name;
  int? get monthUsed => _monthUsed;
  num? get monthPrice => _monthPrice;
  num? get totalPrice => _totalPrice;
  String? get discount => _discount;
  String? get highlight => _highlight;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = _name;
    map['monthUsed'] = _monthUsed;
    map['monthPrice'] = _monthPrice;
    map['totalPrice'] = _totalPrice;
    map['discount'] = _discount;
    map['highlight'] = _highlight;
    return map;
  }

}