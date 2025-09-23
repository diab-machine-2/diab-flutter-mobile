import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/service/resource.dart';
import 'package:medical/src/widget/bmi/views/add_bmi/bloc/bmi_input_bloc.dart';
import 'package:medical/src/widget/bmi/views/add_bmi/bloc/bmi_input_state.dart';
import 'package:medical/src/widget/bmi/views/bmi_overview.dart/widgets/bmi_overview_ai_evaluation.dart';
import 'package:medical/src/widget/bmi/views/bmi_overview.dart/widgets/bmi_overview_app_bar.dart';
import 'package:medical/src/widget/bmi/views/bmi_overview.dart/widgets/bmi_overview_evaluated_chart_session.dart';
import 'package:medical/src/widget/bmi/views/bmi_overview.dart/widgets/bmi_overview_note_session.dart';
import 'package:medical/src/widgets/button/outlined_rounded_button.dart';
import 'package:medical/src/widgets/button/primary_rounded_button.dart';
import 'package:medical/src/widgets/button/secondary_rounded_button.dart';
import 'package:medical/src/widgets/custom_dialog.dart';

class BmiOverviewPage extends StatefulWidget {
  const BmiOverviewPage({super.key});

  @override
  State<BmiOverviewPage> createState() => _BmiOverviewPageState();

  static const String bmiInputBlocKey = "bmi_input_bloc_key";
}

class _BmiOverviewPageState extends State<BmiOverviewPage> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<BmiInputBloc, BmiInputState>(
      listener: _handleListener,
      child: Scaffold(
        backgroundColor: R.color.glucose_bg_color,
        resizeToAvoidBottomInset: true,
        appBar: const BmiOverviewAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BmiOverviewEvalutatedChartSession(),
              const SizedBox(
                height: 12,
              ),
              const BmiOverviewAIEvaluationSession(),
              const SizedBox(
                height: 12,
              ),
              const BmiOverviewNoteSession()
            ],
          ),
        ),
        bottomNavigationBar: _BottomActionButtons(),
      ),
    );
  }

  void _handleListener(BuildContext context, BmiInputState state) {
    if (state is BmiInputSubmitedState) {
      if (state.result.isLoading) {
        CustomDialog.showLoadingDialog(context);
      } else if (state.result.isSuccess) {
        CustomDialog.hideLoadingDialog(context);
        CustomDialog.showSuccessDialog(context);
      } else {
        CustomDialog.hideLoadingDialog(context);
        CustomDialog.showErrorDialog(
          context,
          message: state.result.error.toString(),
        );
      }
    }
  }
}

class _BottomActionButtons extends StatelessWidget {
  const _BottomActionButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    BmiInputBloc _bmiInputBloc = context.read();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedRoundedButton(
                title: R.string.share.tr(),
                onPressed: () {},
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: PrimaryRoundedButton(
                title: R.string.completed.tr(),
                onPressed: () {
                  _bmiInputBloc.submitWeightRecord();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
