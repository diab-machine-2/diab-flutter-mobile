import 'package:easy_localization/easy_localization.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/HbA1C/short_gui.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/HbA1C/widget/description/description_detail.dart';
import 'package:medical/src/widget/blood_sugar_schedule_sample/blood_sugar_schedule_sample.dart';
import 'package:medical/src/widgets/blood_sugar_recommand_layout_widget.dart';

class BloodSugarScheduleRecommand extends StatelessWidget {
  const BloodSugarScheduleRecommand();

  @override
  Widget build(BuildContext context) {
    const int number_of_models = 6;
    return BloodSugarRecommandLayoutWidget(
      title: R.string.result.tr(),
      resultSurvey: '2',
      onTapBack: () {
        Navigator.pop(context);
      },
      child: Container(
        color: R.color.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              children: [
                Text(R.string.pick_a_model.tr(args: ['$number_of_models'])),
                _buildModelItem(
                  context,
                  onShowDetail: () {
                    NavigationUtil.navigatePage(context, const BloodScheduleSamplePage());
                  },
                  onShowHelp: () {
                    showDialog(
                      barrierColor: R.color.color0xff003F38.withOpacity(0.8),
                      useSafeArea: false,
                      context: context,
                      builder: (_) => DetailDescription(
                          input: true,
                          data: ShortGuiModel(
                            content1: 'Content 1',
                            content2: '<h1>Content 2</h1>',
                            content3: '',
                            content4: '',
                          ),
                          title: 'Hello'),
                    );
                  },
                ),
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  decoration: BoxDecoration(
                      color: R.color.color0xFFE4F5F5,
                      borderRadius: BorderRadius.circular(8)),
                  child: ExpandableText(
                    'sdfhkashdfksajhdfksdhgjkdshgjkdfbvvhjasbldsjhfbsahjbfiweufbuwehfIAFHJKSAhfkdsjhfdsfhuerhfuihaiHFIUSGDSBpbgidsbgfuwgbvci',
                    expandText: 'Xem thêm',
                    maxLines: 3,
                    linkColor: Colors.blue,
                    animation: true,
                    collapseOnTextTap: true,
                    prefixText: 'username',
                    onPrefixTap: () => {},
                    prefixStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'MaterialIcons'),
                    onHashtagTap: (name) => {},
                    hashtagStyle: const TextStyle(
                        color: Color(0xFF30B6F9), fontFamily: 'MaterialIcons'),
                    onMentionTap: (username) => {},
                    mentionStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'MaterialIcons'),
                    onUrlTap: (url) => {},
                    urlStyle: const TextStyle(
                        decoration: TextDecoration.underline,
                        fontFamily: 'MaterialIcons'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildModelItem(
  BuildContext context, {
  required VoidCallback onShowDetail,
  required VoidCallback onShowHelp,
}) {
  return Container(
    margin: const EdgeInsets.only(top: 16),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: R.color.color0xFFE4F5F5,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onShowDetail,
            child: Text(
              'Mẫu cơ bản',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: R.color.greenGradientBottom,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GestureDetector(
          onTap: onShowHelp,
          child: Image.asset(
            R.drawable.ic_question_circle,
            height: 24,
            width: 24,
          ),
        ),
      ],
    ),
  );
}
