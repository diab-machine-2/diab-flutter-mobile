#import "FlutterZoomVideoSdkSessionDialInNumberInfo.h"
#import "JSONConvert.h"

@implementation FlutterZoomVideoSdkSessionDialInNumberInfo

+ (NSDictionary *)mapSessionDialInNumberInfoDictionary: (ZoomVideoSDKDialInNumberInfo*) sessionDialInNumberInfo {
    @try {
        NSMutableDictionary *mappedSessionDialInNumberInfo = [[NSMutableDictionary alloc] init];
        if (sessionDialInNumberInfo == nil) {
            return [JSONConvert NSDictionaryToNSString: mappedSessionDialInNumberInfo];
        }
        NSDictionary *dialInNumberInfoData = @{
                @"countryId": [sessionDialInNumberInfo countryID],
                @"countryCode": [sessionDialInNumberInfo countryCode],
                @"countryName": [sessionDialInNumberInfo countryName],
                @"number": [sessionDialInNumberInfo number],
                @"displayNumber": [sessionDialInNumberInfo displayNumber],
                @"type": [[JSONConvert ZoomVideoSDKDialInNumTypeValuesReversed] objectForKey: @([sessionDialInNumberInfo type])],
        };
        [mappedSessionDialInNumberInfo setDictionary:dialInNumberInfoData];
        return mappedSessionDialInNumberInfo;
    }
    @catch (NSException *e) {
        return @{};
    }
}

+ (NSString *)mapSessionDialInNumberInfo: (ZoomVideoSDKDialInNumberInfo*) sessionDialInNumberInfo {
    @try {
        NSMutableDictionary *mappedSessionDialInNumberInfo =
        [FlutterZoomVideoSdkSessionDialInNumberInfo mapSessionDialInNumberInfo: sessionDialInNumberInfo];
        return [JSONConvert NSDictionaryToNSString: mappedSessionDialInNumberInfo];
    }
    @catch (NSException *e) {
        return @"";
    }
}

+ (NSString *)mapSessionDialInNumberInfoArray: (NSArray <ZoomVideoSDKDialInNumberInfo*> *)dialInNumberInfoArray {
    NSMutableArray *mappedDialInNumberInfoArray = [NSMutableArray array];

    @try {
        [dialInNumberInfoArray enumerateObjectsUsingBlock:^(ZoomVideoSDKDialInNumberInfo * _Nonnull sessionDialInNumberInfo, NSUInteger idx, BOOL * _Nonnull stop) {
            [mappedDialInNumberInfoArray addObject: [FlutterZoomVideoSdkSessionDialInNumberInfo mapSessionDialInNumberInfo: sessionDialInNumberInfo]];
        }];
    }
    @finally {
        return [JSONConvert NSMutableArrayToNSString: mappedDialInNumberInfoArray];
    }
}

@end