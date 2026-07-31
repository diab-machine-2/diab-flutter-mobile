import 'package:flutter/material.dart';

/// Scoped navigator key for the Benefit booking flow.
///
/// [BenefitPage] and [BenefitRescheduleFlow] each create their own
/// [GlobalKey<NavigatorState>] and expose it through this scope so that all
/// descendant Benefit pages can navigate without touching the shared
/// [DsmesNavigationMixin] static state.
class BenefitNavigatorScope extends InheritedWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const BenefitNavigatorScope({
    Key? key,
    required this.navigatorKey,
    required Widget child,
  }) : super(key: key, child: child);

  /// Returns the nearest [BenefitNavigatorScope]'s navigator key.
  static GlobalKey<NavigatorState> of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<BenefitNavigatorScope>();
    assert(scope != null,
        'BenefitNavigatorScope not found. Wrap with BenefitPage or BenefitRescheduleFlow.');
    return scope!.navigatorKey;
  }

  /// Navigates on the scoped inner navigator, falling back to the root
  /// navigator if the inner one cannot pop (e.g. when at the root of
  /// [BenefitRescheduleFlow]'s stack).
  static void popOrRoot(BuildContext context) {
    final key = of(context);
    if (key.currentState?.canPop() ?? false) {
      key.currentState?.pop();
    } else {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  bool updateShouldNotify(BenefitNavigatorScope oldWidget) =>
      navigatorKey != oldWidget.navigatorKey;
}
