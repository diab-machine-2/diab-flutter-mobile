import 'package:easy_localization/easy_localization.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/HbA1C/short_gui.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/HbA1C/widget/description/description_detail.dart';
import 'package:medical/src/widgets/blood_sugar_recommand_layout_widget.dart';

import '../../../model/response/blood_sugar_template_category_response.dart';
import '../blood_sugar_schedule_templete/blood_sugar_schedule_templete.dart';
import 'blood_sugar_survey_result.dart';

class BloodSugarSurveyResultPage extends StatefulWidget {
  const BloodSugarSurveyResultPage(this.templateList);
  final List<BloodSugarTemplateCategory> templateList;

  @override
  State<BloodSugarSurveyResultPage> createState() =>
      _BloodSugarSurveyResultPageState();
}

class _BloodSugarSurveyResultPageState
    extends State<BloodSugarSurveyResultPage> {
  late BloodSugarSurveyResultCubit _cubit;

  @override
  void initState() {
    final AppRepository repository = AppRepository();
    _cubit = BloodSugarSurveyResultCubit(repository);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: BlocConsumer<BloodSugarSurveyResultCubit,
          BloodSugarSurveyResultState>(
        listener: (context, state) {
          if (state is BloodSugarSurveyResultFailure) {
            Utils.showErrorSnackBar(context, state.error ?? '');
          }
        },
        builder: (context, state) {
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Column(
                    children: [
                      Text(R.string.pick_a_model.tr(args: [''])),
                      ..._buildListOfTemplate(
                        context,
                        templateList: widget.templateList,
                      ),
                      _buildExpandedText(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

List<Widget> _buildListOfTemplate(
  BuildContext context, {
  required List<BloodSugarTemplateCategory> templateList,
}) {
  return List.generate(
    templateList.length,
    (index) => _buildTemplateItem(
      context,
      data: templateList[index],
    ),
  );
}

Widget _buildExpandedText() {
  return Container(
    margin: const EdgeInsets.only(top: 16),
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    decoration: BoxDecoration(
        color: R.color.color0xFFE4F5F5, borderRadius: BorderRadius.circular(8)),
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
          fontWeight: FontWeight.bold, fontFamily: 'MaterialIcons'),
      onHashtagTap: (name) => {},
      hashtagStyle: const TextStyle(
          color: Color(0xFF30B6F9), fontFamily: 'MaterialIcons'),
      onMentionTap: (username) => {},
      mentionStyle: const TextStyle(
          fontWeight: FontWeight.w600, fontFamily: 'MaterialIcons'),
      onUrlTap: (url) => {},
      urlStyle: const TextStyle(
          decoration: TextDecoration.underline, fontFamily: 'MaterialIcons'),
    ),
  );
}

Widget _buildTemplateItem(
  BuildContext context, {
  required BloodSugarTemplateCategory data,
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
            onTap: () {
              NavigationUtil.navigatePage(
                context,
                BloodSugarScheduleTempletePage(data),
              );
            },
            child: Text(
              data.name ?? '',
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
          onTap: () {
            showDialog(
              barrierColor: R.color.color0xff003F38.withOpacity(0.8),
              useSafeArea: false,
              context: context,
              builder: (_) => DetailDescription(
                  input: true,
                  data: ShortGuiModel(
                    content1: '',
                    content2: data.description ?? '',
                    content3: '',
                    content4: '',
                  ),
                  title: data.name ?? ''),
            );
          },
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
