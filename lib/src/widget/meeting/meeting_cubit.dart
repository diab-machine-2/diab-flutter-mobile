import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk_chat_message.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk_event_listener.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk_user.dart';
import 'package:events_emitter/events_emitter.dart';
import 'package:medical/src/service/zoom_service.dart';
import 'models/MeetingMessage.dart';

import 'meeting_state.dart';

class MeetingCubit extends Cubit<MeetingState> {
  final MeetingArguments args;

  // Shared state with app session
  static String? _latestSessionId = null;
  static List<MeetingMessage> _latestChatMessages = [];

  // Zoom
  final ZoomVideoSdk _zoom = ZoomVideoSdk();
  final _eventListener = ZoomVideoSdkEventListener();
  final List<EventListener<Object?>> meetingEvents = [];
  // Future<String?> get sessionName => _zoom.session.getSessionName();
  Future<String?> get sessionName => Future.value('Cuộc họp');

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
  bool _audioStopped = false;
  final ValueNotifier<SpeakerMode> _currentSpeaker = ValueNotifier(SpeakerMode.speaker);
  ValueNotifier<SpeakerMode> get currentSpeaker => _currentSpeaker;
  List<SpeakerMode> _speakerModes = [SpeakerMode.speaker, SpeakerMode.telephony, SpeakerMode.off];
  List<SpeakerMode> get speakerModes => _speakerModes;

  // Camera
  bool _initVideoOn = false;
  final ValueNotifier<bool> _haveMultipleCamera = ValueNotifier(false);
  ValueNotifier<bool> get haveMultipleCamera => _haveMultipleCamera;

  // Time out
  final int timeoutInSeconds = 30;
  bool _isJoined = false;
  Timer? _timeoutTimer;

  MeetingCubit(this.args) : super(MeetingJoining()) {
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
  Future<void> close() async {
    // Remove listeners
    meetingEvents.forEach((listener) {
      listener.cancel();
    });
    _mySelf = null;
    _remoteUsers = [];

    _timeoutTimer?.cancel();
    _timeoutTimer = null;

    return super.close();
  }

  void switchSpeaker(SpeakerMode mode) async {
    _currentSpeaker.value = mode;
    if (_audioStopped && mode != SpeakerMode.off) {
      _audioStopped = false;
      await _zoom.audioHelper.startAudio();
    }
    switch (mode) {
      case SpeakerMode.speaker:
        await _zoom.audioHelper.setSpeaker(true);
        break;
      case SpeakerMode.telephony:
        await _zoom.audioHelper.setSpeaker(false);
        break;
      case SpeakerMode.off:
        _audioStopped = true;
        await _zoom.audioHelper.stopAudio();
        break;
    }
  }

  void toggleAudio() async {
    ZoomVideoSdkUser? mySelf = await _zoom.session.getMySelf();
    if (mySelf != null) {
      final audioStatus = mySelf.audioStatus;
      if (audioStatus != null) {
        var muted = await audioStatus.isMuted();
        if (muted) {
          await _zoom.audioHelper.unMuteAudio(mySelf.userId);
        } else {
          await _zoom.audioHelper.muteAudio(mySelf.userId);
        }
      }
    }
    var newState = (state as MeetingJoined).copyWith(thisUser: mySelf);
    emit(newState);
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
          if (!_haveMultipleCamera.value) {
            _haveMultipleCamera.value = await _zoom.videoHelper.getNumberOfCameras() > 1;
          }
        }
      }
    }
    var newState = (state as MeetingJoined).copyWith(thisUser: mySelf);
    emit(newState);
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

  void appPaused() {
    _turnoffVideoPreviewIfNeeded();
    _turnoffAudioIfNeeded();
  }

  void appResumed() {
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
        var newState = (state as MeetingJoined).copyWith(thisUser: mySelf);
        emit(newState);
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
    print('chatPrivilege: $chatPrivilege');
    if (chatPrivilege == 'none') {
      return;
    }
    await _zoom.chatHelper.sendChatToAll(message);
  }

  void leaveSession() async {
    try {
      await _zoom.audioHelper.stopAudio();
      await _zoom.leaveSession(false);
    } catch (e) {
      print('zoom: Error leaving session: $e');
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
    } catch (e) {
      print('zoom: Error joining session: $e');
      // TODO: emit error
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
      print('zoom: onUserVideoStatusChanged: $data');
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
        } else {
          _remoteUsers = (await _zoom.session.getRemoteUsers()) ?? [];
          print('zoom: remoteUsers: $_remoteUsers');
          MeetingJoined newState = await _composeJoinedState(
            thisUser: mySelf,
            remoteUsers: _remoteUsers,
          );
          emit(newState);
        }
        return;
      }
      print('zoom: onUserVideoStatusChanged: mySelf is null');
    });
    meetingEvents.add(userVideoStatusChangedListener);

    // * Audio status of a user changed
    final userAudioStatusChangedListener =
        emitter.on(EventType.onUserAudioStatusChanged, (data) async {
      data = data as Map;
      print('zoom: onUserAudioStatusChanged: $data');
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
      print('zoom: onUserAudioStatusChanged: mySelf is null');
    });
    meetingEvents.add(userAudioStatusChangedListener);

    // * User share-screen status changed
    final userShareStatusChangeListener =
        emitter.on(EventType.onUserShareStatusChanged, (data) async {
      data = data as Map;
      print('zoom: onUserShareStatusChanged: $data');
      if (data['status'] == ShareStatus.Start) {
        ZoomVideoSdkUser? shareUser = data['user'] == null
            ? null
            : ZoomVideoSdkUser.fromJson(jsonDecode(data['user'].toString()));
        _isSharing = true;
        _sharingUserId = shareUser?.userId ?? '';
        _remoteUsers = (await _zoom.session.getRemoteUsers()) ?? [];
        ZoomVideoSdkUser? mySelf = await _zoom.session.getMySelf();
        MeetingJoined newState = await _composeJoinedState(
          thisUser: _mySelf ?? mySelf!,
          remoteUsers: _remoteUsers,
        );
        emit(newState);
      } else {
        _isSharing = false;
        _sharingUserId = '';
        MeetingJoined newState = await _composeJoinedState(
          thisUser: _mySelf!,
          remoteUsers: await _zoom.session.getRemoteUsers() ?? [],
        );
        emit(newState);
      }
    });
    meetingEvents.add(userShareStatusChangeListener);

    // * Chat message received
    final chatMessageReceivedListener = emitter.on(EventType.onChatNewMessageNotify, (data) async {
      print('zoom: onChatNewMessageNotify: $data');
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
      print('zoom: onUserJoin: $data');
      var userListJson = jsonDecode(data['remoteUsers']) as List;
      List<ZoomVideoSdkUser> remoteUsers =
          userListJson.map((userJson) => ZoomVideoSdkUser.fromJson(userJson)).toList();
      _remoteUsers = remoteUsers;
      MeetingJoined newState =
          await _composeJoinedState(thisUser: _mySelf!, remoteUsers: _remoteUsers);
      emit(newState);
    });
    meetingEvents.add(userJoinListener);

    // * Other user left the session
    final userLeaveListener = emitter.on(EventType.onUserLeave, (data) async {
      data = data as Map;
      print('zoom: onUserLeave: $data');
      var userListJson = jsonDecode(data['remoteUsers']) as List;
      List<ZoomVideoSdkUser> remoteUsers =
          userListJson.map((userJson) => ZoomVideoSdkUser.fromJson(userJson)).toList();
      _remoteUsers = remoteUsers;
      if (_mySelf != null) {
        MeetingJoined newState =
            await _composeJoinedState(thisUser: _mySelf!, remoteUsers: _remoteUsers);
        emit(newState);
      }
    });
    meetingEvents.add(userLeaveListener);

    // * username changed
    final userNameChangedListener = emitter.on(EventType.onUserNameChanged, (data) async {
      print('zoom: onUserNameChanged: $data');
    });
    meetingEvents.add(userNameChangedListener);

    // * User's network quality changed
    final networkStatusChangeListener =
        emitter.on(EventType.onUserVideoNetworkStatusChanged, (data) async {
      print('zoom: onUserVideoNetworkStatusChanged: $data');
    });
    meetingEvents.add(networkStatusChangeListener);

    // ! Session error
    final sessionErrorListener = emitter.on(EventType.onError, (data) async {
      print('zoom: onError: $data');
    });
    meetingEvents.add(sessionErrorListener);
  }

  void _userJoined(Object? sessionUser) async {
    _isJoined = true;
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    print('zoom: onSessionJoin: $sessionUser');
    _zoom.session.getSessionID().then((value) {
      if (_latestSessionId != null && _latestSessionId == value) {
        _chatMessagesNotifier.value = _latestChatMessages;
      } else {
        _latestChatMessages = [];
        _chatMessagesNotifier.value = [];
      }
      _latestSessionId = value;
    });
    _zoom.videoHelper.getNumberOfCameras().then((value) {
      _haveMultipleCamera.value = _initVideoOn && value > 1;
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

    MeetingJoined newState = await _composeJoinedState(thisUser: mySelf, remoteUsers: _remoteUsers);
    emit(newState);
  }

  void _userLeft(Object? data) {
    _isJoined = false;
    print('zoom: onSessionLeave: $data');
    emit(MeetingLeaving());
  }

  Future<MeetingJoined> _composeJoinedState({
    required ZoomVideoSdkUser thisUser,
    List<ZoomVideoSdkUser> remoteUsers = const [],
  }) async {
    // Just this user in the session
    if (remoteUsers.isEmpty) {
      return MeetingJoined(
        thisUser: thisUser,
        fullscreenUser: thisUser,
        remoteUsers: remoteUsers,
      );
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
      if (sharingUser != null) {
        // This user is sharing screen
        if (sharingUser.userId == thisUser.userId) {
          return MeetingJoined(
            thisUser: thisUser,
            fullscreenUser: thisUser,
            remoteUsers: remoteUsers,
          );
        } else {
          // Someone else is sharing screen
          return MeetingJoined(
            thisUser: thisUser,
            fullscreenUser: sharingUser,
            remoteUsers: remoteUsers,
          );
        }
      } else {
        // No one is sharing screen
        // Priority: Host > Manager > Attendee (any with video on)
        ZoomVideoSdkUser? hostUser = null;
        for (var user in remoteUsers) {
          bool isVideoOn = await user.videoStatus?.isOn() ?? false;
          if ((user.isHost ?? false) && isVideoOn) {
            hostUser = user;
            break;
          }
          if ((user.isManager ?? false) && isVideoOn) {
            hostUser = user;
            break;
          }
          if (isVideoOn) {
            hostUser = user;
            break;
          }
        }
        if (hostUser == null) {
          hostUser = remoteUsers.first;
        }
        return MeetingJoined(
          thisUser: thisUser,
          fullscreenUser: hostUser,
          remoteUsers: remoteUsers,
        );
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
