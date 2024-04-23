import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_in_app_pip/flutter_in_app_pip.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk.dart';
import 'package:medical/src/app.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/meeting/meeting_cubit.dart';
import 'package:medical/src/widget/meeting/meeting_state.dart';

import 'widgets/video_view.dart';

class MeetingPagePip extends StatelessWidget {
  final MeetingCubit cubit;
  const MeetingPagePip({super.key, required this.cubit});

  void _stopPip() {
    cubit.leaveSession();
    cubit.close();
    PictureInPicture.stopPiP();
  }

  void _backToFullScreen() {
    PictureInPicture.stopPiP();
    navigatorKey.currentState!.pushNamed(NavigatorName.meeting, arguments: cubit);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: BlocListener<MeetingCubit, MeetingState>(
        listener: (context, state) {
          // Handle leave session
          if (state is MeetingLeaving) {
            _stopPip();
            return;
          } else if (state is MeetingJoinError) {
            _stopPip();
            return;
          }
          _stopPip();
        },
        listenWhen: (previous, current) => current is MeetingLeaving || current is MeetingJoinError,
        child: BlocBuilder<MeetingCubit, MeetingState>(
          builder: (context, state) {
            MeetingJoined meetingJoined = state as MeetingJoined;
            final key = Key('userId: ${meetingJoined.fullscreenUser.userId}, sharing: ${meetingJoined.fullscreenUser.isSharing}');
            return Stack(
              children: [
                VideoView(
                  key: key,
                  avatarUrl: null,
                  user: meetingJoined.fullscreenUser,
                  fullScreen: true,
                  isPiPView: true,
                  sharing: meetingJoined.fullscreenUser.isSharing,
                  resolution: VideoResolution.Resolution180,
                  isPiPMode: true,
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: IconButton(
                    icon: Icon(Icons.fullscreen),
                    color: Colors.white,
                    onPressed: _backToFullScreen,
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: Icon(Icons.close),
                    color: Colors.white,
                    onPressed: _stopPip,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
