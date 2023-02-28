import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/HbA1C/short_gui.dart';
import 'package:medical/src/modal/emotion/emotion_model.dart';
import 'package:medical/src/model/preference/app_preference.dart';
import 'package:medical/src/repo/HbA1C/HbA1C_client.dart';
import 'package:medical/src/repo/emotion/emotion_client.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/HbA1C/widget/description/description.dart';
import 'package:medical/src/widget/base/base_state.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/components/card_horizontal/card_horizontal.dart';
import 'package:medical/src/widget/components/card_horizontal/card_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';

import '../../../widgets/network_image_widget.dart';

typedef EmotionCallback = Function(EmotionModel?);

class AddEmoController extends StatefulWidget {
  final String? type;
  final EmotionModel? emotion;
  final EmotionCallback? callback;
  final String? goalId;

  AddEmoController({this.type, this.emotion, this.callback, this.goalId});
  @override
  _AddEmoControllerState createState() => _AddEmoControllerState();
}

class _AddEmoControllerState extends BaseState<AddEmoController> {
  bool isClicked = false;
  EmotionModel? selectedEmotion;

  List<EmotionModel> model = [];

  ShortGuiModel? des;

  void initState() {
    super.initState();
    if (widget.type == 'update') {
      selectedEmotion = widget.emotion;
    }
    loadData();
    loadDescription();
    firebaseSetup();
  }

  Future firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
      screenName: "kpi_emotional_add",
      screenClass: "AddEmoController",
    );
    await TrackingManager.analytics.logEvent(
      name: 'kpi_add_begin',
      parameters: {
        "screen_name": 'kpi_emotional_add',
        'object_type': 'kpi_emotional',
        'object_title': 'Chỉ số cảm xúc'
      },
    );
    AppSettings.currentScreenName = 'kpi_emotional_add';
  }

  void dispose() {
    super.dispose();
  }

  loadData() async {
    try {
      BotToast.showLoading();
      model = await EmotionClient().fetchEmotion();
      if (widget.emotion == null) {
        final initIndex = (model.length / 2).round() - 1;
        selectedEmotion = model[initIndex];
      } else {
        selectedEmotion = widget.emotion;
      }

      BotToast.closeAllLoading();

      setState(() {});
    } catch (_) {}
  }

  loadDescription() async {
    des = await HbA1CClient().fetchShortGuide(6);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String appLanguage = AppPreference().appLanguage;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: R.color.backgroundColor,
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(R.drawable.bg_splash), fit: BoxFit.cover)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomAppBar(
                backgroundColor: R.color.transparent,
                title: Text(
                    widget.type == 'update'
                        ? R.string.chinh_sua_cam_xuc.tr()
                        : R.string.nhap_cam_xuc.tr(),
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: R.color.textDark)),
                leadingIcon: IconButton(
                    splashColor: R.color.transparent,
                    highlightColor: R.color.transparent,
                    icon: Icon(Icons.arrow_back, color: R.color.textDark),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                actions: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isClicked = !isClicked;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: isClicked
                          ? Image.asset(R.drawable.ic_help_circle_active,
                              width: 24, height: 24)
                          : Image.asset(R.drawable.ic_help_circle,
                              width: 24, height: 24),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      // height:
                      //     (MediaQuery.of(context).size.width) * 153 / 343 + 16,
                      padding: EdgeInsets.only(left: 16, right: 16),
                      child: isClicked
                          ? Description(
                              input: true,
                              data: des,
                              titleDetail: R
                                  .string.kiem_soat_cam_xuc_benh_tieu_duong
                                  .tr())
                          : SizedBox(),
                    ),
                    Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Center(
                            child: Text(
                                R.string.hom_nay_ban_cam_thay_the_nao.tr(),
                                style: TextStyle(
                                    color: R.color.textDark,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700),
                                textAlign: TextAlign.center),
                          ),
                          SizedBox(height: 10),
                          Center(
                            child: Text(R.string.scroll_to_select_emotion.tr(),
                                style: R.style.normalTextStyle),
                          ),
                          SizedBox(height: 30),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              model.length == 0
                                  ? SizedBox()
                                  : HorizontalCardPager(
                                      initialPage: model.lastIndexWhere(
                                          (element) =>
                                              element.id ==
                                              selectedEmotion!.id),
                                      onPageChanged: (page) {
                                        if (page != null)
                                          setState(() {
                                            selectedEmotion =
                                                model[page.toInt()];
                                          });
                                      },
                                      items:
                                          List.generate(model.length, (index) {
                                        return ImageCarditem(
                                          image: Container(
                                            height: 100,
                                            width: 100,
                                            padding: EdgeInsets.all(
                                                selectedEmotion!.id ==
                                                        model[index].id
                                                    ? 0
                                                    : 12),
                                            //color: R.color.red,
                                            child: NetWorkImageWidget(
                                              imageUrl:
                                                  model[index].imageUrl ?? '',
                                              // width: selectedEmotion.id ==
                                              //         model[index].id
                                              //     ? 100
                                              //     : 36,
                                              // height: selectedEmotion.id ==
                                              //         model[index].id
                                              //     ? 100
                                              //     : 36,
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                              SizedBox(height: 20),
                              Text(
                                model.length == 0
                                    ? ''
                                    : appLanguage == "vi"
                                        ? selectedEmotion!.vietnameseName!
                                        : selectedEmotion!.englishName!,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w400),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  if (widget.type == 'input') {
                    Navigator.pushNamed(context, NavigatorName.add_symbo,
                        arguments: {
                          'type': 'input',
                          'emotion': selectedEmotion,
                          'goalId': widget.goalId,
                        });
                  } else {
                    widget.callback!(selectedEmotion);
                    Navigator.pop(context);
                  }
                },
                child: SafeArea(
                  top: false,
                  child: Container(
                      margin: EdgeInsets.all(16),
                      height: 48,
                      width: 195,
                      decoration: BoxDecoration(
                          color: R.color.mainColor,
                          borderRadius: BorderRadius.circular(200),
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.centerRight,
                              colors: [
                                R.color.greenGradientTop,
                                R.color.greenGradientBottom
                              ])),
                      child: Center(
                          child: Text(
                              widget.type == 'input'
                                  ? R.string.tiep_tuc.tr()
                                  : R.string.cap_nhat.tr(),
                              style: TextStyle(
                                  color: R.color.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16)))),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
