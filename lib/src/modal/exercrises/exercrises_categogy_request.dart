import 'package:medical/src/modal/base/images.dart';
import 'package:medical/src/modal/exercrises/exercrises_Category.dart';
import 'package:meta/meta.dart';

// class ExercrisesCategoryRequestModel1 {
//   final String intensityId;
//   final String activeId;
//   //final double calories;
//   final ExercrisesCategoryModel categoryModel;
//   // final String id;
//   // final double duration;
//   // final String unit;
//   // final String name;
//   // final String exerciseId;
//   final String exerciseIntensityId;
//   final String exerciseIntensityName;
//   //final ImagesUrlModel imageUrl;

//   ExercrisesCategoryRequestModel({
//     @required this.intensityId,
//     @required this.activeId,
//     @required this.calories,
//     @required this.categoryModel,
//     // @required this.duration,
//     // @required this.exerciseId,
//     // @required this.unit,
//     // @required this.id,
//     // @required this.name,
//     @required this.exerciseIntensityId,
//     @required this.exerciseIntensityName,
//     //@required this.imageUrl,
//   });
//   @override
//   factory ExercrisesCategoryRequestModel.fromJson(Map<String, dynamic> json) {
//     return ExercrisesCategoryRequestModel(
//       intensityId: null,
//       activeId: null,
//       //id: json['id'],
//       categoryModel: ExercrisesCategoryModel(
//           id: json['categoryId'],
//           exerciseId: json['exerciseId'],
//           name: json['category'],
//           code: null,
//           description: null,
//           duration: json['duration'],
//           burnedCalorie: json['burnedCalorie'],
//           unit: json['unit'],
//           order: null,
//           cover: ImagesModel.fromJson(json['imageUrl'])),
//       // name: json['name'],
//       // duration: json['duration'],
//       calories: json['burnedCalorie'],
//       exerciseIntensityId: json['exerciseIntensityId'],
//       //exerciseId: json['exerciseId'],
//       exerciseIntensityName: json['exerciseIntensityName'],
//       //unit: json['unit'],
//       //imageUrl: ImagesUrlModel.fromJson(json['imageUrl']),
//     );
//   }

//   static List<ExercrisesCategoryRequestModel> toList(List<dynamic> items) {
//     return items
//         .map((item) => ExercrisesCategoryRequestModel.fromJson(item))
//         .toList();
//   }
// }

class ImagesUrlModel {
  final String? id;
  final String? url;

  ImagesUrlModel({required this.id, required this.url});
  @override
  factory ImagesUrlModel.fromJson(Map<String, dynamic> json) {
    return ImagesUrlModel(
      id: json['id'],
      url: json['url'],
    );
  }
  static List<ImagesUrlModel> toList(List<dynamic> items) {
    return items.map((item) => ImagesUrlModel.fromJson(item)).toList();
  }
}
