import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class PackageProgram {
  final String id;
  final String title;
  final bool isRecommended;
  final String color;
  final List<ProgramItem> items;
  final List<ProgramAudience> audiences;
  final List<ProgramTarget> targets;
  final List<ProgramAction> actions;

  PackageProgram({
    required this.id,
    required this.title,
    required this.isRecommended,
    required this.color,
    required this.items,
    required this.audiences,
    required this.targets,
    required this.actions,
  });

  Color get getProgramColor {
    final argbColor = int.tryParse(this.color.replaceAll('#', '0xff'));
    if (argbColor == null) return R.color.greenGradientTop02;
    return Color(argbColor);
  }

  // Factory constructor for creating a Program from JSON
  factory PackageProgram.fromJson(Map<String, dynamic> json) {
    return PackageProgram(
      id: json['id'] as String,
      title: json['title'] as String,
      isRecommended: json['isRecommended'] as bool,
      color: json['color'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => ProgramItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      audiences: (json['audiences'] as List<dynamic>)
          .map((audience) =>
              ProgramAudience.fromJson(audience as Map<String, dynamic>))
          .toList(),
      targets: (json['targets'] as List<dynamic>)
          .map((target) =>
              ProgramTarget.fromJson(target as Map<String, dynamic>))
          .toList(),
      actions: (json['actions'] as List<dynamic>)
          .map((action) =>
              ProgramAction.fromJson(action as Map<String, dynamic>))
          .toList(),
    );
  }

  // Method to convert Program to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isRecommended': isRecommended,
      'color': color,
      'items': items.map((item) => item.toJson()).toList(),
      'audiences': audiences.map((audience) => audience.toJson()).toList(),
      'targets': targets.map((target) => target.toJson()).toList(),
      'actions': actions.map((action) => action.toJson()).toList(),
    };
  }
}

class ProgramItem {
  final String id;
  final String description;

  ProgramItem({
    required this.id,
    required this.description,
  });

  factory ProgramItem.fromJson(Map<String, dynamic> json) {
    return ProgramItem(
      id: json['id'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
    };
  }
}

class ProgramAudience {
  final String id;
  final String title;

  ProgramAudience({
    required this.id,
    required this.title,
  });

  factory ProgramAudience.fromJson(Map<String, dynamic> json) {
    return ProgramAudience(
      id: json['id'] as String,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }
}

class ProgramTarget {
  final String id;
  final String title;

  ProgramTarget({
    required this.id,
    required this.title,
  });

  factory ProgramTarget.fromJson(Map<String, dynamic> json) {
    return ProgramTarget(
      id: json['id'] as String,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }
}

class ProgramAction {
  final String id;
  final String title;

  ProgramAction({
    required this.id,
    required this.title,
  });

  factory ProgramAction.fromJson(Map<String, dynamic> json) {
    return ProgramAction(
      id: json['id'] as String,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }
}
