import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/food_menu_screens/food_menu/food_menu_page.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/kcal_parameter/kcal_parameter.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/common_page.dart';

import 'intro_sample_menu.dart';

class IntroSampleMenuPage extends StatefulWidget {
  const IntroSampleMenuPage();
  @override
  _IntroSampleMenuPageState createState() => _IntroSampleMenuPageState();
}

class _IntroSampleMenuPageState extends State<IntroSampleMenuPage> {
  late IntroSampleMenuCubit _cubit;

  @override
  void initState() {
    super.initState();
    final AppRepository repository = AppRepository();
    _cubit = IntroSampleMenuCubit(repository);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocConsumer<IntroSampleMenuCubit, IntroSampleMenuState>(
          listener: (context, state) {
            if (state is IntroSampleMenuFailure) {
              Message.showToastMessage(context, state.error);
            }
          },
          builder: (
            BuildContext context,
            IntroSampleMenuState state,
          ) {
            if (state is IntroSampleMenuLoading) {
              BotToast.showLoading();
            } else {
              BotToast.closeAllLoading();
            }
            return buildPage(context, state);
          },
        ),
      ),
    );
  }

  Widget buildPage(BuildContext context, IntroSampleMenuState state) {
    return Scaffold(
      body: CommonPage(
        background: R.drawable.bg_welcome,
        title: R.string.sample_menu.tr(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          shrinkWrap: true,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  R.drawable.img_cooking,
                  width: double.infinity,
                  height: 240,
                ),
                const SizedBox(height: 32),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    R.string.text_intro_menu.tr(),
                    style: TextStyle(
                      color: R.color.textDark,
                      fontSize: 16,
                      letterSpacing: 0.4,
                      height: 1.375,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: RichText(
                    text: TextSpan(
                      text: R.string.step_1.tr(),
                      style: TextStyle(
                        color: R.color.textDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.4,
                        height: 1.375,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                            text: R.string.text_step_1.tr(),
                            style: TextStyle(
                              color: R.color.textDark,
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                              letterSpacing: 0.4,
                              height: 1.375,
                            )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: RichText(
                    text: TextSpan(
                      text: R.string.step_2.tr(),
                      style: TextStyle(
                        color: R.color.textDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.4,
                        height: 1.375,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                            text: R.string.text_step_2.tr(),
                            style: TextStyle(
                              color: R.color.textDark,
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                              letterSpacing: 0.4,
                              height: 1.375,
                            )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 34),
                Container(
                  width: 128,
                  child: ButtonWidget(
                    title: R.string.start.tr(),
                    onPressed: () {
                      showDialog(
                        barrierColor: R.color.color0xff003F38.withOpacity(0.5),
                        context: context,
                        builder: (_) => KcalParameterPage(
                          callback: (request) {
                            NavigationUtil.replace(context,
                                FoodMenuPage(createMenuRequest: request));
                          },
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
