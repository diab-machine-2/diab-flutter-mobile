import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/meeting/widgets/chat_view.dart';
import 'package:medical/src/widget/meeting/widgets/video_view.dart';
import 'package:wakelock/wakelock.dart';

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
  late final AnimationController _controller = AnimationController(
    duration: Duration(milliseconds: 200),
    vsync: this,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
    reverseCurve: Curves.easeIn,
  );
  ValueNotifier<bool> _keyboardVisible = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
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
    _controller.dispose();
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
        _cubit.turnoffVideoPreviewIfNeeded();
        break;
      case AppLifecycleState.resumed:
        _cubit.turnonVideoPreviewIfNeeded();
        break;
      default:
        break;
    }
  }

  @override
  void didChangeMetrics() async {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final keyboardVisible = bottomInset > 0.0;
    if (keyboardVisible == this._keyboardVisible.value) {
      return;
    }
    this._keyboardVisible.value = keyboardVisible;
    await Future.delayed(Duration(milliseconds: 100));
    if (keyboardVisible && _controller.isCompleted && !_controller.isAnimating) {
      _controller.forward();
    } else if (!keyboardVisible && _controller.isDismissed && !_controller.isAnimating) {
      _controller.reverse();
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
        videoAspect: VideoAspect.Original,
      );
    }
    if (isLandScape && state.fullscreenUser.isSharing) {
      return VideoView(
        avatarUrl: null,
        user: state.fullscreenUser,
        fullScreen: true,
        isPiPView: true,
        sharing: state.fullscreenUser.isSharing,
        resolution: VideoResolution.Resolution720,
      );
    }
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
                // Back button
                Container(
                  width: leaveButtonWidth,
                  height: leaveButtonHeight,
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
                        icon: Icon(
                          Icons.switch_camera,
                          color: Colors.white,
                          size: 20.0,
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
                // More
                Container(
                  width: leaveButtonWidth,
                  height: leaveButtonHeight,
                  child: ElevatedButton(
                    onPressed: () => _confirmAndQuitSession(context),
                    child: const Text(
                      'Rời khỏi',
                      style: TextStyle(
                        fontSize: 16,
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
          Align(
            alignment: Alignment.topRight,
            child: previewView,
          ),
        ],
      ),
    );
    var media = MediaQuery.of(context);
    final size = media.size;
    return Stack(
      children: [
        Positioned.fill(child: fullScreenView),
        Positioned(
          top: 0.0,
          right: 0.0,
          left: 0.0,
          child: controlAndPreviewWidget,
        ),
        Positioned(
          bottom: media.padding.bottom,
          left: 0.0,
          right: 0.0,
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                Container(child: _buildControls(size.height)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // build controls
  Widget _buildControls(double maxHeight) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          ValueListenableBuilder(
            valueListenable: _keyboardVisible,
            builder: (_, value, child) {
              if (value) {
                return const SizedBox();
              }
              final listActions = Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                    isOff: true,
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
              double width = MediaQuery.of(context).size.width;
              if (width > 450.0) {
                return Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 450.0,
                    child: listActions,
                  ),
                );
              }
              return listActions;
            },
          ),
          SizeTransition(
            sizeFactor: _animation,
            axis: Axis.vertical,
            axisAlignment: 1.0,
            child: Container(
              margin: EdgeInsets.only(top: 8.0),
              height: min(maxHeight * 0.5, 400.0),
              child: ChatView(
                messagesValueNotifier: _cubit.chatMessages,
                onSendMessage: _cubit.sendChatToAll,
                textEditingController: chatController,
                onClose: _hideChat,
                focusNode: chatFocusNode,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buttonIconWithTextBelow(
    String iconPath,
    String text,
    void Function() onPressed, {
    bool isOff = false,
    double size = 33.0,
    Color? backgroundColor,
  }) {
    var color = Colors.white.withAlpha(200);
    return Column(
      children: [
        InkWell(
          onTap: onPressed,
          splashFactory: InkRipple.splashFactory,
          child: Container(
            width: 62,
            height: 62,
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
          style: TextStyle(
            color: color,
            fontSize: 16.0,
          ),
        ),
      ],
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
              Navigator.popUntil(context, _rootPredicate);
            },
            child: Text('Đồng ý'),
          ),
        ],
      ),
    );
  }

  void _showChat() {
    _cubit.startChat();
    chatFocusNode.requestFocus();
    _controller.forward();
  }

  void _hideChat() {
    _cubit.endChat();
    _controller.reverse();
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _moreAction() {}

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
