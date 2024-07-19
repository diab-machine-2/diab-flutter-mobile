import 'package:in_app_review/in_app_review.dart';

class RatingService {
  static final InAppReview _inAppReview = InAppReview.instance;

  static Future<bool> showRating() async {
    try {
      final available = await _inAppReview.isAvailable();
      if (available) {
        _inAppReview.requestReview();
        print("show request review success");
      } else {
        _inAppReview.openStoreListing(
          appStoreId: '1569353448',
        );
      }
      return true;
    } catch (e) {
      print("show request review fail");
      return false;
    }
  }
}
