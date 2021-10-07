import 'detail_package_data.dart';
import 'meta.dart';

/// meta : {"success":true}
/// data : {"id":"3fa85f64-5717-4562-b3fc-2c963f66afa6","code":"string","name":"string","description":"string","detail":"string","price":0,"level":0,"coverId":"string","coverPath":"string","prices":[{"name":"string","monthUsed":0,"monthPrice":0,"totalPrice":0,"discount":"string","highlight":"string"}],"enableFeatures":[{"featureId":"3fa85f64-5717-4562-b3fc-2c963f66afa6","featureName":"string"}],"successStories":[{"avatarPath":"string","name":"string","job":"string","story":"string"}]}

class DetailPackageResponse {
  DetailPackageResponse({
      Meta? meta, 
      DetailPackageData? data,}){
    _meta = meta;
    _data = data;
}

  DetailPackageResponse.fromJson(dynamic json) {
    _meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    _data = json['data'] != null ? DetailPackageData.fromJson(json['data']) : null;
  }
  Meta? _meta;
  DetailPackageData? _data;

  Meta? get meta => _meta;
  DetailPackageData? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_meta != null) {
      map['meta'] = _meta?.toJson();
    }
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    return map;
  }

}

