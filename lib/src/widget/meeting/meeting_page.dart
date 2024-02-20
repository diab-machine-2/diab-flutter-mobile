import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/service/zoom_service.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/meeting/widgets/video_view.dart';
import 'package:wakelock/wakelock.dart';

import 'widgets/chat_view.dart';
import 'widgets/top_bottom_control_autohide_widget.dart';
import 'meeting_cubit.dart';
import 'meeting_state.dart';

class MeetingPage extends StatefulWidget {
  final MeetingArguments args;
  const MeetingPage(this.args, {super.key});

  @override
  State<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late MeetingCubit _cubit;
  final TextEditingController chatController = TextEditingController();
  final FocusNode chatFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    _cubit = MeetingCubit(widget.args);
    WidgetsBinding.instance.addObserver(this);
    Wakelock.enable();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    chatController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    Wakelock.disable();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _cubit.appPaused();
        break;
      case AppLifecycleState.resumed:
        _cubit.appResumed();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _confirmAndQuitSession(context);
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: BlocProvider(
          create: (_) => _cubit,
          child: BlocListener<MeetingCubit, MeetingState>(
            listener: (context, state) {
              // Handle leave session
              if (state is MeetingLeaving) {
                _popupSessionEnded(context);
                return;
              } else if (state is MeetingJoinError) {
                _popupUnknowError(context);
                return;
              }
            },
            listenWhen: (previous, current) =>
                current is MeetingLeaving || current is MeetingJoinError,
            child: BlocBuilder<MeetingCubit, MeetingState>(
              builder: (context, state) {
                print('zoom: Building state: $state');
                if (state is MeetingJoining) {
                  return _buildJoining();
                } else if (state is MeetingJoined) {
                  return _buildJoinedState(state);
                } else if (state is MeetingJoinError) {
                  // TODO: Handle error
                }
                return Container(
                  alignment: Alignment.center,
                  color: Colors.black,
                  child: CircleAvatar(
                    child: Text('Error', style: TextStyle(color: Colors.white)),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJoining() {
    return Container(
      color: Colors.black,
      width: double.infinity,
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
    );
  }

  Widget _buildJoinedState(MeetingJoined state) {
    bool isLandScape = MediaQuery.of(context).orientation == Orientation.landscape;
    Widget previewView = const SizedBox();
    Widget fullScreenView = const SizedBox();

    if (!isLandScape && state.remoteUsers.isNotEmpty && state.thisUser != null) {
      previewView = VideoView(
        avatarUrl: null,
        user: state.thisUser,
        fullScreen: false,
        resolution: VideoResolution.Resolution720,
      );
    }
    // Landscape mode + Other user is sharing screen
    if (isLandScape &&
        state.fullscreenUser.userId != state.thisUser?.userId &&
        state.fullscreenUser.isSharing) {
      fullScreenView = VideoView(
        avatarUrl: null,
        user: state.fullscreenUser,
        fullScreen: true,
        isPiPView: true,
        sharing: state.fullscreenUser.isSharing,
        resolution: VideoResolution.Resolution720,
      );
    } else {
      // This user is sharing screen
      if (state.thisUser != null &&
          state.thisUser!.userId == state.fullscreenUser.userId &&
          state.fullscreenUser.isSharing) {
        fullScreenView = Center(
          child: Text(
            'Đang chia sẻ màn hình',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      } else {
        // Other cases
        bool allowPiPMode = state.thisUser?.userId != state.fullscreenUser.userId;
        fullScreenView = VideoView(
          avatarUrl: null,
          user: state.fullscreenUser,
          fullScreen: true,
          isPiPView: allowPiPMode,
          sharing: state.fullscreenUser.isSharing,
          resolution: VideoResolution.Resolution720,
        );
      }
    }

    final media = MediaQuery.of(context);

    final double sizeComponentWidth = 100.0;
    final double sizeComponentHeight = 45.0;
    Widget headerWidget = Container(
      padding: EdgeInsets.only(top: media.padding.top),
      height: sizeComponentHeight + media.padding.top,
      color: Colors.black.withOpacity(0.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Switch camera
          Container(
            width: sizeComponentWidth,
            height: sizeComponentHeight,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 8.0),
            child: ValueListenableBuilder(
              valueListenable: _cubit.haveMultipleCamera,
              builder: (context, value, child) {
                if (!value) {
                  return const SizedBox();
                }
                return IconButton(
                  onPressed: () => _cubit.switchCamera(),
                  icon: Image.asset(
                    R.drawable.ic_zoom_camera_switch,
                  ),
                );
              },
            ),
          ),
          // Session name
          Expanded(
            child: Center(
              child: FutureBuilder<String?>(
                  future: _cubit.sessionName,
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }),
            ),
          ),
          // Speaker
          Container(
            width: sizeComponentWidth,
            height: sizeComponentHeight,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 8.0),
            child: ValueListenableBuilder(
              valueListenable: _cubit.currentSpeaker,
              builder: (context, value, _) {
                final icon = value == SpeakerMode.speaker
                    ? Icons.volume_up
                    : value == SpeakerMode.telephony
                        ? Icons.phone
                        : Icons.volume_off;
                return IconButton(
                  onPressed: () => _switchSpeaker(context),
                  icon: Icon(
                    icon,
                    color: Colors.white,
                    size: 24.0,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
    Widget floatingWidget = Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 12.0, right: 12.0),
        child: previewView,
      ),
    );
    Widget controlsWidget = _buildControls();
    return Stack(
      children: [
        Positioned.fill(child: fullScreenView),
        Positioned.fill(
          child: TopBottomControlAutohideWidget(
            topWidget: headerWidget,
            topWidgetHeight: sizeComponentHeight,
            bottomWidget: controlsWidget,
            bottomWidgetHeight: 100.0,
            floatingRightWidget: floatingWidget,
          ),
        ),
      ],
    );
  }

  // build controls
  Widget _buildControls() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Builder(
        builder: (context) {
          final media = MediaQuery.of(context);
          Widget listActions = Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Chat
              ValueListenableBuilder(
                valueListenable: _cubit.haveNewChat,
                child: _buttonIconWithTextBelow(
                  R.drawable.ic_zoom_chat,
                  'Trò chuyện',
                  _showChat,
                  isOff: false,
                ),
                builder: (__, value, child) {
                  return Stack(
                    children: [
                      child!,
                      if (value)
                        Positioned(
                          top: 12.0,
                          right: 12.0,
                          child: Container(
                            width: 12.0,
                            height: 12.0,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),

              // Camera
              FutureBuilder(
                future: _cubit.user?.videoStatus?.isOn(),
                builder: (context, snapshot) {
                  bool isVideoOn = snapshot.data ?? false;
                  return _buttonIconWithTextBelow(
                    isVideoOn ? R.drawable.ic_zoom_video_on : R.drawable.ic_zoom_video_off,
                    isVideoOn ? 'Bật camera' : 'Tắt camera',
                    _cubit.toggleVideo,
                    isOff: !isVideoOn,
                  );
                },
              ),

              // Audio
              FutureBuilder(
                future: _cubit.user?.audioStatus?.isMuted(),
                builder: (context, snapshot) {
                  bool isMuted = snapshot.data ?? false;
                  return _buttonIconWithTextBelow(
                    isMuted ? R.drawable.ic_zoom_audio_off : R.drawable.ic_zoom_audio_on,
                    isMuted ? 'Bật âm' : 'Tắt âm',
                    _cubit.toggleAudio,
                    isOff: isMuted,
                  );
                },
              ),

              // More
              _buttonIconWithTextBelow(
                R.drawable.ic_zoom_more,
                'Xem thêm',
                _moreAction,
                isOff: false,
              ),

              // Leave
              _buttonIconWithTextBelow(
                R.drawable.ic_zoom_end,
                'Kết thúc',
                () => _confirmAndQuitSession(context),
                isOff: true,
                backgroundColor: Color(0xFFD85140),
              ),
            ],
          );
          listActions = Padding(
            padding: EdgeInsets.only(bottom: media.padding.bottom + 8.0, top: 8.0),
            child: listActions,
          );
          if (media.size.width > 368.0) {
            return Align(
              alignment: Alignment.center,
              child: Container(
                width: 368.0,
                child: listActions,
              ),
            );
          }
          return listActions;
        },
      ),
    );
  }

  Widget _buttonIconWithTextBelow(
    String iconPath,
    String text,
    void Function() onPressed, {
    bool isOff = false,
    double size = 28.0,
    Color? backgroundColor,
  }) {
    var color = Colors.white.withAlpha(200);
    return SizedBox(
      width: 68.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: onPressed,
            child: Container(
              width: 56.0,
              height: 56.0,
              alignment: Alignment.center,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: backgroundColor ?? (isOff ? Colors.white : Color(0xFF3D4043)),
              ),
              child: Image.asset(
                iconPath,
                width: size,
                height: size,
              ),
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    );
  }

  bool _rootPredicate(Route<dynamic> route) {
    return route.isFirst || route.settings.name == NavigatorName.tabbar;
  }

  void _confirmAndQuitSession(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bạn có chắc chắn muốn rời khỏi cuộc họp?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              _cubit.leaveSession();
              Observable.instance.notifyObservers([], notifyName: "mark_completed_calendar");
              Navigator.popUntil(context, _rootPredicate);
            },
            child: Text('Đồng ý'),
          ),
        ],
      ),
    );
  }

  void _showChat() async {
    _cubit.startChat();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.9,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return ChatView(
              messagesValueNotifier: _cubit.chatMessages,
              onSendMessage: _cubit.sendChatToAll,
              textEditingController: chatController,
              focusNode: chatFocusNode,
              // scrollController: scrollController,
            );
          },
        );
      },
    );
    _cubit.endChat();
  }

  void _switchSpeaker(BuildContext context) {
    // show bottom sheet _cubit.speakerModes + Huỷ
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
      ),
      builder: (context) {
        return SafeArea(
          bottom: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var mode in _cubit.speakerModes)
                ListTile(
                  leading: Icon(
                    mode == SpeakerMode.speaker
                        ? Icons.volume_up
                        : mode == SpeakerMode.telephony
                            ? Icons.phone
                            : Icons.volume_off,
                  ),
                  title: Text(mode.name),
                  onTap: () {
                    _cubit.switchSpeaker(mode);
                    Navigator.pop(context);
                  },
                ),
              ListTile(
                leading: Icon(Icons.close),
                title: Text('Huỷ'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _moreAction() {
    // show bottom sheet with 3 options
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
      ),
      builder: (context) {
        final media = MediaQuery.of(context);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20.0),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Danh sách người tham gia'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Cài đặt'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('Thông tin'),
              onTap: () {},
            ),
            Padding(padding: media.padding),
          ],
        );
      },
    );
  }

  void _popupSessionEnded(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cuộc họp đã kết thúc'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.popUntil(context, _rootPredicate);
            },
            child: Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _popupUnknowError(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Đã có lỗi xảy ra'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.popUntil(context, _rootPredicate);
            },
            child: Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
