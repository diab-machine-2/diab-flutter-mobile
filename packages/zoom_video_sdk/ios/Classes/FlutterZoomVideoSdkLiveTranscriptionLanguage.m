#import "FlutterZoomVideoSdkLiveTranscriptionLanguage.h"
#import "JSONConvert.h"

@implementation FlutterZoomVideoSdkLiveTranscriptionLanguage

+ (NSString *) mapLanguageDictionary: (ZoomVideoSDKLiveTranscriptionLanguage*) language {
    @try {
        NSMutableDictionary *mappedLanguage = [[NSMutableDictionary alloc] init];
        NSDictionary *languageData = @{
                @"languageId": @([language languageID]),
                @"languageName": [language languageName],
        };
        [mappedLanguage setDictionary:languageData];
        return [JSONConvert NSDictionaryToNSString: mappedLanguage];
    }
    @catch (NSException *e) {
        return @{};
    }
}

+ (NSString *) mapLanguage: (ZoomVideoSDKLiveTranscriptionLanguage*) language {
    @try {
        NSMutableDictionary *mappedLanguage = [[NSMutableDictionary alloc] init];

        NSDictionary *languageData =
            [FlutterZoomVideoSdkLiveTranscriptionLanguage mapLanguageDictionary: language];
        [mappedLanguage setDictionary:languageData];
        return [JSONConvert NSDictionaryToNSString: mappedLanguage];
    }
    @catch (NSException *e) {
        return @"";
    }
}

+ (NSString *)mapLanguageArray: (NSArray <ZoomVideoSDKLiveTranscriptionLanguage*> *)languageArray {
    NSMutableArray *mappedLanguageArray = [NSMutableArray array];

    @try {
        [languageArray enumerateObjectsUsingBlock:^(ZoomVideoSDKLiveTranscriptionLanguage * _Nonnull language, NSUInteger idx, BOOL * _Nonnull stop) {
            [mappedLanguageArray addObject: [FlutterZoomVideoSdkLiveTranscriptionLanguage mapLanguageDictionary: language]];
        }];
    }
    @finally {
        return [JSONConvert NSMutableArrayToNSString: mappedLanguageArray];
    }
}

@end
