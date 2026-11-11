/// BE-7 benefit booking quota, returned by `my-benefit/booking-check` and
/// `my-benefit/booking-use` (the latter with the quota left afterwards).
///
/// Failures come back as HTTP 200 with `meta.success == false` and the reason
/// in `error.message`, so callers must check [success].
class BookingCheckResponse {
  BookingCheckResponse({
    required this.success,
    this.data,
    this.errorMessage,
  });

  final bool success;
  final BookingCheckData? data;
  final String? errorMessage;

  factory BookingCheckResponse.fromJson(dynamic json) {
    final data = json['data'];
    return BookingCheckResponse(
      success: json['meta']?['success'] == true,
      data: data is Map<String, dynamic> ? BookingCheckData.fromJson(data) : null,
      errorMessage: json['error']?['message']?.toString(),
    );
  }
}

class BookingCheckData {
  BookingCheckData({
    this.mode,
    this.allowed = false,
    this.isUnlimited = false,
    this.remaining = 0,
    this.message,
    this.reason,
  });

  /// `online` (telemedicine) or `offline` (at a clinic).
  final String? mode;
  final bool allowed;

  /// An unlimited bundle reports `remaining: 0`; rely on [allowed].
  final bool isUnlimited;
  final int remaining;

  /// Why booking isn't allowed (e.g. "Đã hết lượt đặt").
  final String? message;

  /// Machine-readable [message]: `no_bundle` (no active bundle),
  /// `not_included` (the bundle has no item for this mode), or null when
  /// [allowed] / when the quota is simply used up.
  final String? reason;

  /// No active bundle → nothing to show on the bundle page.
  bool get hasNoBundle => reason == 'no_bundle';

  factory BookingCheckData.fromJson(Map<String, dynamic> json) {
    return BookingCheckData(
      mode: json['mode']?.toString(),
      allowed: json['allowed'] == true,
      isUnlimited: json['isUnlimited'] == true,
      remaining: (json['remaining'] as num?)?.toInt() ?? 0,
      message: json['message']?.toString(),
      reason: json['reason']?.toString(),
    );
  }
}
