import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/common_page.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => _cubit,
        child: CommonPage(
          title: R.string.filter.tr(),
          background: R.drawable.bg_welcome,
          showCloseBackButton: true,
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
          keyWord: _cubit.filterData.keyWordFilter,
          hintText: R.string.filter_by_key_word.tr(),
          onSelectTag: () {
            _cubit.searchingStatus = SearchingStatus.keyWord;
            _cubit.refresh();
          },
          onRemoveTag: (index) {
            _cubit.filterData.keyWordFilter.removeAt(index);
            _cubit.refresh();
          },
        ),
        const SizedBox(height: 16),
        _buildSearchBox(
          keyWord: _cubit.filterData.lessonNameFilter,
          hintText: R.string.enter_lesson_name.tr(),
          onSelectTag: () {
            _cubit.searchingStatus = SearchingStatus.lessonName;
            _cubit.refresh();
          },
          onRemoveTag: (index) {
            _cubit.filterData.lessonNameFilter.removeAt(index);
            _cubit.refresh();
          },
        ),
        const SizedBox(height: 16),
        _buildCheckbox(),
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
            onPressed: () {
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
            onPressed: () {
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
    final List<String> selectedList =
        _cubit.searchingStatus == SearchingStatus.keyWord
            ? _cubit.filterData.keyWordFilter
            : _cubit.filterData.lessonNameFilter;
    final String hintText = _cubit.searchingStatus == SearchingStatus.keyWord
        ? R.string.filter_by_key_word.tr()
        : R.string.enter_lesson_name.tr();
    return Stack(
      children: [
        Visibility(
          visible: _cubit.suggestWordFiltered.isNotEmpty,
          child: Container(
            width: double.infinity,
            height: min(262, _cubit.suggestWordFiltered.length * 48 + 70),
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
                      final bool isSelected = selectedList
                          .contains(_cubit.suggestWordFiltered[index]);
                      return InkWell(
                        onTap: () {
                          if (!isSelected) {
                            _cubit.searchingStatus == SearchingStatus.keyWord
                                ? _cubit.filterData.keyWordFilter
                                    .add(_cubit.suggestWordFiltered[index])
                                : _cubit.filterData.lessonNameFilter
                                    .add(_cubit.suggestWordFiltered[index]);
                          } else {
                            _cubit.searchingStatus == SearchingStatus.keyWord
                                ? _cubit.filterData.keyWordFilter
                                    .remove(_cubit.suggestWordFiltered[index])
                                : _cubit.filterData.lessonNameFilter
                                    .remove(_cubit.suggestWordFiltered[index]);
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
                                  '${_cubit.suggestWordFiltered[index]}',
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
                        ),
                        style: TextStyle(
                          color: R.color.grey_2,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        onChanged: (text) {
                          _cubit.textSearch = text;
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
                ),),
            const Spacer(),
            _buildButtonFilter(),
            const SizedBox(height: 20),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBox({
    required List<String> keyWord,
    required String hintText,
    VoidCallback? onSelectTag,
    Function(int)? onRemoveTag,
  }) {
    return GestureDetector(
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
                      title: keyWord[index],
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
            Text(
              title,
              style: TextStyle(
                color: R.color.gray_1,
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

  Widget _buildCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            _cubit.onToggleCheckBox();
          },
          child: Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(left: 4, right: 14),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _cubit.filterData.showOnlyNotLearnLesson
                  ? R.color.accentColor
                  : R.color.white,
              border: _cubit.filterData.showOnlyNotLearnLesson
                  ? null
                  : Border.all(width: 2, color: R.color.grayComponentBorder),
              borderRadius: BorderRadius.circular(4),
            ),
            child: _cubit.filterData.showOnlyNotLearnLesson
                ? Icon(
                    Icons.check,
                    color: R.color.white,
                    size: 24,
                  )
                : const SizedBox(),
          ),
        ),
        Text(
          R.string.filter_not_learnt_lesson_yet.tr(),
          style: TextStyle(
            color: R.color.grey_1,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        )
      ],
    );
  }
}
