import 'dart:async';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/const.dart';

import '../activity_tab.dart';

class CustomProgressBarWidget extends StatefulWidget {
  const CustomProgressBarWidget();

  @override
  State<CustomProgressBarWidget> createState() =>
      _CustomProgressBarWidgetState();
}

class _CustomProgressBarWidgetState extends State<CustomProgressBarWidget>
    with Observer {
  late final ActivityTabCubit _cubit;
  final LayerLink layerLink = LayerLink();
  OverlayEntry? messegeEntry;
  OverlayEntry? triangleEntry;
  Timer? _timer;

  bool isShowing = false;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<ActivityTabCubit>();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      showOverlay();
    });
    Observable.instance.addObserver(this);
  }

  @override
  void dispose() {
    disposeOverlay();
    Observable.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ActivityTabCubit, ActivityTabState>(
      listener: (context, state) {
        if (state is ActivityTabProgressChanged) {
          showOverlay();
        }
        if (state is GoalTypeChanged) {
          disposeOverlay();
          showOverlay();
        }
        if (state is ActivityTabHideProgressMessage) {
          disposeOverlay();
        }
      },
      builder: (context, state) {
        return CompositedTransformTarget(
          link: layerLink,
          child: LayoutBuilder(
            builder: (context, constraint) {
              return Container(
                alignment: Alignment.centerLeft,
                height: 6,
                width: double.infinity,
                color: R.color.gray,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(200),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        R.color.color0xff004E47.withOpacity(0.3),
                        R.color.mainColor,
                      ],
                    ),
                  ),
                  width: constraint.maxWidth * _cubit.progress,
                ),
              );
            },
          ),
        );
      },
    );
  }

  void showOverlay() {
    late final int progress;
    if (_cubit.progress >= 0.9 && !_cubit.messageState.showed90Message) {
      progress = 90;
      _cubit.messageState.showed90Message = true;
      _cubit.messageState.showed50Message = true;
      disposeOverlay();
    } else if (_cubit.progress >= 0.5 && !_cubit.messageState.showed50Message) {
      progress = 50;
      _cubit.messageState.showed50Message = true;
      disposeOverlay();
    } else {
      return;
    }

    final OverlayState? overlay = Overlay.of(context);
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    final Size? size = renderBox?.size;
    if (!isShowing) {
      messegeEntry = OverlayEntry(
        builder: (context) {
          return Positioned(
            height: 18,
            child: CompositedTransformFollower(
              link: layerLink,
              offset: Offset(
                  progress == 50
                      ? ((size?.width ?? 0) - 240) / 2
                      : ((size?.width ?? 0) - 260),
                  -23),
              child: Material(
                color: R.color.transparent,
                child: Container(
                  width: 240,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  decoration: BoxDecoration(
                    color: R.color.mainColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    R.string.survey_progress.tr(args: [progress.toString()]),
                    style: TextStyle(
                      color: R.color.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );

      triangleEntry = OverlayEntry(builder: (context) {
        return Positioned(
          height: 6,
          child: CompositedTransformFollower(
            link: layerLink,
            offset: Offset(
                progress == 50
                    ? ((size?.width ?? 0) / 2 - 3)
                    : ((size?.width ?? 0) * 0.9 - 3),
                -6),
            child: ClipPath(
              clipper: CustomTriangleClipper(),
              child: Container(
                width: 6,
                height: 5,
                color: R.color.mainColor,
              ),
            ),
          ),
        );
      });

      if (_cubit.progress > 0 && overlay != null && messegeEntry != null) {
        overlay.insert(messegeEntry!);
        overlay.insert(triangleEntry!);
        isShowing = true;
        startTimer();
      }
    }
  }

  void disposeOverlay() {
    messegeEntry?.remove();
    messegeEntry = null;
    triangleEntry?.remove();
    triangleEntry = null;
    isShowing = false;
    stopTimer();
  }

  void startTimer() {
    _timer = Timer(const Duration(seconds: 5), () {
      disposeOverlay();
    });
  }

  void stopTimer() {
    if (_timer != null && _timer?.isActive == true) {
      _timer?.cancel();
    }
  }

  @override
  update(Observable observable, String? notifyName, Map? map) {
    if (notifyName == Const.HIDE_OVERLAY_KEY) {
      disposeOverlay();
    }
  }
}

class CustomTriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
