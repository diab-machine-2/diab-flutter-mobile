#import "FlutterZoomVideoSdkILiveTranscriptionMessageInfo.h"
#import "JSONConvert.h"

@implementation FlutterZoomVideoSdkILiveTranscriptionMessageInfo

+ (NSString *) mapMessageInfo: (ZoomVideoSDKLiveTranscriptionMessageInfo*) messageInfo {
    @try {
            NSMutableDictionary *mappedMessageInfo = [[NSMutableDictionary alloc] init];
            if (messageInfo == nil) {
                return [JSONConvert NSDictionaryToNSString: mappedMessageInfo];
            }
            NSDictionary *messageInfoData = @{
                    @"messageID": [messageInfo messageID],
                    @"messageContent": [messageInfo messageContent],
                    @"messageType": [[JSONConvert ZoomVideoSDKLiveTranscriptionOperationTypeValuesReversed] objectForKey: @([messageInfo messageType])],
                    @"speakerID": [messageInfo speakerID],
                    @"speakerName": [messageInfo speakerName],
                    @"timeStamp": [NSString stringWithFormat:@"%d",[messageInfo timeStamp]],
            };
            [mappedMessageInfo setDictionary:messageInfoData];
            return [JSONConvert NSDictionaryToNSString: mappedMessageInfo];
        }
        @catch (NSException *e) {
            return @"";
        }
}

+ (NSString *) mapMessageInfoArray: (NSArray <ZoomVideoSDKLiveTranscriptionMessageInfo*>*) messageInfoArray {
    NSMutableArray *mappedMessageInfoArray = [NSMutableArray array];

    @try {
        [messageInfoArray enumerateObjectsUsingBlock:^(ZoomVideoSDKLiveTranscriptionMessageInfo * _Nonnull messageInfo, NSUInteger idx, BOOL * _Nonnull stop) {
            [mappedMessageInfoArray addObject: [FlutterZoomVideoSdkILiveTranscriptionMessageInfo mapMessageInfo: messageInfo]];
        }];
    }
    @finally {
        return [JSONConvert NSMutableArrayToNSString: mappedMessageInfoArray];
    }
}

@end
