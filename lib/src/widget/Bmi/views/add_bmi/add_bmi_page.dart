import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/src/utils/app_media_query.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_bloc.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_input_bloc.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_input_state.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi/widgets/add_bmi_app_bar.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi/widgets/add_bmi_note_session.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi/widgets/add_bmi_waist_circumference_input_session.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi/widgets/add_bmi_weight_input_session.dart';
import 'package:medical/src/widget/Bmi/views/bmi_exit_confirm_dialog.dart';
import 'package:medical/src/widget/Bmi/views/bmi_input_waist_confirm_dialog.dart';
import 'package:medical/src/widget/Bmi/views/bmi_overview.dart/bmi_overview_page.dart';
import 'package:medical/src/widget/nipro/health_app/widgets/request_health_connect.dart';
import 'package:medical/src/widgets/button/primary_rounded_button.dart';
import 'package:medical/src/widgets/custom_dialog.dart';

class AddBmiPage extends StatefulWidget {
  const AddBmiPage({super.key, this.goalId});

  final String? goalId;

  @override
  State<AddBmiPage> createState() => _AddBmiPageState();

  static const bmiInputCurrentHeightKey = "bmi_input_current_height_key";
  static const bmiBlocKey = "bmi_bloc_key";
}

class _AddBmiPageState extends State<AddBmiPage> {
  late BmiInputBloc _bmiInputBloc;
  late BmiBloc _bmiBloc;

  bool _canPop = false;

  @override
  void initState() {
    super.initState();
    _bmiInputBloc = context.read();
    _bmiBloc = context.read();
    if (widget.goalId != null) {
      _bmiInputBloc.goalId = widget.goalId;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    double initialCurrentHeight =
        arguments[AddBmiPage.bmiInputCurrentHeightKey] ??
            _bmiBloc.height ??
            0.0;
    _bmiInputBloc.currentHeight = initialCurrentHeight;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_bmiInputBloc.weight > 0 || _bmiInputBloc.waist > 0) {
          var result = await BmiExitConfirmDialog.show(context);
          return Future.value(result);
        }
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: R.color.glucose_bg_color,
        resizeToAvoidBottomInset: true,
        appBar: const AddBmiAppBar(),
        body: BlocListener<BmiInputBloc, BmiInputState>(
          listener: _handleListener,
          child: GestureDetector(
            onTap: () {
              // Dismiss keyboard when tapping outside any input field
              FocusScope.of(context).unfocus();
            },
            behavior: HitTestBehavior.opaque,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AddBmiWeightInputSession(
                          autoFocus: true,
                        ),
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
                const _SaveButton()
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleListener(BuildContext context, BmiInputState state) {
    if (state is BmiWaistValidatedState) {
      if (state.hasWaist) {
        _bmiInputBloc.submitWeightRecord();
      } else {
        BmiInputWaistConfirmDialog.show(
          context,
          onConfirmed: _bmiInputBloc.submitWeightRecord,
        );
      }
    } else if (state is BmiInputErrorState) {
      CustomDialog.showErrorDialog(
        context,
        message: state.error,
      );
    } else if (state is BmiInputSubmitedState) {
      if (state.result.isLoading) {
        BotToast.showLoading();
      } else if (state.result.isSuccess) {
        BotToast.closeAllLoading();
        _bmiBloc.hasModifiedData = true;
        _redirectToNextStep(state.result.data!);
      } else {
        BotToast.closeAllLoading();
        CustomDialog.showErrorDialog(
          context,
          message: state.result.error.toString(),
        );
      }
    }
  }

  void _redirectToNextStep(String recordId) {
    // Navigator.pushNamed(context, NavigatorName.bmiOverviewPage,
    //     arguments: {BmiOverviewPage.bmiInputBlocKey: _bmiInputBloc});
    BmiBloc _bmiBloc = context.read();
    _bmiBloc.getAIAnalysicWeightRecord(recordId);

    Navigator.pushReplacementNamed(
      context,
      NavigatorName.bmiOverviewPage,
      arguments: {
        BmiOverviewPage.bmiInputBlocKey: _bmiInputBloc,
        BmiOverviewPage.bmiBlocKey: _bmiBloc,
      },
      result: true,
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final BmiInputBloc _bmiInputBloc = context.read();
    final BmiBloc _bmiBloc = context.read();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        child: PrimaryRoundedButton(
          title: R.string.confirm.tr(),
          onPressed: () => _bmiInputBloc.validate(_bmiBloc.hasInputedWaist),
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
    return InkWell(
      onTap: () async {
        RequestHealthConnect.showModal(
          context,
          callback: () => Navigator.pop(context),
        );
      },
      child: Container(
        decoration: R.decorationStyle.mediumRadiusCardStyles,
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 12,
        ),
        child: Row(
          children: [
            Image.asset(
              Platform.isIOS
                  ? R.drawable.logo_healthkit
                  : R.drawable.logo_healthConnect,
              width: AppMediaQuery.deviceWidth * 0.15,
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
                child: Text(
              R.string.connectToHealthConnect.tr(),
              style: R.style.largeTextStyle,
            )),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.neutral4,
              size: 20,
            )
          ],
        ),
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
