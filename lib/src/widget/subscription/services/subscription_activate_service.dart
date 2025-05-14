import 'dart:async';
import 'dart:developer';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:medical/src/app_setting/branchio_link_config.dart';
import 'package:medical/src/model/repository/app_repository.dart';

class SubscriptionActivateService {
  static final SubscriptionActivateService _instance =
      SubscriptionActivateService._internal();
  factory SubscriptionActivateService() => _instance;
  SubscriptionActivateService._internal();

  /// Activate package with improved UX
  Future<bool> activateSubscription(
      String accountId, BuildContext context) async {
    try {
      // Call API to activate subscription
      final result = await _startActivation(accountId);
      BranchioLinkConfig.instance.isActivatedSubscription = result;

      return result;
    } catch (e) {
      log('[SUBSCRIPTION] Activation error: ${e.toString()}');

      return false;
    }
  }

  /// Start the actual subscription activation API call
  Future<bool> _startActivation(String accountId) async {
    try {
      // BotToast.showCustomLoading(
      //   toastBuilder: (cancelFunc) {
      //     return Container(
      //       width: 300,
      //       padding: const EdgeInsets.all(16),
      //       decoration: BoxDecoration(
      //         color: R.color.color0xff111515.withOpacity(0.7),
      //         borderRadius: BorderRadius.circular(8),
      //       ),
      //       child: Column(
      //         mainAxisSize: MainAxisSize.min,
      //         children: [
      //           GapH(12),
      //           Text(
      //             R.string.waiting_active_subscription_content_1.tr(),
      //             textAlign: TextAlign.center,
      //             style: TextStyle(color: Colors.white, fontSize: 14),
      //           ),
      //         ],
      //       ),
      //     );
      //   },
      //   crossPage: true,
      //   backgroundColor: R.color.color0xff111515.withOpacity(0.7),
      //   backButtonBehavior: BackButtonBehavior.ignore,
      //   clickClose: true,
      //   allowClick: false,
      // );

      final apiResult =
          await AppRepository().subscriptionActivePackage(accountId);

      return await apiResult.when(success: (response) async {
        BotToast.closeAllLoading();
        return true;
      }, failure: (error) {
        BotToast.closeAllLoading();
        return false;
      });
    } catch (e) {
      log('[SUBSCRIPTION] API call error: ${e.toString()}');
      BotToast.closeAllLoading();
      return false;
    }
  }
}
