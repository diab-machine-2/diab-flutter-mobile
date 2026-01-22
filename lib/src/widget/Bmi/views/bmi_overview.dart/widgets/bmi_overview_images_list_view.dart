import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/dimens.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_input_bloc.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_input_event.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_input_state.dart';

class BmiOverviewImagesListView extends StatelessWidget {
  const BmiOverviewImagesListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    BmiInputBloc _bmiInputBloc = context.read();

    return BlocBuilder<BmiInputBloc, BmiInputState>(
        buildWhen: (_, state) =>
            state is BmiInputDataChangedState &&
            state.event == BmiInputDataChangeEvent.noteImagesChanged,
        builder: (context, state) {
          return SizedBox(
            height: 56,
            child: ListView.separated(
              itemBuilder: (context, index) => _BmiImageThumbnail(
                path: _bmiInputBloc.noteImages[index],
              ),
              separatorBuilder: (context, index) => const SizedBox(
                width: 12,
              ),
              itemCount: _bmiInputBloc.noteImages.length,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
            ),
          );
        });
  }
}

class _BmiImageThumbnail extends StatelessWidget {
  const _BmiImageThumbnail({
    super.key,
    required this.path,
  });

  final String path;

  @override
  Widget build(BuildContext context) {
    const double removeIcon = 20;
    BmiInputBloc _bmiInputBloc = context.read();

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: Image.file(File(path)).image, fit: BoxFit.cover),
          borderRadius: BorderRadius.circular(AppDimens.smallRadius)),
      margin: const EdgeInsets.fromLTRB(0, removeIcon / 3, removeIcon / 3, 0),
    );
  }
}
