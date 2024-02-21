#import "FlutterZoomVideoSdkUserHelper.h"
#import "FlutterZoomVideoSdkUser.h"
#import "JSONConvert.h"

@implementation FlutterZoomVideoSdkUserHelper

-(void) changeName: (FlutterMethodCall *)call withResult:(FlutterResult) result {
    ZoomVideoSDKUserHelper* userHelper = [[ZoomVideoSDK shareInstance] getUserHelper];
    ZoomVideoSDKUser *user = [FlutterZoomVideoSdkUser getUser:call.arguments[@"userId"]];
    if (user != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([userHelper changeName:call.arguments[@"name"] withUser:user]) {
                result(@YES);
            } else {
                result(@NO);
            }
        });
    }
}

-(void) makeHost: (FlutterMethodCall *)call withResult:(FlutterResult) result {
    ZoomVideoSDKUserHelper* userHelper = [[ZoomVideoSDK shareInstance] getUserHelper];
    ZoomVideoSDKUser *user = [FlutterZoomVideoSdkUser getUser:call.arguments[@"userId"]];
    if (user != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([userHelper makeHost:user]) {
                result(@YES);
            } else {
                result(@NO);
            }
        });
    }
}

-(void) makeManager: (FlutterMethodCall *)call withResult:(FlutterResult) result {
    ZoomVideoSDKUserHelper* userHelper = [[ZoomVideoSDK shareInstance] getUserHelper];
    ZoomVideoSDKUser *user = [FlutterZoomVideoSdkUser getUser:call.arguments[@"userId"]];
    if (user != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([userHelper makeManager:user]) {
                result(@YES);
            } else {
                result(@NO);
            }
        });
    }
}

-(void) revokeManager: (FlutterMethodCall *)call withResult:(FlutterResult) result {
    ZoomVideoSDKUserHelper* userHelper = [[ZoomVideoSDK shareInstance] getUserHelper];
    ZoomVideoSDKUser *user = [FlutterZoomVideoSdkUser getUser:call.arguments[@"userId"]];
    if (user != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([userHelper revokeManager:user]) {
                result(@YES);
            } else {
                result(@NO);
            }
        });
    }
}

-(void) removeUser: (FlutterMethodCall *)call withResult:(FlutterResult) result {
    ZoomVideoSDKUserHelper* userHelper = [[ZoomVideoSDK shareInstance] getUserHelper];
    ZoomVideoSDKUser *user = [FlutterZoomVideoSdkUser getUser:call.arguments[@"userId"]];
    if (user != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            result(([[JSONConvert ZoomVideoSDKErrorValuesReversed] objectForKey: @([userHelper removeUser:user])]));
        });
    }
}

@end
