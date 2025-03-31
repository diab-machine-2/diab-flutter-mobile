import 'package:medical/src/widget/helper/tracking_manager.dart';

class SubscriptionTracking {
  static Future<void> programExplore(int index) async {
    await TrackingManager.trackEvent(
      'program_explore',
      'program_banner',
      params: {
        'page_index': index,
      },
    );
  }

  static Future<void> programServiceSelect({required String objectTitle}) async {
    await TrackingManager.trackEvent(
      'program_service_select',
      'program_service',
      params: {
        'object_title': objectTitle,
      },
    );
  }

  static Future<void> serviceView({
    required String objectTitle,
  }) async {
    await TrackingManager.trackEvent(
      'service_view',
      'program_service',
      params: {
        'object_title': objectTitle,
      },
    );
  }

  static Future<void> programServiceRegister({
    required String screenName,
    required String objectTitle,
  }) async {
    await TrackingManager.trackEvent(
      'program_service_register',
      screenName,
      params: {
        'object_title': objectTitle,
      },
    );
  }

  static Future<void> supportClick({required String screenName}) async {
    await TrackingManager.trackEvent(
      'support_click',
      screenName,
    );
  }

  static Future<void> programView({
    required String? objectTitle,
    required String? objectAction,
  }) async {
    await TrackingManager.trackEvent(
      'program_view',
      'program_listing',
      params: {
        "screen_name": 'program_listing',
        'object_title': objectTitle,
        'object_action': objectAction,
      },
    );
  }

  static Future<void> programRequest({
    required String screenName,
    required String objectTitle,
  }) async {
    await TrackingManager.trackEvent(
      'program_request',
      screenName,
      params: {
        'object_title': objectTitle,
      },
    );
  }

  static Future<void> homeReturn({required String screenName}) async {
    await TrackingManager.trackEvent(
      'home_return',
      screenName,
    );
  }
}
