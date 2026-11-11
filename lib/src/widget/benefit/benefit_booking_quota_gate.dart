import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/booking_check_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/utils/navigator_name.dart';

/// BE-7 quota check (`my-benefit/booking-check`) run before the user starts a
/// benefit booking, so a user without quota is stopped at the entry point
/// instead of after picking specialty, clinic and time.
///
/// Only a confirmed `allowed: false` blocks. Network errors or a backend
/// without the endpoint let the user through; `BenefitConfirmPage` checks
/// again right before booking.
class BenefitBookingQuotaGate {
  BenefitBookingQuotaGate._();

  /// Overridable in tests.
  @visibleForTesting
  static Future<ApiResult<BookingCheckResponse>> Function(String mode)
      fetchCheck = (mode) => AppRepository().benefitBookingCheck(mode);

  /// The blocking answer for [mode], or null when booking may go ahead.
  static Future<BookingCheckData?> blockingCheck(String mode) async {
    final result = await fetchCheck(mode);
    final check = result.whenOrNull(success: (r) => r.success ? r.data : null);
    if (check == null || check.allowed) return null;
    return check;
  }

  /// Returns true when the booking may go ahead; otherwise shows
  /// [BenefitQuotaDialog] and returns false.
  ///
  /// [showViewBenefits]: false when the caller already is the bundle page.
  static Future<bool> ensure(
    BuildContext context, {
    required bool atClinic,
    bool showViewBenefits = true,
  }) async {
    BotToast.showLoading();
    final BookingCheckData? blocked;
    try {
      blocked = await blockingCheck(AppRepository.benefitBookingMode(atClinic));
    } finally {
      BotToast.closeAllLoading();
    }
    if (blocked == null) return true;
    if (!context.mounted) return false;
    await BenefitQuotaDialog.show(context,
        check: blocked, showViewBenefits: showViewBenefits);
    return false;
  }
}

/// "Can't book" dialog: warning icon, title, the backend's reason, and
/// "Đóng" / "Xem quyền lợi" (same layout as the app's other `ic_warning`
/// dialogs, e.g. very high/low blood sugar).
class BenefitQuotaDialog extends StatelessWidget {
  const BenefitQuotaDialog({
    super.key,
    this.check,
    this.showViewBenefits = true,
  });

  /// The blocking `booking-check` answer; null = generic "out of quota".
  final BookingCheckData? check;
  final bool showViewBenefits;

  static Future<void> show(
    BuildContext context, {
    BookingCheckData? check,
    bool showViewBenefits = true,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => BenefitQuotaDialog(
        check: check,
        showViewBenefits: showViewBenefits,
      ),
    );
  }

  /// Quota used up → "Đã hết lượt đặt"; no bundle / mode not in the bundle →
  /// "Chưa thể đặt lịch".
  String get _title => check?.reason == null
      ? R.string.benefit_booking_quota_used_title.tr()
      : R.string.benefit_booking_unavailable_title.tr();

  String get _message {
    final message = check?.message?.trim() ?? '';
    return message.isNotEmpty ? message : R.string.benefit_out_of_quota.tr();
  }

  bool get _canViewBenefits =>
      showViewBenefits && !(check?.hasNoBundle ?? false);

  void _viewBenefits(BuildContext context) {
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    Navigator.of(context).pop();
    rootNavigator.pushNamed(NavigatorName.benefit_introduce_bundle);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: R.color.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(R.drawable.ic_warning, width: 64, height: 64),
            const SizedBox(height: 16),
            Text(
              _title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: R.color.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: R.style.normalTextStyle,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    label: R.string.close.tr(),
                    filled: false,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                if (_canViewBenefits) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DialogButton(
                      label: R.string.benefit_view_benefits.tr(),
                      filled: true,
                      onTap: () => _viewBenefits(context),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton(
      {required this.label, required this.filled, required this.onTap});

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(200),
          color: filled ? null : R.color.grayBorder,
          gradient: filled
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.centerRight,
                  colors: [
                    R.color.greenGradientTop,
                    R.color.greenGradientBottom,
                  ],
                )
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: filled ? R.color.white : R.color.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
