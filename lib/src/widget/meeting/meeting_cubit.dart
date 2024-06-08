import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk_chat_message.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk_event_listener.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk_user.dart';
import 'package:events_emitter/events_emitter.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/service/zoom_service.dart';
import 'package:medical/src/utils/async_queue.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:wakelock/wakelock.dart';
import 'models/meeting_message.dart';

import 'meeting_state.dart';

class MeetingCubit extends Cubit<MeetingState> with WidgetsBindingObserver {
  final MeetingArguments args;

  // Shared state with app session
  static String? _latestSessionId = null;
  static List<MeetingMessage> _latestChatMessages = [];

  // Queue to state
  AsyncActionQueue _actionQueue = AsyncActionQueue();

  // Zoom
  final ZoomVideoSdk _zoom = ZoomVideoSdk();
  final _eventListener = ZoomVideoSdkEventListener();
  final List<EventListener<Object?>> meetingEvents = [];
  // Future<String?> get sessionName => _zoom.session.getSessionName();
  Future<String?> get sessionName => Future.value('Cuộc họp');
  bool _isRejoining = false;

  // Cached
  ZoomVideoSdkUser? _mySelf;
  ZoomVideoSdkUser? get user => _mySelf;

  // Chat
  final ValueNotifier<bool> _haveNewChatNotifier = ValueNotifier(false);
  final ValueNotifier<List<MeetingMessage>> _chatMessagesNotifier = ValueNotifier([]);
  ValueNotifier<bool> get haveNewChat => _haveNewChatNotifier;
  ValueNotifier<List<MeetingMessage>> get chatMessages => _chatMessagesNotifier;
  bool _chatSheetPresented = false;

  // Sharing
  bool _isSharing = false;
  String _sharingUserId = '';
  List<ZoomVideoSdkUser> _remoteUsers = [];

  // Audio
  bool _audioAttached = false;
  bool _mutedBeforeOffSpeaker = false;
  final ValueNotifier<SpeakerMode> _currentSpeaker = ValueNotifier(SpeakerMode.speaker);
  ValueNotifier<SpeakerMode> get currentSpeaker => _currentSpeaker;
  List<SpeakerMode> _speakerModes = [SpeakerMode.speaker, SpeakerMode.telephony, SpeakerMode.off];
  List<SpeakerMode> get speakerModes => _speakerModes;

  // Camera
  bool _initVideoOn = false;
  bool _videoStatisticChecked = false;
  final ValueNotifier<bool> _haveMultipleCamera = ValueNotifier(false);
  ValueNotifier<bool> get haveMultipleCamera => _haveMultipleCamera;

  // Time out
  final int timeoutInSeconds = 30;
  bool _isJoined = false;
  Timer? _timeoutTimer;

  MeetingCubit(this.args) : super(MeetingJoining()) {
    WidgetsBinding.instance.addObserver(this);
    Wakelock.enable();

    // Join session
    _doJoinMeeting();

    // Listen to session events
    _doStartListenZoomEvents();

    // Time out for connection
    _timeoutTimer = Timer(Duration(seconds: timeoutInSeconds), () {
      if (!_isJoined) {
        emit(MeetingJoinError());
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _appPaused();
        break;
      case AppLifecycleState.resumed:
        _appResumed();
        break;
      default:
        break;
    }
  }

  @override
  Future<void> close() async {
    // Remove listeners
    meetingEvents.forEach((listener) {
      listener.cancel();
    });
    _mySelf = null;
    _remoteUsers = [];

    _timeoutTimer?.cancel();
    _timeoutTimer = null;

    WidgetsBinding.instance.removeObserver(this);
    Wakelock.disable();

    return super.close();
  }

  void switchSpeaker(SpeakerMode mode) async {
    _currentSpeaker.value = mode;
    ZoomVideoSdkUser? mySelf = await _zoom.session.getMySelf();
    if (mySelf != null) {
      _mySelf = mySelf;
    }
    if (!_audioAttached && mode != SpeakerMode.off) {
      _audioAttached = true;
      await _zoom.audioHelper.startAudio();
      if (!_mutedBeforeOffSpeaker) {
        await _zoom.audioHelper.unMuteAudio(_mySelf!.userId);
      }
    }
    switch (mode) {
      case SpeakerMode.speaker:
        await _zoom.audioHelper.setSpeaker(true);
        break;
      case SpeakerMode.telephony:
        await _zoom.audioHelper.setSpeaker(false);
        break;
      case SpeakerMode.off:
        _audioAttached = false;
        if (_mySelf!.audioStatus != null) {
          _mutedBeforeOffSpeaker = await _mySelf!.audioStatus!.isMuted();
        }
        await _zoom.audioHelper.muteAudio(_mySelf!.userId);
        await _zoom.audioHelper.stopAudio();
        break;
    }
    if (state is MeetingJoined) {
      var newState = (state as MeetingJoined).copyWith(thisUser: _mySelf);
      emit(newState);
    }
  }

  void toggleAudio() async {
    if (_currentSpeaker.value == SpeakerMode.off) {
      return;
    }
    ZoomVideoSdkUser? mySelf = await _zoom.session.getMySelf();
    if (mySelf != null) {
      final audioStatus = mySelf.audioStatus;
      if (audioStatus != null) {
        var muted = await audioStatus.isMuted();
        if (muted) {
          if (!_audioAttached) {
            _audioAttached = true;
            await _zoom.audioHelper.startAudio();
          }
          await _zoom.audioHelper.unMuteAudio(mySelf.userId);
        } else {
          await _zoom.audioHelper.muteAudio(mySelf.userId);
        }
      }
    }
    if (state is MeetingJoined) {
      var newState = (state as MeetingJoined).copyWith(thisUser: mySelf);
      emit(newState);
    }
  }

  void toggleVideo() async {
    ZoomVideoSdkUser? mySelf = await _zoom.session.getMySelf();
    if (mySelf != null) {
      final videoStatus = mySelf.videoStatus;
      if (videoStatus != null) {
        var videoOn = await videoStatus.isOn();
        if (videoOn) {
          await _zoom.videoHelper.stopVideo();
          _haveMultipleCamera.value = false;
        } else {
          await _zoom.videoHelper.startVideo();
          try {
            if (!_videoStatisticChecked) {
              if (await _zoom.videoHelper.isMyVideoMirrored()) {
                await _zoom.videoHelper.mirrorMyVideo(false);
              }
              _haveMultipleCamera.value = await _zoom.videoHelper.getNumberOfCameras() > 1;
              _videoStatisticChecked = true;
            }
          } catch (e, s) {
            TrackingManager.recordError(e, s);
          }
        }
      }
    }
    if (state is MeetingJoined) {
      var newState = (state as MeetingJoined).copyWith(thisUser: mySelf);
      emit(newState);
    }
  }

  void switchCamera() async {
    ZoomVideoSdkUser? mySelf = await _zoom.session.getMySelf();
    if (mySelf != null) {
      final videoStatus = mySelf.videoStatus;
      if (videoStatus != null) {
        var videoOn = await videoStatus.isOn();
        if (videoOn && state is MeetingJoined) {
          await _zoom.videoHelper.switchCamera('');
          emit((state as MeetingJoined).copyWith(thisUser: mySelf));
        }
      }
    }
  }

  void _appPaused() {
    _turnoffVideoPreviewIfNeeded();
    _turnoffAudioIfNeeded();
  }

  void _appResumed() {
    _turnonVideoPreviewIfNeeded();
    _turnonAudioIfNeeded();
  }

  bool _lastVideoStatus = false;
  void _turnoffVideoPreviewIfNeeded() async {
    ZoomVideoSdkUser? mySelf = await _zoom.session.getMySelf();
    if (mySelf != null) {
      final videoStatus = mySelf.videoStatus;
      if (videoStatus != null) {
        var videoOn = await videoStatus.isOn();
        if (videoOn) {
          await _zoom.videoHelper.stopVideo();
          _lastVideoStatus = true;
        }
      }
    }
  }

  void _turnonVideoPreviewIfNeeded() async {
    if (!_lastVideoStatus) {
      return;
    }
    _lastVideoStatus = false;
    ZoomVideoSdkUser? mySelf = await _zoom.session.getMySelf();
    if (mySelf != null) {
      final videoStatus = mySelf.videoStatus;
      if (videoStatus != null) {
        await _zoom.videoHelper.startVideo();
      }
    }
  }

  bool _lastAudioStatus = false;
  void _turnoffAudioIfNeeded() async {
    ZoomVideoSdkUser? mySelf = await _zoom.session.getMySelf();
    if (mySelf != null) {
      final audioStatus = mySelf.audioStatus;
      if (audioStatus != null) {
        var audioOn = !(await audioStatus.isMuted());
        if (audioOn) {
          await _zoom.audioHelper.muteAudio(mySelf.userId);
          _lastAudioStatus = true;
        }
      }
    }
  }

  void _turnonAudioIfNeeded() async {
    if (!_lastAudioStatus) {
      return;
    }
    _lastAudioStatus = false;
    ZoomVideoSdkUser? mySelf = await _zoom.session.getMySelf();
    if (mySelf != null) {
      final audioStatus = mySelf.audioStatus;
      if (audioStatus != null) {
        await _zoom.audioHelper.unMuteAudio(mySelf.userId);
        var newState = (state as MeetingJoined).copyWith(thisUser: mySelf);
        emit(newState);
      }
    }
  }

  void startChat() {
    _chatSheetPresented = true;
    _haveNewChatNotifier.value = false;
  }

  void endChat() {
    _chatSheetPresented = false;
    _haveNewChatNotifier.value = false;
  }

  Future<void> sendChatToAll(String message) async {
    bool isChatEnable = !(await _zoom.chatHelper.isChatDisabled());
    if (!isChatEnable) {
      return;
    }
    String chatPrivilege = await _zoom.chatHelper.getChatPrivilege();
    if (chatPrivilege == 'none') {
      return;
    }
    await _zoom.chatHelper.sendChatToAll(message);
  }

  void leaveSession() async {
    try {
      await _zoom.leaveSession(false);
    } catch (e, s) {
      TrackingManager.recordError(e, s);
    }
  }

  void _doJoinMeeting() async {
    try {
      Map<String, bool> audioOptions = {
        "connect": true,
        "mute": true,
        "autoAdjustSpeakerVolume": false
      };
      Map<String, bool> videoOptions = {
        "localVideoOn": _initVideoOn,
      };
      JoinSessionConfig joinSession = JoinSessionConfig(
        sessionName: args.sessionName,
        sessionPassword: args.sessionPassword,
        token: args.token,
        userName: args.displayName,
        audioOptions: audioOptions,
        videoOptions: videoOptions,
        sessionIdleTimeoutMins: int.parse(args.sessionIdleTimeoutMins),
      );
      await _zoom.joinSession(joinSession);
      // TODO: Check why camera is mirrored
      // _zoom.videoHelper.mirrorMyVideo(false).then((_) => null);
    } catch (e, s) {
      TrackingManager.recordError(e, s);
      emit(MeetingJoinError());
    }
  }

  void _doStartListenZoomEvents() {
    _eventListener.addEventListener();
    EventEmitter emitter = _eventListener.eventEmitter;
    // * This user joined the session
    final sessionJoinListener = emitter.on(EventType.onSessionJoin, _userJoined);
    meetingEvents.add(sessionJoinListener);

    // * This user left the session
    final sessionLeaveListener = emitter.on(EventType.onSessionLeave, _userLeft);
    meetingEvents.add(sessionLeaveListener);

    // * Video status of a user changed
    final userVideoStatusChangedListener =
        emitter.on(EventType.onUserVideoStatusChanged, (data) async {
      data = data as Map;
      ZoomVideoSdkUser? mySelf = await _zoom.session.getMySelf();
      if (mySelf != null) {
        var userListJson = jsonDecode(data['changedUsers']) as List;
        List<ZoomVideoSdkUser> userList =
            userListJson.map((userJson) => ZoomVideoSdkUser.fromJson(userJson)).toList();
        // Change if mySelf is in the list
        if (userList.any((e) => e.userId == mySelf.userId)) {
          _mySelf = mySelf;
          if (state is MeetingJoined) {
            FutureFunc action = () async => await _sendJoinedState(
                  thisUser: mySelf,
                  remoteUsers: _remoteUsers,
                );
            _actionQueue.enqueue(action);
          }
        } else {
          _remoteUsers = (await _zoom.session.getRemoteUsers()) ?? [];
          FutureFunc action = () async => await _sendJoinedState(
                thisUser: mySelf,
                remoteUsers: _remoteUsers,
              );
          _actionQueue.enqueue(action);
        }
        return;
      }
    });
    meetingEvents.add(userVideoStatusChangedListener);

    // * Audio status of a user changed
    final userAudioStatusChangedListener =
        emitter.on(EventType.onUserAudioStatusChanged, (data) async {
      data = data as Map;
      ZoomVideoSdkUser? mySelf = await _zoom.session.getMySelf();
      if (mySelf != null) {
        var userListJson = jsonDecode(data['changedUsers']) as List;
        List<ZoomVideoSdkUser> userList =
            userListJson.map((userJson) => ZoomVideoSdkUser.fromJson(userJson)).toList();
        // Change if mySelf is in the list
        if (userList.any((e) => e.userId == mySelf.userId)) {
          _mySelf = mySelf;
          if (state is MeetingJoined) {
            MeetingJoined newState = (state as MeetingJoined).copyWith(thisUser: mySelf);
            emit(newState);
          }
        }
        return;
      }
    });
    meetingEvents.add(userAudioStatusChangedListener);

    // * User share-screen status changed
    final userShareStatusChangeListener =
        emitter.on(EventType.onUserShareStatusChanged, (data) async {
      data = data as Map;
      if (data['status'] == ShareStatus.Start) {
        ZoomVideoSdkUser? shareUser = data['user'] == null
            ? null
            : ZoomVideoSdkUser.fromJson(jsonDecode(data['user'].toString()));
        _isSharing = true;
        _sharingUserId = shareUser?.userId ?? '';
        _remoteUsers = (await _zoom.session.getRemoteUsers()) ?? [];
        ZoomVideoSdkUser? mySelf = await _zoom.session.getMySelf();
        if (mySelf != null) {
          FutureFunc action = () async => await _sendJoinedState(
                thisUser: mySelf,
                remoteUsers: _remoteUsers,
              );
          _actionQueue.enqueue(action);
        }
      } else {
        _isSharing = false;
        _sharingUserId = '';
        FutureFunc action = () async => await _sendJoinedState(
              thisUser: _mySelf!,
              remoteUsers: await _zoom.session.getRemoteUsers() ?? [],
            );
        _actionQueue.enqueue(action);
      }
    });
    meetingEvents.add(userShareStatusChangeListener);

    // * Chat message received
    final chatMessageReceivedListener = emitter.on(EventType.onChatNewMessageNotify, (data) async {
      ZoomVideoSdkChatMessage message =
          ZoomVideoSdkChatMessage.fromJson(jsonDecode(data.toString()));
      if (_mySelf != null && !_chatSheetPresented && message.senderUser.userId != _mySelf!.userId) {
        _haveNewChatNotifier.value = true;
      }
      final transformedMessage = MeetingMessage.fromZoomVideoSdkChatMessage(message);
      _chatMessagesNotifier.value = [transformedMessage, ..._chatMessagesNotifier.value];
      _latestChatMessages = _chatMessagesNotifier.value;
    });
    meetingEvents.add(chatMessageReceivedListener);

    // * Other user joined the session
    final userJoinListener = emitter.on(EventType.onUserJoin, (data) async {
      data = data as Map;
      var userListJson = jsonDecode(data['remoteUsers']) as List;
      List<ZoomVideoSdkUser> remoteUsers =
          userListJson.map((userJson) => ZoomVideoSdkUser.fromJson(userJson)).toList();
      _remoteUsers = remoteUsers;
      FutureFunc action =
          () async => await _sendJoinedState(thisUser: _mySelf!, remoteUsers: _remoteUsers);
      _actionQueue.enqueue(action);
    });
    meetingEvents.add(userJoinListener);

    // * Other user left the session
    final userLeaveListener = emitter.on(EventType.onUserLeave, (data) async {
      data = data as Map;
      var userListJson = jsonDecode(data['remoteUsers']) as List;
      List<ZoomVideoSdkUser> remoteUsers =
          userListJson.map((userJson) => ZoomVideoSdkUser.fromJson(userJson)).toList();
      _remoteUsers = remoteUsers;
      if (_mySelf != null) {
        FutureFunc action =
            () async => await _sendJoinedState(thisUser: _mySelf!, remoteUsers: _remoteUsers);
        _actionQueue.enqueue(action);
      }
    });
    meetingEvents.add(userLeaveListener);

    // ! Session error
    final sessionErrorListener = emitter.on(EventType.onError, (data) async {
      if (data == null) {
        return;
      }
      data = data as Map;
      // ZoomVideoSDKError_Session_Already_In_Progress
      if (data['errorType']?.toString() == 'ZoomVideoSDKError_Session_Already_In_Progress') {
        _isRejoining = true;
        await _zoom.leaveSession(false);
        _doJoinMeeting();
        return;
      }
      String username = '';
      String id = '';
      if (AppSettings.userInfo != null) {
        username = AppSettings.userInfo!.userName ?? '';
        id = AppSettings.userInfo!.id ?? '';
      }
      final error = """
        User: $username ($id),
        Session: ${args.sessionName}
        ${data.toString()}
        """;
      await TrackingManager.recordError(
        error,
        null,
      );
    });
    meetingEvents.add(sessionErrorListener);
  }

  void _userJoined(Object? sessionUser) async {
    _isJoined = true;
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    _zoom.session.getSessionID().then((value) {
      if (_latestSessionId != null && _latestSessionId == value) {
        _chatMessagesNotifier.value = _latestChatMessages;
      } else {
        _latestChatMessages = [];
        _chatMessagesNotifier.value = [];
      }
      _latestSessionId = value;
    });
    ZoomVideoSdkUser mySelf = ZoomVideoSdkUser.fromJson(jsonDecode(sessionUser.toString()));
    _mySelf = mySelf;
    List<ZoomVideoSdkUser>? otherUsers = await _zoom.session.getRemoteUsers();
    _remoteUsers = otherUsers ?? [];
    // Prepare audio
    bool isTelephonySupport = await _zoom.audioHelper.canSwitchSpeaker();
    if (!isTelephonySupport) {
      _speakerModes.remove(SpeakerMode.telephony);
    }

    FutureFunc action =
        () async => await _sendJoinedState(thisUser: mySelf, remoteUsers: _remoteUsers);
    _actionQueue.enqueue(action);
  }

  void _userLeft(Object? data) {
    if (_isRejoining) {
      _isRejoining = false;
      return;
    }
    _isJoined = false;
    _zoom.audioHelper.cleanAudioSession().catchError((e, s) {
      TrackingManager.recordError(e, s);
    });

    emit(MeetingLeaving());
  }

  Future<void> _sendJoinedState({
    required ZoomVideoSdkUser thisUser,
    List<ZoomVideoSdkUser> remoteUsers = const [],
  }) async {
    // Just this user in the session
    if (remoteUsers.isEmpty) {
      final newState = MeetingJoined(
        thisUser: thisUser,
        previewUser: null,
        fullscreenUser: thisUser,
        remoteUsers: remoteUsers,
      );
      emit(newState);
    } else {
      // Someone is sharing screen
      ZoomVideoSdkUser? sharingUser;
      if (_isSharing) {
        for (var user in remoteUsers) {
          if (user.userId == _sharingUserId) {
            user.isSharing = true;
            sharingUser = user;
            break;
          }
        }
      }

      // Priority: Host > Manager > Attendee (any with video on)
      ZoomVideoSdkUser? hostUser = null;

      final hostUsers = remoteUsers.where((user) => user.isHost ?? false).toList();
      final managerUsers = remoteUsers.where((user) => user.isManager ?? false).toList();
      final otherUsers = remoteUsers
          .where((user) => !(user.isHost ?? false) && !(user.isManager ?? false))
          .toList();
      final orderedUsers = [...hostUsers, ...managerUsers, ...otherUsers];

      ZoomVideoSdkUser? hostSharingAndVideoOn;
      for (var user in orderedUsers) {
        bool isVideoOn = await user.videoStatus?.isOn() ?? false;
        if ((user.isHost ?? false) && isVideoOn) {
          hostUser = user;
          if (_isSharing) {
            hostSharingAndVideoOn = user;
          }
          break;
        }
        if ((user.isManager ?? false) && isVideoOn) {
          hostUser = user;
          if (_isSharing) {
            hostSharingAndVideoOn = user;
          }
          break;
        }
        if (isVideoOn) {
          hostUser = user;
          break;
        }
      }
      if (hostUser == null) {
        hostUser = orderedUsers.first;
      }

      if (sharingUser != null) {
        // This user is sharing screen
        if (sharingUser.userId == thisUser.userId) {
          if (state is MeetingJoined) {
            final currentState = state as MeetingJoined;
            final newState = currentState.copyWith(
              thisUser: thisUser,
              previewUser: hostSharingAndVideoOn ?? thisUser,
              fullscreenUser: thisUser,
              remoteUsers: orderedUsers,
            );
            emit(newState);
          } else {
            final newState = MeetingJoined(
              thisUser: thisUser,
              previewUser: hostSharingAndVideoOn ?? thisUser,
              fullscreenUser: thisUser,
              remoteUsers: orderedUsers,
            );
            emit(newState);
          }
        } else {
          // Someone else is sharing screen
          if (state is MeetingJoined) {
            final currentState = state as MeetingJoined;
            final newState = currentState.copyWith(
              thisUser: thisUser,
              previewUser: hostSharingAndVideoOn ?? thisUser,
              fullscreenUser: sharingUser,
              remoteUsers: orderedUsers,
            );
            emit(newState);
          } else {
            final newState = MeetingJoined(
              thisUser: thisUser,
              previewUser: hostSharingAndVideoOn ?? thisUser,
              fullscreenUser: sharingUser,
              remoteUsers: orderedUsers,
            );
            emit(newState);
          }
        }
      } else {
        // No one is sharing screen
        if (state is MeetingJoined) {
          final currentState = state as MeetingJoined;
          final newState = currentState.copyWith(
            thisUser: thisUser,
            previewUser: thisUser,
            fullscreenUser: hostUser,
            remoteUsers: orderedUsers,
          );
          emit(newState);
        } else {
          final newState = MeetingJoined(
            thisUser: thisUser,
            previewUser: thisUser,
            fullscreenUser: hostUser,
            remoteUsers: orderedUsers,
          );
          emit(newState);
        }
      }
    }
  }
}

enum SpeakerMode {
  speaker,
  telephony,
  off,
}

extension SpeakerModeExtension on SpeakerMode {
  String get name {
    switch (this) {
      case SpeakerMode.speaker:
        return 'Loa ngoài';
      case SpeakerMode.telephony:
        return 'Loa thoại';
      case SpeakerMode.off:
        return 'Tắt loa';
    }
  }
}
