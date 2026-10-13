import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:store_redirect/store_redirect.dart';

import 'force_update_cubit.dart';

/// App-wide mandatory update gate. Mounted in `MaterialApp.builder` (above the
/// Navigator), so the popup:
/// - covers every route (splash, login, tabbar, deep-linked pages) and can't
///   be removed by `pushReplacement` / `popUntil` / later route pushes;
/// - has no dismiss action — tapping "Cập nhật" opens the store and the popup
///   stays until a re-check (on resume) finds the app up to date.
///
/// Note: Android system back still reaches the Navigator underneath (it pops
/// hidden routes / backgrounds the app on the root route); the gate stays on
/// top and re-checks on resume, so the app remains unusable.
class ForceUpdateGate extends StatefulWidget {
  const ForceUpdateGate({
    super.key,
    required this.child,
    this.cubit,
    this.enabled = Const.ENVIRONMENT_DEFAULT == 'product',
  });

  final Widget child;

  /// Injectable for tests; defaults to [ForceUpdateCubit.platform].
  final ForceUpdateCubit? cubit;
  final bool enabled;

  @override
  State<ForceUpdateGate> createState() => _ForceUpdateGateState();
}

class _ForceUpdateGateState extends State<ForceUpdateGate>
    with WidgetsBindingObserver {
  late final ForceUpdateCubit _cubit =
      widget.cubit ?? ForceUpdateCubit.platform();

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      WidgetsBinding.instance.addObserver(this);
      _cubit.start();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _cubit.check(refresh: true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.cubit == null) _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForceUpdateCubit, ForceUpdateState>(
      bloc: _cubit,
      builder: (context, state) {
        if (state is! ForceUpdateRequired) return widget.child;
        return Stack(
          children: [
            // Keep the app mounted (state preserved) but unreachable.
            ExcludeFocus(child: widget.child),
            Positioned.fill(
              child: _ForceUpdatePopup(requiredVersion: state.requiredVersion),
            ),
          ],
        );
      },
    );
  }
}

class _ForceUpdatePopup extends StatelessWidget {
  const _ForceUpdatePopup({required this.requiredVersion});

  final String requiredVersion;

  Future<void> _openStore() async {
    try {
      final packageName = (await PackageInfo.fromPlatform()).packageName;
      await StoreRedirect.redirect(
        androidAppId: packageName,
        iOSAppId: Const.IOS_APP_STORE_ID,
      );
    } catch (e, s) {
      TrackingManager.recordError(e, s);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          ModalBarrier(
            dismissible: false,
            color: R.color.color0xff003F38.withValues(alpha: 0.5),
          ),
          Center(
            child: CupertinoAlertDialog(
              title: Text(R.string.cap_nhat.tr()),
              content: Text(
                R.string.mes_force_update_required.tr(args: [requiredVersion]),
                textAlign: TextAlign.center,
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: _openStore,
                  child: Text(R.string.cap_nhat.tr()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
