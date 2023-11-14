import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/user/category_item_user_model.dart';
import 'package:medical/src/modal/user/user_model.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/widgets/block_bottom_sheet.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/custom_checkbox_widget.dart';
import 'package:medical/src/widgets/spacing_row.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LevelOffDiabetesRulePicker extends StatefulWidget {
  final Function onSuccess;
  const LevelOffDiabetesRulePicker({
    Key? key,
    required this.onSuccess,
  }) : super(key: key);

  static showModal(
    BuildContext context, {
    required Function onSuccess,
  }) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      context: context,
      builder: (BuildContext ctx) => LevelOffDiabetesRulePicker(
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  State<LevelOffDiabetesRulePicker> createState() =>
      _LevelOffDiabetesRulePickerState();
}

class _LevelOffDiabetesRulePickerState
    extends State<LevelOffDiabetesRulePicker> {
  CategoryItemUserModel? diabeteSelected;
  List<CategoryItemUserModel> levelOfDiabetesRuleList = [];

  @override
  void initState() {
    initData();
    super.initState();
  }

  initData() async {
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    final userJson = prefs.getString('user');
    UserModel? user = UserModel.fromJson(jsonDecode(userJson!));
    int indexWhere = user.levelOfDiabetesRuleList!
        .indexWhere((element) => element.selected == true);
    setState(() {
      levelOfDiabetesRuleList = user.levelOfDiabetesRuleList!;
      diabeteSelected =
          indexWhere.isNegative ? null : levelOfDiabetesRuleList[indexWhere];
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlockBottomSheet(
      title: 'Chọn loại bệnh',
      description:
          'Chọn loại bệnh để cập nhật số liệu phù hợp theo từng tình trạng bệnh.',
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: SpacingColumn(
          spacing: 30,
          children: [
            SpacingColumn(
                spacing: 15,
                separator: Divider(),
                children: levelOfDiabetesRuleList.map(
                  (item) {
                    bool isSelected = diabeteSelected != null &&
                        diabeteSelected!.value == item.value;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          diabeteSelected = item;
                        });
                      },
                      child: SpacingRow(
                        spacing: 15,
                        children: [
                          CustomCheckboxWidget(
                            isChecked: isSelected,
                            onTap: () {
                              setState(() {
                                diabeteSelected = item;
                              });
                            },
                          ),
                          Text(
                            '${item.text}',
                            style: TextStyle(
                              fontSize: 18,
                              color: isSelected ? R.color.main_1 : null,
                              fontWeight: isSelected ? FontWeight.w700 : null,
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ).toList()),
            SpacingRow(
              spacing: 20,
              children: [
                Expanded(
                  child: ButtonWidget(
                    height: 43,
                    textSize: 14,
                    onPressed: () => Navigator.pop(context),
                    title: R.string.cancel.tr(),
                    textColor: R.color.textDark,
                    backgroundColor: Color(0xFFF4F5F6),
                  ),
                ),
                Expanded(
                  child: ButtonWidget(
                    height: 43,
                    title: R.string.cap_nhat.tr(),
                    onPressed: () => _updateData(),
                    textSize: 14,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _updateData() async {
    final UserModel userInfo = AppSettings.userInfo!;
    await UserClient().updateCategoryUser(
      AppSettings.userInfo!.id,
      userInfo,
      [diabeteSelected!],
      CategoryType.LEVEL_OF_DIABETES_TYPE,
      false,
      isUpdateDiabetes: true,
    );
    await UserClient().fetchUser();
    Navigator.pop(context);
    widget.onSuccess();
  }
}
