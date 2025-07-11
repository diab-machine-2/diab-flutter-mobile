class SubscriptionPaymentState {
  final bool isActive;
  final bool willRenew;
  final String? entitlementId;
  final String? productId;
  final DateTime? expirationDate;
  
  SubscriptionPaymentState._({
    required this.isActive,
    required this.willRenew,
    this.entitlementId,
    this.productId,
    this.expirationDate,
  });
  
  factory SubscriptionPaymentState.none() {
    return SubscriptionPaymentState._(isActive: false, willRenew: false);
  }

  factory SubscriptionPaymentState.active({
    required String entitlementId,
    required DateTime expirationDate,
    required String productId,
  }) {
    return SubscriptionPaymentState._(
      isActive: true,
      willRenew: false,
      entitlementId: entitlementId,
      expirationDate: expirationDate,
      productId: productId,
    );
  }

  factory SubscriptionPaymentState.activeRenewing({
    required String entitlementId,
    required DateTime expirationDate,
    required String productId,
  }) {
    return SubscriptionPaymentState._(
      isActive: true,
      willRenew: true,
      entitlementId: entitlementId,
      expirationDate: expirationDate,
      productId: productId,
    );
  }
  
  factory SubscriptionPaymentState.activeCancelled({
    required String entitlementId,
    required DateTime expirationDate,
    required String productId,
  }) {
    return SubscriptionPaymentState._(
      isActive: true,
      willRenew: false,
      entitlementId: entitlementId,
      expirationDate: expirationDate,
      productId: productId,
    );
  }
  
  String get statusText {
    if (!isActive) return "No active subscription";
    if (willRenew) return "Active subscription";
    return "Subscription ending soon";
  }
  
  bool get isExpiringSoon {
    if (expirationDate == null) return false;
    final now = DateTime.now();
    final difference = expirationDate!.difference(now);
    return !willRenew && difference.inDays < 7;
  }
}