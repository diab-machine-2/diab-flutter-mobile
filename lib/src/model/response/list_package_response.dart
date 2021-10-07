import 'detail_package_data.dart';
import 'meta.dart';

class ListPackageResponse {
  ListPackageResponse({
      Meta? meta,
    List<DetailPackageData>? data,}){
    _meta = meta;
    _data = data;
}

  ListPackageResponse.fromJson(dynamic json) {
    _meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(DetailPackageData.fromJson(v));
      });
    }
  }
  Meta? _meta;
  List<DetailPackageData>? _data;

  Meta? get meta => _meta;
  List<DetailPackageData>? get data => _data;

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

