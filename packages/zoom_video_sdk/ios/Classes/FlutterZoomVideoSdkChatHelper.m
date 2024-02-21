#import "FlutterZoomVideoSdkChatHelper.h"
#import "FlutterZoomVideoSdkUser.h"
#import "JSONConvert.h"

@implementation FlutterZoomVideoSdkChatHelper

-(void) isChatDisabled: (FlutterResult) result {
    ZoomVideoSDKChatHelper* chatHelper = [[ZoomVideoSDK shareInstance] getChatHelper];
    if ([chatHelper IsChatDisabled]) {
        result(@YES);
    } else {
        result(@NO);
    }
}

-(void) isPrivateChatDisabled: (FlutterResult) result {
    ZoomVideoSDKChatHelper* chatHelper = [[ZoomVideoSDK shareInstance] getChatHelper];
    if ([chatHelper IsPrivateChatDisabled]) {
        result(@YES);
    } else {
        result(@NO);
    }
}

-(void) sendChatToUser: (FlutterMethodCall *)call withResult:(FlutterResult) result {
    ZoomVideoSDKChatHelper* chatHelper = [[ZoomVideoSDK shareInstance] getChatHelper];

    if (chatHelper.IsChatDisabled == NO && chatHelper.IsPrivateChatDisabled == NO) {
        ZoomVideoSDKUser* user = [FlutterZoomVideoSdkUser getUser: call.arguments[@"userId"]];

        dispatch_async(dispatch_get_main_queue(), ^{
            result([[JSONConvert ZoomVideoSDKErrorValuesReversed] objectForKey: @([chatHelper SendChatToUser:user Content: call.arguments[@"message"]])]);
        });
    }
}

-(void) sendChatToAll: (FlutterMethodCall *)call withResult:(FlutterResult) result {
    ZoomVideoSDKChatHelper* chatHelper = [[ZoomVideoSDK shareInstance] getChatHelper];

    if (chatHelper.IsChatDisabled == NO) {
        dispatch_async(dispatch_get_main_queue(), ^{
            result([[JSONConvert ZoomVideoSDKErrorValuesReversed] objectForKey: @([chatHelper SendChatToAll: call.arguments[@"message"]])]);
        });
    }
}

-(void) deleteChatMessage: (FlutterMethodCall *)call withResult:(FlutterResult) result {
    ZoomVideoSDKChatHelper* chatHelper = [[ZoomVideoSDK shareInstance] getChatHelper];

    if (chatHelper.IsChatDisabled == NO) {
        dispatch_async(dispatch_get_main_queue(), ^{
            result([[JSONConvert ZoomVideoSDKErrorValuesReversed] objectForKey: @([chatHelper deleteChatMessage: call.arguments[@"msgID"]])]);
        });
    }
}

-(void) canChatMessageBeDeleted: (FlutterMethodCall *)call withResult:(FlutterResult) result {
    ZoomVideoSDKChatHelper* chatHelper = [[ZoomVideoSDK shareInstance] getChatHelper];

    if (chatHelper.IsChatDisabled == NO) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([chatHelper canChatMessageBeDeleted: call.arguments[@"msgID"]]) {
                result(@YES);
            } else {
                result(@NO);
            }
        });
    }
}

-(void) changeChatPrivilege: (FlutterMethodCall *)call withResult:(FlutterResult) result {
    ZoomVideoSDKChatHelper* chatHelper = [[ZoomVideoSDK shareInstance] getChatHelper];
    NSString* privilege = call.arguments[@"privilege"];
    ZoomVideoSDKChatPrivilegeType type = [JSONConvert ZoomVideoSDKChatPrivilegeType: privilege];
    
    if (chatHelper.IsChatDisabled == NO) {
        dispatch_async(dispatch_get_main_queue(), ^{
            result([[JSONConvert ZoomVideoSDKErrorValuesReversed] objectForKey: @([chatHelper changeChatPrivilege: type])]);
        });
    }
}

-(void) getChatPrivilege: (FlutterResult) result {
    ZoomVideoSDKChatHelper* chatHelper = [[ZoomVideoSDK shareInstance] getChatHelper];

    if (chatHelper.IsChatDisabled == NO) {
        dispatch_async(dispatch_get_main_queue(), ^{
            result([[JSONConvert ZoomVideoSDKChatPrivilegeTypeValuesReversed] objectForKey: @([chatHelper getChatPrivilege])]);
        });
    }
}

@end
