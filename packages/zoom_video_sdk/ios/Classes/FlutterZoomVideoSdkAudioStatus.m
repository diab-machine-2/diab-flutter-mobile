#import "JSONConvert.h"
#import "FlutterZoomVideoSdkAudioStatus.h"
#import "FlutterZoomVideoSdkUser.h"

@implementation FlutterZoomVideoSdkAudioStatus

-(void) isMuted:(FlutterMethodCall *)call withResult:(FlutterResult) result {
    ZoomVideoSDKUser *user = [FlutterZoomVideoSdkUser getUser: call.arguments[@"userId"]];
    if (user != nil) {
        if ([[user audioStatus] isMuted]) {
            result(@(YES));
        } else {
            result(@(NO));
        }
    }
}

-(void) isTalking:(FlutterMethodCall *)call withResult:(FlutterResult) result {
    ZoomVideoSDKUser *user = [FlutterZoomVideoSdkUser getUser: call.arguments[@"userId"]];
    if (user != nil) {
        if ([[user audioStatus] talking]) {
            result(@YES);
        } else {
            result(@NO);
        }
    }
}

-(void) getAudioType:(FlutterMethodCall *)call withResult:(FlutterResult) result {
    ZoomVideoSDKUser *user = [FlutterZoomVideoSdkUser getUser: call.arguments[@"userId"]];
    if (user != nil) {
        result([[JSONConvert ZoomVideoSDKAudioTypeValuesReversed] objectForKey: @([[user audioStatus] audioType])]);
    }
}

@end
