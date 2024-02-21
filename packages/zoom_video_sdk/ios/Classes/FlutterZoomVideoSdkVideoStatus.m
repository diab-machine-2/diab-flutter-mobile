#import "FlutterZoomVideoSdkVideoStatus.h"
#import "FlutterZoomVideoSdkUser.h"

@implementation FlutterZoomVideoSdkVideoStatus

-(void) isOn: (FlutterMethodCall *)call withResult:(FlutterResult) result {
    ZoomVideoSDKUser *user = [FlutterZoomVideoSdkUser getUser: call.arguments[@"userId"]];
    if (user != nil) {
        if ([[[user getVideoCanvas] videoStatus] on]) {
            result(@YES);
        } else {
            result(@NO);
        }
    }
}

@end
