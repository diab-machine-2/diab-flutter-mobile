package com.vbhc.diab;

import io.flutter.app.FlutterApplication;
import com.zing.zalo.zalosdk.oauth.ZaloSDKApplication;

import io.branch.referral.Branch;

public class Application extends FlutterApplication {
  @Override
  public void onCreate() {
    super.onCreate();
      // Branch logging for debugging
      Branch.enableLogging();
      // Branch object initialization
      Branch.getAutoInstance(this);
      ZaloSDKApplication.wrap(this);
      // Note: Flutter v2 embedding auto-registers plugins, no manual registration needed
  }
}
