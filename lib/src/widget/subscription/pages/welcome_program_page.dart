import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/home/widget/home_support_functions.dart';
import 'package:medical/src/widget/subscription/model/package_program_model.dart';
import 'package:medical/src/widget/subscription/services/package_program_service.dart';
import 'package:medical/src/widget/subscription/services/subscription_activate_service.dart';
import 'package:medical/src/widget/subscription/subscription_cubit.dart';
import 'package:medical/src/widgets/gap_widget.dart';

class WelcomeProgramPage extends StatefulWidget {
  final PackageProgram program;

  const WelcomeProgramPage({
    Key? key,
    required this.program,
  }) : super(key: key);

  @override
  State<WelcomeProgramPage> createState() => _WelcomeProgramPageState();
}

class _WelcomeProgramPageState extends State<WelcomeProgramPage> {
  late SubscriptionCubit _cubit;
  final _subscriptionActivateService = SubscriptionActivateService();

  @override
  void initState() {
    super.initState();
    _cubit = context.read<SubscriptionCubit>();
  }

  void dispose() {
    super.dispose();
  }

  Future<void> _activateSubscription() async {
    final accountId = AppSettings.userInfo?.accountId ?? '';
    if (accountId.isEmpty) {
      return;
    }

    // Use new subscription service for improved UX
    await _subscriptionActivateService.activateSubscription(accountId, context);

    // // In case current account already display welcome screen
    // // we need to reset state display when activate new subscription
    // AppSettings.isDisplayedWelcome = false;

    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
      NavigatorName.tabbar,
      (route) => false, // This removes all routes from stack
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  R.color.greenGradientTop02,
                  R.color.greenGradientBottom
                ],
                stops: const [0.01, 0.99],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            child: CustomAppBar(
              hideAllBackButton: true,
              backgroundColor: Colors.transparent,
              title: Text(
                R.string.basic_program.tr(),
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: R.color.white),
              ),
              actions: [
                InkWell(
                  onTap: () async {
                    HomeSupportFunctions.showModalAddData(context);
                  },
                  child: Container(
                    height: 36,
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                    margin: const EdgeInsets.fromLTRB(0, 12, 16, 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: R.color.color0xffCAFAF5,
                      border: Border.all(
                        color: R.color.color0xff8FEBE0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          R.icons.ic_telephone,
                          width: 16,
                          height: 16,
                          color: R.color.greenGradientBottom,
                          fit: BoxFit.scaleDown,
                        ),
                        GapW(4),
                        MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                            textScaler: TextScaler.linear(MediaQuery.of(context)
                                .textScaleFactor
                                .clamp(1.0, 1.3)),
                          ),
                          child: Text(
                            R.string.contact.tr(),
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'sfpro',
                              fontWeight: FontWeight.w700,
                              color: R.color.greenGradientBottom,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                _buildProgramImage(),
                _buildCardWithButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Image.asset(
        ProgramService.getProgramImageFull(widget.program.id),
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildCardWithButton() {
    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            Utils.getBoxShadowDropCard(),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(
                    MediaQuery.of(context).textScaleFactor.clamp(1.0, 1.3)),
              ),
              child: Text(
                R.string.welcome_program.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: R.color.color0xff111515,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            GapH(12),
            MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(
                    MediaQuery.of(context).textScaleFactor.clamp(1.0, 1.3)),
              ),
              child: Text(
                widget.program.title.toUpperCase(),
                maxLines: 2,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: R.color.color0xff111515,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            GapH(24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () async {
                    await _activateSubscription();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: R.color.white,
                    ),
                    child: Container(
                      height: 43,
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            R.color.greenGradientTop02,
                            R.color.greenGradientBottom,
                            R.color.greenGradientBottom,
                          ],
                        ),
                      ),
                      child: Text(
                        R.string.start.tr(),
                        style: TextStyle(
                            color: R.color.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
