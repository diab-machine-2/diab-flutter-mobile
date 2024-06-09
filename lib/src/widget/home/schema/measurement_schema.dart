class HomeMeasurementInlineData {
  final String? title;
  final String? icon;
  final String value;
  final String unit;
  final int color;

  HomeMeasurementInlineData({
    this.title,
    this.icon,
    required this.value,
    required this.unit,
    required this.color,
  }) : assert(title != null || icon != null);
}

class HomeMeasurementData {
  final String title;
  final String icon;
  final String? value1;
  final int value1Color;
  final String? value2;
  final int? value2Color;
  final String unit;

  HomeMeasurementData({
    required this.title,
    required this.icon,
    required this.value1,
    required this.value1Color,
    this.value2,
    this.value2Color,
    required this.unit,
  });
}

class HomeActivityData {
  final String icon;
  final String title;
  final String? description;

  HomeActivityData({
    required this.icon,
    required this.title,
    this.description,
  });
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
