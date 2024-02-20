#import <ZoomVideoSDK/ZoomVideoSDK.h>
#import "FlutterZoomView.h"
#import "FlutterZoomVideoSdkUser.h"
#import "FlutterZoomVideoSdkAnnotationHelper.h"
#import "JSONConvert.h"
#import "SDKPiPHelper.h"
#import "SDKCallKitManager.h"

@implementation FlutterZoomView {
    ZoomView *_view;
}

- (instancetype)initWithFrame:(CGRect)frame
                viewIdentifier:(int64_t)viewId
                arguments:(id _Nullable)args
                registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  if (self = [super init]) {
    _view = [[ZoomView alloc] initWithFrame: frame];
    _view.backgroundColor = [UIColor blackColor];

    NSDictionary *dictionary = [NSDictionary dictionaryWithDictionary:args];
    if (dictionary[@"videoAspect"]) {
        [_view setVideoAspect: dictionary[@"videoAspect"]];
    }
    if (dictionary[@"userId"]) {
        [_view setUserId: dictionary[@"userId"]];
    }
    if (dictionary[@"sharing"]) {
        [_view setSharing: [dictionary[@"sharing"] boolValue]];
    }
    if (dictionary[@"isPiPView"]) {
      [_view setIsPiPView: [dictionary[@"isPiPView"] boolValue]];
    }
    if (dictionary[@"preview"]) {
        [_view setPreview: [dictionary[@"preview"] boolValue]];
    }
    if (dictionary[@"hasMultiCamera"]) {
        [_view setHasMultiCamera: [dictionary[@"hasMultiCamera"] boolValue]];
    }
    if (dictionary[@"resolution"]) {
        [_view setVideoResolution:dictionary[@"resolution"]];
    }

  }
  return self;
}

- (UIView*)view {
  return _view;
}

@end


@implementation ZoomView {
    NSString* userId;
    BOOL sharing;
    BOOL preview;
    BOOL hasMultiCamera;
    BOOL isPiPView;
    NSString* multiCameraIndex;
    ZoomVideoSDKVideoAspect videoAspect;
    ZoomVideoSDKVideoCanvas* currentCanvas;
    ZoomVideoSDKVideoResolution videoResolution;
    ZoomVideoSDKAnnotationHelper* helper;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self setViewingCanvas];
}

- (void)setUserId:(NSString*)newUserId {
    if ([userId isEqualToString:newUserId]) {
        return;
    }
    userId = newUserId;
    [self setNeedsLayout];
}

- (void)setSharing:(BOOL)newSharing {
    if (sharing == newSharing) {
        return;
    }
    sharing = newSharing;
    [self setNeedsLayout];
}

- (void)setIsPiPView:(BOOL)newIsPiPView {
    if (isPiPView == newIsPiPView) {
        return;
    }
    if (newIsPiPView) {
        [[SDKPiPHelper shared] presetPiPWithSrcView:self];
        [[SDKCallKitManager sharedManager] startCallWithHandle:@"<Your Email>" complete:^{
            NSLog(@" ----CallKitManager startCall Complete ------");
            [[SDKPiPHelper shared] presetPiPWithSrcView:self];
        }];
    } else {
        [[SDKPiPHelper shared] cleanUpPictureInPicture];
    }
    isPiPView = newIsPiPView;
    [self setNeedsLayout];
}

- (void)setVideoAspect:(NSString*)newVideoAspect {
    ZoomVideoSDKVideoAspect aspect = [JSONConvert ZoomVideoSDKVideoAspect: newVideoAspect];
    if (videoAspect == aspect) {
        return;
    }
    videoAspect = aspect;
    [self setNeedsLayout];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview == nil && currentCanvas != nil) {
        [currentCanvas unSubscribeWithView: self];
    }
}

- (void)setHasMultiCamera:(BOOL)newHasMultiCamera {
    if (hasMultiCamera == newHasMultiCamera) {
        return;
    }
    hasMultiCamera = newHasMultiCamera;
    [self setViewingCanvas];
}

- (void)setMultCameraIndex:(NSString*)newIndex {
    if (multiCameraIndex == newIndex) {
        return;
    }
    multiCameraIndex = newIndex;
}

- (void)setPreview: (BOOL)newPreview {
    if (preview == newPreview) {
        return;
    }
    preview = newPreview;

    ZoomVideoSDKVideoHelper* videoHelper = [[ZoomVideoSDK shareInstance] getVideoHelper];
    if (preview == YES && currentCanvas == nil) {
        [videoHelper startVideoCanvasPreview: self andAspectMode: videoAspect];
        ZoomVideoSDKUser* user = [[[ZoomVideoSDK shareInstance] getSession] getMySelf];
        currentCanvas = [user getVideoCanvas];
    } else {
        [videoHelper stopVideoCanvasPreview: self];
        currentCanvas = nil;
    }
}

- (void)setVideoResolution:(NSString*)newVideoResolution {
    ZoomVideoSDKVideoResolution resolution = [JSONConvert ZoomVideoSDKVideoResolution: newVideoResolution];
    if (videoResolution == resolution) {
        return;
    }
    videoResolution = resolution;
    [self setNeedsLayout];
}

- (void)setViewingCanvas {
    if (currentCanvas != nil) {
        [currentCanvas unSubscribeWithView:self];
        currentCanvas = nil;
    }

    if (videoResolution == nil) {
        videoResolution = ZoomVideoSDKVideoResolution_Auto;
    }

    // Get the user
    ZoomVideoSDKUser *user = [FlutterZoomVideoSdkUser getUser:userId];

    // Get the canvas
    if (sharing) {
        currentCanvas = [user getShareCanvas];
        videoAspect = ZoomVideoSDKVideoAspect_Original;
        [[SDKPiPHelper shared] updatePiPVideoUser:user videoType:ZoomVideoSDKVideoType_ShareData];
    } else {
        videoAspect = ZoomVideoSDKVideoAspect_LetterBox;
        [[SDKPiPHelper shared] updatePiPVideoUser:user videoType:ZoomVideoSDKVideoType_VideoData];

        if (hasMultiCamera) {
            NSArray < ZoomVideoSDKVideoCanvas * >
            *multiCameraList = [user getMultiCameraCanvasList];
            NSInteger index = [multiCameraIndex integerValue];
            currentCanvas = multiCameraList[index];
        } else {
            currentCanvas = [user getVideoCanvas];
        }
    }

    // Subscribe User's videoCanvas to render their video stream.
    if (isPiPView) {
        [currentCanvas subscribeWithPiPView:self aspectMode:videoAspect andResolution:videoResolution];
    } else {
        [currentCanvas subscribeWithView:self aspectMode:videoAspect andResolution:videoResolution];
    }
    bool annotationEnable = [[[ZoomVideoSDK shareInstance] getShareHelper] isAnnotationFeatureSupport];
    if (sharing && annotationEnable && (helper == nil)) {
        helper = [[[ZoomVideoSDK shareInstance] getShareHelper] createAnnotationHelper:self];
        [[FlutterZoomVideoSdkAnnotationHelper alloc] setAnnotationHelper:helper];
    }
}
@end
