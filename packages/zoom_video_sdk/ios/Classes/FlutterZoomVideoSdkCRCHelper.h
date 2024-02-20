#import <Flutter/Flutter.h>
#import <ZoomVideoSDK/ZoomVideoSDK.h>

@interface FlutterZoomVideoSdkCRCHelper : NSObject

-(void) isCRCEnabled: (FlutterResult) result;

-(void) callCRCDevice: (FlutterMethodCall *)call withResult:(FlutterResult) result;

-(void) cancelCallCRCDevice: (FlutterResult) result;

@end

