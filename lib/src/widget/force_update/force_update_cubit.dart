import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/app_setting/firebase_remote_config.dart';
import 'package:medical/src/utils/version_utils.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'force_update_state.dart';

/// Decides whether the installed app is below the minimum version configured
/// in Remote Config (`PLAY_STORE_VERSION` / `APP_STORE_VERSION`).
///
/// Dependencies are injected as functions so the cubit can be unit-tested
/// without Firebase / platform channels — see [ForceUpdateCubit.platform] for
/// the real wiring.
class ForceUpdateCubit extends Cubit<ForceUpdateState> {
  ForceUpdateCubit({
    required Future<String?> Function() currentVersion,
    required String? Function() requiredVersion,
    Future<void> Function()? waitUntilReady,
    Future<void> Function()? refreshRemote,
  })  : _currentVersion = currentVersion,
        _requiredVersion = requiredVersion,
        _waitUntilReady = waitUntilReady,
        _refreshRemote = refreshRemote,
        super(const ForceUpdateInitial());

  /// Production wiring: installed version from `PackageInfo`, required version
  /// from Remote Config for the current platform.
  factory ForceUpdateCubit.platform() {
    return ForceUpdateCubit(
      currentVersion: () async => (await PackageInfo.fromPlatform()).version,
      requiredVersion: () {
        if (Platform.isAndroid) {
          return FirebaseRemoteSetting.instance.playStoreVersion;
        }
        if (Platform.isIOS) {
          return FirebaseRemoteSetting.instance.appStoreVersion;
        }
        return null;
      },
      waitUntilReady: () => FirebaseRemoteSetting.instance.initialized,
      refreshRemote: () => FirebaseRemoteSetting.instance.refreshStoreVersions(),
    );
  }

  final Future<String?> Function() _currentVersion;
  final String? Function() _requiredVersion;
  final Future<void> Function()? _waitUntilReady;
  final Future<void> Function()? _refreshRemote;

  bool _ready = false;
  bool _checking = false;

  /// Cold-start check: waits for Remote Config to be initialised, then checks.
  Future<void> start() async {
    try {
      await _waitUntilReady?.call();
    } catch (e, s) {
      TrackingManager.recordError(e, s);
    }
    _ready = true;
    await check();
  }

  /// Re-evaluates the requirement. With [refresh], re-fetches Remote Config
  /// first (used on app resume). Ignored until [start] has finished waiting
  /// for Remote Config, and while another check is in flight.
  Future<void> check({bool refresh = false}) async {
    if (!_ready || _checking || isClosed) return;
    _checking = true;
    try {
      if (refresh) await _refreshRemote?.call();
      final current = await _currentVersion();
      final required = _requiredVersion();
      if (isClosed) return;
      if (isUpdateRequired(
          currentVersion: current, requiredVersion: required)) {
        emit(ForceUpdateRequired(required!.trim()));
      } else {
        emit(const ForceUpdateNotRequired());
      }
    } catch (e, s) {
      // Never block the user because of a failing check.
      TrackingManager.recordError(e, s);
    } finally {
      _checking = false;
    }
  }
}
