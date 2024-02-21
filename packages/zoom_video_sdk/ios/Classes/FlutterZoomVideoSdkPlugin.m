#import <ZoomVideoSdk/ZoomVideoSDK.h>
#import "FlutterZoomVideoSdkPlugin.h"
#import "JSONConvert.h"
#import "FlutterZoomVideoSdkSession.h"
#import "FlutterZoomVideoSdkUser.h"
#import "FlutterZoomVideoSdkAudioHelper.h"
#import "FlutterZoomVideoSdkAudioSettingHelper.h"
#import "FlutterZoomVideoSdkAudioStatus.h"
#import "FlutterZoomVideoSdkChatHelper.h"
#import "FlutterZoomVideoSdkCmdChannel.h"
#import "FlutterZoomVideoSdkLiveStreamHelper.h"
#import "FlutterZoomVideoSdkLiveTranscriptionHelper.h"
#import "FlutterZoomVideoSdkPhoneHelper.h"
#import "FlutterZoomVideoSdkRecordingHelper.h"
#import "FlutterZoomVideoSdkSessionStatisticsInfo.h"
#import "FlutterZoomVideoSdkShareStatisticInfo.h"
#import "FlutterZoomVideoSdkTestAudioDeviceHelper.h"
#import "FlutterZoomVideoSdkUserHelper.h"
#import "FlutterZoomVideoSdkVideoHelper.h"
#import "FlutterZoomVideoSdkVideoStatisticInfo.h"
#import "FlutterZoomVideoSdkVideoStatus.h"
#import "FlutterZoomVideoSdkChatMessage.h"
#import "FlutterZoomVideoSdkLiveTranscriptionLanguage.h"
#import "FlutterZoomVideoSdkILiveTranscriptionMessageInfo.h"
#import "FlutterZoomVideoSdkShareHelper.h"
#import "FlutterZoomVideoSdkVirtualBackgroundHelper.h"
#import "FlutterZoomViewViewFactory.h"
#import "FlutterZoomVideoSdkCRCHelper.h"
#import "FlutterZoomVideoSdkAnnotationHelper.h"

@implementation FlutterZoomVideoSdkPlugin

static ZoomVideoSDKRecordAgreementHandler* recordAgreementHandler;

FlutterMethodChannel* channel;
FlutterEventChannel* eventChannel;

FlutterZoomVideoSdkSession* flutterZoomVideoSdkSession;
FlutterZoomVideoSdkUser* flutterZoomVideoSdkUser;
FlutterZoomVideoSdkAudioHelper* flutterZoomVideoSdkAudioHelper;
FlutterZoomVideoSdkAudioSettingHelper* flutterZoomVideoSdkAudioSettingHelper;
FlutterZoomVideoSdkAudioStatus* flutterZoomVideoSdkAudioStatus;
FlutterZoomVideoSdkChatHelper* flutterZoomVideoSdkChatHelper;
FlutterZoomVideoSdkCmdChannel* flutterZoomVideoSdkCmdChannel;
FlutterZoomVideoSdkLiveStreamHelper* flutterZoomVideoSdkLiveStreamHelper;
FlutterZoomVideoSdkLiveTranscriptionHelper* flutterZoomVideoSdkLiveTranscriptionHelper;
FlutterZoomVideoSdkPhoneHelper* flutterZoomVideoSdkPhoneHelper;
FlutterZoomVideoSdkRecordingHelper* flutterZoomVideoSdkRecordingHelper;
FlutterZoomVideoSdkSessionStatisticsInfo* flutterZoomVideoSdkSessionStatisticsInfo;
FlutterZoomVideoSdkShareStatisticInfo* flutterZoomVideoSdkShareStatisticInfo;
FlutterZoomVideoSdkTestAudioDeviceHelper* flutterZoomVideoSdkTestAudioDeviceHelper;
FlutterZoomVideoSdkUserHelper* flutterZoomVideoSdkUserHelper;
FlutterZoomVideoSdkVideoHelper* flutterZoomVideoSdkVideoHelper;
FlutterZoomVideoSdkVideoStatisticInfo* flutterZoomVideoSdkVideoStatisticInfo;
FlutterZoomVideoSdkVideoStatus* flutterZoomVideoSdkVideoStatus;
FlutterZoomVideoSdkShareHelper* flutterZoomVideoSdkShareHelper;
FlutterZoomVideoSdkVirtualBackgroundHelper* flutterZoomVideoSdkVirtualBackgroundHelper;
FlutterZoomVideoSdkCRCHelper* flutterZoomVideoSdkCRCHelper;
FlutterZoomVideoSdkAnnotationHelper* flutterZoomVideoSdkAnnotationHelper;

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_zoom_videosdk"
            binaryMessenger:[registrar messenger]];
  FlutterZoomVideoSdkPlugin* instance = [[FlutterZoomVideoSdkPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
  [registrar addApplicationDelegate:instance];
  eventChannel = [FlutterEventChannel
                                        eventChannelWithName:@"eventListener"
                                        binaryMessenger:[registrar messenger]];
  [eventChannel setStreamHandler:instance];
  FlutterZoomViewViewFactory* factory =
        [[FlutterZoomViewViewFactory alloc] initWithMessenger:registrar.messenger];
  [registrar registerViewFactory:factory withId:@"<platform-view-type>"];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  flutterZoomVideoSdkSession = [[FlutterZoomVideoSdkSession alloc] init];
  flutterZoomVideoSdkUser = [[FlutterZoomVideoSdkUser alloc] init];
  flutterZoomVideoSdkAudioHelper = [[FlutterZoomVideoSdkAudioHelper alloc] init];
  flutterZoomVideoSdkAudioSettingHelper = [[FlutterZoomVideoSdkAudioSettingHelper alloc] init];
  flutterZoomVideoSdkAudioStatus = [[FlutterZoomVideoSdkAudioStatus alloc] init];
  flutterZoomVideoSdkChatHelper = [[FlutterZoomVideoSdkChatHelper alloc] init];
  flutterZoomVideoSdkCmdChannel = [[FlutterZoomVideoSdkCmdChannel alloc] init];
  flutterZoomVideoSdkLiveStreamHelper = [[FlutterZoomVideoSdkLiveStreamHelper alloc] init];
  flutterZoomVideoSdkLiveTranscriptionHelper = [[FlutterZoomVideoSdkLiveTranscriptionHelper alloc] init];
  flutterZoomVideoSdkPhoneHelper = [[FlutterZoomVideoSdkPhoneHelper alloc] init];
  flutterZoomVideoSdkRecordingHelper = [[FlutterZoomVideoSdkRecordingHelper alloc] init];
  flutterZoomVideoSdkSessionStatisticsInfo = [[FlutterZoomVideoSdkSessionStatisticsInfo alloc] init];
  flutterZoomVideoSdkTestAudioDeviceHelper = [[FlutterZoomVideoSdkTestAudioDeviceHelper alloc] init];
  flutterZoomVideoSdkUserHelper = [[FlutterZoomVideoSdkUserHelper alloc] init];
  flutterZoomVideoSdkVideoHelper = [[FlutterZoomVideoSdkVideoHelper alloc] init];
  flutterZoomVideoSdkVideoStatisticInfo = [[FlutterZoomVideoSdkVideoStatisticInfo alloc] init];
  flutterZoomVideoSdkVideoStatus = [[FlutterZoomVideoSdkVideoStatus alloc] init];
  flutterZoomVideoSdkShareHelper = [[FlutterZoomVideoSdkShareHelper alloc] init];
  flutterZoomVideoSdkVirtualBackgroundHelper = [[FlutterZoomVideoSdkVirtualBackgroundHelper alloc] init];
  flutterZoomVideoSdkCRCHelper = [[FlutterZoomVideoSdkCRCHelper alloc] init];
  flutterZoomVideoSdkAnnotationHelper = [[FlutterZoomVideoSdkAnnotationHelper alloc] init];

  if ([@"initSdk" isEqualToString:call.method]) {
    return [self initSDK:call withResult:result];
   } else if ([@"joinSession" isEqualToString:call.method]) {
    return [self joinSession:call withResult:result];
   } else if ([@"leaveSession" isEqualToString:call.method]) {
    return [self leaveSession:call withResult:result];
   } else if ([@"getSdkVersion" isEqualToString:call.method]) {
    return [self getSdkVersion:result];
   } else if ([@"cleanup" isEqualToString:call.method]) {
    return [self cleanup:result];
   } else if ([@"acceptRecordingConsent" isEqualToString:call.method]) {
    return [self acceptRecordingConsent:result];
   } else if ([@"declineRecordingConsent" isEqualToString:call.method]) {
    return [self declineRecordingConsent:result];
   } else if ([@"getRecordingConsentType" isEqualToString:call.method]) {
    return [self getRecordingConsentType:result];
   } else if ([@"getMySelf" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkSession getMySelf:result];
   } else if ([@"getRemoteUsers" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkSession getRemoteUsers:result];
   } else if ([@"getSessionHost" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkSession getSessionHost:result];
   } else if ([@"getSessionHostName" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkSession getSessionHostName:result];
   } else if ([@"getSessionName" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkSession getSessionName:result];
   } else if ([@"getSessionID" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkSession getSessionID:result];
   } else if ([@"getSessionPassword" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkSession getSessionPassword:result];
   } else if ([@"getSessionNumber" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkSession getSessionNumber:result];
   } else if ([@"getSessionPhonePasscode" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkSession getSessionPhonePasscode:result];
   } else if ([@"getUserName" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkUser getUserName:call withResult:result];
   } else if ([@"getShareStatus" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkUser getShareStatus:call withResult:result];
   } else if ([@"isHost" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkUser isHost:call withResult:result];
   } else if ([@"isManager" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkUser isManager:call withResult:result];
   } else if ([@"getMultiCameraCanvasList" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkUser getMultiCameraCanvasList:call withResult:result];
   } else if ([@"getUserVolume" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkUser getUserVolume:call withResult:result];
   } else if ([@"setUserVolume" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkUser setUserVolume:call withResult:result];
   } else if ([@"canSetUserVolume" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkUser canSetUserVolume:call withResult:result];
   } else if ([@"canSwitchSpeaker" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkAudioHelper canSwitchSpeaker:result];
   } else if ([@"getSpeakerStatus" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkAudioHelper getSpeakerStatus:result];
   } else if ([@"muteAudio" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkAudioHelper muteAudio:call withResult:result];
   } else if ([@"unMuteAudio" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkAudioHelper unMuteAudio:call withResult:result];
   } else if ([@"setSpeaker" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkAudioHelper setSpeaker:call withResult:result];
   } else if ([@"startAudio" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkAudioHelper startAudio:result];
   } else if ([@"stopAudio" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkAudioHelper stopAudio:result];
   } else if ([@"subscribe" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkAudioHelper subscribe:result];
   } else if ([@"unSubscribe" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkAudioHelper unSubscribe:result];
   } else if ([@"resetAudioSession" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkAudioHelper resetAudioSession:result];
   } else if ([@"cleanAudioSession" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkAudioHelper cleanAudioSession:result];
   } else if ([@"isMicOriginalInputEnable" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkAudioSettingHelper isMicOriginalInputEnable:result];
   } else if ([@"enableMicOriginalInput" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkAudioSettingHelper enableMicOriginalInput:call withResult:result];
   } else if ([@"isAutoAdjustMicVolumeEnabled" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkAudioSettingHelper isAutoAdjustMicVolumeEnabled:result];
   } else if ([@"enableAutoAdjustMicVolume" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkAudioSettingHelper enableAutoAdjustMicVolume:call withResult:result];
   } else if ([@"isMuted" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkAudioStatus isMuted:call withResult:result];
   } else if ([@"isTalking" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkAudioStatus isTalking:call withResult:result];
   } else if ([@"getAudioType" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkAudioStatus getAudioType:call withResult:result];
   } else if ([@"isChatDisabled" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkChatHelper isChatDisabled:result];
   } else if ([@"isPrivateChatDisabled" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkChatHelper isPrivateChatDisabled:result];
   } else if ([@"sendChatToUser" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkChatHelper sendChatToUser:call withResult:result];
   } else if ([@"sendChatToAll" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkChatHelper sendChatToAll:call withResult:result];
   } else if ([@"deleteChatMessage" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkChatHelper deleteChatMessage:call withResult:result];
   } else if ([@"canChatMessageBeDeleted" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkChatHelper canChatMessageBeDeleted:call withResult:result];
   } else if ([@"changeChatPrivilege" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkChatHelper changeChatPrivilege:call withResult:result];
   } else if ([@"getChatPrivilege" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkChatHelper getChatPrivilege:result];
   } else if ([@"sendCommand" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkCmdChannel sendCommand:call withResult:result];
   } else if ([@"canStartLiveStream" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkLiveStreamHelper canStartLiveStream:result];
   } else if ([@"startLiveStream" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkLiveStreamHelper startLiveStream:call withResult:result];
   } else if ([@"stopLiveStream" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkLiveStreamHelper stopLiveStream:result];
   } else if ([@"canStartLiveTranscription" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkLiveTranscriptionHelper canStartLiveTranscription:result];
   } else if ([@"getLiveTranscriptionStatus" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkLiveTranscriptionHelper getLiveTranscriptionStatus:result];
   } else if ([@"startLiveTranscription" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkLiveTranscriptionHelper startLiveTranscription: result];
   } else if ([@"stopLiveTranscription" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkLiveTranscriptionHelper stopLiveTranscription: result];
   } else if ([@"getAvailableSpokenLanguages" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkLiveTranscriptionHelper getAvailableSpokenLanguages: result];
   } else if ([@"setSpokenLanguage" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkLiveTranscriptionHelper setSpokenLanguage:call withResult:result];
   } else if ([@"getSpokenLanguage" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkLiveTranscriptionHelper getSpokenLanguage: result];
   } else if ([@"getAvailableTranslationLanguages" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkLiveTranscriptionHelper getAvailableTranslationLanguages: result];
   } else if ([@"setTranslationLanguage" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkLiveTranscriptionHelper setTranslationLanguage:call withResult:result];
   } else if ([@"getTranslationLanguage" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkLiveTranscriptionHelper getTranslationLanguage:result];
   } else if ([@"isReceiveSpokenLanguageContentEnabled" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkLiveTranscriptionHelper isReceiveSpokenLanguageContentEnabled:result];
   } else if ([@"enableReceiveSpokenLanguageContent" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkLiveTranscriptionHelper enableReceiveSpokenLanguageContent:call withResult: result];
   } else if ([@"isAllowViewHistoryTranslationMessageEnabled" isEqualToString:call.method]) {
     return [flutterZoomVideoSdkLiveTranscriptionHelper isAllowViewHistoryTranslationMessageEnabled:result];
   } else if ([@"getHistoryTranslationMessageList" isEqualToString:call.method]) {
     return [flutterZoomVideoSdkLiveTranscriptionHelper getHistoryTranslationMessageList:result];
   } else if ([@"cancelInviteByPhone" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkPhoneHelper cancelInviteByPhone: result];
   } else if ([@"getInviteByPhoneStatus" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkPhoneHelper getInviteByPhoneStatus: result];
   } else if ([@"getSupportCountryInfo" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkPhoneHelper getSupportCountryInfo: result];
   } else if ([@"inviteByPhone" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkPhoneHelper inviteByPhone:call withResult: result];
   } else if ([@"isSupportPhoneFeature" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkPhoneHelper isSupportPhoneFeature: result];
   } else if ([@"getSessionDialInNumbers" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkPhoneHelper getSessionDialInNumbers:result];
   } else if ([@"canStartRecording" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkRecordingHelper canStartRecording: result];
   } else if ([@"startCloudRecording" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkRecordingHelper startCloudRecording: result];
   } else if ([@"stopCloudRecording" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkRecordingHelper stopCloudRecording: result];
   } else if ([@"pauseCloudRecording" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkRecordingHelper pauseCloudRecording: result];
   } else if ([@"resumeCloudRecording" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkRecordingHelper resumeCloudRecording: result];
   } else if ([@"getCloudRecordingStatus" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkRecordingHelper getCloudRecordingStatus:result];
   } else if ([@"getAudioStatisticsInfo" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkSessionStatisticsInfo getAudioStatisticsInfo: result];
   } else if ([@"getVideoStatisticsInfo" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkSessionStatisticsInfo getVideoStatisticsInfo: result];
   } else if ([@"getShareStatisticsInfo" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkSessionStatisticsInfo getShareStatisticsInfo: result];
   } else if ([@"getUserShareBpf" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkShareStatisticInfo getUserShareBpf:call withResult:result];
   } else if ([@"getUserShareFps" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkShareStatisticInfo getUserShareFps:call withResult:result];
   } else if ([@"getUserShareHeight" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkShareStatisticInfo getUserShareHeight:call withResult:result];
   } else if ([@"getUserShareWidth" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkShareStatisticInfo getUserShareWidth:call withResult:result];
   } else if ([@"startMicTest" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkTestAudioDeviceHelper startMicTest: result];
   } else if ([@"stopMicTest" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkTestAudioDeviceHelper stopMicTest: result];
   } else if ([@"playMicTest" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkTestAudioDeviceHelper playMicTest: result];
   } else if ([@"startSpeakerTest" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkTestAudioDeviceHelper startSpeakerTest:result];
   } else if ([@"stopSpeakerTest" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkTestAudioDeviceHelper stopSpeakerTest: result];
   } else if ([@"changeName" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkUserHelper changeName:call withResult:result];
   } else if ([@"makeHost" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkUserHelper makeHost:call withResult:result];
   } else if ([@"makeManager" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkUserHelper makeManager:call withResult:result];
   } else if ([@"revokeManager" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkUserHelper revokeManager:call withResult:result];
   } else if ([@"removeUser" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkUserHelper removeUser:call withResult:result];
   } else if ([@"rotateMyVideo" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkVideoHelper rotateMyVideo:call withResult:result];
   } else if ([@"startVideo" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkVideoHelper startVideo: result];
   } else if ([@"stopVideo" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkVideoHelper stopVideo:result];
   } else if ([@"switchCamera" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkVideoHelper switchCamera];
   } else if ([@"mirrorMyVideo" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkVideoHelper mirrorMyVideo:call withResult:result];
   } else if ([@"isMyVideoMirrored" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkVideoHelper isMyVideoMirrored: result];
   } else if ([@"enableOriginalAspectRatio" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkVideoHelper enableOriginalAspectRatio:call withResult:result];
   } else if ([@"isOriginalAspectRatioEnabled" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkVideoHelper isOriginalAspectRatioEnabled: result];
   } else if ([@"getUserVideoBpf" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkVideoStatisticInfo getUserVideoBpf:call withResult:result];
   } else if ([@"getUserVideoFps" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkVideoStatisticInfo getUserVideoFps:call withResult:result];
   } else if ([@"getUserVideoHeight" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkVideoStatisticInfo getUserVideoHeight:call withResult:result];
   } else if ([@"getUserVideoWidth" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkVideoStatisticInfo getUserVideoWidth:call withResult:result];
   } else if ([@"isOn" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkVideoStatus isOn:call withResult:result];
   } else if ([@"shareScreen" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkShareHelper shareScreen:result];
   } else if ([@"shareView" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkShareHelper shareView:result];
   } else if ([@"lockShare" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkShareHelper lockShare:call withResult: result];
   } else if ([@"stopShare" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkShareHelper stopShare:result];
   } else if ([@"isOtherSharing" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkShareHelper isOtherSharing:result];
   } else if ([@"isScreenSharingOut" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkShareHelper isScreenSharingOut:result];
   } else if ([@"isShareLocked" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkShareHelper isShareLocked:result];
   } else if ([@"isSharingOut" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkShareHelper isSharingOut:result];
   } else if ([@"isShareDeviceAudioEnabled" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkShareHelper isShareDeviceAudioEnabled:result];
   } else if ([@"enableShareDeviceAudio" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkShareHelper enableShareDeviceAudio:call withResult:result];
   } else if ([@"isAnnotationFeatureSupport" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkShareHelper isAnnotationFeatureSupport:result];
   } else if ([@"disableViewerAnnotation" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkShareHelper disableViewerAnnotation:call withResult:result];
   } else if ([@"isViewerAnnotationDisabled" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkShareHelper isViewerAnnotationDisabled:result];
   } else if ([@"isSupportVirtualBackground" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkVirtualBackgroundHelper isSupportVirtualBackground:result];
   } else if ([@"addVirtualBackgroundItem" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkVirtualBackgroundHelper addVirtualBackgroundItem:call withResult:result];
   } else if ([@"removeVirtualBackgroundItem" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkVirtualBackgroundHelper removeVirtualBackgroundItem:call withResult:result];
   } else if ([@"setVirtualBackgroundItem" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkVirtualBackgroundHelper setVirtualBackgroundItem:call withResult:result];
   } else if ([@"getVirtualBackgroundItemList" isEqualToString:call.method]) {
    return [flutterZoomVideoSdkVirtualBackgroundHelper getVirtualBackgroundItemList:result];
   } else if ([@"openBrowser" isEqualToString:call.method]) {
     return [self openBrowser:call withResult:result];
   } else if ([@"isCRCEnabled" isEqualToString:call.method]) {
     return [flutterZoomVideoSdkCRCHelper isCRCEnabled:result];
   } else if ([@"callCRCDevice" isEqualToString:call.method]) {
     return [flutterZoomVideoSdkCRCHelper callCRCDevice:call withResult:result];
   } else if ([@"cancelCallCRCDevice" isEqualToString:call.method]) {
      return [flutterZoomVideoSdkCRCHelper cancelCallCRCDevice:result];
   } else if ([@"isSenderDisableAnnotation" isEqualToString:call.method]) {
      return [flutterZoomVideoSdkAnnotationHelper isSenderDisableAnnotation:result];
   } else if ([@"startAnnotation" isEqualToString:call.method]) {
      return [flutterZoomVideoSdkAnnotationHelper startAnnotation:result];
   } else if ([@"stopAnnotation" isEqualToString:call.method]) {
      return [flutterZoomVideoSdkAnnotationHelper stopAnnotation:result];
   } else if ([@"setToolColor" isEqualToString:call.method]) {
      return [flutterZoomVideoSdkAnnotationHelper setToolColor:call withResult:result];
   } else if ([@"getToolColor" isEqualToString:call.method]) {
      return [flutterZoomVideoSdkAnnotationHelper getToolColor:result];
   } else if ([@"setToolType" isEqualToString:call.method]) {
      return [flutterZoomVideoSdkAnnotationHelper setToolType:call withResult:result];
   } else if ([@"getToolType" isEqualToString:call.method]) {
      return [flutterZoomVideoSdkAnnotationHelper getToolType:result];
   } else if ([@"setToolWidth" isEqualToString:call.method]) {
      return [flutterZoomVideoSdkAnnotationHelper setToolWidth:call withResult:result];
   } else if ([@"getToolWidth" isEqualToString:call.method]) {
      return [flutterZoomVideoSdkAnnotationHelper getToolWidth:result];
   } else if ([@"undo" isEqualToString:call.method]) {
      return [flutterZoomVideoSdkAnnotationHelper undo:result];
   } else if ([@"redo" isEqualToString:call.method]) {
      return [flutterZoomVideoSdkAnnotationHelper redo:result];
   } else if ([@"clear" isEqualToString:call.method]) {
      return [flutterZoomVideoSdkAnnotationHelper clear:call withResult:result];
   } else {
      result(FlutterMethodNotImplemented);
   }
}

-(void) initSDK:(FlutterMethodCall *)call withResult:(FlutterResult) result {
  ZoomVideoSDKInitParams *initParams = [[ZoomVideoSDKInitParams alloc] init];
  initParams.domain = call.arguments[@"domain"];
  initParams.enableLog = call.arguments[@"enableLog"];
  if ([call.arguments[@"logFilePrefix"] isKindOfClass:[NSString class]])
    initParams.logFilePrefix = call.arguments[@"logFilePrefix"];
  if ([call.arguments[@"appGroupId"] isKindOfClass:[NSString class]])
    initParams.appGroupId = call.arguments[@"appGroupId"];
  if ([call.arguments[@"videoRawdataMemoryMode"] isKindOfClass:[NSString class]])
    initParams.videoRawdataMemoryMode = [JSONConvert ZoomVideoSDKRawDataMemoryMode: call.arguments[@"videoRawdataMemoryMode"]];
  if ([call.arguments[@"audioRawdataMemoryMode"] isKindOfClass:[NSString class]])
    initParams.audioRawdataMemoryMode = [JSONConvert ZoomVideoSDKRawDataMemoryMode: call.arguments[@"audioRawdataMemoryMode"]];
  if ([call.arguments[@"shareRawdataMemoryMode"] isKindOfClass:[NSString class]])
    initParams.shareRawdataMemoryMode = [JSONConvert ZoomVideoSDKRawDataMemoryMode: call.arguments[@"shareRawdataMemoryMode"]];
  NSString *speakerFilePath = call.arguments[@"speakerFilePath"];
  ZoomVideoSDKExtendParams *extendParams = [[ZoomVideoSDKExtendParams alloc] init];
  extendParams.wrapperType = 1;
  if ([speakerFilePath isKindOfClass:[NSString class]] && speakerFilePath.length != 0) {
      extendParams.speakerTestFilePath = speakerFilePath;
  }
  initParams.extendParam = extendParams;

  dispatch_async(dispatch_get_main_queue(), ^{
      ZoomVideoSDKError ret = [[ZoomVideoSDK shareInstance] initialize:initParams];

      switch (ret) {
      case Errors_Success:
          NSLog(@"SDK initialized successfully");
          result(@"SDK initialized successfully");
          break;
      default:
          NSLog(@"SDK failed to initialize with error code: %lu", (unsigned long)ret);
          result([[JSONConvert ZoomVideoSDKErrorValuesReversed] objectForKey: @(ret)]);
      }
      // Setup My Video Rotation. NOTE: We may eventually want to make this configurable.
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChangeNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
  });

}

-(void) joinSession:(FlutterMethodCall *)call withResult:(FlutterResult) result {
    NSString* token = call.arguments[@"token"];
    NSString* sessionName = call.arguments[@"sessionName"];
    NSString* sessionPassword = call.arguments[@"sessionPassword"];
    NSString* userName = call.arguments[@"userName"];
    NSInteger* sessionIdleTimeoutMins = [call.arguments[@"sessionIdleTimeoutMins"] intValue];

    ZoomVideoSDKAudioOptions *audioOption = [ZoomVideoSDKAudioOptions new];
    NSDictionary* audioOptionConfig = call.arguments[@"audioOptions"];
    audioOption.connect = [[audioOptionConfig valueForKey:@"connect"] boolValue];
    audioOption.mute = [[audioOptionConfig valueForKey:@"mute"] boolValue];
    audioOption.autoAdjustSpeakerVolume = [[audioOptionConfig valueForKey:@"autoAdjustSpeakerVolume"] boolValue];

    ZoomVideoSDKVideoOptions *videoOption = [ZoomVideoSDKVideoOptions new];
    NSDictionary* videoOptionConfig = call.arguments[@"videoOptions"];
    videoOption.localVideoOn = [[videoOptionConfig valueForKey:@"localVideoOn"] boolValue];

    ZoomVideoSDKSessionContext *sessionContext = [[ZoomVideoSDKSessionContext alloc] init];
    // Ensure that you do not hard code JWT or any other confidential credentials in your production app.
    sessionContext.token = token;
    sessionContext.sessionName = sessionName;
    sessionContext.sessionPassword = sessionPassword;
    sessionContext.userName = userName;
    sessionContext.audioOption = audioOption;
    sessionContext.videoOption = videoOption;
    sessionContext.sessionIdleTimeoutMins = sessionIdleTimeoutMins;

    [ZoomVideoSDK shareInstance].delegate = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        ZoomVideoSDKSession *session = [[ZoomVideoSDK shareInstance] joinSession:sessionContext];

        if (session) {
            NSLog(@"join session success");
            result(@"join session success");
        }
        else {
            NSLog(@"join session error");
            result(@"joinSession_failure");
        }
    });
}

-(void) leaveSession:(FlutterMethodCall *)call withResult:(FlutterResult) result {
    [ZoomVideoSDK shareInstance].delegate = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        result([[JSONConvert ZoomVideoSDKErrorValuesReversed] objectForKey: @([[ZoomVideoSDK shareInstance] leaveSession: [call.arguments[@"endSession"] boolValue]])]);
    });
}

-(void) getSdkVersion:(FlutterResult) result {
    result([[ZoomVideoSDK shareInstance] getSDKVersion]);
}

-(void) openBrowser:(FlutterMethodCall *)call withResult:(FlutterResult) result {
    NSString* url = call.arguments[@"url"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

-(void) cleanup:(FlutterResult) result {
    ZoomVideoSDKError ret = [[ZoomVideoSDK shareInstance] cleanup];
    switch (ret) {
        case Errors_Success:
          NSLog(@"SDK cleanup successfully");
          break;
        default:
          NSLog(@"SDK failed to cleanup with error code: %lu", (unsigned long)ret);
    }
    result([[JSONConvert ZoomVideoSDKErrorValuesReversed] objectForKey: @(ret)]);
}

-(void) acceptRecordingConsent:(FlutterResult) result {
    if (recordAgreementHandler != NULL) {
        if ([recordAgreementHandler accept]) {
            result(@YES);
        } else {
            result(@NO);
        }
    } else {
        result(@NO);
    }
}

-(void) declineRecordingConsent:(FlutterResult) result {
    if (recordAgreementHandler != NULL) {
        if ([recordAgreementHandler decline]) {
            result(@YES);
        } else {
            result(@NO);
        }
    } else {
        result(@NO);
    }
}

-(void) getRecordingConsentType:(FlutterResult) result {
    if (recordAgreementHandler != NULL) {
        result([[JSONConvert ZoomVideoSDKRecordAgreementTypeValuesReversed] objectForKey: @(recordAgreementHandler.agreementType)]);
    } else {
        result(@"ConsentType_Invalid");
    }
}

- (void) onError:(ZoomVideoSDKError)ErrorType detail:(NSInteger)details {
    switch (ErrorType) {
        case Errors_Success:
            NSLog(@"Success");
            break;
        default:
            // Your ZoomVideoSDK operation raised an error.
            // Refer to error code documentation.
            NSLog(@"Error %lu %ld", (unsigned long)ErrorType, (long)details);
            break;
    }
    if (self.eventSink) {
        self.eventSink(@{
            @"name": @"onError",
            @"message": @{
                @"errorType": [[JSONConvert ZoomVideoSDKErrorValuesReversed] objectForKey: @(ErrorType)],
                @"details": @(details)
            }
        });
    }
}

- (void)onSessionJoin {
    if (self.eventSink) {
        self.eventSink(@{
           @"name": @"onSessionJoin",
           @"message": [FlutterZoomVideoSdkUser mapUser: [[[ZoomVideoSDK shareInstance] getSession] getMySelf]]
       });
    }
    // Set initial video orientation
    [self onDeviceOrientationChangeNotification:nil];
}

- (void)onDeviceOrientationChangeNotification:(NSNotification *)aNotification {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if ((orientation == UIDeviceOrientationUnknown) || (orientation == UIDeviceOrientationFaceUp) || (orientation == UIDeviceOrientationFaceDown)) {
        orientation = (UIDeviceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [[[ZoomVideoSDK shareInstance] getVideoHelper] rotateMyVideo:orientation];
    });
}
- (void)onSessionLeave {
    if (self.eventSink) {
        self.eventSink(@{
           @"name": @"onSessionLeave",
           @"message": @"onSessionLeave"
       });
    }
}

- (void)onUserJoin:(ZoomVideoSDKUserHelper *)helper users:(NSArray<ZoomVideoSDKUser *> *)userArray {
    if (self.eventSink) {
        self.eventSink(@{
           @"name": @"onUserJoin",
           @"message": @{
                @"joinedUsers": [FlutterZoomVideoSdkUser mapUserArray:userArray],
                @"remoteUsers": [FlutterZoomVideoSdkUser mapUserArray: [[[ZoomVideoSDK shareInstance] getSession] getRemoteUsers]]
           }
       });
    }
}

- (void)onUserLeave:(ZoomVideoSDKUserHelper *)helper users:(NSArray<ZoomVideoSDKUser *> *)userArray {
    if (self.eventSink) {
        self.eventSink(@{
           @"name": @"onUserLeave",
           @"message": @{
                @"leftUsers": [FlutterZoomVideoSdkUser mapUserArray:userArray],
                @"remoteUsers": [FlutterZoomVideoSdkUser mapUserArray: [[[ZoomVideoSDK shareInstance] getSession] getRemoteUsers]]
           }
       });
    }
}

- (void)onUserVideoStatusChanged:(ZoomVideoSDKVideoHelper *)helper user:(NSArray<ZoomVideoSDKUser *> *)userArray {
    if (self.eventSink) {
        self.eventSink(@{
           @"name": @"onUserVideoStatusChanged",
           @"message": @{@"changedUsers": [FlutterZoomVideoSdkUser mapUserArray: userArray]}
       });
    }
}

- (void)onUserAudioStatusChanged:(ZoomVideoSDKAudioHelper *)helper user:(NSArray<ZoomVideoSDKUser *> *)userArray {
    if (self.eventSink) {
        self.eventSink(@{
           @"name": @"onUserAudioStatusChanged",
           @"message": @{@"changedUsers": [FlutterZoomVideoSdkUser mapUserArray: userArray]}
       });
    }
}

- (void)onUserShareStatusChanged:(ZoomVideoSDKShareHelper *)helper user:(ZoomVideoSDKUser *)user status:(ZoomVideoSDKReceiveSharingStatus)status {
    if (self.eventSink) {
        self.eventSink(@{
           @"name": @"onUserShareStatusChanged",
           @"message": @{
               @"user": [FlutterZoomVideoSdkUser mapUser: user],
               @"status": [[JSONConvert ZoomVideoSDKReceiveSharingStatusValuesReversed] objectForKey: @(status)]
           }
       });
    }
}

- (void)onLiveStreamStatusChanged:(ZoomVideoSDKLiveStreamHelper *)helper status:(ZoomVideoSDKLiveStreamStatus)status {
    if (self.eventSink) {
        self.eventSink(@{
           @"name": @"onLiveStreamStatusChanged",
           @"message": @{@"status": [[JSONConvert ZoomVideoSDKLiveStreamStatusValuesReversed ] objectForKey: @(status)]}
       });
    }
}

- (void)onChatNewMessageNotify:(ZoomVideoSDKChatHelper *)helper message:(ZoomVideoSDKChatMessage *)chatMessage {
    if (self.eventSink) {
        self.eventSink(@{
           @"name": @"onChatNewMessageNotify",
           @"message": [FlutterZoomVideoSdkChatMessage mapChatMessage:chatMessage]
       });
    }
}

- (void)onUserNameChanged:(ZoomVideoSDKUser *)user {
    if (self.eventSink) {
        self.eventSink(@{
           @"name": @"onUserNameChanged",
           @"message": @{@"changedUser": [FlutterZoomVideoSdkUser mapUser: user]}
       });
    }
}

- (void)onUserHostChanged:(ZoomVideoSDKUserHelper *)helper user:(ZoomVideoSDKUser *)user {
    if (self.eventSink) {
        self.eventSink(@{
           @"name": @"onUserHostChanged",
           @"message": @{@"changedUser": [FlutterZoomVideoSdkUser mapUser: user]}
       });
    }
}

- (void)onUserManagerChanged:(ZoomVideoSDKUser *)user {
    if (self.eventSink) {
        self.eventSink(@{
           @"name": @"onUserManagerChanged",
           @"message": @{@"changedUser": [FlutterZoomVideoSdkUser mapUser: user]}
       });
    }
}

- (void)onUserActiveAudioChanged:(ZoomVideoSDKUserHelper *)helper users:(NSArray<ZoomVideoSDKUser *> *)userArray {
    if (self.eventSink) {
        self.eventSink(@{
           @"name": @"onUserActiveAudioChanged",
           @"message": @{@"changedUsers": [FlutterZoomVideoSdkUser mapUserArray: userArray]}
       });
    }
}

- (void)onSessionNeedPassword:(ZoomVideoSDKError (^)(NSString *, BOOL))completion {
    NSString *userInput = NULL;
    Boolean cancelJoinSession = YES;

    if (self.eventSink) {
        self.eventSink(@{
           @"name": @"onSessionNeedPassword",
           @"message": @"onSessionNeedPassword"
       });
    }
}

- (void)onSessionPasswordWrong:(ZoomVideoSDKError (^)(NSString *, BOOL))completion {
    NSString *userInput = NULL;
    Boolean cancelJoinSession = YES;

    if (self.eventSink) {
        self.eventSink(@{
           @"name": @"onSessionPasswordWrong",
           @"message": @"onSessionPasswordWrong"
       });
    }
}

- (void)onCmdChannelConnectResult:(BOOL)success {
    if (self.eventSink) {
        self.eventSink(@{
           @"name": @"onCmdChannelConnectResult",
           @"message": @{@"success": [NSNumber numberWithBool:success]}
       });
    }
}

- (void)onCommandReceived:(NSString * _Nullable)commandContent sendUser:(ZoomVideoSDKUser * _Nullable)sendUser {
    if (self.eventSink) {
        self.eventSink(@{
           @"name": @"onCommandReceived",
           @"message": @{@"sender": [FlutterZoomVideoSdkUser mapUser: sendUser], @"command": commandContent}
       });
    }
}

- (void)onCloudRecordingStatus:(ZoomVideoSDKRecordingStatus)status recordAgreementHandler:(ZoomVideoSDKRecordAgreementHandler * _Nullable)handler {
    if (handler != NULL) {
      NSLog(@"handler is not null");
      recordAgreementHandler = handler;
    }
    NSDictionary* statusDic = [[JSONConvert ZoomVideoSDKRecordingStatusValuesReversed] objectForKey: @(status)];
    if (statusDic != nil && self.eventSink) {
        self.eventSink(@{
           @"name": @"onCloudRecordingStatus",
           @"message": @{
               @"status": statusDic
           }
       });
    }
}

- (void)onUserRecordAgreementNotification:(ZoomVideoSDKUser * _Nullable)user {
    if (user != NULL && self.eventSink) {
        self.eventSink(@{
          @"name": @"onUserRecordingConsent",
          @"message": @{
              @"user": [FlutterZoomVideoSdkUser mapUser: user]
          }
       });
    }
}

- (void)onHostAskUnmute {
    if (self.eventSink) {
        self.eventSink(@{
           @"name": @"onHostAskUnmute",
           @"message": @"onHostAskUnmute"
       });
    }
}

- (void)onInviteByPhoneStatus:(ZoomVideoSDKPhoneStatus)status failReason:(ZoomVideoSDKPhoneFailedReason)reason {
    if (self.eventSink) {
        self.eventSink(@{
           @"name": @"onInviteByPhoneStatus",
           @"message": @{
               @"status": [[JSONConvert ZoomVideoSDKPhoneStatusValuesReversed] objectForKey: @(status)],
               @"reason": [[JSONConvert ZoomVideoSDKPhoneFailedReasonValuesReversed] objectForKey: @(reason)]
           }
       });
    }
}

- (void)onMultiCameraStreamStatusChanged:(ZoomVideoSDKMultiCameraStreamStatus)status parentUser:(ZoomVideoSDKUser *_Nullable)user videoPipe:(ZoomVideoSDKRawDataPipe *_Nullable)videoPipe {

}

- (void)onMultiCameraStreamStatusChanged:(ZoomVideoSDKMultiCameraStreamStatus)status parentUser:(ZoomVideoSDKUser *_Nullable)user videoCanvas:(ZoomVideoSDKVideoCanvas *_Nullable)videoCanvas {
    if (self.eventSink) {
        self.eventSink(@{
           @"name": @"onMultiCameraStreamStatusChanged",
           @"message": @{
               @"status": [[JSONConvert ZoomVideoSDKMultiCameraStreamStatusValuesReversed] objectForKey: @(status)],
               @"user": [FlutterZoomVideoSdkUser mapUser: user]
           }
       });
    }
}

- (void)onChatMsgDeleteNotification:(ZoomVideoSDKChatHelper * _Nullable)helper messageID:(NSString * __nonnull)msgID deleteBy:(ZoomVideoSDKChatMsgDeleteBy) type {
    if (self.eventSink) {
        self.eventSink(@{
           @"name": @"onChatDeleteMessageNotify",
           @"message": @{
               @"msgID": msgID,
               @"type": [[JSONConvert ZoomVideoSDKChatMsgDeleteByValuesReversed] objectForKey: @(type)]
           }
       });
    }
}

- (void)onLiveTranscriptionStatus:(ZoomVideoSDKLiveTranscriptionStatus)status {
    if (self.eventSink) {
        self.eventSink(@{
           @"name": @"onLiveTranscriptionStatus",
           @"message": @{
               @"status": [[JSONConvert ZoomVideoSDKLiveTranscriptionStatusValuesReversed] objectForKey: @(status)]
           }
       });
    }
}

- (void)onLiveTranscriptionMsgReceived:(NSString *)ltMsg user:(ZoomVideoSDKUser *)user type:(ZoomVideoSDKLiveTranscriptionOperationType)type {

}

- (void)onLiveTranscriptionMsgReceived:(ZoomVideoSDKLiveTranscriptionMessageInfo *)messageInfo {
    NSLog(@"onLiveTranscriptionMsgInfoReceived");
    if (self.eventSink) {
            self.eventSink(@{
               @"name": @"onLiveTranscriptionMsgInfoReceived",
               @"message": @{
                   @"messageInfo": [FlutterZoomVideoSdkILiveTranscriptionMessageInfo mapMessageInfo: messageInfo]
               }
           });
        }
}

- (void)onLiveTranscriptionMsgError:(ZoomVideoSDKLiveTranscriptionLanguage *)spokenLanguage transLanguage:(ZoomVideoSDKLiveTranscriptionLanguage *)transcriptLanguage {
    if (self.eventSink) {
        self.eventSink(@{
           @"name": @"onLiveTranscriptionMsgError",
           @"message": @{
              @"spokenLanguage": [FlutterZoomVideoSdkLiveTranscriptionLanguage mapLanguage: spokenLanguage],
              @"transcriptLanguage": [FlutterZoomVideoSdkLiveTranscriptionLanguage mapLanguage: transcriptLanguage]
           }
       });
    }
}

- (void)onRequireSystemPermission:(ZoomVideoSDKSystemPermissionType)permissionType {
    if (self.eventSink) {
        self.eventSink(@{
           @"name": @"onRequireSystemPermission",
           @"message": @{
                @"permissionType": [[JSONConvert ZoomVideoSDKSystemPermissionTypeValuesReversed] objectForKey: @(permissionType)]
           }
       });
    }
}

- (void)onUserVideoNetworkStatusChanged:(ZoomVideoSDKNetworkStatus)status user:(ZoomVideoSDKUser *)user {
    if (self.eventSink) {
        self.eventSink(@{
           @"name": @"onUserVideoNetworkStatusChanged",
           @"message": @{
                @"status": [[JSONConvert ZoomVideoSDKNetworkStatusValuesReversed] objectForKey: @(status)],
                @"user": [FlutterZoomVideoSdkUser mapUser: user],
           }
       });
    }
}

// OS Event Listeners
- (void)onProxySettingNotification:(ZoomVideoSDKProxySettingHandler *_Nonnull)handler {
    if (self.eventSink) {
        self.eventSink(@{
            @"name": @"onProxySettingNotification",
            @"message": @{
                @"proxyHost": [handler proxyHost],
                @"proxyPort": [NSNumber numberWithInteger:[handler proxyPort]],
                @"proxyDescription": [handler proxyDescription]
            }
        });
    }
}

- (void)onSSLCertVerifiedFailNotification:(ZoomVideoSDKSSLCertificateInfo *_Nonnull)handler {
    if (self.eventSink) {
        self.eventSink(@{
            @"name": @"onSSLCertVerifiedFailNotification",
            @"message": @{
                @"certIssuedTo": [handler certIssuedTo],
                @"certIssuedBy": [handler certIssuedBy],
                @"certSerialNum": [handler certSerialNum],
                @"certFingerprint": [handler certFingerprint]
            }
        });
    }
}

- (void)onCallCRCDeviceStatusChanged:(ZoomVideoSDKCRCCallStatus)status {
    if (self.eventSink) {
        self.eventSink(@{
           @"name": @"onCallCRCDeviceStatusChanged",
           @"message": @{
                @"status": [[JSONConvert ZoomVideoSDKCRCCallStatusValuesReversed] objectForKey: @(status)],
           }
       });
    }
}

- (void)onOriginalLanguageMsgReceived:(ZoomVideoSDKLiveTranscriptionMessageInfo *)messageInfo {
    NSLog(@"onOriginalLanguageMsgReceived");
    if (self.eventSink) {
            self.eventSink(@{
               @"name": @"onOriginalLanguageMsgReceived",
               @"message": @{
                   @"messageInfo": [FlutterZoomVideoSdkILiveTranscriptionMessageInfo mapMessageInfo: messageInfo]
               }
           });
        }
}

- (void)onChatPrivilegeChanged:(ZoomVideoSDKChatHelper * _Nullable)helper privilege:(ZoomVideoSDKChatPrivilegeType)currentPrivilege {
    if (self.eventSink) {
        self.eventSink(@{
            @"name": @"onChatPrivilegeChanged",
            @"message": @{
                @"privilege": [[JSONConvert ZoomVideoSDKChatPrivilegeTypeValuesReversed] objectForKey: @(currentPrivilege)],
            }
        });
    }
}

- (void)onAnnotationHelperCleanUp:(ZoomVideoSDKAnnotationHelper *)helper
{
    [[FlutterZoomVideoSdkAnnotationHelper alloc] setAnnotationHelper:nil];
    [[[ZoomVideoSDK shareInstance] getShareHelper] destroyAnnotationHelper:helper];
    if (self.eventSink) {
        self.eventSink(@{
            @"name": @"onAnnotationHelperCleanUp",
            @"message": @"onAnnotationHelperCleanUp",
        });
    }
}

- (void)onAnnotationPrivilegeChange:(BOOL)enable shareOwner:(ZoomVideoSDKUser *)user
{
    if (self.eventSink) {
        self.eventSink(@{
            @"name": @"onAnnotationPrivilegeChange",
            @"message": @{
                @"privilege": @(enable),
                @"user": [FlutterZoomVideoSdkUser mapUser: user],
            }
        });
    }
}

- (void)onVideoCanvasSubscribeFail:(ZoomVideoSDKSubscribeFailReason)failReason user:(ZoomVideoSDKUser *_Nullable)user view:(UIView *_Nullable)view
{
    if (self.eventSink) {
        self.eventSink(@{
            @"name": @"onAnnotationPrivilegeChange",
            @"message": @{
                @"failReason": [[JSONConvert ZoomVideoSDKSubscribeFailReasonValuesReversed] objectForKey: @(failReason)],
                @"user": [FlutterZoomVideoSdkUser mapUser: user],
            }
        });
    }
}


- (void)onShareCanvasSubscribeFail:(ZoomVideoSDKSubscribeFailReason)failReason user:(ZoomVideoSDKUser *_Nullable)user view:(UIView *_Nullable)view
{
    if (self.eventSink) {
        self.eventSink(@{
            @"name": @"onAnnotationPrivilegeChange",
            @"message": @{
                @"failReason": [[JSONConvert ZoomVideoSDKSubscribeFailReasonValuesReversed] objectForKey: @(failReason)],
                @"user": [FlutterZoomVideoSdkUser mapUser: user],
            }
        });
    }
}


- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
  eventSink:(FlutterEventSink)events {
    self.eventSink = events;
    return nil;
}

- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    return nil;
}
@end
