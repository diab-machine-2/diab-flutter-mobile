import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import '../make_question.dart';

class BuildLessonModule extends StatelessWidget {
  final MakeQuestionCubit cubit;
  const BuildLessonModule({Key? key, required this.cubit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String title = R.string.topic.tr();
    final String hintText = R.string.select_topic.tr();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            color: R.color.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Visibility(
              visible: cubit.suggestLessonModuleItems.isEmpty &&
                  cubit.isShowSuggestLessonModuleList,
              child: Padding(
                padding: EdgeInsets.only(top: 64.0, left: 4, bottom: 12),
                child: Text(
                  R.string.no_result.tr(),
                  style: TextStyle(
                    color: R.color.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            Visibility(
              visible: cubit.suggestLessonModuleItems.isNotEmpty &&
                  cubit.isShowSuggestLessonModuleList,
              child: Container(
                width: double.infinity,
                height:
                    min(276, cubit.suggestLessonModuleItems.length * 48 + 70),
                decoration: BoxDecoration(
                  color: R.color.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 8),
                  child: ListView.separated(
                    itemCount: cubit.suggestLessonModuleItems.length,
                    shrinkWrap: true,
                    //     physics: AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      bool isSelected =
                          cubit.suggestLessonModuleItems[index]!.id ==
                              cubit.currentLessonModule?.id;
                      return InkWell(
                        onTap: () {
                          cubit.currentLessonModule =
                              cubit.suggestLessonModuleItems[index];
                          cubit.searchLessonModuleController.text =
                              cubit.currentLessonModule?.name ?? '';
                          cubit.textSearch = '';
                          cubit.isShowSuggestLessonModuleList = false;
                          cubit.refresh();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          height: 48,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${cubit.suggestLessonModuleItems[index]!.name ?? ""}',
                                  style: TextStyle(
                                    color: isSelected
                                        ? R.color.mainColor
                                        : R.color.textDark,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Visibility(
                                visible: isSelected,
                                child: Icon(
                                  Icons.check_rounded,
                                  size: 20,
                                  color: R.color.accentColor,
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Container(
                        height: 1,
                        color: R.color.color0xffE5E5E5,
                      );
                    },
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: R.color.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  width: 1.5,
                  color: R.color.color0xffE5E5E5,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onTap: () {
                        if (!cubit.isShowSuggestLessonModuleList) {
                          cubit.isShowSuggestLessonModuleList = true;
                          cubit.refresh();
                        }
                      },
                      controller: cubit.searchLessonModuleController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: hintText,
                      ),
                      style: TextStyle(
                        color: R.color.grey_2,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      onChanged: (text) {
                        cubit.textSearch = text.trim();
                        cubit.isShowSuggestLessonModuleList = true;
                        cubit.refresh();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      if (cubit.isShowSuggestLessonModuleList) {
                        cubit.textSearch = '';
                        if (cubit.currentLessonModule == null) {
                          cubit.searchLessonModuleController.text = '';
                        } else {
                          cubit.searchLessonModuleController.text =
                              cubit.currentLessonModule?.name ?? '';
                        }
                      }
                      cubit.isShowSuggestLessonModuleList =
                          !cubit.isShowSuggestLessonModuleList;
                      cubit.refresh();
                    },
                    child: Icon(
                      cubit.isShowSuggestLessonModuleList
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 20,
                      color: R.color.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
