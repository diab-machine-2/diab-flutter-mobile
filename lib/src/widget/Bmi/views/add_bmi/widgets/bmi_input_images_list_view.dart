import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/dimens.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_input_bloc.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_input_event.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_input_state.dart';

const double _imgThumbnailSize = 64;

class BmiInputImagesListView extends StatelessWidget {
  const BmiInputImagesListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    BmiInputBloc _bmiInputBloc = context.read();

    return BlocBuilder<BmiInputBloc, BmiInputState>(
        buildWhen: (_, state) =>
            state is BmiInputDataChangedState &&
            [
              BmiInputDataChangeEvent.noteImagesChanged,
              BmiInputDataChangeEvent.noteImagesFromRecordChanged,
            ].contains(state.event),
        builder: (context, state) {
          if (_bmiInputBloc.noteImages.isEmpty &&
              _bmiInputBloc.noteImagesFromRecord.isEmpty)
            return const SizedBox();

          // Combine both lists into a single ListView for proper horizontal scrolling
          final int recordImagesCount =
              _bmiInputBloc.noteImagesFromRecord.length;
          final int newImagesCount = _bmiInputBloc.noteImages.length;
          final int totalItems = recordImagesCount + newImagesCount;

          return SizedBox(
            height: _imgThumbnailSize,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: totalItems,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                if (index < recordImagesCount) {
                  // Show record images first
                  return _BmiUrlImageThumbnail(
                    url: _bmiInputBloc.noteImagesFromRecord[index].url ?? "",
                    onRemove: () {
                      _bmiInputBloc.removeRecordImage(
                          _bmiInputBloc.noteImagesFromRecord[index]);
                    },
                  );
                } else {
                  // Then show new images
                  final newImageIndex = index - recordImagesCount;
                  return _BmiImageThumbnail(
                    path: _bmiInputBloc.noteImages[newImageIndex],
                  );
                }
              },
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

    return SizedBox.square(
      dimension: _imgThumbnailSize,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: Image.file(File(path)).image, fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(AppDimens.smallRadius)),
            margin:
                const EdgeInsets.fromLTRB(0, removeIcon / 3, removeIcon / 3, 0),
          ),
          GestureDetector(
            onTap: () {
              _bmiInputBloc.removeImage(path);
            },
            child: Icon(
              Icons.cancel_rounded,
              color: R.color.red,
              size: removeIcon,
            ),
          )
        ],
      ),
    );
  }
}

class _BmiUrlImageThumbnail extends StatelessWidget {
  const _BmiUrlImageThumbnail({
    super.key,
    required this.url,
    this.onRemove,
  });

  final String url;
  final Function()? onRemove;

  @override
  Widget build(BuildContext context) {
    const double removeIcon = 20;
    // BmiInputBloc _bmiInputBloc = context.read();

    return SizedBox.square(
      dimension: _imgThumbnailSize,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            // width: 56,
            // height: 56,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: CachedNetworkImageProvider(
                      url,
                    ),
                    fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(AppDimens.smallRadius)),
            margin:
                const EdgeInsets.fromLTRB(0, removeIcon / 3, removeIcon / 3, 0),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.cancel_rounded,
              color: R.color.red,
              size: removeIcon,
            ),
          )
        ],
      ),
    );
  }
}
