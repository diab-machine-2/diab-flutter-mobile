import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk.dart';
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

class _MeetingPageState extends State<MeetingPage> {
  late MeetingCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = MeetingCubit(widget.args);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocListener<MeetingCubit, MeetingState>(
          listener: (context, state) {
            // Handle leave session
            if (state is MeetingLeaving || state is MeetingJoinError) {
              Navigator.pop(context);
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
              return SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildJoining() {
    return Material(
      child: Container(
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
      ),
    );
  }

  Widget _buildJoinedState(MeetingJoined state) {
    Widget previewView = const SizedBox();
    Widget fullScreenView = const SizedBox();

    if (state.remoteUsers.isNotEmpty && state.thisUser != null) {
      previewView = VideoView(
        avatarUrl: null,
        user: state.thisUser,
        fullScreen: false,
        resolution: VideoResolution.Resolution720,
        videoAspect: VideoAspect.Original,
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
                      onPressed: _cubit.leaveSession,
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
                    onPressed: _cubit.leaveSession,
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
          Expanded(
            child: Align(
              alignment: Alignment.topRight,
              child: previewView,
            ),
          ),
          // Controls
          _buildControls(),
        ],
      ),
    );
    return Stack(
      children: [
        Positioned.fill(child: fullScreenView),
        // Preview - right top
        Positioned.fill(child: controlAndPreviewWidget),
      ],
    );
  }

  // build controls
  Widget _buildControls() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
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
              }),
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
          _buttonIconWithTextBelow(
            CupertinoIcons.chat_bubble_text_fill,
            'Chat',
            () => _showChatBottomSheet(context),
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

  void _showChatBottomSheet(BuildContext context) {
    var bloc = _cubit;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => ChatView(
          messagesValueNotifier: bloc.chatMessages,
          onSendMessage: bloc.sendChatToAll,
          scrollController: scrollController,
          textEditingController: bloc.chatController,
        ),
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
