import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/styles.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_bloc.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_state.dart';
import 'package:medical/src/widget/Bmi/models/weight_instruction_model.dart';

class BmiInstructionSession extends StatelessWidget {
  const BmiInstructionSession({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    BmiBloc _bmiBloc = context.read<BmiBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            R.string.glucose_intro_help_title.tr(),
            style: R.style.alertTitle,
          ),
        ),
        BlocBuilder<BmiBloc, BmiState>(
            buildWhen: (_, state) => state is BmiGetInstructionState,
            builder: (context, state) {
              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 4 / 3),
                itemBuilder: (context, index) => _BmiInstructionCard(
                  instructionModel: _bmiBloc.weightInstructions[index],
                  onTap: _onTap,
                ),
                itemCount: _bmiBloc.weightInstructions.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              );
            }),
      ],
    );
  }

  void _onTap(WeightInstructionModel instructionModel) {}
}

class _BmiInstructionCard extends StatelessWidget {
  const _BmiInstructionCard(
      {super.key, required this.instructionModel, this.onTap});

  final WeightInstructionModel instructionModel;
  final Function(WeightInstructionModel instructionModel)? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: R.decorationStyle.mediumRadiusCardStyles,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: instructionModel.image ?? "",
              fit: BoxFit.fill,
            ),
          ),
          const SizedBox(height: 12,),
          Text(
            instructionModel.name ?? "--",
            style: R.style.normalTextStyle,
          )
        ],
      ),
    );
  }
}
