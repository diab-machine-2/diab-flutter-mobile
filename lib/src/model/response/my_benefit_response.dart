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
}

/// Item types for benefit bundle items.
/// API is not finalized; these values are used in mock data.
enum BenefitBundleItemType {
  medicine(0),
  booking(1),
  partnerIntro(2),
  report(3),
  dsp(4),
  medicinePurchase(5),
  labTest(6);

  const BenefitBundleItemType(this.value);
  final int value;

  static BenefitBundleItemType fromValue(int? value) {
    return BenefitBundleItemType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => BenefitBundleItemType.medicine,
    );
  }
}

class MyBenefitItem {
  MyBenefitItem({
    String? itemId,
    int? itemType,
    String? name,
    int? isUnlimited,
    int? quantity,
    int? quantityUsed,
    int? discountValue,
    int? discountType,
  }) {
    _itemId = itemId;
    _itemType = itemType;
    _name = name;
    _isUnlimited = isUnlimited;
    _quantity = quantity;
    _quantityUsed = quantityUsed;
    _discountValue = discountValue;
    _discountType = discountType;
  }

  MyBenefitItem.fromJson(dynamic json) {
    _itemId = json['itemId'];
    _itemType = json['itemType'];
    _name = json['name'];
    _isUnlimited = json['isUnlimited'];
    _quantity = json['quantity'];
    _quantityUsed = json['quantityUsed'];
    _discountValue = json['discountValue'];
    _discountType = json['discountType'];
  }

  String? _itemId;
  int? _itemType;
  String? _name;
  int? _isUnlimited;
  int? _quantity;
  int? _quantityUsed;
  int? _discountValue;
  int? _discountType;

  String? get itemId => _itemId;
  int? get itemType => _itemType;
  String? get name => _name;
  int? get isUnlimited => _isUnlimited;
  int? get quantity => _quantity;
  int? get quantityUsed => _quantityUsed;
  int? get discountValue => _discountValue;
  int? get discountType => _discountType;

  BenefitBundleItemType get bundleItemType =>
      BenefitBundleItemType.fromValue(itemType);

  int get remainingQuantity =>
      ((quantity ?? 0) - (quantityUsed ?? 0)).clamp(0, quantity ?? 0);

  bool get isUnlimitedBenefit => isUnlimited == 1;
}
