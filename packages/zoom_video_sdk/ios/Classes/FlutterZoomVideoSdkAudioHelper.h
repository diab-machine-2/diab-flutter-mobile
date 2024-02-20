#import <Flutter/Flutter.h>
#import <ZoomVideoSdk/ZoomVideoSDK.h>

@interface FlutterZoomVideoSdkAudioHelper: NSObject

-(void) canSwitchSpeaker: (FlutterResult) result;

-(void) getSpeakerStatus: (FlutterResult) result;

-(void) setSpeaker:(FlutterMethodCall *)call withResult:(FlutterResult) result;

-(void) startAudio: (FlutterResult) result;

-(void) stopAudio: (FlutterResult) result;

-(void) muteAudio:(FlutterMethodCall *)call withResult:(FlutterResult) result;

-(void) unMuteAudio:(FlutterMethodCall *)call withResult:(FlutterResult) result;

-(void) subscribe: (FlutterResult) result;

-(void) unSubscribe: (FlutterResult) result;

-(void) resetAudioSession: (FlutterResult) result;

-(void) cleanAudioSession: (FlutterResult) result;

@end