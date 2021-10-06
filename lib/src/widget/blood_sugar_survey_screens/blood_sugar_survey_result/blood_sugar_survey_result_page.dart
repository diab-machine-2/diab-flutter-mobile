import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/HbA1C/short_gui.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/HbA1C/widget/description/description_detail.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/blood_sugar_result_layout_widget.dart';
import 'package:medical/src/widgets/expandable_rich_text.dart';

import '../../../model/response/blood_sugar_template_category_response.dart';
import '../blood_sugar_schedule_template/blood_sugar_schedule_template.dart';
import 'blood_sugar_survey_result.dart';
import 'widgets/blood_sugar_survey_result_empty.dart';

class BloodSugarSurveyResultPage extends StatefulWidget {
  const BloodSugarSurveyResultPage(this.templateList);
  final List<BloodSugarTemplateCategoryResponseData?> templateList;

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
    return widget.templateList.isEmpty
        ? const BloodSugarSurveyEmpty()
        : BlocProvider(
            create: (context) => _cubit,
            child: BlocConsumer<BloodSugarSurveyResultCubit,
                BloodSugarSurveyResultState>(
              listener: (context, state) {
                if (state is BloodSugarSurveyResultFailure) {
                  Message.showToastMessage(context, state.error ?? '');
                }
              },
              builder: (context, state) {
                return BloodSugarResultLayoutWidget(
                  title: R.string.result.tr(),
                  timeToTestPerDay: 1,
                  onTapBack: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    color: R.color.white,
                    child: SafeArea(
                      top: false,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 24.h),
                          child: Column(
                            children: [
                              Text(
                                R.string.pick_a_model.tr(
                                  args: ['${widget.templateList.length}'],
                                ),
                                style: TextStyle(
                                  color: R.color.textDark,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              ..._buildListOfTemplate(
                                context,
                                templateList: widget.templateList,
                              ),
                              SizedBox(height: 32.h),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                    color: R.color.main_6,
                                    borderRadius: BorderRadius.circular(8)),
                                child: ExpandableRichText(
                                  //TODO: Tuyen add long text into this
                                  'Long text',
                                  maxLines: 3,
                                  trimExpandedText: R.string.show_less.tr(),
                                  trimCollapsedText: R.string.show_more.tr(),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w400,
                                    color: R.color.textDark,
                                  ),
                                  moreStyle: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: R.color.greenGradientBottom,
                                  ),
                                  lessStyle: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: R.color.greenGradientBottom,
                                  ),
                                ),
                              ),
                              SizedBox(height: 14.h)
                            ],
                          ),
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
  required List<BloodSugarTemplateCategoryResponseData?> templateList,
}) {
  return List.generate(
    templateList.length,
    (index) => _buildTemplateItem(
      context,
      data: templateList[index],
    ),
  );
}

Widget _buildTemplateItem(
  BuildContext context, {
  BloodSugarTemplateCategoryResponseData? data,
}) {
  if (data == null) return const SizedBox();
  return Container(
    margin: EdgeInsets.only(top: 16.h),
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    decoration: BoxDecoration(
      color: R.color.main_6,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              NavigationUtil.navigatePage(
                context,
                BloodSugarScheduleTemplatePage(data),
              );
            },
            child: Text(
              data.name ?? '',
              style: TextStyle(
                fontSize: 14.sp,
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
            R.drawable.ic_question_circle_fill,
            height: 24.w,
            width: 24.w,
          ),
        ),
      ],
    ),
  );
}
