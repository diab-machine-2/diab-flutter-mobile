package com.flutterzoom.videosdk;

import android.app.Activity;

import androidx.annotation.NonNull;

import com.flutterzoom.videosdk.convert.FlutterZoomVideoSdkErrors;

import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import us.zoom.sdk.ZoomVideoSDK;
import us.zoom.sdk.ZoomVideoSDKRemoteCameraControlHelper;
import us.zoom.sdk.ZoomVideoSDKUser;

public class FlutterZoomVideoSdkRemoteCameraControlHelper {

    private Activity activity;

    FlutterZoomVideoSdkRemoteCameraControlHelper(Activity activity) {
        this.activity = activity;
    }

    private ZoomVideoSDKRemoteCameraControlHelper getRemoteCameraControlHelper() {
        ZoomVideoSDKRemoteCameraControlHelper remoteCameraControlHelper = null;
        try {
            ZoomVideoSDKUser mySelf = ZoomVideoSDK.getInstance().getSession().getMySelf();
            remoteCameraControlHelper = mySelf.getRemoteCameraControlHelper();
            if (remoteCameraControlHelper == null) {
                throw new Exception("No Remote Camera Control Helper Found");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return remoteCameraControlHelper;
    }

    public void requestControlRemoteCamera(@NonNull MethodChannel.Result result) {
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                result.success(FlutterZoomVideoSdkErrors.valueOf(getRemoteCameraControlHelper().requestControlRemoteCamera()));
            }
        });
    }

    public void giveUpControlRemoteCamera(@NonNull MethodChannel.Result result) {
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                result.success(FlutterZoomVideoSdkErrors.valueOf(getRemoteCameraControlHelper().giveUpControlRemoteCamera()));
            }
        });
    }

    public void turnLeft(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Map<String, Object> params = call.arguments();
        int range = (Integer) params.get("range");

        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                result.success(FlutterZoomVideoSdkErrors.valueOf(getRemoteCameraControlHelper().turnLeft(range)));
            }
        });
    }

    public void turnRight(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Map<String, Object> params = call.arguments();
        int range = (Integer) params.get("range");

        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                result.success(FlutterZoomVideoSdkErrors.valueOf(getRemoteCameraControlHelper().turnRight(range)));
            }
        });
    }

    public void turnDown(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Map<String, Object> params = call.arguments();
        int range = (Integer) params.get("range");

        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                result.success(FlutterZoomVideoSdkErrors.valueOf(getRemoteCameraControlHelper().turnDown(range)));
            }
        });
    }

    public void turnUp(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Map<String, Object> params = call.arguments();
        int range = (Integer) params.get("range");

        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                result.success(FlutterZoomVideoSdkErrors.valueOf(getRemoteCameraControlHelper().turnUp(range)));
            }
        });
    }

    public void zoomIn(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Map<String, Object> params = call.arguments();
        int range = (Integer) params.get("range");

        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                result.success(FlutterZoomVideoSdkErrors.valueOf(getRemoteCameraControlHelper().zoomIn(range)));
            }
        });
    }

    public void zoomOut(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Map<String, Object> params = call.arguments();
        int range = (Integer) params.get("range");

        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                result.success(FlutterZoomVideoSdkErrors.valueOf(getRemoteCameraControlHelper().zoomOut(range)));
            }
        });
    }
}

