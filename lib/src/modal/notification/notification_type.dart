enum NotificationActionType {
  redirect_to_activity_tab,
  redirect_to_url,
  add_reminder,
  add_blood_sugar,
  none,
  share_profile,
  redirect_date_detail,
}

enum NotificationType {
  CREATE_ACCOUNT,
  HAPPY_BIRTHDAY,
  JOIN_PACKAGE,
  JOIN_GROUP,
  TARGET_START_DAY,
  TARGET_END_DAY,
  TARGET_START_WEEK,
  TARGET_END_WEEK,
  REMIND_COACH_MINUTE,
  REMIND_COACH_DAY,
  ACTIVITY,
  SURVEY,
}

extension NotificationActionExtend on NotificationActionType {
  static NotificationActionType getNotificationActionTypeFromIndex(int? index) {
    if (index == NotificationType.CREATE_ACCOUNT.index + 1) return NotificationActionType.redirect_to_url;
    if (index == NotificationType.HAPPY_BIRTHDAY.index + 1 ||
        index == NotificationType.JOIN_GROUP.index + 1 ||
        index == NotificationType.ACTIVITY.index + 1 ||
        index == NotificationType.SURVEY.index + 1) return NotificationActionType.none;
    if (index == NotificationType.JOIN_PACKAGE.index + 1 ||
        index == NotificationType.TARGET_START_DAY.index + 1 ||
        index == NotificationType.TARGET_END_DAY.index + 1 ||
        index == NotificationType.TARGET_START_WEEK.index + 1 ||
        index == NotificationType.TARGET_END_WEEK.index + 1) return NotificationActionType.redirect_to_activity_tab;
    if (index == NotificationType.REMIND_COACH_MINUTE.index + 1 || index == NotificationType.REMIND_COACH_DAY.index + 1)
      return NotificationActionType.redirect_date_detail;

    // if (index == 0) return NotificationActionType.add_reminder;
    // if (index == 0) return NotificationActionType.add_blood_sugar;
    // if (index == 0) return NotificationActionType.share_profile;

    return NotificationActionType.redirect_to_url;
  }
}
