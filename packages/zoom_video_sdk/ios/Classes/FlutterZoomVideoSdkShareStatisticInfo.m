#import "FlutterZoomVideoSdkShareStatisticInfo.h"
#import "FlutterZoomVideoSdkUser.h"

@implementation FlutterZoomVideoSdkShareStatisticInfo

-(void) getUserShareBpf: (FlutterMethodCall *)call withResult:(FlutterResult) result {
    ZoomVideoSDKUser *user = [FlutterZoomVideoSdkUser getUser: call.arguments[@"userId"]];
    if (user != nil) {
        result(@([[user getShareStatisticInfo] bps]));
    }
}

-(void) getUserShareFps: (FlutterMethodCall *)call withResult:(FlutterResult) result {
    ZoomVideoSDKUser *user = [FlutterZoomVideoSdkUser getUser: call.arguments[@"userId"]];
    if (user != nil) {
        result(@([[user getShareStatisticInfo] fps]));
    }
}

-(void) getUserShareHeight: (FlutterMethodCall *)call withResult:(FlutterResult) result {
    ZoomVideoSDKUser *user = [FlutterZoomVideoSdkUser getUser: call.arguments[@"userId"]];
    if (user != nil) {
        result(@([[user getShareStatisticInfo] height]));
    }
}

-(void) getUserShareWidth: (FlutterMethodCall *)call withResult:(FlutterResult) result {
    ZoomVideoSDKUser *user = [FlutterZoomVideoSdkUser getUser: call.arguments[@"userId"]];
    if (user != nil) {
        result(@([[user getShareStatisticInfo] width]));
    }
}

@end
