part of 'force_update_cubit.dart';

sealed class ForceUpdateState {
  const ForceUpdateState();
}

class ForceUpdateInitial extends ForceUpdateState {
  const ForceUpdateInitial();
}

class ForceUpdateNotRequired extends ForceUpdateState {
  const ForceUpdateNotRequired();
}

class ForceUpdateRequired extends ForceUpdateState {
  /// Minimum version configured in Remote Config, shown in the popup.
  final String requiredVersion;

  const ForceUpdateRequired(this.requiredVersion);
}
