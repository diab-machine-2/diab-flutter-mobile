import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_in_app_pip/flutter_in_app_pip.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/service/zoom_service.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/meeting/meeting_page_pip.dart';
import 'package:medical/src/widgets/background_page.dart';
import 'package:medical/src/widgets/button/primary_rounded_button.dart';
import 'package:medical/src/widgets/button/secondary_rounded_button.dart';

import 'widgets/chat_view.dart';
import 'meeting_cubit.dart';
import 'meeting_state.dart';
import 'widgets/video_view_v2.dart';
import 'widgets/zoom_functional_button.dart';

class MeetingPage extends StatefulWidget {
  final MeetingArguments? args;
  final MeetingCubit? cubit;
  const MeetingPage(this.args, this.cubit, {super.key});

  @override
  State<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage> with TickerProviderStateMixin {
  late MeetingCubit _cubit;
  final TextEditingController chatController = TextEditingController();
  final FocusNode chatFocusNode = FocusNode();

  bool _isPipMode = false;
  bool _confirmQuit = false;

  @override
  void initState() {
    super.initState();
    _cubit = widget.cubit ?? MeetingCubit(widget.args!);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    BotToast.closeAllLoading();
  }

  @override
  void dispose() {
    chatController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    if (!_isPipMode) {
      _cubit.close();
    }
    super.dispose();
  }

  void _pipMode(Size size) {
    _isPipMode = true;
    if (_cubit.state is! MeetingJoined) return;
    double space = 16.0;
    double minWH = size.width < size.height ? size.width : size.height;
    double width = (minWH - space * 2.0) * 2.0 / 3.0;
    double height = width * 9.0 / 16.0;
    PictureInPicture.updatePiPParams(
      pipParams: PiPParams(
        pipWindowWidth: width,
        pipWindowHeight: height,
        initialCorner: PIPViewCorner.bottomRight,
      ),
    );

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    PictureInPicture.startPiP(
      pipWidget: PiPWidget(
        onPiPClose: () {},
        child: MeetingPagePip(cubit: _cubit),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (!_confirmQuit) {
          _pipMode(MediaQuery.of(context).size);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        body: BlocProvider.value(
          value: _cubit,
          child: BlocListener<MeetingCubit, MeetingState>(
            listener: (context, state) {
              // Handle leave session
              if (!_confirmQuit && state is MeetingLeaving) {
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
                if (state is MeetingJoining) {
                  return _buildJoining();
                } else if (state is MeetingJoined) {
                  return _buildJoinedState(state);
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
    return Stack(
      children: [
        Positioned.fill(child: _buildBackgroundView()),
        Positioned.fill(child: _buildForegroundView()),
      ],
    );
  }

  bool _rootPredicate(Route<dynamic> route) {
    return route.isFirst || route.settings.name == NavigatorName.tabbar;
  }

  void _confirmAndQuitSession(BuildContext context) {
    double width = 343.0;

    // show dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          content: Container(
            width: width,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(height: 22.0),
                Text(
                  'zoom_leave_title'.tr(),
                  style: R.style.alertTitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'zoom_leave_content'.tr(),
                    style: R.style.alertContent,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 46.0),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: SecondaryRoundedButton(
                        title: 'alert_leave_cancel'.tr(),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: PrimaryRoundedButton(
                        title: 'alert_leave_agree'.tr(),
                        onPressed: () async {
                          _confirmQuit = true;
                          _cubit.leaveSession();
                          Observable.instance
                              .notifyObservers([], notifyName: "mark_completed_calendar");
                          Navigator.popUntil(context, _rootPredicate);
                        },
                      ),
                    ),
                    const SizedBox(width: 16.0),
                  ],
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        );
      },
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
              thisUserId: _cubit.user?.userId ?? '--',
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

  void _switchSpeaker() {
    SpeakerMode nextMode =
        _cubit.currentSpeaker.value == SpeakerMode.speaker ? SpeakerMode.off : SpeakerMode.speaker;
    _cubit.switchSpeaker(nextMode);
  }

  Widget _buildBackgroundView() {
    // this can be:
    // - host not join yet graphic
    // - host video view
    // - host avatar
    // ALL inside a Stack view
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    bool isHostJoined = _cubit.isHostJoined;
    bool isHostVideoOn = _cubit.isHostCameraOn;
    if (isHostJoined) {
      final state = _cubit.state as MeetingJoined;
      if (isHostVideoOn || state.fullscreenUser!.isSharing) {
        return VideoViewV2(
          avatarUrl: null,
          user: state.fullscreenUser,
          fullScreen: true,
          isPiPView: true,
          sharing: state.fullscreenUser!.isSharing,
          resolution: VideoResolution.Resolution360,
        );
      }
      double expectSized = 120.0;
      final avatarWidget = Container(
        clipBehavior: Clip.antiAlias,
        width: expectSized,
        height: expectSized,
        decoration: BoxDecoration(
          color: R.color.mainColor,
          borderRadius: BorderRadius.circular(expectSized / 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Icon(Icons.person, size: 72.0, color: R.color.white),
        ),
      );
      if (isLandscape) {
        return BackgroundPage(
          background: R.drawable.im_zoom_host_bg_landscape,
          child: Column(
            children: [
              const Expanded(flex: 1, child: SizedBox()),
              Center(child: avatarWidget),
              const Expanded(flex: 4, child: SizedBox()),
            ],
          ),
          fit: BoxFit.cover,
        );
      }
      return BackgroundPage(
        background: R.drawable.im_zoom_host_bg,
        child: Center(child: avatarWidget),
      );
    } else {
      int flexTop = isLandscape ? 3 : 3;
      int flexBottom = isLandscape ? 5 : 2;
      return Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(flex: flexTop, child: const SizedBox()),
            Image.asset(
              R.drawable.im_zoom_host_empty,
              width: 175.0,
              height: 163.0,
            ),
            SizedBox(height: isLandscape ? 20.0 : 55.0),
            Text(
              'host_not_joined_yet'.tr(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.0,
                height: 24.0 / 15.0,
              ),
            ),
            Expanded(flex: flexBottom, child: const SizedBox()),
          ],
        ),
      );
    }
  }

  Widget _buildForegroundView() {
    // this include
    // - app bar (with title, back button, switch camera)
    // - preview video view (or avatar)
    // - spacing
    // - host camera/mic status
    // - control buttons
    final media = MediaQuery.of(context);
    bool isLandscape = media.orientation == Orientation.landscape;

    List<Widget> micCamStatusWidgets = [
      // host camera/mic status
      if (_cubit.isHostJoined && _cubit.isHostMicOn == false)
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Center(
            child: Container(
              height: 28.0,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(R.drawable.ic_zoom_host_off_mic, width: 20.0, height: 20.0),
                  const SizedBox(width: 4.0),
                  Text(
                    'zoom_host_off_mic'.tr(),
                    style: TextStyle(
                      color: R.color.textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      if (_cubit.isHostJoined && _cubit.isHostCameraOn == false)
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Center(
            child: Container(
              height: 28.0,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.0),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(R.drawable.ic_zoom_host_off_camera, width: 20.0, height: 20.0),
                  const SizedBox(width: 4.0),
                  Text(
                    'zoom_host_off_camera'.tr(),
                    style: TextStyle(
                      color: R.color.textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    ];

    return Column(
      children: <Widget>[
        AppBar(
          actionsIconTheme: IconThemeData(size: 40.0),
          title: Text(_cubit.args.sessionName),
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Image.asset(R.drawable.ic_zoom_back, width: 40.0, height: 40.0),
            onPressed: () {
              _pipMode(MediaQuery.of(context).size);
              Navigator.pop(context);
            },
          ),
          actions: [
            ValueListenableBuilder(
                valueListenable: _cubit.haveMultipleCamera,
                builder: (context, value, child) {
                  if (value == false) return const SizedBox();
                  return IconButton(
                    icon: Image.asset(R.drawable.ic_zoom_switch_camera),
                    onPressed: () => _cubit.switchCamera(),
                  );
                }),
          ],
        ),

        const SizedBox(height: 8.0),

        // preview
        if (!isLandscape)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: _buildPreview(),
            ),
          ),
        if (isLandscape)
          Padding(
            padding: EdgeInsets.only(
              right: 8.0 + media.padding.right,
              left: 8.0 + media.padding.left,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: micCamStatusWidgets,
                  ),
                ),
                _buildPreview(),
              ],
            ),
          ),

        // spacing
        Expanded(child: SizedBox()),

        // host camera/mic status
        if (!isLandscape) ...micCamStatusWidgets,

        const SizedBox(height: 8.0),

        // control buttons
        Builder(builder: (context) {
          final media = MediaQuery.of(context);
          Color labelColor = Colors.white;
          double expectSized = 72.0;
          double expectPadding = 4.0;
          double finalWidth = 5 * expectSized + 4 * expectPadding;
          // check if 5 buttons with "expectSized", can fit in the screen, else loop to reduce 2 each time
          while (finalWidth > media.size.width) {
            expectSized -= 2.0;
            expectPadding -= 1.0;
            finalWidth = 5 * expectSized + 4 * expectPadding;
          }
          finalWidth = finalWidth.roundToDouble();

          Widget listActions = Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Chat
              ValueListenableBuilder(
                child: ZoomFunctionalButton(
                  assetPath: R.drawable.ic_zoom_chat,
                  labelText: 'zoom_chat'.tr(),
                  labelColor: labelColor,
                  onPressed: _showChat,
                ),
                valueListenable: _cubit.countNewChat,
                builder: (context, value, child) {
                  bool haveNewMessage = value > 0;
                  if (haveNewMessage) {
                    String text = value > 9 ? '9+' : " ${value.toString()} ";
                    return Stack(
                      children: [
                        child!,
                        Positioned(
                          top: 2.0,
                          right: 12.0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFE90101),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            clipBehavior: Clip.antiAlias,
                            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                            child: Text(
                              text,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return child!;
                },
              ).wrapWidth(expectSized),

              // Camera
              FutureBuilder(
                  future: _cubit.user?.videoStatus?.isOn(),
                  builder: (context, snapshot) {
                    bool isMyCameraOn = snapshot.data ?? false;
                    return ZoomFunctionalButton(
                      assetPath: isMyCameraOn
                          ? R.drawable.ic_zoom_camera_on
                          : R.drawable.ic_zoom_camera_off,
                      labelText: (!isMyCameraOn ? 'camera_turnon' : 'camera_turnoff').tr(),
                      labelColor: labelColor,
                      onPressed: _cubit.toggleVideo,
                    ).wrapWidth(expectSized);
                  }),

              // Mic
              FutureBuilder(
                  future: _cubit.user?.audioStatus?.isMuted(),
                  builder: (context, snapshot) {
                    bool isMyMicOn = !(snapshot.data ?? true);
                    return ZoomFunctionalButton(
                      assetPath: isMyMicOn ? R.drawable.ic_zoom_mic_on : R.drawable.ic_zoom_mic_off,
                      labelText: (!isMyMicOn ? 'mic_turnon' : 'mic_turnoff').tr(),
                      labelColor: labelColor,
                      onPressed: _cubit.toggleAudio,
                    ).wrapWidth(expectSized);
                  }),

              // Speaker
              ValueListenableBuilder(
                  valueListenable: _cubit.currentSpeaker,
                  builder: (context, value, _) {
                    bool isSpeakerOn =
                        value == SpeakerMode.speaker || value == SpeakerMode.telephony;
                    return ZoomFunctionalButton(
                      assetPath: isSpeakerOn
                          ? R.drawable.ic_zoom_speaker_on
                          : R.drawable.ic_zoom_speaker_off,
                      labelText: (!isSpeakerOn ? 'zoom_speaker_on' : 'zoom_speaker_off').tr(),
                      labelColor: labelColor,
                      onPressed: () => _switchSpeaker(),
                    ).wrapWidth(expectSized);
                  }),

              // End call
              ZoomFunctionalButton(
                assetPath: R.drawable.ic_zoom_end,
                labelText: 'zoom_endcall'.tr(),
                labelColor: labelColor,
                onPressed: () => _confirmAndQuitSession(context),
              ).wrapWidth(expectSized),
            ],
          );
          listActions = Padding(
            padding: EdgeInsets.only(bottom: media.padding.bottom / 2 + 8.0),
            child: listActions,
          );
          if (media.size.width > finalWidth) {
            return Align(
              alignment: Alignment.center,
              child: Container(
                width: finalWidth,
                child: listActions,
              ),
            );
          }
          return Center(child: listActions);
        }),
      ],
    );
  }

  Widget _buildPreview() {
    final media = MediaQuery.of(context);
    bool isLandscape = media.orientation == Orientation.landscape;
    final state = _cubit.state as MeetingJoined;

    // wrap max size to render is 90.0 x 160.0
    final thisMedia = media.copyWith(size: isLandscape ? Size(160.0, 90.0) : Size(90.0, 160.0));
    return MediaQuery(
      data: thisMedia,
      child: Container(
        width: thisMedia.size.width,
        height: thisMedia.size.height,
        decoration: BoxDecoration(
          color: Color(0xFF494949),
          // borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: VideoViewV2(
          avatarUrl: null,
          user: state.previewUser,
          fullScreen: false,
          resolution: VideoResolution.Resolution360,
        ),
      ),
    );
  }

  void _popupSessionEnded(BuildContext context) {
    if (context.mounted == false) return;
    showDialog(
      context: context,
      builder: (context) => _buildDialogInfoThenQuit('zoom_meeting_ended'.tr(), () {
        _confirmQuit = true;
        _cubit.leaveSession();
        Navigator.popUntil(context, _rootPredicate);
      }),
    );
  }

  void _popupUnknowError(BuildContext context) {
    if (context.mounted == false) return;
    showDialog(
      context: context,
      builder: (context) => _buildDialogInfoThenQuit('error_unexpected_error'.tr(), () {
        _confirmQuit = true;
        _cubit.leaveSession();
        Navigator.popUntil(context, _rootPredicate);
      }),
    );
  }

  Widget _buildDialogInfoThenQuit(String title, VoidCallback onQuit) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      content: Container(
        width: 343.0,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                title,
                style: R.style.alertContent,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24.0),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 16.0),
                const Expanded(child: SizedBox()),
                const SizedBox(width: 16.0),
                Expanded(
                  child: PrimaryRoundedButton(
                    title: 'close'.tr(),
                    onPressed: onQuit,
                  ),
                ),
                const SizedBox(width: 16.0),
              ],
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}

extension on Widget {
  Widget wrapWidth(double width) {
    return SizedBox(width: width, child: this);
  }
}
