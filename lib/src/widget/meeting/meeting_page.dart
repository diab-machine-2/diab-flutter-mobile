import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/meeting/widgets/chat_view.dart';
import 'package:medical/src/widget/meeting/widgets/video_view.dart';

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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  void didChangeMetrics() async {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
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
          create: (context) => _cubit,
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
      fullScreenView = VideoView(
        avatarUrl: null,
        user: state.fullscreenUser,
        fullScreen: true,
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
                    child: IconButton(
                      onPressed: () => _confirmAndQuitSession(context),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                    )),
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
                ValueListenableBuilder<bool>(
                  valueListenable: _keyboardVisible,
                  builder: (_, value, child) {
                    double finalHeight = value ? 300.0 : 0.0;
                    return SizedBox(height: finalHeight);
                  },
                ),
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
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Audio
                  FutureBuilder(
                    future: _cubit.user?.audioStatus?.isMuted(),
                    builder: (context, snapshot) {
                      bool isMuted = snapshot.data ?? true;
                      return _buttonIconWithTextBelow(isMuted ? Icons.mic_off : Icons.mic,
                          isMuted ? 'Bật tiếng' : 'Tắt tiếng', _cubit.toggleAudio,
                          iconSize: 28.0);
                    },
                  ),
                  const SizedBox(width: 8.0),
                  FutureBuilder(
                      future: _cubit.user?.videoStatus?.isOn(),
                      builder: (context, snapshot) {
                        bool isVideoOn = snapshot.data ?? false;
                        return _buttonIconWithTextBelow(
                          isVideoOn ? Icons.videocam : Icons.videocam_off,
                          isVideoOn ? 'Bật video' : 'Tắt video',
                          _cubit.toggleVideo,
                        );
                      }),
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
                  ValueListenableBuilder(
                    valueListenable: _cubit.haveNewChat,
                    child: _buttonIconWithTextBelow(
                      CupertinoIcons.chat_bubble_text_fill,
                      'Trò chuyện',
                      _showChat,
                      iconSize: 28.0,
                    ),
                    builder: (__, value, child) {
                      return Stack(
                        children: [
                          child!,
                          if (value)
                            Positioned(
                              top: 8.0,
                              right: 8.0,
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
                ],
              );
            },
          ),
          SizeTransition(
            sizeFactor: _animation,
            axis: Axis.vertical,
            axisAlignment: 1.0,
            child: Container(
              margin: EdgeInsets.only(top: 8.0),
              height: min(maxHeight * 0.7, 500.0),
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
