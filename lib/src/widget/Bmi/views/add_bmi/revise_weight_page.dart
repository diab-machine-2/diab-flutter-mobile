import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/bloc/nipro/nipro_bloc.dart';
import 'package:medical/src/model/response/bmi_get_weight_list_response.dart';
import 'package:medical/src/utils/app_media_query.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_bloc.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_input_bloc.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_input_state.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi/widgets/add_bmi_app_bar.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi/widgets/add_bmi_note_session.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi/widgets/add_bmi_waist_circumference_input_session.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi/widgets/add_bmi_weight_input_session.dart';
import 'package:medical/src/widget/Bmi/views/bmi_overview.dart/bmi_overview_page.dart';
import 'package:medical/src/widgets/button/outlined_rounded_button.dart';
import 'package:medical/src/widgets/button/primary_rounded_button.dart';
import 'package:medical/src/widgets/custom_dialog.dart';

class ReviseWeightPage extends StatefulWidget {
  const ReviseWeightPage({super.key});

  @override
  State<ReviseWeightPage> createState() => _ReviseWeightPageState();

  static const bmiBlocKey = "bmi_bloc_key";
  static const dataKey = "data_key";
}

class _ReviseWeightPageState extends State<ReviseWeightPage> {
  late BmiInputBloc _bmiInputBloc;
  late BmiBloc _bmiBloc;

  @override
  void initState() {
    super.initState();
    _bmiInputBloc = context.read();
    _bmiBloc = context.read();

    Future.delayed(const Duration(milliseconds: 200)).then((value) {
      Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
      BmiGetWeightRecord initialData = arguments[ReviseWeightPage.dataKey];
      _bmiInputBloc.initRevisingData(initialData);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.glucose_bg_color,
      resizeToAvoidBottomInset: true,
      appBar: const AddBmiAppBar(),
      body: BlocListener<BmiInputBloc, BmiInputState>(
        listener: _handleListener,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
            const _ActionButtons()
          ],
        ),
      ),
    );
  }

  void _handleListener(BuildContext context, BmiInputState state) {
    if (state is BmiInputErrorState) {
      CustomDialog.showErrorDialog(
        context,
        message: state.error,
      );
    } else if (state is BmiInputSubmitedState) {
      if (state.result.isLoading) {
        CustomDialog.showLoadingDialog(context);
      } else if (state.result.isSuccess) {
        CustomDialog.hideLoadingDialog(context);
        CustomDialog.showSuccessDialog(
          context,
          onPrimaryButtonTap: () {
            _bmiBloc.hasModifiedData = true;
            _redirectToNextStep(state.result.data!);
          },
        );
      } else {
        CustomDialog.hideLoadingDialog(context);
        CustomDialog.showErrorDialog(
          context,
          message: state.result.error.toString(),
        );
      }
    } else if (state is BmiInputRecordDeletedState) {
      if (state.result.isLoading) {
        CustomDialog.showLoadingDialog(context);
      } else if (state.result.isSuccess) {
        CustomDialog.hideLoadingDialog(context);
        CustomDialog.showSuccessDialog(
          context,
          onPrimaryButtonTap: () {
            _bmiBloc.hasModifiedData = true;
            Navigator.pop(context, true);
          },
        );
      } else {
        CustomDialog.hideLoadingDialog(context);
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

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final BmiInputBloc _bmiInputBloc = context.read();

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        color: R.color.white,
        child: Row(
          children: [
            Expanded(
              child: OutlinedRoundedButton(
                title: R.string.delete.tr(),
                onPressed: () {
                  CustomDialog.showDeleteConfirmDialog(
                    context,
                    message: R.string.confirm_to_remove_data.tr(),
                    onPrimaryButtonTap: () {
                      _bmiInputBloc.deleteWeightRecord();
                    },
                  );
                },
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: PrimaryRoundedButton(
                title: R.string.confirm.tr(),
                onPressed: _bmiInputBloc.reviseWeightRecord,
              ),
            ),
          ],
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
        if (await AppSettings.getLastOpenedBloodPressureInputType() == null) {
          AppSettings.setLastOpenedBloodPressureInputType('device');
        }
        // TODO: BLOOD PRESSURE
        // TrackingManager.trackEvent(
        //   'glucose_select_method',
        //   'kpi_glucose',
        //   params: {
        //     'method': 'device',
        //   },
        // );
        Navigator.pop(context);
        BlocProvider.of<NiproBloc>(context).tryAutoConnect();
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
              R.drawable.logo_healthConnect,
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
