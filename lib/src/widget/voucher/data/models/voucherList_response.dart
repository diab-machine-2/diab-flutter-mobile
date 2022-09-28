import 'package:medical/src/modal/base/images.dart';

class VoucherListResponse {
  late int totalActive;
  late int totalInActive;
  late int total;
  late int page;
  late int size;
  late List<VoucherModel> items;

  VoucherListResponse.fromJson(Map<String, dynamic> json) {
    this.totalActive = json["totalActive"] ?? 0;
    this.totalInActive = json["totalInActive"] ?? 0;
    this.total = json["total"] ?? 0;
    this.page = json["page"] ?? 0;
    this.size = json["size"] ?? 0;
    this.items = json["items"] == null
        ? []
        : (json["items"] as List).map((e) => VoucherModel.fromJson(e)).toList();
  }
}

class VoucherModel {
  String? logo;
  late String title;
  late String code;
  String? description;
  int? status;
  late String id;

  VoucherModel.fromJson(Map<String, dynamic> json) {
    logo = json['logo'];
    title = json["title"] ?? "";
    code = json["code"] ?? "";
    description = json["description"] ?? "";
    status = json["status"];
    id = json["id"] ?? "";
  }
}
