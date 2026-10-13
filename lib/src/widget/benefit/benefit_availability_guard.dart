import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/my_benefit_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widgets/custom_dialog.dart';

/// Re-checks `GET App/UserBundleOrders/my-benefit` before the user commits
/// to a benefit action, so a bundle removed server-side while the app is in
/// use can't be booked/consumed (the Docosan booking APIs don't check it).
///
/// "Unavailable" = success with `data == null`, or a 404 ([NotFound]) only.
/// Everything else — incl. [UnauthorizedRequest] / [BadRequest], which
/// `NetworkExceptions.handleResponse` also uses for 400/401/403 (e.g. an
/// expired token) — plus network errors, timeouts and 5xx are treated as
/// available, so neither auth nor a flaky connection is mis-shown as
/// "benefit removed"; the downstream API / auth flow surfaces its own error.
class BenefitAvailabilityGuard {
  BenefitAvailabilityGuard._();

  static const Duration cacheDuration = Duration(seconds: 60);

  /// After [handleUnavailable] completes, further calls within this window
  /// are ignored so overlapping triggers (guard + bundle page refresh, etc.)
  /// can't stack repeated dialogs/pops.
  static const Duration unavailableCooldown = Duration(seconds: 5);

  /// Overridable in tests.
  @visibleForTesting
  static Future<ApiResult<MyBenefitResponse>> Function() fetchMyBenefit =
      () => AppRepository().getMyBenefit();

  /// Overridable in tests.
  @visibleForTesting
  static DateTime Function() now = DateTime.now;

  static DateTime? _confirmedAvailableAt;
  static Future<bool>? _inFlight;
  static bool _isHandlingUnavailable = false;
  static DateTime? _lastHandledAt;

  static bool isUnavailableError(NetworkExceptions error) => error is NotFound;

  static bool isUnavailableResult(ApiResult<MyBenefitResponse> result) =>
      result.when(
        success: (response) => response.data == null,
        failure: isUnavailableError,
      );

  /// Returns `false` (and shows the "no longer available" dialog) only when
  /// the backend confirms the bundle is gone. Pass [origin] (the caller's
  /// `ModalRoute`) when the result may arrive late — see [handleUnavailable].
  static Future<bool> ensureAvailable({Route<dynamic>? origin}) async {
    final confirmedAt = _confirmedAvailableAt;
    if (confirmedAt != null && now().difference(confirmedAt) < cacheDuration) {
      return true;
    }
    final available = await (_inFlight ??= _check());
    if (!available) unawaited(handleUnavailable(origin: origin));
    return available;
  }

  static Future<bool> _check() async {
    try {
      final result = await fetchMyBenefit();
      if (isUnavailableResult(result)) return false;
      // Only cache a confirmed success — network errors re-check next time.
      if (result is Success<MyBenefitResponse>) _confirmedAvailableAt = now();
      return true;
    } catch (_) {
      return true;
    } finally {
      _inFlight = null;
    }
  }

  /// Shows one dialog per burst, refreshes Home (which flips `hasBundle` and
  /// the program tab), then returns the user to the tab bar.
  ///
  /// Only refreshes Home (no dialog, no pop) when [silent] is true, or when
  /// [origin] is given and no longer active — the user already left the
  /// screen that started the check, so popping would close unrelated screens.
  /// Ignored while one is in progress or within [unavailableCooldown].
  static Future<void> handleUnavailable({
    Route<dynamic>? origin,
    bool silent = false,
  }) async {
    invalidate();
    if (_isHandlingUnavailable) return;
    final lastHandledAt = _lastHandledAt;
    if (lastHandledAt != null &&
        now().difference(lastHandledAt) < unavailableCooldown) {
      return;
    }
    _isHandlingUnavailable = true;
    try {
      Observable.instance.notifyObservers([], notifyName: 'refresh_home');
      if (silent || (origin != null && !origin.isActive)) return;
      final context = navigatorKey.currentContext;
      if (context != null) {
        await CustomDialog.showErrorDialog(
          context,
          title: R.string.notification.tr(),
          message: R.string.benefit_no_longer_available.tr(),
        );
      }
      final navigatorContext = navigatorKey.currentContext;
      if (navigatorContext != null) {
        NavigationUtil.popUntilTabbar(navigatorContext);
      }
    } finally {
      _isHandlingUnavailable = false;
      _lastHandledAt = now();
    }
  }

  static void invalidate() => _confirmedAvailableAt = null;

  @visibleForTesting
  static void resetForTest() {
    invalidate();
    _inFlight = null;
    _isHandlingUnavailable = false;
    _lastHandledAt = null;
    fetchMyBenefit = () => AppRepository().getMyBenefit();
    now = DateTime.now;
  }
}
