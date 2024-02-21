#import <ReplayKit/ReplayKit.h>
#import "FlutterZoomVideoSdkShareHelper.h"
#import "JSONConvert.h"

@implementation FlutterZoomVideoSdkShareHelper

- (ZoomVideoSDKShareHelper *)getShareHelper
{
    ZoomVideoSDKShareHelper* shareHelper = nil;

    @try {
        shareHelper = [[ZoomVideoSDK shareInstance] getShareHelper];
        if (shareHelper == nil) {
            NSException *e = [NSException exceptionWithName:@"NoShareFound" reason:@"No Share Found" userInfo:nil];
            @throw e;
        }
    } @catch (NSException *e) {
        NSLog(@"%@ - %@", e.name, e.reason);
    }

    return shareHelper;
}

-(void) shareScreen: (FlutterResult) result
{
    if (@available(iOS 12.0, *)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            RPSystemBroadcastPickerView *broadcastView = [[RPSystemBroadcastPickerView alloc] init];

            UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
            [root.view addSubview:broadcastView];

            for (UIView *subView in broadcastView.subviews) {
                if ([subView isKindOfClass:[UIButton class]])
                {
                    UIButton *broadcastBtn = (UIButton *)subView;
                    [broadcastBtn sendActionsForControlEvents:UIControlEventAllTouchEvents];
                    break;
                }
            }

        });
    } else {
        // TODO: Should we just error our?
    }
}

-(void) shareView: (FlutterResult) result
{
    // TODO
}

-(void) lockShare:(FlutterMethodCall *)call withResult:(FlutterResult) result
{
    result([[JSONConvert ZoomVideoSDKErrorValuesReversed] objectForKey: @([[self getShareHelper] lockShare:[call.arguments[@"lock"] boolValue]])]);
}

-(void) stopShare: (FlutterResult) result
{
    dispatch_async(dispatch_get_main_queue(), ^{
        result([[JSONConvert ZoomVideoSDKErrorValuesReversed] objectForKey: @([[self getShareHelper] stopShare])]);
    });
}

-(void) isOtherSharing: (FlutterResult) result
{
    if ([[self getShareHelper] isOtherSharing]) {
        result(@YES);
    } else {
        result(@NO);
    }
}

-(void) isScreenSharingOut: (FlutterResult) result
{
    if ([[self getShareHelper] isScreenSharingOut]) {
        result(@YES);
    } else {
        result(@NO);
    }
}

-(void) isShareLocked: (FlutterResult) result
{
    if ([[self getShareHelper] isShareLocked]) {
        result(@YES);
    } else {
        result(@NO);
    }
}

-(void) isSharingOut: (FlutterResult) result
{
    if ([[self getShareHelper] isSharingOut]) {
        result(@YES);
    } else {
        result(@NO);
    }
}

-(void) isShareDeviceAudioEnabled: (FlutterResult) result
{
    if ([[self getShareHelper] isShareDeviceAudioEnabled]) {
        result(@YES);
    } else {
        result(@NO);
    }
}

-(void) enableShareDeviceAudio:(FlutterMethodCall *)call withResult:(FlutterResult) result
{
    if ([[self getShareHelper] enableShareDeviceAudio:call.arguments[@"enable"]]) {
        result(@YES);
    } else {
        result(@NO);
    }
}

-(void) isAnnotationFeatureSupport: (FlutterResult) result
{
    if ([[self getShareHelper] isAnnotationFeatureSupport]) {
        result(@YES);
    } else {
        result(@NO);
    }
}

-(void) disableViewerAnnotation:(FlutterMethodCall *)call withResult:(FlutterResult) result
{
    dispatch_async(dispatch_get_main_queue(), ^{
        result([[JSONConvert ZoomVideoSDKErrorValuesReversed] objectForKey: @([[self getShareHelper] disableViewerAnnotation:[call.arguments[@"disable"] boolValue]])]);
    });
}

-(void) isViewerAnnotationDisabled: (FlutterResult) result
{
    if ([[self getShareHelper] isViewerAnnotationDisabled]) {
        result(@YES);
    } else {
        result(@NO);
    }
}

@end
