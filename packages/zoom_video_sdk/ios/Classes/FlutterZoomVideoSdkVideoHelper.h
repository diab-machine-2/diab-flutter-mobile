#import <Flutter/Flutter.h>
#import <ZoomVideoSdk/ZoomVideoSDK.h>

@interface FlutterZoomVideoSdkVideoHelper: NSObject

-(void) startVideo: (FlutterResult) result;

-(void) stopVideo: (FlutterResult) result;

-(void) rotateMyVideo: (FlutterMethodCall *)call withResult:(FlutterResult) result;

-(void) switchCamera;

-(void) setVideoQualityPreference: (FlutterMethodCall *)call withResult:(FlutterResult) result;

-(void) mirrorMyVideo: (FlutterMethodCall *)call withResult:(FlutterResult) result;

-(void) isMyVideoMirrored: (FlutterResult) result;

-(void) enableOriginalAspectRatio: (FlutterMethodCall *)call withResult:(FlutterResult) result;

-(void) isOriginalAspectRatioEnabled: (FlutterResult) result;

@end

