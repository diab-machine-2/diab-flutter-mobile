import 'package:flutter/widgets.dart';

/// Largest system font scale the app follows. Android's top settings (1.8 /
/// 2.0, often picked by older users) together with a large display size
/// pushed buttons and whole options off screen (e.g. "Nhập thủ công" in the
/// input-method sheets). 1.5 still gives clearly bigger text than default.
const double kMaxAppTextScale = 1.5;

/// The system [scaler], capped at [kMaxAppTextScale]. Smaller-than-default
/// settings are left untouched.
TextScaler appTextScaler(TextScaler scaler) =>
    scaler.clamp(maxScaleFactor: kMaxAppTextScale);
