import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/localization/localization.dart';
import 'package:medical/src/model/preference/app_preference.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ButtonLanguagePicker extends StatelessWidget {
  final String? screenName;
  const ButtonLanguagePicker({
    Key? key,
    this.screenName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String appLanguage = AppPreference().appLanguage;
    return GestureDetector(
      onTap: () async {
        await TrackingManager.analytics.logEvent(
          name: 'component_clicked',
          parameters: {
            "screen_name": screenName,
            'cta_button_name': 'cta_profile_change_language',
          },
        );
        LanguagePicker.showBottomLanguages(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: SvgPicture.asset(
                appLanguage == "vi" ? R.icons.ic_flag_vn : R.icons.ic_flag_en,
                height: 20,
              ),
            ),
            const SizedBox(width: 5),
            SvgPicture.asset(
              R.icons.ic_arrow_down,
              width: 16,
              color: R.color.primaryGreyColor,
            ),
            SizedBox(width: 15),
          ],
        ),
      ),
    );
  }
}

class LanguagePicker extends StatelessWidget {
  const LanguagePicker({Key? key}) : super(key: key);

  static void showBottomLanguages(BuildContext context) {
    showBarModalBottomSheet(
      backgroundColor: Colors.transparent,
      isDismissible: true,
      context: context,
      builder: (BuildContext ctx) {
        return const LanguagePicker();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Locale> supportedLanguage = Localization.supportedLanguage;
    for (var element in supportedLanguage) {
      switch (element.languageCode) {
        case "en":
          break;
        case "vi":
          break;
      }
    }
    return SingleChildScrollView(
      child: Container(
        color: R.color.white,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(15),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Chọn ngôn ngữ",
                      style: TextStyle(
                        color: R.color.textDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: 28),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: supportedLanguage.map((item) {
                  return itemLanguage(context, item);
                }).toList(),
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget itemLanguage(BuildContext context, Locale item) {
    String appLanguage = AppPreference().appLanguage;
    bool isSelected = item.languageCode == appLanguage;
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        if (isSelected == false) {
          Localization.changeLanguage(context, item.languageCode);
          Message.showToastMessage(context, "Thay đổi ngôn ngữ thành công.");
          Observable.instance
              .notifyObservers([], notifyName: Const.NAVIGATE_TO_PROFILE_TAB);
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Container(
          height: 35,
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    item.languageCode == "vi"
                        ? R.icons.ic_flag_vn
                        : R.icons.ic_flag_en,
                    width: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(item.languageCode == "vi" ? "Tiếng Việt" : "Tiếng Anh",
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w400,
                      )),
                ],
              ),
              if (isSelected)
                Icon(
                  Icons.check,
                  size: 22,
                  color: R.color.accentColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
