#import "FlutterZoomVideoSdkVideoHelper.h"
#import "JSONConvert.h"

@implementation FlutterZoomVideoSdkVideoHelper

- (ZoomVideoSDKVideoHelper *)getVideoHelper {
 ZoomVideoSDKVideoHelper* videoHelper = nil;
 @try {
     videoHelper = [[ZoomVideoSDK shareInstance] getVideoHelper];
     if (videoHelper == nil) {
         NSException *e = [NSException exceptionWithName:@"NoVideoHelperFound" reason:@"No Video Helper Found" userInfo:nil];
         @throw e;
     }
 } @catch (NSException *e) {
     NSLog(@"%@ - %@", e.name, e.reason);
 }
 return videoHelper;
}

-(void) startVideo: (FlutterResult) result {
 dispatch_async(dispatch_get_main_queue(), ^{
     result([[JSONConvert ZoomVideoSDKErrorValuesReversed] objectForKey: @([[self getVideoHelper] startVideo])]);
 });
}

-(void) stopVideo: (FlutterResult) result {
 dispatch_async(dispatch_get_main_queue(), ^{
     result([[JSONConvert ZoomVideoSDKErrorValuesReversed] objectForKey: @([[self getVideoHelper] stopVideo])]);
 });
}

-(void) rotateMyVideo: (FlutterMethodCall *)call withResult:(FlutterResult) result {
 dispatch_async(dispatch_get_main_queue(), ^{
    if ([[self getVideoHelper] rotateMyVideo:(UIDeviceOrientation) call.arguments[@"rotation"]]) {
        result(@YES);
    } else {
        result(@NO);
    }
 });
}

-(void) switchCamera {
 dispatch_async(dispatch_get_main_queue(), ^{
     [[self getVideoHelper] switchCamera];
 });
}

-(void) mirrorMyVideo: (FlutterMethodCall *)call withResult:(FlutterResult) result {
    dispatch_async(dispatch_get_main_queue(), ^{
        result([[JSONConvert ZoomVideoSDKErrorValuesReversed] objectForKey: @([[self getVideoHelper] mirrorMyVideo: [call.arguments[@"enable"] boolValue]])]);
    });
}

-(void) isMyVideoMirrored: (FlutterResult) result {
    if ([[self getVideoHelper] isMyVideoMirrored]) {
        result(@YES);
    } else {
        result(@NO);
    }
}

-(void) enableOriginalAspectRatio: (FlutterMethodCall *)call withResult:(FlutterResult) result {
    dispatch_async(dispatch_get_main_queue(), ^{
        result(@([[self getVideoHelper] enableOriginalAspectRatio: [call.arguments[@"enabled"] boolValue]]));
    });
}

-(void) isOriginalAspectRatioEnabled: (FlutterResult) result {
    if ([[self getVideoHelper] isOriginalAspectRatioEnabled]) {
        result(@YES);
    } else {
        result(@NO);
    }
}

@end
