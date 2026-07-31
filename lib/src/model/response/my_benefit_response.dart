import 'package:medical/src/model/response/meta.dart';

class MyBenefitResponse {
  MyBenefitResponse({Meta? meta, MyBenefitData? data}) {
    _meta = meta;
    _data = data;
  }

  MyBenefitResponse.fromJson(dynamic json) {
    _meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    _data = json['data'] != null ? MyBenefitData.fromJson(json['data']) : null;
  }

  Meta? _meta;
  MyBenefitData? _data;

  Meta? get meta => _meta;
  MyBenefitData? get data => _data;
}

class MyBenefitData {
  MyBenefitData({
    String? id,
    String? name,
    int? status,
    int? remainingDays,
    int? startDate,
    int? endDate,
    int? totalItems,
    int? usedItems,
    int? completionPercent,
    String? partnerHotline,
    List<MyBenefitSection>? sections,
  }) {
    _id = id;
    _name = name;
    _status = status;
    _remainingDays = remainingDays;
    _startDate = startDate;
    _endDate = endDate;
    _totalItems = totalItems;
    _usedItems = usedItems;
    _completionPercent = completionPercent;
    _partnerHotline = partnerHotline;
    _sections = sections;
  }

  MyBenefitData.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
    _status = json['status'];
    _remainingDays = json['remainingDays'];
    _startDate = json['startDate'];
    _endDate = json['endDate'];
    _totalItems = json['totalItems'];
    _usedItems = json['usedItems'];
    _completionPercent = json['completionPercent'];
    _partnerHotline = json['partnerHotline']?.toString();
    if (json['sections'] != null) {
      _sections = [];
      json['sections'].forEach((v) {
        _sections?.add(MyBenefitSection.fromJson(v));
      });
    }
  }

  String? _id;
  String? _name;
  int? _status;
  int? _remainingDays;
  int? _startDate;
  int? _endDate;
  int? _totalItems;
  int? _usedItems;
  int? _completionPercent;
  String? _partnerHotline;
  List<MyBenefitSection>? _sections;

  String? get id => _id;
  String? get name => _name;
  int? get status => _status;
  int? get remainingDays => _remainingDays;
  int? get startDate => _startDate;
  int? get endDate => _endDate;
  int? get totalItems => _totalItems;
  int? get usedItems => _usedItems;
  int? get completionPercent => _completionPercent;
  String? get partnerHotline => _partnerHotline;
  List<MyBenefitSection>? get sections => _sections;
}

class MyBenefitSection {
  MyBenefitSection({String? tagName, List<MyBenefitItem>? items}) {
    _tagName = tagName;
    _items = items;
  }

  MyBenefitSection.fromJson(dynamic json) {
    _tagName = json['tagName'];
    if (json['items'] != null) {
      _items = [];
      json['items'].forEach((v) {
        _items?.add(MyBenefitItem.fromJson(v));
      });
    }
  }

  String? _tagName;
  List<MyBenefitItem>? _items;

  String? get tagName => _tagName;
  List<MyBenefitItem>? get items => _items;

  /// Items whose [MyBenefitItem.bundleItemType] resolves to a known type.
  /// `itemType == 0` (or any unrecognized itemType/appFeature combo) is
  /// ignored by the API contract and must never reach the UI.
  List<MyBenefitItem> get visibleItems =>
      (items ?? []).where((i) => i.bundleItemType != null).toList();
}

/// Semantic item types for benefit bundle items, resolved from the raw
/// `itemType`/`appFeature` pair via [BenefitBundleItemType.resolve].
enum BenefitBundleItemType {
  dsp,
  booking,
  partnerIntro,
  report,
  medicinePurchase,
  labTest;

  /// Maps the wire `itemType`/`appFeature` pair to a semantic type.
  /// `itemType == 0` has no meaning in the UI and resolves to `null`.
  /// `itemType == 1` is always `dsp`. `itemType == 2` is disambiguated by
  /// `appFeature`: 1/2 = booking (telemedicine/at-clinic), 3 = partnerIntro,
  /// 4 = report, 5 = medicinePurchase, 6 = labTest.
  static BenefitBundleItemType? resolve({int? itemType, int? appFeature}) {
    switch (itemType) {
      case 1:
        return BenefitBundleItemType.dsp;
      case 2:
        switch (appFeature) {
          case 1:
          case 2:
            return BenefitBundleItemType.booking;
          case 3:
            return BenefitBundleItemType.partnerIntro;
          case 4:
            return BenefitBundleItemType.report;
          case 5:
            return BenefitBundleItemType.medicinePurchase;
          case 6:
            return BenefitBundleItemType.labTest;
        }
        return null;
      default:
        return null;
    }
  }
}

class MyBenefitItem {
  MyBenefitItem({
    String? itemId,
    int? itemType,
    String? name,
    int? category,
    int? appFeature,
    int? reportType,
    int? specialtyId,
    String? specialtyName,
    int? clinicId,
    int? isUnlimited,
    int? quantity,
    int? quantityUsed,
    int? discountValue,
    int? discountType,
    BenefitType? benefitType,
    int? totalWeek,
    int? currentWeek,
    String? servicePackageId,
  }) {
    _itemId = itemId;
    _itemType = itemType;
    _name = name;
    _category = category;
    _appFeature = appFeature;
    _reportType = reportType;
    _specialtyId = specialtyId;
    _specialtyName = specialtyName;
    _clinicId = clinicId;
    _isUnlimited = isUnlimited;
    _quantity = quantity;
    _quantityUsed = quantityUsed;
    _discountValue = discountValue;
    _discountType = discountType;
    _benefitType = benefitType;
    _totalWeek = totalWeek;
    _currentWeek = currentWeek;
    _servicePackageId = servicePackageId;
  }

  MyBenefitItem.fromJson(dynamic json) {
    _itemId = json['itemId'];
    _itemType = json['itemType'];
    _name = json['name'];
    _category = json['category'];
    _appFeature = json['appFeature'];
    _reportType = json['reportType'];
    _specialtyId = json['specialtyId'];
    _specialtyName = json['specialtyName'];
    _clinicId = json['clinicId'];
    _isUnlimited = json['isUnlimited'];
    _quantity = json['quantity'];
    _quantityUsed = json['quantityUsed'];
    _discountValue = json['discountValue'];
    _discountType = json['discountType'];
    _benefitType = json['benefitType'] != null
        ? BenefitType.fromJson(json['benefitType'])
        : null;
    _totalWeek = json['totalWeek'];
    _currentWeek = json['currentWeek'];
    _servicePackageId = json['servicePackageId'];
  }

  String? _itemId;
  int? _itemType;
  String? _name;
  int? _category;
  int? _appFeature;
  int? _reportType;
  int? _specialtyId;
  String? _specialtyName;
  int? _clinicId;
  int? _isUnlimited;
  int? _quantity;
  int? _quantityUsed;
  int? _discountValue;
  int? _discountType;
  BenefitType? _benefitType;
  int? _totalWeek;
  int? _currentWeek;
  String? _servicePackageId;

  String? get itemId => _itemId;
  int? get itemType => _itemType;
  String? get name => _name;
  int? get category => _category;
  int? get appFeature => _appFeature;
  int? get reportType => _reportType;
  int? get specialtyId => _specialtyId;
  String? get specialtyName => _specialtyName;
  int? get clinicId => _clinicId;
  int? get isUnlimited => _isUnlimited;
  int? get quantity => _quantity;
  int? get quantityUsed => _quantityUsed;
  int? get discountValue => _discountValue;
  int? get discountType => _discountType;
  BenefitType? get benefitType => _benefitType;

  /// Only meaningful for [BenefitBundleItemType.dsp] items.
  int? get totalWeek => _totalWeek;

  /// Only meaningful for [BenefitBundleItemType.dsp] items.
  int? get currentWeek => _currentWeek;

  /// Only meaningful for [BenefitBundleItemType.dsp] items.
  String? get servicePackageId => _servicePackageId;

  BenefitBundleItemType? get bundleItemType =>
      BenefitBundleItemType.resolve(itemType: itemType, appFeature: appFeature);

  /// Derived from `itemType`/`appFeature` — the API no longer sends this
  /// directly on the wire.
  String? get bookingType {
    if (itemType == 2 && appFeature == 1) return 'telemedicine';
    if (itemType == 2 && appFeature == 2) return 'at_clinic';
    return null;
  }

  int get remainingQuantity =>
      ((quantity ?? 0) - (quantityUsed ?? 0)).clamp(0, quantity ?? 0);

  bool get isUnlimitedBenefit => isUnlimited == 1;
}

class BenefitType {
  BenefitType({
    String? id,
    String? title,
    int? contentType,
    String? contentValue,
    String? description,
    String? location,
    String? openTime,
    int? status,
    String? tag,
    int? hasVoucher,
    String? voucherName,
    String? voucherSubName,
    String? voucherCode,
    dynamic voucherValue,
    String? applicableTo,
    int? validUntil,
    String? applicableLocation,
    int? order,
    String? bundleTagId,
    List<BenefitMedia>? media,
  }) {
    _id = id;
    _title = title;
    _contentType = contentType;
    _contentValue = contentValue;
    _description = description;
    _location = location;
    _openTime = openTime;
    _status = status;
    _tag = tag;
    _hasVoucher = hasVoucher;
    _voucherName = voucherName;
    _voucherSubName = voucherSubName;
    _voucherCode = voucherCode;
    _voucherValue = voucherValue?.toString();
    _applicableTo = applicableTo;
    _validUntil = validUntil;
    _applicableLocation = applicableLocation;
    _order = order;
    _bundleTagId = bundleTagId;
    _media = media;
  }

  BenefitType.fromJson(dynamic json) {
    _id = json['id'];
    _title = json['title'];
    _contentType = json['contentType'];
    _contentValue = json['contentValue'];
    _description = json['description'];
    _location = json['location'];
    _openTime = json['openTime'];
    _status = json['status'];
    _tag = json['tag'];
    _hasVoucher = json['hasVoucher'];
    _voucherName = json['voucherName'];
    _voucherSubName = json['voucherSubName'];
    _voucherCode = json['voucherCode'];
    _voucherValue = json['voucherValue']?.toString();
    _applicableTo = json['applicableTo'];
    _validUntil = json['validUntil'];
    _applicableLocation = json['applicableLocation'];
    _order = json['order'];
    _bundleTagId = json['bundleTagId'];
    if (json['media'] != null) {
      _media = [];
      json['media'].forEach((v) {
        _media?.add(BenefitMedia.fromJson(v));
      });
    }
  }

  String? _id;
  String? _title;
  int? _contentType;
  String? _contentValue;
  String? _description;
  String? _location;
  String? _openTime;
  int? _status;
  String? _tag;
  int? _hasVoucher;
  String? _voucherName;
  String? _voucherSubName;
  String? _voucherCode;
  String? _voucherValue;
  String? _applicableTo;
  int? _validUntil;
  String? _applicableLocation;
  int? _order;
  String? _bundleTagId;
  List<BenefitMedia>? _media;

  String? get id => _id;
  String? get title => _title;
  int? get contentType => _contentType;
  String? get contentValue => _contentValue;
  String? get description => _description;
  String? get location => _location;
  String? get openTime => _openTime;
  int? get status => _status;
  String? get tag => _tag;
  int? get hasVoucher => _hasVoucher;
  String? get voucherName => _voucherName;
  String? get voucherSubName => _voucherSubName;
  String? get voucherCode => _voucherCode;
  String? get voucherValue => _voucherValue;
  String? get applicableTo => _applicableTo;
  int? get validUntil => _validUntil;
  String? get applicableLocation => _applicableLocation;
  int? get order => _order;
  String? get bundleTagId => _bundleTagId;
  List<BenefitMedia>? get media => _media;
}

class BenefitMedia {
  BenefitMedia({
    String? id,
    String? bundleBenefitTypeId,
    String? imageId,
    String? url,
    int? type,
    int? sortOrder,
    BenefitImageUrl? imageUrl,
  }) {
    _id = id;
    _bundleBenefitTypeId = bundleBenefitTypeId;
    _imageId = imageId;
    _url = url;
    _type = type;
    _sortOrder = sortOrder;
    _imageUrl = imageUrl;
  }

  BenefitMedia.fromJson(dynamic json) {
    _id = json['id'];
    _bundleBenefitTypeId = json['bundleBenefitTypeId'];
    _imageId = json['imageId'];
    _url = json['url'];
    _type = json['type'];
    _sortOrder = json['sortOrder'];
    _imageUrl = json['imageUrl'] != null
        ? BenefitImageUrl.fromJson(json['imageUrl'])
        : null;
  }

  String? _id;
  String? _bundleBenefitTypeId;
  String? _imageId;
  String? _url;
  int? _type;
  int? _sortOrder;
  BenefitImageUrl? _imageUrl;

  String? get id => _id;
  String? get bundleBenefitTypeId => _bundleBenefitTypeId;
  String? get imageId => _imageId;
  String? get url => _url;
  int? get type => _type;
  int? get sortOrder => _sortOrder;
  BenefitImageUrl? get imageUrl => _imageUrl;
}

class BenefitImageUrl {
  BenefitImageUrl({
    String? id,
    String? url,
  }) {
    _id = id;
    _url = url;
  }

  BenefitImageUrl.fromJson(dynamic json) {
    _id = json['id'];
    _url = json['url'];
  }

  String? _id;
  String? _url;

  String? get id => _id;
  String? get url => _url;
}
