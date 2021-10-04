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
    String? advantageHighlight,
    num? price,
    int? level,
    String? coverId,
    ImageData? image,
    List<Price>? prices,
    List<EnableFeature>? enableFeatures,
    List<SuccessStory>? successStories,
    List<CourseSection>? courseSections,
    List<PackageAdvantage>? packageAdvantages,
    List<FeaturesComparisonTable>? featuresComparisonTable,}){
    _id = id;
    _code = code;
    _name = name;
    _description = description;
    _detail = detail;
    _advantageHighlight = advantageHighlight;
    _price = price;
    _level = level;
    _coverId = coverId;
    _image = image;
    _prices = prices;
    _enableFeatures = enableFeatures;
    _successStories = successStories;
    _courseSections = courseSections;
    _packageAdvantages = packageAdvantages;
    _featuresComparisonTable = featuresComparisonTable;
  }

  DetailPackageData.fromJson(dynamic json) {
    _id = json['id'];
    _code = json['code'];
    _name = json['name'];
    _description = json['description'];
    _detail = json['detail'];
    _advantageHighlight = json['advantageHighlight'];
    _price = json['price'];
    _level = json['level'];
    _coverId = json['coverId'];
    _image = json['image'] != null ? ImageData.fromJson(json['image']) : null;
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
    if (json['courseSections'] != null) {
      _courseSections = [];
      json['courseSections'].forEach((v) {
        _courseSections?.add(CourseSection.fromJson(v));
      });
    }
    if (json['packageAdvantages'] != null) {
      _packageAdvantages = [];
      json['packageAdvantages'].forEach((v) {
        _packageAdvantages?.add(PackageAdvantage.fromJson(v));
      });
    }
    if (json['featuresComparisonTable'] != null) {
      _featuresComparisonTable = [];
      json['featuresComparisonTable'].forEach((v) {
        _featuresComparisonTable?.add(FeaturesComparisonTable.fromJson(v));
      });
    }
  }
  String? _id;
  String? _code;
  String? _name;
  String? _description;
  String? _detail;
  String? _advantageHighlight;
  num? _price;
  int? _level;
  String? _coverId;
  ImageData? _image;
  List<Price>? _prices;
  List<EnableFeature>? _enableFeatures;
  List<SuccessStory>? _successStories;
  List<CourseSection>? _courseSections;
  List<PackageAdvantage>? _packageAdvantages;
  List<FeaturesComparisonTable>? _featuresComparisonTable;

  String? get id => _id;
  String? get code => _code;
  String? get name => _name;
  String? get description => _description;
  String? get detail => _detail;
  String? get advantageHighlight => _advantageHighlight;
  num? get price => _price;
  int? get level => _level;
  String? get coverId => _coverId;
  ImageData? get image => _image;
  List<Price>? get prices => _prices;
  List<EnableFeature>? get enableFeatures => _enableFeatures;
  List<SuccessStory>? get successStories => _successStories;
  List<CourseSection>? get courseSections => _courseSections;
  List<PackageAdvantage>? get packageAdvantages => _packageAdvantages;
  List<FeaturesComparisonTable>? get featuresComparisonTable => _featuresComparisonTable;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['code'] = _code;
    map['name'] = _name;
    map['description'] = _description;
    map['detail'] = _detail;
    map['advantageHighlight'] = _advantageHighlight;
    map['price'] = _price;
    map['level'] = _level;
    map['coverId'] = _coverId;
    if (_image != null) {
      map['image'] = _image?.toJson();
    }
    if (_prices != null) {
      map['prices'] = _prices?.map((v) => v.toJson()).toList();
    }
    if (_enableFeatures != null) {
      map['enableFeatures'] = _enableFeatures?.map((v) => v.toJson()).toList();
    }
    if (_successStories != null) {
      map['successStories'] = _successStories?.map((v) => v.toJson()).toList();
    }
    if (_courseSections != null) {
      map['courseSections'] = _courseSections?.map((v) => v.toJson()).toList();
    }
    if (_packageAdvantages != null) {
      map['packageAdvantages'] = _packageAdvantages?.map((v) => v.toJson()).toList();
    }
    if (_featuresComparisonTable != null) {
      map['featuresComparisonTable'] = _featuresComparisonTable?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// id : "6b9771f8-81da-4b03-818e-f033033d236d"
/// code : "1"
/// name : "Nhật ký chỉ số sinh học"
/// description : "Theo dõi 07 chỉ số sinh học ( Đường huyết, Huyết áp, Cân nặng, Vận động, Dinh dưỡng, Cảm xúc, HbA1C) đưa ra những khuyến cáo phù hợp dành cho người sử dụng."
/// toggleStatus : {"isEnableBasic":true,"isEnablePro":true,"isEnablePremium":true}
/// image : {"id":"06391e10-8e4a-446f-63a2-08d900ad881f","url":"http://diab-api-dev.savvycom.vn/App/Image/06391e10-8e4a-446f-63a2-08d900ad881f?expires=1633140244&signature=31511ab9780e50f0181cc90dde090815b3b99d7e2ea22cad8cd528e3d231f3a1"}

class FeaturesComparisonTable {
  FeaturesComparisonTable({
    String? id,
    String? code,
    String? name,
    String? description,
    ToggleStatus? toggleStatus,
    ImageData? image,}){
    _id = id;
    _code = code;
    _name = name;
    _description = description;
    _toggleStatus = toggleStatus;
    _image = image;
  }

  FeaturesComparisonTable.fromJson(dynamic json) {
    _id = json['id'];
    _code = json['code'];
    _name = json['name'];
    _description = json['description'];
    _toggleStatus = json['toggleStatus'] != null ? ToggleStatus.fromJson(json['toggleStatus']) : null;
    _image = json['image'] != null ? ImageData.fromJson(json['image']) : null;
  }
  String? _id;
  String? _code;
  String? _name;
  String? _description;
  ToggleStatus? _toggleStatus;
  ImageData? _image;

  String? get id => _id;
  String? get code => _code;
  String? get name => _name;
  String? get description => _description;
  ToggleStatus? get toggleStatus => _toggleStatus;
  ImageData? get image => _image;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['code'] = _code;
    map['name'] = _name;
    map['description'] = _description;
    if (_toggleStatus != null) {
      map['toggleStatus'] = _toggleStatus?.toJson();
    }
    if (_image != null) {
      map['image'] = _image?.toJson();
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

/// id : "18ac8bfe-aff1-4fdd-bbeb-3768098f14ff"
/// name : "Mở khoá gói Coaching"
/// description : "Kết nối 1 - 1 với huấn luyện viên"
/// image : {"id":"007877b7-045c-41d3-c9f8-08d8fe9da6ef","url":"http://diab-api-dev.savvycom.vn/App/Image/007877b7-045c-41d3-c9f8-08d8fe9da6ef?expires=1633140243&signature=6e5a969c8507e8f2021dc7763a798e166552fc60e3debde78efc4ae0f59a1c0d"}

class PackageAdvantage {
  PackageAdvantage({
    String? id,
    String? name,
    String? description,
    ImageData? image,}){
    _id = id;
    _name = name;
    _description = description;
    _image = image;
  }

  PackageAdvantage.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
    _description = json['description'];
    _image = json['image'] != null ? ImageData.fromJson(json['image']) : null;
  }
  String? _id;
  String? _name;
  String? _description;
  ImageData? _image;

  String? get id => _id;
  String? get name => _name;
  String? get description => _description;
  ImageData? get image => _image;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['description'] = _description;
    if (_image != null) {
      map['image'] = _image?.toJson();
    }
    return map;
  }

}


/// id : "06391e10-8e4a-446f-63a2-08d900ad881f"
/// url : "http://diab-api-dev.savvycom.vn/App/Image/06391e10-8e4a-446f-63a2-08d900ad881f?expires=1633140244&signature=31511ab9780e50f0181cc90dde090815b3b99d7e2ea22cad8cd528e3d231f3a1"

class ImageData {
  ImageData({
    String? id,
    String? url,}){
    _id = id;
    _url = url;
  }

  ImageData.fromJson(dynamic json) {
    _id = json['id'];
    _url = json['url'];
  }
  String? _id;
  String? _url;

  String? get id => _id;
  String? get url => _url;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['url'] = _url;
    return map;
  }

}

/// id : "0909f183-3e9f-4024-9534-f7686e46bf24"
/// name : "Dinh dưỡng đúng"
/// description : null
/// image : {"id":"002a1a72-80a8-4fa4-54fd-08d93079d098","url":"http://diab-api-dev.savvycom.vn/App/Image/002a1a72-80a8-4fa4-54fd-08d93079d098?expires=1633140243&signature=bc8064496561e4f8ddd5b30fc2f3dbc2a1f69849a397a3bc31e824445e944ae4"}
/// totalLesson : 1
/// totalHours : 8

class CourseSection {
  CourseSection({
    String? id,
    String? name,
    String? description,
    ImageData? image,
    int? totalLesson,
    int? totalHours,}){
    _id = id;
    _name = name;
    _description = description;
    _image = image;
    _totalLesson = totalLesson;
    _totalHours = totalHours;
  }
  CourseSection.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
    _description = json['description'];
    _image = json['image'] != null ? ImageData.fromJson(json['image']) : null;
    _totalLesson = json['totalLesson'];
    _totalHours = json['totalHours'];
  }
  String? _id;
  String? _name;
  String? _description;
  ImageData? _image;
  int? _totalLesson;
  int? _totalHours;

  String? get id => _id;
  String? get name => _name;
  String? get description => _description;
  ImageData? get image => _image;
  int? get totalLesson => _totalLesson;
  int? get totalHours => _totalHours;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['description'] = _description;
    if (_image != null) {
      map['image'] = _image?.toJson();
    }
    map['totalLesson'] = _totalLesson;
    map['totalHours'] = _totalHours;
    return map;
  }

}
/// avatarPath : "string"
/// name : "string"
/// job : "string"
/// story : "string"

class SuccessStory {
  SuccessStory({
    ImageData? image,
    String? name,
    String? job,
    String? story,}){
    _image = image;
    _name = name;
    _job = job;
    _story = story;
  }

  SuccessStory.fromJson(dynamic json) {
    _image = json['image'] != null ? ImageData.fromJson(json['image']) : null;
    _name = json['name'];
    _job = json['job'];
    _story = json['story'];
  }
  ImageData? _image;
  String? _name;
  String? _job;
  String? _story;

  ImageData? get image => _image;
  String? get name => _name;
  String? get job => _job;
  String? get story => _story;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_image != null) {
      map['image'] = _image?.toJson();
    }
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
    String? highlight,
    List<PackageBankPayment>? packageBankPayments,}){
    _name = name;
    _monthUsed = monthUsed;
    _monthPrice = monthPrice;
    _totalPrice = totalPrice;
    _discount = discount;
    _highlight = highlight;
    _packageBankPayments = packageBankPayments;
  }

  Price.fromJson(dynamic json) {
    _name = json['name'];
    _monthUsed = json['monthUsed'];
    _monthPrice = json['monthPrice'];
    _totalPrice = json['totalPrice'];
    _discount = json['discount'];
    _highlight = json['highlight'];
    if (json['packageBankPayments'] != null) {
      _packageBankPayments = [];
      json['packageBankPayments'].forEach((v) {
        _packageBankPayments?.add(PackageBankPayment.fromJson(v));
      });
    }
  }
  String? _name;
  int? _monthUsed;
  num? _monthPrice;
  num? _totalPrice;
  String? _discount;
  String? _highlight;
  List<PackageBankPayment>? _packageBankPayments;

  String? get name => _name;
  int? get monthUsed => _monthUsed;
  num? get monthPrice => _monthPrice;
  num? get totalPrice => _totalPrice;
  String? get discount => _discount;
  String? get highlight => _highlight;
  List<PackageBankPayment>? get packageBankPayments => _packageBankPayments;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = _name;
    map['monthUsed'] = _monthUsed;
    map['monthPrice'] = _monthPrice;
    map['totalPrice'] = _totalPrice;
    map['discount'] = _discount;
    map['highlight'] = _highlight;
    if (_packageBankPayments != null) {
      map['packageBankPayments'] = _packageBankPayments?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// bankAccountId : "0149582050"
/// bankAccountName : "Nguyễn Văn An"
/// bankName : "Viettin bank"
/// content : "Thanh toan goi Thay doi loi song"

class PackageBankPayment {
  PackageBankPayment({
    String? bankAccountId,
    String? bankAccountName,
    String? bankName,
    String? content,}){
    _bankAccountId = bankAccountId;
    _bankAccountName = bankAccountName;
    _bankName = bankName;
    _content = content;
  }

  PackageBankPayment.fromJson(dynamic json) {
    _bankAccountId = json['bankAccountId'];
    _bankAccountName = json['bankAccountName'];
    _bankName = json['bankName'];
    _content = json['content'];
  }
  String? _bankAccountId;
  String? _bankAccountName;
  String? _bankName;
  String? _content;

  String? get bankAccountId => _bankAccountId;
  String? get bankAccountName => _bankAccountName;
  String? get bankName => _bankName;
  String? get content => _content;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['bankAccountId'] = _bankAccountId;
    map['bankAccountName'] = _bankAccountName;
    map['bankName'] = _bankName;
    map['content'] = _content;
    return map;
  }

}