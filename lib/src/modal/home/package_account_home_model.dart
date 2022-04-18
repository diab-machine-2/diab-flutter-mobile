class PackageAccountHomeModel {
  String? id;
  String? accountId;
  String? packageId;
  int? activationDate;
  int? expirationDate;
  String? packageAccountTransactionId;
  bool? isDisplayedWelcome;
  Package? package;

  PackageAccountHomeModel(
      {this.id,
      this.accountId,
      this.packageId,
      this.activationDate,
      this.expirationDate,
      this.packageAccountTransactionId,
      this.isDisplayedWelcome,
      this.package});

  PackageAccountHomeModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    accountId = json['accountId'];
    packageId = json['packageId'];
    activationDate = json['activationDate'];
    expirationDate = json['expirationDate'];
    packageAccountTransactionId = json['packageAccountTransactionId'];
    isDisplayedWelcome = json['isDisplayedWelcome'];
    package =
        json['package'] != null ? new Package.fromJson(json['package']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['accountId'] = this.accountId;
    data['packageId'] = this.packageId;
    data['activationDate'] = this.activationDate;
    data['expirationDate'] = this.expirationDate;
    data['packageAccountTransactionId'] = this.packageAccountTransactionId;
    data['isDisplayedWelcome'] = this.isDisplayedWelcome;
    if (this.package != null) {
      data['package'] = this.package!.toJson();
    }
    return data;
  }
}

class Package {
  String? id;
  String? code;
  int? duration;
  int? durationType;
  bool? isRoadmap;
  String? name;
  String? description;

  Package(
      {this.id,
      this.code,
      this.duration,
      this.durationType,
      this.isRoadmap,
      this.name,
      this.description});

  Package.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    duration = json['duration'];
    durationType = json['durationType'];
    isRoadmap = json['isRoadmap'];
    name = json['name'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
    data['duration'] = this.duration;
    data['durationType'] = this.durationType;
    data['isRoadmap'] = this.isRoadmap;
    data['name'] = this.name;
    data['description'] = this.description;
    return data;
  }
}