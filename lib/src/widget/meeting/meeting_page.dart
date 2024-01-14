import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:events_emitter/events_emitter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk_event_listener.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk_user.dart';
import 'package:medical/src/widget/meeting/widgets/video_view.dart';

class MeetingPage extends HookWidget {
  const MeetingPage({super.key});

  @override
  Widget build(BuildContext context) {
    var zoom = ZoomVideoSdk();
    var eventListener = ZoomVideoSdkEventListener();
    var videoInfo = useState<String>('');

    var sessionName = useState('');

    // Only remote users
    var remoteUsers = useState(<ZoomVideoSdkUser>[]);
    // This user
    var thisUser = useState<ZoomVideoSdkUser?>(null);
    // Video On or Sharing screen
    var fullScreenUser = useState<ZoomVideoSdkUser?>(null);

    var isMounted = useIsMounted();
    var isMuted = useState(true);
    var isVideoOn = useState(false);

    // * Prepare & Join session
    useEffect(() {
      Future<void>.microtask(() async {
        try {
          Map<String, bool> audioOptions = {
            "connect": true,
            "mute": true,
            "autoAdjustSpeakerVolume": false
          };
          Map<String, bool> videoOptions = {
            "localVideoOn": true,
          };
          final args = ModalRoute.of(context)!.settings.arguments as MeetingArguments;
          JoinSessionConfig joinSession = JoinSessionConfig(
            sessionName: args.sessionName,
            sessionPassword: args.sessionPassword,
            token: args.token,
            userName: args.displayName,
            audioOptions: audioOptions,
            videoOptions: videoOptions,
            sessionIdleTimeoutMins: int.parse(args.sessionIdleTimeoutMins),
          );
          await zoom.joinSession(joinSession);
        } catch (e) {
          debugPrint('Error joining session: $e');
          // Show error dialog
          const AlertDialog(
            title: Text("Error"),
            content: Text("Failed to join the session"),
          );
          Future.delayed(const Duration(milliseconds: 1000)).asStream().listen((event) {
            Navigator.pop(context);
          });
        }
      });
      return null;
    }, []);

    // * Listen to events
    useEffect(() {
      eventListener.addEventListener();
      EventEmitter emitter = eventListener.eventEmitter;

      final sessionJoinListener = emitter.on(EventType.onSessionJoin, (sessionUser) async {
        zoom.session.getSessionName().then((value) => sessionName.value = value!);
        ZoomVideoSdkUser mySelf = ZoomVideoSdkUser.fromJson(jsonDecode(sessionUser.toString()));
        List<ZoomVideoSdkUser>? otherUsers = await zoom.session.getRemoteUsers();
        var muted = await mySelf.audioStatus?.isMuted();
        var videoOn = await mySelf.videoStatus?.isOn();
        thisUser.value = mySelf;
        remoteUsers.value = otherUsers!;
        isMuted.value = muted!;
        isVideoOn.value = videoOn!;
        _determineFullscreenAndPreviewUser(mySelf, otherUsers, fullScreenUser);
      });

      final eventErrorListener = emitter.on(EventType.onError, (data) async {
        print(data);
      });

      final sessionLeaveListener = emitter.on(EventType.onSessionLeave, (data) async {
        thisUser.value = null;
        remoteUsers.value = <ZoomVideoSdkUser>[];
        fullScreenUser.value = null;
        // TODO: Show dialog
        Future.delayed(const Duration(milliseconds: 1000)).asStream().listen((event) {
          Navigator.pop(context);
        });
      });

      final sessionNeedPasswordListener = emitter.on(EventType.onSessionNeedPassword, (data) async {
        // ! Can't occur, because these params got from server-side
        // => consider as error-case
      });

      final sessionPasswordWrongListener =
          emitter.on(EventType.onSessionPasswordWrong, (data) async {
        // ! Can't occur, because these params got from server-side
        // => consider as error-case
      });

      final userVideoStatusChangedListener =
          emitter.on(EventType.onUserVideoStatusChanged, (data) async {
        data = data as Map;
        ZoomVideoSdkUser? mySelf = await zoom.session.getMySelf();
        var userListJson = jsonDecode(data['changedUsers']) as List;
        List<ZoomVideoSdkUser> userList =
            userListJson.map((userJson) => ZoomVideoSdkUser.fromJson(userJson)).toList();
        for (var user in userList) {
          if (user.userId == mySelf?.userId) {
            mySelf?.videoStatus?.isOn().then((on) => isVideoOn.value = on);
            thisUser.value = mySelf;
            break;
          } else {
            for (var remoteUser in remoteUsers.value) {
              if (remoteUser.userId == user.userId) {
                int index = remoteUsers.value.indexOf(remoteUser);
                remoteUsers.value[index] = user;
              }
            }
            _determineFullscreenAndPreviewUser(thisUser.value, remoteUsers.value, fullScreenUser);
          }
        }
      });

      final userAudioStatusChangedListener =
          emitter.on(EventType.onUserAudioStatusChanged, (data) async {
        data = data as Map;
        ZoomVideoSdkUser? mySelf = await zoom.session.getMySelf();
        var userListJson = jsonDecode(data['changedUsers']) as List;
        List<ZoomVideoSdkUser> userList =
            userListJson.map((userJson) => ZoomVideoSdkUser.fromJson(userJson)).toList();
        for (var user in userList) {
          if (user.userId == thisUser.value!.userId) {
            mySelf?.audioStatus?.isMuted().then((muted) {
              isMuted.value = muted;
              thisUser.value = mySelf;
            });
            break;
          }
        }
      });

      final userShareStatusChangeListener =
          emitter.on(EventType.onUserShareStatusChanged, (data) async {
        data = data as Map;
        ZoomVideoSdkUser shareUser = ZoomVideoSdkUser.fromJson(jsonDecode(data['user'].toString()));
        for (var user in remoteUsers.value) {
          if (user.userId == shareUser.userId) {
            int index = remoteUsers.value.indexOf(user);
            remoteUsers.value[index] = shareUser;
          }
        }
        _determineFullscreenAndPreviewUser(thisUser.value, remoteUsers.value, fullScreenUser);
      });

      final userJoinListener = emitter.on(EventType.onUserJoin, (data) async {
        if (!isMounted()) return;
        data = data as Map;
        var userListJson = jsonDecode(data['remoteUsers']) as List;
        List<ZoomVideoSdkUser> otherUsers =
            userListJson.map((userJson) => ZoomVideoSdkUser.fromJson(userJson)).toList();
        remoteUsers.value = otherUsers;
        _determineFullscreenAndPreviewUser(thisUser.value, otherUsers, fullScreenUser);
      });

      final userLeaveListener = emitter.on(EventType.onUserLeave, (data) async {
        if (!isMounted()) return;
        data = data as Map;
        var remoteUserListJson = jsonDecode(data['remoteUsers']) as List;
        List<ZoomVideoSdkUser> otherUsers =
            remoteUserListJson.map((userJson) => ZoomVideoSdkUser.fromJson(userJson)).toList();
        // var leftUserListJson = jsonDecode(data['leftUsers']) as List;
        // List<ZoomVideoSdkUser> leftUserLis = leftUserListJson
        //     .map((userJson) => ZoomVideoSdkUser.fromJson(userJson))
        //     .toList();
        remoteUsers.value = otherUsers;
        _determineFullscreenAndPreviewUser(thisUser.value, otherUsers, fullScreenUser);
      });

      final userNameChangedListener = emitter.on(EventType.onUserNameChanged, (data) async {
        if (!isMounted()) return;
        data = data as Map;
        ZoomVideoSdkUser? changedUser = ZoomVideoSdkUser.fromJson(jsonDecode(data['changedUser']));
        int index;
        for (var user in remoteUsers.value) {
          if (user.userId == changedUser.userId) {
            index = remoteUsers.value.indexOf(user);
            remoteUsers.value[index] = changedUser;
          }
        }
        // Just keep for next-time view users join list
        // _determineFullscreenAndPreviewUser(thisUser.value, remoteUsers.value, fullScreenUser);
      });

      final requireSystemPermission = emitter.on(EventType.onRequireSystemPermission, (data) async {
        // TODO: More check on it
        // await _grantPermission();
      });

      final networkStatusChangeListener =
          emitter.on(EventType.onUserVideoNetworkStatusChanged, (data) async {});

      return () => {
            sessionJoinListener.cancel(),
            sessionLeaveListener.cancel(),
            sessionPasswordWrongListener.cancel(),
            sessionNeedPasswordListener.cancel(),
            userVideoStatusChangedListener.cancel(),
            userAudioStatusChangedListener.cancel(),
            userJoinListener.cancel(),
            userLeaveListener.cancel(),
            userNameChangedListener.cancel(),
            userShareStatusChangeListener.cancel(),
            eventErrorListener.cancel(),
            requireSystemPermission.cancel(),
            networkStatusChangeListener.cancel(),
          };
    }, [zoom, remoteUsers.value, isMounted]);

    void _onPressAudio() async {
      ZoomVideoSdkUser? mySelf = await zoom.session.getMySelf();
      if (mySelf != null) {
        final audioStatus = mySelf.audioStatus;
        if (audioStatus != null) {
          var muted = await audioStatus.isMuted();
          if (muted) {
            await zoom.audioHelper.unMuteAudio(mySelf.userId);
          } else {
            await zoom.audioHelper.muteAudio(mySelf.userId);
          }
        }
      }
    }

    void _onPressVideo() async {
      ZoomVideoSdkUser? mySelf = await zoom.session.getMySelf();
      if (mySelf != null) {
        final videoStatus = mySelf.videoStatus;
        if (videoStatus != null) {
          var videoOn = await videoStatus.isOn();
          if (videoOn) {
            await zoom.videoHelper.stopVideo();
          } else {
            await zoom.videoHelper.startVideo();
          }
        }
      }
    }

    void _onLeaveSession() async {
      await zoom.leaveSession(false);
      if (isMounted()) {
        Navigator.pop(context);
      }
    }

    // TODO: Handle chat

    Widget fullScreenView;
    Widget previewView;

    // * Connecting
    if (thisUser.value == null) {
      return Material(
        child: Container(
          color: Colors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 30.0),
              Text(
                'Đang kết nối...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.0,
                ),
              ),
              const SizedBox(height: 20.0),
              Text(
                'Vui lòng chờ trong giây lát',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // * JOINED
    // * Only me in session => Fullscreen view
    if (remoteUsers.value.isEmpty) {
      fullScreenView = VideoView(
        avatarUrl: null,
        user: thisUser.value!,
        fullScreen: true,
        resolution: VideoResolution.Resolution1080,
        videoAspect: VideoAspect.Original,
      );
      previewView = const SizedBox();
    } else {
      // * More than 1 user in session
      previewView = VideoView(
        avatarUrl: null,
        user: thisUser.value!,
        fullScreen: false,
        resolution: VideoResolution.Resolution720,
        videoAspect: VideoAspect.Original,
      );
      // if (thisUser.value!.videoStatus != null) {
      // } else {
      //   previewView = SizedBox();
      // }
      // host view
      fullScreenView = VideoView(
        avatarUrl: null,
        user: fullScreenUser.value!,
        fullScreen: true,
        resolution: VideoResolution.Resolution720,
      );
    }

    final double leaveButtonWidth = 100.0;
    final double leaveButtonHeight = 32.0;
    Widget controlAndPreviewWidget = SafeArea(
      child: Column(
        children: [
          // Headers
          Container(
            height: 56.0,
            color: Colors.black.withOpacity(0.5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Dummy for center
                Container(
                    width: leaveButtonWidth,
                    height: leaveButtonHeight,
                    child: IconButton(
                      onPressed: _onLeaveSession,
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                    )),
                // Session name
                Expanded(
                  child: Center(
                    child: Text(
                      sessionName.value,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // More
                Container(
                  width: leaveButtonWidth,
                  height: leaveButtonHeight,
                  child: ElevatedButton(
                    onPressed: _onLeaveSession,
                    child: const Text(
                      'Rời khỏi',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0)
              ],
            ),
          ),
          // Preview
          Expanded(
            child: Align(
              alignment: Alignment.topRight,
              child: previewView,
            ),
          ),
          // Controls
          _buildControls(
            isMuted.value,
            isVideoOn.value,
            _onPressAudio,
            _onPressVideo,
          ),
        ],
      ),
    );

    return Scaffold(
      body: WillPopScope(
        onWillPop: () async => false,
        child: Stack(
          children: [
            // VideoView
            Positioned.fill(child: fullScreenView),
            // Preview - right top
            Positioned.fill(child: controlAndPreviewWidget),
          ],
        ),
      ),
    );
  }

  // build controls
  Widget _buildControls(
    bool isMuted,
    bool isVideoOn,
    void Function() onPressAudio,
    void Function() onPressVideo,
  ) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Audio
          _buttonIconWithTextBelow(isMuted ? Icons.mic_off : Icons.mic,
              isMuted ? 'Bật tiếng' : 'Tắt tiếng', onPressAudio,
              iconSize: 28.0),
          const SizedBox(width: 8.0),
          _buttonIconWithTextBelow(
            isVideoOn ? Icons.videocam : Icons.videocam_off,
            isVideoOn ? 'Bật video' : 'Tắt video',
            onPressVideo,
          ),
          // separator
          Container(
            width: 20.0,
            padding: const EdgeInsets.symmetric(horizontal: 9.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(100),
                borderRadius: BorderRadius.circular(1.0),
              ),
              child: SizedBox(
                height: 42.0,
                width: 2.0,
              ),
            ),
          ),
          // Chat
          _buttonIconWithTextBelow(
            CupertinoIcons.chat_bubble_text_fill,
            'Chat',
            () {},
            iconSize: 28.0,
          ),
        ],
      ),
    );
  }

  Widget _buttonIconWithTextBelow(IconData icon, String text, void Function() onPressed,
      {double iconSize = 32.0}) {
    var color = Colors.white.withAlpha(200);
    return Column(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            color: color,
            size: iconSize,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 11.0,
          ),
        ),
      ],
    );
  }

  void _determineFullscreenAndPreviewUser(
    ZoomVideoSdkUser? thisUser,
    List<ZoomVideoSdkUser> remoteUsers,
    ValueNotifier<ZoomVideoSdkUser?> fullScreenUser,
  ) {
    if (remoteUsers.isEmpty) {
      fullScreenUser.value = thisUser;
    } else {
      // Priority: Host > Manager > Any share-screen > Attendee
      List<ZoomVideoSdkUser> hosts = remoteUsers.where((user) => user.isHost == true).toList();
      if (hosts.isNotEmpty) {
        fullScreenUser.value = hosts.first;
      } else {
        List<ZoomVideoSdkUser> coHosts =
            remoteUsers.where((user) => user.isManager == true).toList();
        if (coHosts.isNotEmpty) {
          fullScreenUser.value = coHosts.first;
        } else {
          List<ZoomVideoSdkUser> shareScreens =
              remoteUsers.where((user) => user.isSharing == true).toList();
          if (shareScreens.isNotEmpty) {
            fullScreenUser.value = shareScreens.first;
          } else {
            fullScreenUser.value = remoteUsers.first;
          }
        }
      }
    }
  }
}

class MeetingArguments {
  final String token;
  final String sessionName;
  final String displayName;
  final String sessionPassword;
  final String sessionIdleTimeoutMins;

  MeetingArguments({
    required this.token,
    required this.sessionName,
    required this.displayName,
    required this.sessionPassword,
    required this.sessionIdleTimeoutMins,
  });
}
