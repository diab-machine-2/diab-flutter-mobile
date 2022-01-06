import 'package:meta/meta.dart';

@immutable
class CategoryItemUserModel {
  final bool? disabled;
  final bool? selected;
  final GroupModel? group;
  final String? text;
  final String? value;

  CategoryItemUserModel({
    required this.disabled,
    required this.selected,
    required this.group,
    required this.text,
    required this.value,
  });

  factory CategoryItemUserModel.fromJson(Map<String, dynamic> json) {
    return CategoryItemUserModel(
      disabled: json['disabled'],
      selected: json['selected'],
      group: json['group'] == null ? null : GroupModel.fromJson(json['group']),
      text: json['text'],
      value: json['value'],
    );
  }

  static List<CategoryItemUserModel> toList(List<dynamic> items) {
    return items.map((item) => CategoryItemUserModel.fromJson(item)).toList();
  }
}

class GroupModel {
  final bool? disabled;
  final String? name;

  GroupModel({required this.disabled, required this.name});

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(disabled: json['disabled'], name: json['name']);
  }

  static List<GroupModel> toList(List<dynamic> items) {
    return items.map((item) => GroupModel.fromJson(item)).toList();
  }
}
