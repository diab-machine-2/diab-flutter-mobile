#import "FlutterZoomVideoSdkUser.h"
#import "JSONConvert.h"

@implementation FlutterZoomVideoSdkUser

+ (NSString *)mapUser: (ZoomVideoSDKUser*) user {
    @try {
        NSDictionary* userDic =  @{
            @"userId": [@([user getUserID]) stringValue],
            @"customUserId": [user getCustomUserId],
            @"userName": [user getUserName],
            @"isHost": @([user isHost]),
            @"isManager": @([user isManager]),
        };
        return [JSONConvert NSDictionaryToNSString: userDic];
    }
    @catch (NSException *e) {
        return @"{}";
    }
}

+ (NSDictionary *)mapUserDictionary: (ZoomVideoSDKUser*) user {
    @try {
        return  @{
            @"userId": [@([user getUserID]) stringValue],
            @"customUserId": [user getCustomUserId],
            @"userName": [user getUserName],
            @"isHost": @([user isHost]),
            @"isManager": @([user isManager]),
        };
    }
    @catch (NSException *e) {
        return @{};
    }
}

+ (NSString *)mapUserArray: (NSArray<ZoomVideoSDKUser *> *)userArray {
    NSMutableArray *mappedUserArray = [NSMutableArray array];

    @try {
        [userArray enumerateObjectsUsingBlock:^(ZoomVideoSDKUser * _Nonnull user, NSUInteger idx, BOOL * _Nonnull stop) {
            [mappedUserArray addObject: [self mapUserDictionary: user]];
        }];
    }
    @finally {
        if ([mappedUserArray count] > 0) {
            return [JSONConvert NSMutableArrayToNSString: mappedUserArray];
        } else {
            return @"[]";
        }
    }
}

+ (ZoomVideoSDKUser *)getUser:(NSString*)userId {
    // Check if the user is ourself?
    ZoomVideoSDKUser* myUser = [[[ZoomVideoSDK shareInstance] getSession] getMySelf];
    
    if ([myUser getUserID] == [userId intValue]) {
        return myUser;
    }
    
    // Wasn't us, try remote users
    NSArray<ZoomVideoSDKUser *>* remoteUsers = [[[ZoomVideoSDK shareInstance] getSession] getRemoteUsers];
    for (ZoomVideoSDKUser* user in remoteUsers) {
        if ([user getUserID] == [userId intValue]) {
            return user;
        }
    }
    
    return nil;
}

-(void) getUserName: (FlutterMethodCall *)call withResult:(FlutterResult) result {
    ZoomVideoSDKUser *user = [FlutterZoomVideoSdkUser getUser: call.arguments[@"userId"]];
    if (user != nil) {
        result([user getUserName]);
    }
}

-(void) getShareStatus:(FlutterMethodCall *)call withResult:(FlutterResult) result {
    ZoomVideoSDKUser *user = [FlutterZoomVideoSdkUser getUser: call.arguments[@"userId"]];
    if (user != nil) {
        result([[JSONConvert ZoomVideoSDKReceiveSharingStatusValuesReversed] objectForKey: @([[[user getShareCanvas] shareStatus] sharingStatus])]);
    }
}

-(void) isHost:(FlutterMethodCall *)call withResult:(FlutterResult) result {
    ZoomVideoSDKUser *user = [FlutterZoomVideoSdkUser getUser: call.arguments[@"userId"]];
    if (user != nil) {
        if ([user isHost]) {
            result(@YES);
        } else {
            result(@NO);
        }
    }
}

-(void) isManager:(FlutterMethodCall *)call withResult:(FlutterResult) result {
    ZoomVideoSDKUser *user = [FlutterZoomVideoSdkUser getUser: call.arguments[@"userId"]];
    if (user != nil) {
        if ([user isManager]) {
            result(@YES);
        } else {
            result(@NO);
        }
    }
}

-(void) getMultiCameraCanvasList:(FlutterMethodCall *)call withResult:(FlutterResult) result {
    ZoomVideoSDKUser *user = [FlutterZoomVideoSdkUser getUser: call.arguments[@"userId"]];
    if (user != nil) {
        result([JSONConvert NSMutableArrayToNSString: [user getMultiCameraCanvasList]]);
    }
}

-(void) hasIndividualRecordingConsent:(FlutterMethodCall *)call withResult:(FlutterResult) result {
    ZoomVideoSDKUser *user = [FlutterZoomVideoSdkUser getUser: call.arguments[@"userId"]];
    if (user != nil) {
        if ([user isIndividualRecordAgreed]) {
            result(@YES);
        } else {
            result(@NO);
        }
    }
}

-(void) setUserVolume:(FlutterMethodCall *)call withResult:(FlutterResult) result {
    ZoomVideoSDKUser *user = [FlutterZoomVideoSdkUser getUser: call.arguments[@"userId"]];
    if (user != nil) {
        if ([user setUserVolume: [call.arguments[@"volume"] floatValue] isShareAudio: [call.arguments[@"isSharingAudio"] boolValue]]) {
            result(@YES);
        } else {
            result(@NO);
        }
    }
}

-(void) getUserVolume:(FlutterMethodCall *)call withResult:(FlutterResult) result {
    ZoomVideoSDKUser *user = [FlutterZoomVideoSdkUser getUser: call.arguments[@"userId"]];
    if (user != nil) {
        float volume;
        [user getUserVolume: &volume isShareAudio: [call.arguments[@"isSharingAudio"] boolValue]];
        result(@(volume));
    }
}

-(void) canSetUserVolume:(FlutterMethodCall *)call withResult:(FlutterResult) result {
    ZoomVideoSDKUser *user = [FlutterZoomVideoSdkUser getUser: call.arguments[@"userId"]];
    if (user != nil) {
        if ([user canSetUserVolume: [call.arguments[@"isSharingAudio"] boolValue]]) {
            result(@YES);
        } else {
            result(@NO);
        }
    }
}

@end
