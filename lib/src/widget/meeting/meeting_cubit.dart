import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk_event_listener.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk_user.dart';
import 'package:medical/src/widget/meeting/meeting_page.dart';
import 'package:events_emitter/events_emitter.dart';

import 'meeting_state.dart';

class MeetingCubit extends Cubit<MeetingState> {
  final MeetingArguments args;
  final ZoomVideoSdk _zoom = ZoomVideoSdk();
  final _eventListener = ZoomVideoSdkEventListener();
  final List<EventListener<Object?>> meetingEvents = [];

  Future<String?> get sessionName => _zoom.session.getSessionName();

  // Cached
  ZoomVideoSdkUser? _mySelf;
  ZoomVideoSdkUser? get user => _mySelf;
  List<ZoomVideoSdkUser> _remoteUsers = [];

  bool _isSharing = false;
  String _sharingUserId = '';

  final int timeoutInSeconds = 15;
  bool _isJoined = false;
  Timer? _timeoutTimer;
  // late

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
    var newState = (state as MeetingJoined).copyWith(previewUser: mySelf);
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
        } else {
          await _zoom.videoHelper.startVideo();
        }
      }
    }
    var newState = (state as MeetingJoined).copyWith(previewUser: mySelf);
    emit(newState);
  }

  void leaveSession() async {
    try {
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
        "localVideoOn": false,
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
    } catch (e) {
      print('zoom: Error joining session: $e');
      // TODO: emit error
    }
  }

  void _doStartListenZoomEvents() {
    _eventListener.addEventListener();
    EventEmitter emitter = _eventListener.eventEmitter;
    // * This user joined the session
    final sessionJoinListener = emitter.on(EventType.onSessionJoin, (sessionUser) async {
      _isJoined = true;
      _timeoutTimer?.cancel();
      _timeoutTimer = null;
      print('zoom: onSessionJoin: $sessionUser');
      ZoomVideoSdkUser mySelf = ZoomVideoSdkUser.fromJson(jsonDecode(sessionUser.toString()));
      _mySelf = mySelf;
      List<ZoomVideoSdkUser>? otherUsers = await _zoom.session.getRemoteUsers();
      _remoteUsers = otherUsers ?? [];
      MeetingJoined newState =
          await _composeJoinedState(thisUser: mySelf, remoteUsers: _remoteUsers);
      emit(newState);
    });
    meetingEvents.add(sessionJoinListener);

    // * This user left the session
    final sessionLeaveListener = emitter.on(EventType.onSessionLeave, (data) async {
      _isJoined = false;
      print('zoom: onSessionLeave: $data');
      emit(MeetingLeaving());
    });
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
          if (_mySelf != null) {
            _mySelf = mySelf;
            if (state is MeetingJoined) {
              MeetingJoined newState = (state as MeetingJoined).copyWith(previewUser: mySelf);
              emit(newState);
            }
          }
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
          if (_mySelf != null) {
            _mySelf = mySelf;
            if (state is MeetingJoined) {
              MeetingJoined newState = (state as MeetingJoined).copyWith(previewUser: mySelf);
              emit(newState);
            }
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
      ZoomVideoSdkUser? mySelf = await _zoom.session.getMySelf();
      ZoomVideoSdkUser? shareUser = data['user'] == null
          ? null
          : ZoomVideoSdkUser.fromJson(jsonDecode(data['user'].toString()));

      if (data['status'] == ShareStatus.Start) {
        _isSharing = true;
        _sharingUserId = shareUser?.userId ?? '';
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

  Future<MeetingJoined> _composeJoinedState({
    required ZoomVideoSdkUser thisUser,
    List<ZoomVideoSdkUser> remoteUsers = const [],
  }) async {
    // Just this user in the session
    if (remoteUsers.isEmpty) {
      return MeetingJoined(
        previewUser: null,
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
            previewUser: null,
            fullscreenUser: null,
            remoteUsers: remoteUsers,
          );
        } else {
          // Someone else is sharing screen
          return MeetingJoined(
            previewUser: thisUser,
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
          previewUser: thisUser,
          fullscreenUser: hostUser,
          remoteUsers: remoteUsers,
        );
      }
    }
  }
}
