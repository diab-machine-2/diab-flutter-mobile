#import "FlutterZoomVideoSdkAudioHelper.h"
#import "FlutterZoomVideoSdkUser.h"
#import "JSONConvert.h"
#import <AVFAudio/AVAudioSession.h>

@implementation FlutterZoomVideoSdkAudioHelper

- (ZoomVideoSDKAudioHelper *)getAudioHelper {
    ZoomVideoSDKAudioHelper* audioHelper = nil;
    @try {
        audioHelper = [[ZoomVideoSDK shareInstance] getAudioHelper];
        if (audioHelper == nil) {
            NSException *e = [NSException exceptionWithName:@"NoAudioHelperFound" reason:@"No Audio Helper Found" userInfo:nil];
            @throw e;
        }
    } @catch (NSException *e) {
        NSLog(@"%@ - %@", e.name, e.reason);
    }
    return audioHelper;
}

-(void) canSwitchSpeaker: (FlutterResult) result {
    // There's no API for retrieving available outputs other than external devices
    // since iOS devices always have "Speaker".
    result(@YES);
}

-(void) getSpeakerStatus: (FlutterResult) result {
    for (AVAudioSessionPortDescription *output in [[[AVAudioSession sharedInstance] currentRoute] outputs]) {
        if ([[output portType] isEqualToString:@"Speaker"]) {
            result(@YES);
        } else {
            result(@NO);
        }
    }
}

-(void) setSpeaker:(FlutterMethodCall *)call withResult:(FlutterResult) result {
    NSError *error;
    AVAudioSessionPortOverride override =  [call.arguments[@"isOn"] boolValue] ? AVAudioSessionPortOverrideSpeaker : AVAudioSessionPortOverrideNone;
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:override error:&error];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    if (error) {
        NSLog(@"%@", error);
    } else {
        result(@"ZoomVideoSDKError_Success");
    }
}

-(void) startAudio: (FlutterResult) result {
    dispatch_async(dispatch_get_main_queue(), ^{
        result([[JSONConvert ZoomVideoSDKErrorValuesReversed] objectForKey: @([[self getAudioHelper] startAudio])]);
    });
}

-(void) stopAudio: (FlutterResult) result {
    dispatch_async(dispatch_get_main_queue(), ^{
        result([[JSONConvert ZoomVideoSDKErrorValuesReversed] objectForKey: @([[self getAudioHelper] stopAudio])]);
    });
}

-(void) muteAudio:(FlutterMethodCall *)call withResult:(FlutterResult) result {
    dispatch_async(dispatch_get_main_queue(), ^{
        ZoomVideoSDKUser *user = [FlutterZoomVideoSdkUser getUser: call.arguments[@"userId"]];
        result([[JSONConvert ZoomVideoSDKErrorValuesReversed] objectForKey: @([[self getAudioHelper] muteAudio:user])]);
    });
}

-(void) unMuteAudio:(FlutterMethodCall *)call withResult:(FlutterResult) result {
    dispatch_async(dispatch_get_main_queue(), ^{
        ZoomVideoSDKUser *user = [FlutterZoomVideoSdkUser getUser: call.arguments[@"userId"]];
        result([[JSONConvert ZoomVideoSDKErrorValuesReversed] objectForKey: @([[self getAudioHelper] unmuteAudio:user])]);
    });
}

-(void) subscribe: (FlutterResult) result {
    dispatch_async(dispatch_get_main_queue(), ^{
        result([[JSONConvert ZoomVideoSDKErrorValuesReversed] objectForKey: @([[self getAudioHelper] subscribe])]);
    });
}

-(void) unSubscribe: (FlutterResult) result {
    dispatch_async(dispatch_get_main_queue(), ^{
        result([[JSONConvert ZoomVideoSDKErrorValuesReversed] objectForKey: @([[self getAudioHelper] unSubscribe])]);
    });
}

-(void) resetAudioSession: (FlutterResult) result {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[self getAudioHelper] resetAudioSession]) {
            result(@YES);
        } else {
            result(@NO);
        }
    }
  );
}

-(void) cleanAudioSession: (FlutterResult) result {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self getAudioHelper] cleanAudioSession];
    });
}

@end
