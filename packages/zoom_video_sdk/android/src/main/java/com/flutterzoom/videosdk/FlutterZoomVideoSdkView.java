package com.flutterzoom.videosdk;

import android.content.Context;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.flutterzoom.videosdk.convert.*;

import java.util.List;
import java.util.Map;

import io.flutter.plugin.platform.PlatformView;
import us.zoom.sdk.ZoomVideoSDK;
import us.zoom.sdk.ZoomVideoSDKUser;
import us.zoom.sdk.ZoomVideoSDKVideoAspect;
import us.zoom.sdk.ZoomVideoSDKVideoCanvas;
import us.zoom.sdk.ZoomVideoSDKVideoHelper;
import us.zoom.sdk.ZoomVideoSDKVideoResolution;
import us.zoom.sdk.ZoomVideoSDKVideoView;

public class FlutterZoomVideoSdkView implements PlatformView {

    private ZoomVideoSDKVideoView videoView;
    private ZoomVideoSDKVideoCanvas currentCanvas;
    private String userId = "";
    private boolean sharing = false;
    private ZoomVideoSDKVideoAspect videoAspect = ZoomVideoSDKVideoAspect.ZoomVideoSDKVideoAspect_Original;
    private boolean preview = false;
    private boolean hasMultiCamera = false;
    private String multiCameraIndex = "";
    private Context context;
    private ZoomVideoSDKVideoResolution resolution;


    FlutterZoomVideoSdkView(@NonNull Context context, int id, @NonNull Map<String, Object> creationParams) {
        videoView = new ZoomVideoSDKVideoView(context);
        videoView.setZOrderMediaOverlay(true);


        if (creationParams.containsKey("userId")) {
            setUserId((String) creationParams.get("userId"));
        }
        if (creationParams.containsKey("sharing")) {
            setSharing((boolean) creationParams.get("sharing"));
        }
        if (creationParams.containsKey("hasMultiCamera")) {
            setHasMultiCamera((boolean) creationParams.get("hasMultiCamera"));
        }
        if (creationParams.containsKey("multiCameraIndex")) {
            setMultiCameraIndex((String) creationParams.get("multiCameraIndex"));
        }
        if (creationParams.containsKey("fullScreen")) {
            setFullScreen(videoView, (boolean) creationParams.get("fullScreen"));
        }
        if (creationParams.containsKey("aspect")) {
            setAspect((String) creationParams.get("aspect"));
        }
        if (creationParams.containsKey("preview")) {
            setPreview(videoView, (boolean) creationParams.get("preview"));
        }
        if (creationParams.containsKey("resolution")) {
            setResolution((String) creationParams.get("resolution"));
        }
        setViewingCanvas();
    }

    public void setUserId(String newUserId) {
        if (newUserId.equals(userId)) {
            return;
        }
        this.userId = newUserId;
    }

    public void setSharing(boolean newSharing) {
        if (sharing == newSharing) {
            return;
        }
        this.sharing = newSharing;
    }

    public void setHasMultiCamera(boolean newHasMultiCamera) {
        if (hasMultiCamera == newHasMultiCamera) {
            return;
        }
        this.hasMultiCamera = newHasMultiCamera;
    }

    public void setMultiCameraIndex(String newIndex) {
        if (multiCameraIndex == newIndex) {
            return;
        }
        this.multiCameraIndex = newIndex;
    }

    public void setFullScreen(ZoomVideoSDKVideoView videoView, Boolean fullScreen) {
        videoView.setZOrderOnTop(!fullScreen);
    }

    public void setAspect(String newVideoAspect) {
        ZoomVideoSDKVideoAspect aspect = FlutterZoomVideoSdkVideoAspect.valueOf(newVideoAspect);
        if (videoAspect == aspect) {
            return;
        }
        this.videoAspect = aspect;
    }

    public void setPreview(ZoomVideoSDKVideoView videoView, boolean newPreview) {
        if (preview == newPreview) {
            return;
        }
        this.preview = newPreview;

        ZoomVideoSDKVideoHelper videoHelper = ZoomVideoSDK.getInstance().getVideoHelper();
        if (preview && currentCanvas == null) {
            videoHelper.startVideoCanvasPreview(videoView, videoAspect);
            ZoomVideoSDKUser user = ZoomVideoSDK.getInstance().getSession().getMySelf();
            currentCanvas = user.getVideoCanvas();
        } else {
            videoHelper.stopVideoCanvasPreview(videoView);
            currentCanvas = null;
        }
    }

    private void setResolution(String videoResolution) {
        ZoomVideoSDKVideoResolution resolution = FlutterZoomVideoSdkVideoResolution.valueOf(videoResolution);
        if (resolution == this.resolution) {
            return;
        }
        this.resolution = resolution;
    }

    private void setViewingCanvas()
    {
        ZoomVideoSDKUser user = FlutterZoomVideoSdkUser.getUser(userId);
        if (user == null) return;
        if (currentCanvas != null) {
            currentCanvas.unSubscribe(videoView);
            currentCanvas = null;
        }

        if (sharing) {
            currentCanvas = user.getShareCanvas();
        } else if (hasMultiCamera) {
            List<ZoomVideoSDKVideoCanvas> multiCameraList = user.getMultiCameraCanvasList();
            int index = Integer.parseInt(multiCameraIndex);
            currentCanvas = multiCameraList.get(index);
        } else {
            currentCanvas = user.getVideoCanvas();
        }
        currentCanvas.subscribe(videoView, videoAspect, resolution);
    }

    @Nullable
    @Override
    public View getView() {
        return videoView;
    }

    @Override
    public void dispose() {
        videoView = null;
    }
}
