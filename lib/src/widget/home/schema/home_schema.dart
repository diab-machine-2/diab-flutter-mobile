import 'package:medical/src/widget/my_plan_screens/activity_tab/activity_tab/models/schedule_type.dart';

class HomeMeasurementIndex {
  final String title;
  final String icon;
  final String navigatorName;
  final dynamic args;

  HomeMeasurementIndex({
    required this.title,
    required this.icon,
    required this.navigatorName,
    this.args,
  });
}

class HomeMeasurementInlineData {
  final String? title;
  final String? icon;
  final String value;
  final String unit;
  final int titleColor;
  final int color;
  final String? navigatorName;
  final dynamic args;

  HomeMeasurementInlineData({
    this.title,
    this.icon,
    required this.value,
    required this.unit,
    required this.color,
    required this.titleColor,
    this.navigatorName,
    this.args,
  }) : assert(title != null || icon != null);

  factory HomeMeasurementInlineData.fromJson(Map<String, dynamic> map) {
    return HomeMeasurementInlineData(
      title: map['title'],
      icon: map['icon'],
      value: map['value'],
      unit: map['unit'],
      color: map['color'],
      titleColor: map['titleColor'],
      navigatorName: map['navigatorName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'icon': icon,
      'value': value,
      'unit': unit,
      'color': color,
      'titleColor': titleColor,
      'navigatorName': navigatorName,
    };
  }
}

class HomeMeasurementData {
  final String title;
  final int titleColor;
  final String icon;
  final String? value1;
  final int value1Color;
  final String? value2;
  final int? value2Color;
  final String unit;
  final String? navigatorName;
  final dynamic args;

  HomeMeasurementData({
    required this.title,
    required this.titleColor,
    required this.icon,
    required this.value1,
    required this.value1Color,
    this.value2,
    this.value2Color,
    required this.unit,
    this.navigatorName,
    this.args,
  });

  factory HomeMeasurementData.fromJson(Map<String, dynamic> map) {
    return HomeMeasurementData(
      title: map['title'],
      titleColor: map['titleColor'],
      icon: map['icon'],
      value1: map['value1'],
      value1Color: map['value1Color'],
      value2: map['value2'],
      value2Color: map['value2Color'],
      unit: map['unit'],
      navigatorName: map['navigatorName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'titleColor': titleColor,
      'icon': icon,
      'value1': value1,
      'value1Color': value1Color,
      'value2': value2,
      'value2Color': value2Color,
      'unit': unit,
      'navigatorName': navigatorName,
    };
  }
}

class HomeActivityData {
  final String id;
  final String icon;
  final String title;
  final String? description;

  // Getter/Setter
  late ScheduleType type;

  HomeActivityData({
    required this.id,
    required this.icon,
    required this.title,
    this.description,
  });

  factory HomeActivityData.fromJson(Map<String, dynamic> map) {
    return HomeActivityData(
      id: map['id'],
      icon: map['icon'],
      title: map['title'],
      description: map['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'icon': icon,
      'title': title,
      'description': description,
    };
  }
}

class HomeReminderData {
  final String icon;
  final String title;
  final String time;
  final String? navigatorName;

  HomeReminderData({
    required this.icon,
    required this.title,
    required this.time,
    this.navigatorName,
  });

  factory HomeReminderData.fromJson(Map<String, dynamic> map) {
    return HomeReminderData(
      icon: map['icon'],
      title: map['title'],
      time: map['time'],
      navigatorName: map['navigatorName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'icon': icon,
      'title': title,
      'time': time,
      'navigatorName': navigatorName,
    };
  }
}

class HomeUtilityData {
  final String icon;
  final String title;
  final String navigatorName;

  HomeUtilityData({
    required this.icon,
    required this.title,
    required this.navigatorName,
  });
}

class HomeLessonData {
  final String id;
  final String icon;
  final String category;
  final String title;
  final String? imageUrl;

  final int likeCount;
  final int commentCount;

  HomeLessonData({
    required this.id,
    required this.icon,
    required this.category,
    required this.title,
    this.imageUrl,
    this.likeCount = 0,
    this.commentCount = 0,
  });
}

class HomeNewsData {
  final String id;
  final String icon;
  final String category;
  final String title;
  final String? imageUrl;

  final int likeCount;
  final int commentCount;

  HomeNewsData({
    required this.id,
    required this.icon,
    required this.category,
    required this.title,
    this.imageUrl,
    this.likeCount = 0,
    this.commentCount = 0,
  });
}
