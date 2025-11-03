import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_input_bloc.dart';
import 'package:medical/src/widget/Bmi/views/bmi_overview.dart/widgets/bmi_overview_images_list_view.dart';

class BmiOverviewNoteSession extends StatelessWidget {
  const BmiOverviewNoteSession({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    BmiInputBloc _bmiInputBloc = context.read();

    if (_bmiInputBloc.note.isEmpty && _bmiInputBloc.noteImages.isEmpty) {
      return const SizedBox();
    }

    return Container(
      decoration: R.decorationStyle.mediumRadiusCardStyles,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            R.string.ghi_chu.tr(),
            style: R.style.boldXLargeStyle,
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            _bmiInputBloc.note,
            style: R.style.normalTextStyle,
          ),
          const Divider(),
          //img session
          _bmiInputBloc.noteImages.isNotEmpty
              ? const BmiOverviewImagesListView()
              : const SizedBox()
        ],
      ),
    );
  }
}
