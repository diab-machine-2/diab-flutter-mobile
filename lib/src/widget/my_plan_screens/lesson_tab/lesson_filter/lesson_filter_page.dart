import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/filter_data_response.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/common_page.dart';
import 'package:medical/src/widgets/custom_checkbox_widget.dart';

import 'lesson_filter.dart';
import 'models/filter_data.dart';
import 'models/searching_status.dart';

class LessonFilterPage extends StatefulWidget {
  const LessonFilterPage(this.filterData);

  final FilterData filterData;

  @override
  State<LessonFilterPage> createState() => _LessonFilterPageState();
}

class _LessonFilterPageState extends State<LessonFilterPage> {
  late final LessonFilterCubit _cubit;

  @override
  void initState() {
    super.initState();
    final AppRepository appRepository = AppRepository();
    _cubit = LessonFilterCubit(appRepository, widget.filterData);
    _cubit.getFilterData();
    firebaseSetup();
  }

  Future firebaseSetup() async {
    await TrackingManager.logEvent(
      name: 'component_displayed',
      parameters: {
        "screen_name": 'my_schedule',
        'component_name': 'filter_lesson',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocProvider(
        create: (context) => _cubit,
        child: CommonPage(
          title: R.string.filter.tr(),
          background: R.drawable.bg_welcome,
          showCloseBackButton: true,
          onTapClose: () async {
            await TrackingManager.logEvent(
              name: 'component_clicked',
              parameters: {
                "screen_name": 'my_schedule',
                'component_name': 'filter_lesson_close',
              },
            );
            NavigationUtil.pop(context);
          },
          onTapAppBar: () {
            FocusScope.of(context).unfocus();
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    _cubit.searchingStatus = SearchingStatus.none;
                    _cubit.refresh();
                  },
                  child: Container(
                    color: R.color.transparent,
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: BlocConsumer<LessonFilterCubit, LessonFilterState>(
                    listener: (context, state) {
                      if (state is LessonFilterLoading) {
                        BotToast.showLoading();
                      } else {
                        BotToast.closeAllLoading();
                      }
                      if (state is LessonFilterFailure) {
                        Message.showToastMessage(context, state.error);
                      }
                      if (state is LessonFilterDone) {
                        NavigationUtil.pop(context, result: _cubit.filterData);
                      }
                    },
                    builder: (context, state) {
                      return _cubit.searchingStatus == SearchingStatus.none
                          ? _buildNoneSearchPage()
                          : _buildSearchingPage();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoneSearchPage() {
    return Column(
      children: [
        _buildSearchBox(
          keyWord: _cubit.filterData.tagFilter,
          title: R.string.filter_by_key_word.tr(),
          hintText: R.string.enter_key_word.tr(),
          onSelectTag: () {
            _cubit.searchingStatus = SearchingStatus.keyWord;
            _cubit.textSearch = '';
            _cubit.refresh();
          },
          onRemoveTag: (index) {
            _cubit.filterData.tagFilter.removeAt(index);
            _cubit.refresh();
          },
        ),
        const SizedBox(height: 16),
        _buildSearchBox(
          keyWord: _cubit.filterData.nameFilter,
          title: R.string.filter_by_lesson_name.tr(),
          hintText: R.string.enter_lesson_name.tr(),
          onSelectTag: () {
            _cubit.searchingStatus = SearchingStatus.lessonName;
            _cubit.textSearch = '';
            _cubit.refresh();
          },
          onRemoveTag: (index) {
            _cubit.filterData.nameFilter.removeAt(index);
            _cubit.refresh();
          },
        ),
        //++20230115-LanhVC: remove checkbox
        // const SizedBox(height: 16),
        // Padding(
        //   padding: const EdgeInsets.only(left: 4.0),
        //   child: CustomCheckboxWidget(
        //     isChecked: _cubit.filterData.isCompleted,
        //     title: R.string.filter_not_learnt_lesson_yet.tr(),
        //     titleStyle: TextStyle(
        //       color: R.color.grey_1,
        //       fontSize: 14,
        //       fontWeight: FontWeight.w400,
        //     ),
        //     onTap: () async {
        //       await TrackingManager.logEvent(
        //         name: 'component_clicked',
        //         parameters: {
        //           "screen_name": 'my_schedule',
        //           'component_name': 'filter_lesson_learned',
        //           'filter_learned_check':
        //               _cubit.filterData.isCompleted ? "uncheck" : 'check',
        //         },
        //       );
        //       _cubit.onToggleCheckBox();
        //     },
        //   ),
        // ),
        //--20230115-LanhVC: remove checkbox
        const Spacer(),
        _buildButtonFilter(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildButtonFilter() {
    return Column(
      children: [
        Container(
          width: 245,
          height: 48,
          child: ButtonWidget(
            title: R.string.filtering.tr(),
            textSize: 16,
            onPressed: () async {
              List<String> tagFilter = [];
              List<String> nameFilter = [];
              _cubit.filterData.tagFilter.forEach((element) {
                if (tagFilter.length < 5) {
                  tagFilter.add(element?.text ?? "");
                }
              });
              _cubit.filterData.nameFilter.forEach((element) {
                if (nameFilter.length < 5) {
                  nameFilter.add(element?.text ?? "");
                }
              });
              await TrackingManager.logEvent(
                name: 'cta_button_clicked',
                parameters: {
                  "screen_name": 'my_schedule',
                  'cta_button_name': 'cta_filter_lesson_done',
                  'filter_keyword': tagFilter.join('_'),
                  'filter_title': nameFilter.join('_'),
                  'filter_learned_check':
                      _cubit.filterData.isCompleted ? "uncheck" : 'check',
                },
              );
              _cubit.emit(const LessonFilterDone());
              _cubit.refresh();
            },
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: 245,
          height: 48,
          child: ButtonWidget(
            title: R.string.remake_filter.tr(),
            textSize: 16,
            backgroundColor: R.color.white,
            borderColor: R.color.greenGradientBottom,
            textColor: R.color.greenGradientBottom,
            onPressed: () async {
              await TrackingManager.logEvent(
                name: 'cta_button_clicked',
                parameters: {
                  "screen_name": 'my_schedule',
                  'cta_button_name': 'cta_filter_lesson_reset',
                },
              );
              _cubit.searchingStatus = SearchingStatus.none;
              _cubit.filterData.clearFilter();
              _cubit.refresh();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchingPage() {
    final List<FilterDataItem?> selectedList =
        _cubit.searchingStatus == SearchingStatus.keyWord
            ? _cubit.filterData.tagFilter
            : _cubit.filterData.nameFilter;
    final String title = _cubit.searchingStatus == SearchingStatus.keyWord
        ? R.string.filter_by_key_word.tr()
        : R.string.filter_by_lesson_name.tr();
    final String hintText = _cubit.searchingStatus == SearchingStatus.keyWord
        ? R.string.enter_key_word.tr()
        : R.string.enter_lesson_name.tr();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: R.color.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: Stack(
            children: [
              Visibility(
                visible: _cubit.suggestWordFiltered.isEmpty,
                child: Padding(
                  padding: const EdgeInsets.only(top: 60.0, left: 8),
                  child: Text(
                    'Không có kết quả phù hợp',
                    style: TextStyle(
                      color: R.color.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: _cubit.suggestWordFiltered.isNotEmpty,
                child: Container(
                  width: double.infinity,
                  height: min(310, _cubit.suggestWordFiltered.length * 48 + 70),
                  decoration: BoxDecoration(
                    color: R.color.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      Expanded(
                        child: ListView.separated(
                          itemCount: _cubit.suggestWordFiltered.length,
                          itemBuilder: (context, index) {
                            final bool isSelected = selectedList.indexWhere(
                                    (element) =>
                                        element != null &&
                                        element.value ==
                                            _cubit.suggestWordFiltered[index]
                                                ?.value) !=
                                -1;
                            return InkWell(
                              onTap: () {
                                if (!isSelected) {
                                  _cubit.searchingStatus ==
                                          SearchingStatus.keyWord
                                      ? _cubit.filterData.tagFilter.add(
                                          _cubit.suggestWordFiltered[index])
                                      : _cubit.filterData.nameFilter.add(
                                          _cubit.suggestWordFiltered[index]);
                                } else {
                                  _cubit.searchingStatus ==
                                          SearchingStatus.keyWord
                                      ? _cubit.filterData.tagFilter
                                          .removeWhere((element) {
                                          return element!.value! ==
                                              _cubit.suggestWordFiltered[index]!
                                                  .value!;
                                        })
                                      : _cubit.filterData.nameFilter
                                          .removeWhere((element) {
                                          return element!.value! ==
                                              _cubit.suggestWordFiltered[index]!
                                                  .value!;
                                        });
                                }
                                _cubit.refresh();
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
                                        '${_cubit.suggestWordFiltered[index]?.text ?? ""}',
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
                      )
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: R.color.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        width: 1.5,
                        color: R.color.color0xffE5E5E5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            autofocus: true,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: hintText,
                              counterText: '',
                            ),
                            style: TextStyle(
                              color: R.color.grey_2,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            onChanged: (text) {
                              _cubit.textSearch = text.trim();
                              _cubit.refresh();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            _cubit.searchingStatus = SearchingStatus.none;
                            _cubit.refresh();
                          },
                          child: Image.asset(
                            R.drawable.ic_search,
                            color: R.color.gray,
                            width: 24,
                            height: 24,
                          ),
                        )
                      ],
                    ),
                  ),
                  const Spacer(),
                  _buildButtonFilter(),
                  const SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBox({
    required List<FilterDataItem?> keyWord,
    required String title,
    required String hintText,
    VoidCallback? onSelectTag,
    Function(int)? onRemoveTag,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: R.color.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onSelectTag,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: R.color.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                width: 1.5,
                color: R.color.color0xffE5E5E5,
              ),
            ),
            child: keyWord.isEmpty
                ? Row(
                    children: [
                      Expanded(
                        child: Text(
                          hintText,
                          style: TextStyle(
                            color: R.color.grey_2,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Image.asset(
                        R.drawable.ic_search,
                        color: R.color.gray,
                        width: 24,
                        height: 24,
                      )
                    ],
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...List.generate(
                        keyWord.length,
                        (index) => _buildTag(
                          title: keyWord[index]?.text ?? '',
                          onSelectTag: onSelectTag,
                          onTapRemove: () {
                            if (onRemoveTag != null) {
                              onRemoveTag(index);
                            }
                          },
                        ),
                      ),
                      Image.asset(
                        R.drawable.ic_search,
                        color: R.color.gray,
                        width: 24,
                        height: 24,
                      )
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTag({
    required String title,
    VoidCallback? onSelectTag,
    VoidCallback? onTapRemove,
  }) {
    return InkWell(
      onTap: onSelectTag,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: R.color.tagColor,
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color: R.color.shadowColor.withOpacity(0.5),
              spreadRadius: 0.5,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 120),
              child: Text(
                title,
                style: TextStyle(
                  color: R.color.gray_1,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onTapRemove,
              child: Icon(
                Icons.clear_rounded,
                color: R.color.gray,
                size: 16,
              ),
            )
          ],
        ),
      ),
    );
  }
}
