enum NotificationActionType {
  redirect_to_activity_tab,
  redirect_to_url,
  add_reminder,
  add_blood_sugar,
  none,
  share_profile,
}

extension NotificationActionExtend on NotificationActionType {
  static NotificationActionType getNotificationActionTypeFromIndex(int? index) {
    if (index == NotificationActionType.redirect_to_activity_tab.index)
      return NotificationActionType.redirect_to_activity_tab;
    if (index == NotificationActionType.redirect_to_url.index)
      return NotificationActionType.redirect_to_url;
    if (index == NotificationActionType.add_reminder.index)
      return NotificationActionType.add_reminder;
    if (index == NotificationActionType.add_blood_sugar.index)
      return NotificationActionType.add_blood_sugar;
    if (index == NotificationActionType.none.index)
      return NotificationActionType.none;
    if (index == NotificationActionType.share_profile.index)
      return NotificationActionType.share_profile;
    return NotificationActionType.redirect_to_url;
  }
}
