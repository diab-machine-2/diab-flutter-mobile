import 'package:medical/src/widget/helper/helper.dart';

/// "HH:mm - dd/MM/yyyy" for a notification's `sentDateTime` (epoch seconds),
/// or null when the backend has no send time. Callers hide the date line on
/// null instead of formatting 0, which showed "07:00 - 01/01/1970".
String? notificationSentLabel(int? sentDateTime) {
  if (sentDateTime == null || sentDateTime <= 0) return null;
  return convertToUTC(sentDateTime, 'HH:mm - dd/MM/yyyy');
}
