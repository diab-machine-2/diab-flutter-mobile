enum NotificationActionType {
  redirect_to_activity_tab,
  redirect_to_url,
  add_reminder,
  add_blood_sugar,
  none,
  share_profile,
  redirect_date_detail,
  redirect_survey,
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
  static NotificationActionType getNotificationActionTypeFromIndex(String? index) {
    if (index != null) {
      switch (index) {
        case "0":
          return NotificationActionType.redirect_to_activity_tab;
        case "1":
          return NotificationActionType.redirect_to_url;
        case "2":
          return NotificationActionType.add_reminder;
        case "3":
          return NotificationActionType.add_blood_sugar;
        case "4":
          return NotificationActionType.none;
        case "5":
          return NotificationActionType.share_profile;
        case "6":
          return NotificationActionType.redirect_date_detail;
        case "7":
          return NotificationActionType.redirect_survey;
        default:
          return NotificationActionType.redirect_to_url;
      }
    } else {
      return NotificationActionType.none;
    }
  }

  static NotificationActionType getNotificationActionTypeFromIndexInteger(int? index) {
    if (index != null) {
      switch (index) {
        case 0:
          return NotificationActionType.redirect_to_activity_tab;
        case 1:
          return NotificationActionType.redirect_to_url;
        case 2:
          return NotificationActionType.add_reminder;
        case 3:
          return NotificationActionType.add_blood_sugar;
        case 4:
          return NotificationActionType.none;
        case 5:
          return NotificationActionType.share_profile;
        case 6:
          return NotificationActionType.redirect_date_detail;
        case 7:
          return NotificationActionType.redirect_survey;
        default:
          return NotificationActionType.redirect_to_url;
      }
    } else {
      return NotificationActionType.none;
    }
  }
}
