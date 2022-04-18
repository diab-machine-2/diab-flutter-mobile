import 'package:meta/meta.dart';

@immutable
class ImagesModel {
  final String? id;
  final String? url;

  const ImagesModel({
    required this.id,
    required this.url,
  });

  @override
  factory ImagesModel.fromJson(Map<String, dynamic> json) {
    return ImagesModel(
      id: json['id'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["id"] = id;
    data["url"] = url;
    return data;
  }

  static List<ImagesModel> toList(List<dynamic> items) {
    return items.map((item) => ImagesModel.fromJson(item)).toList();
  }
}

class PackageAccountModel {
  final String? accountId;
  final String? packageId;
  final PackageModel? package;

  const PackageAccountModel({
    required this.accountId,
    required this.packageId,
    required this.package,
  });

  @override
  factory PackageAccountModel.fromJson(Map<String, dynamic> json) {
    return PackageAccountModel(
      accountId: json['accountId'],
      packageId: json['packageId'],
      package: json['package'] == null ? null : PackageModel.fromJson(json['package']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["accountId"] = accountId;
    data["packageId"] = packageId;
    if (package != null) {
      data["package"] = package!.toJson();
    }
    return data;
  }

  static List<PackageAccountModel> toList(List<dynamic> items) {
    return items.map((item) => PackageAccountModel.fromJson(item)).toList();
  }
}

class PackageModel {
  final String? name;
  final double? duration;

  const PackageModel({
    required this.name,
    required this.duration,
  });

  @override
  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      name: json['name'],
      duration: json['duration'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["name"] = name;
    data["duration"] = duration;
    return data;
  }

  static List<PackageModel> toList(List<dynamic> items) {
    return items.map((item) => PackageModel.fromJson(item)).toList();
  }
}
