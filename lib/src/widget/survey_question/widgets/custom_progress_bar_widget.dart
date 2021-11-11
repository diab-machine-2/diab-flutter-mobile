import 'dart:async';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import '../survey_question.dart';

class CustomProgressBarWidget extends StatefulWidget {
  const CustomProgressBarWidget();

  @override
  State<CustomProgressBarWidget> createState() =>
      _CustomProgressBarWidgetState();
}

class _CustomProgressBarWidgetState extends State<CustomProgressBarWidget> {
  late final SurveyQuestionCubit _cubit;
  OverlayEntry? messegeEntry;
  OverlayEntry? triangleEntry;

  bool isShowing = false;
  bool showed50Message = false;
  bool showed90Message = false;

  @override
  void initState() {
    _cubit = context.read<SurveyQuestionCubit>();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      showOverlay();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SurveyQuestionCubit, SurveyQuestionState>(
      listener: (context, state) {
        if (state is SurveyQuestionProgressChanged) {
          showOverlay();
        }
        if (state is SurveyQuestionHideProgressMessage) {
          disposeOverlay();
        }
      },
      builder: (context, state) {
        return LayoutBuilder(
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
        );
      },
    );
  }

  void showOverlay() {
    late final int progress;
    if (_cubit.progress < 90) {
      showed90Message = false;
    }
    if (_cubit.progress < 50) {
      showed50Message = false;
    }
    if (_cubit.progress >= 0.9 && !showed90Message) {
      progress = 90;
      showed90Message = true;
    } else if (_cubit.progress >= 0.5 && !showed50Message) {
      progress = 50;
      showed50Message = true;
    } else {
      return;
    }

    final OverlayState? overlay = Overlay.of(context);
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    final Size? size = renderBox?.size;
    final Offset? offset = renderBox?.localToGlobal(Offset.zero);
    if (!isShowing) {
      messegeEntry = OverlayEntry(
        builder: (context) {
          return Positioned(
            left: progress == 50
                ? ((size?.width ?? 0) - 240) / 2
                : ((size?.width ?? 0) - 260),
            top: (offset?.dy ?? 0) - 23,
            height: 18,
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
          );
        },
      );

      triangleEntry = OverlayEntry(builder: (context) {
        return Positioned(
          left: progress == 50
              ? ((size?.width ?? 0) / 2 - 3)
              : ((size?.width ?? 0) * 0.9 - 3),
          top: (offset?.dy ?? 0) - 6,
          height: 6,
          child: ClipPath(
            clipper: CustomTriangleClipper(),
            child: Container(
              width: 6,
              height: 5,
              color: R.color.mainColor,
            ),
          ),
        );
      });

      if (_cubit.progress > 0 && overlay != null && messegeEntry != null) {
        overlay.insert(messegeEntry!);
        overlay.insert(triangleEntry!);
        isShowing = true;
        Timer(const Duration(seconds: 2), () {
          disposeOverlay();
        });
      }
    }
  }

  void disposeOverlay() {
    messegeEntry?.remove();
    messegeEntry = null;
    triangleEntry?.remove();
    triangleEntry = null;
    isShowing = false;
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
