import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/src/utils/app_media_query.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/bmi/views/add_bmi/bloc/bmi_input_bloc.dart';
import 'package:medical/src/widget/bmi/views/add_bmi/bloc/bmi_input_state.dart';
import 'package:medical/src/widget/bmi/views/add_bmi/widgets/add_bmi_app_bar.dart';
import 'package:medical/src/widget/bmi/views/add_bmi/widgets/add_bmi_note_session.dart';
import 'package:medical/src/widget/bmi/views/add_bmi/widgets/add_bmi_waist_circumference_input_session.dart';
import 'package:medical/src/widget/bmi/views/add_bmi/widgets/add_bmi_weight_input_session.dart';
import 'package:medical/src/widget/bmi/views/bmi_input_waist_confirm_dialog.dart';
import 'package:medical/src/widget/bmi/views/bmi_overview.dart/bmi_overview_page.dart';
import 'package:medical/src/widgets/button/primary_rounded_button.dart';

class AddBmiPage extends StatefulWidget {
  const AddBmiPage({super.key});

  @override
  State<AddBmiPage> createState() => _AddBmiPageState();

  static const bmiInputCurrentHeightKey = "bmi_input_current_height_key";
}

class _AddBmiPageState extends State<AddBmiPage> {
  late BmiInputBloc _bmiInputBloc;

  @override
  void initState() {
    super.initState();
    _bmiInputBloc = context.read();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    int initialCurrentHeight = arguments[AddBmiPage.bmiInputCurrentHeightKey];
    _bmiInputBloc.currentHeight = initialCurrentHeight;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.glucose_bg_color,
      resizeToAvoidBottomInset: true,
      appBar: const AddBmiAppBar(),
      body: BlocListener<BmiInputBloc, BmiInputState>(
        listener: _handleListener,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AddBmiWeightInputSession(),
              const SizedBox(
                height: 12,
              ),
              const AddBmiWaistCircumferenceInputSession(),
              const SizedBox(
                height: 12,
              ),
              const AddBmiNoteSession(),
              const SizedBox(
                height: 12,
              ),
              _Seperator(),
              const SizedBox(
                height: 12,
              ),
              _ConnectToHealthConnectButton()
            ],
          ),
        ),
      ),
      bottomNavigationBar: _SaveButton(),
    );
  }

  void _handleListener(BuildContext context, BmiInputState state) {
    if (state is BmiWaistValidatedState) {
      if (state.hasWaist) {
        _redirectToNextStep();
      } else {
        BmiInputWaistConfirmDialog.show(
          context,
          onConfirmed: _redirectToNextStep,
        );
      }
    }
  }

  void _redirectToNextStep() {
    Navigator.pushNamed(context, NavigatorName.bmiOverviewPage,
        arguments: {BmiOverviewPage.bmiInputBlocKey: _bmiInputBloc});
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final BmiInputBloc _bmiInputBloc = context.read();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        child: PrimaryRoundedButton(
          title: R.string.confirm.tr(),
          onPressed: _bmiInputBloc.validateWaist,
        ),
      ),
    );
  }
}

class _ConnectToHealthConnectButton extends StatelessWidget {
  const _ConnectToHealthConnectButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: R.decorationStyle.mediumRadiusCardStyles,
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 12,
      ),
      child: Row(
        children: [
          Image.asset(
            R.drawable.logo_healthConnect,
            width: AppMediaQuery.deviceWidth * 0.15,
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(child: Text("ket noi vs health connect")),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.neutral4,
            size: 20,
          )
        ],
      ),
    );
  }
}

class _Seperator extends StatelessWidget {
  const _Seperator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 96,
        ),
        Expanded(
            child: Divider(
          color: R.color.mainColor,
        )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            R.string.or.tr(),
            style: R.style.normalTextStyle.copyWith(color: R.color.mainColor),
          ),
        ),
        Expanded(
            child: Divider(
          color: R.color.mainColor,
        )),
        const SizedBox(
          width: 96,
        ),
      ],
    );
  }
}
