import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/blood_sugar_template_category_response.dart';
import 'package:medical/src/model/response/blood_sugar_template_detail_response.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/profile/schedule_glucose.dart';
import 'package:medical/src/widgets/blood_sugar_recommand_layout_widget.dart';
import 'package:medical/src/widgets/button_widget.dart';

import 'blood_sugar_schedule_templete.dart';

class BloodSugarScheduleTempletePage extends StatefulWidget {
  const BloodSugarScheduleTempletePage(this.template);
  final BloodSugarTemplateCategory template;

  @override
  State<BloodSugarScheduleTempletePage> createState() =>
      _BloodSugarScheduleTempletePageState();
}

class _BloodSugarScheduleTempletePageState
    extends State<BloodSugarScheduleTempletePage> {
  late final BloodSugarScheduleTempleteCubit _cubit;

  @override
  void initState() {
    super.initState();
    final AppRepository repository = AppRepository();
    _cubit = BloodSugarScheduleTempleteCubit(repository);
    _cubit.getTempleteDetail();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: BlocConsumer<BloodSugarScheduleTempleteCubit,
          BloodSugarScheduleTempleteState>(
        listener: (context, state) {
          if (state is BloodSugarScheduleTempleteFailure) {
            Utils.showErrorSnackBar(context, state.error ?? '');
          }
          if (state is BloodSugarScheduleSaveSuccess) {
            NavigationUtil.pushAndRemoveUtilPage(context, ScheduleGlucoseController());
          }
        },
        builder: (context, state) {
          return BloodSugarRecommandLayoutWidget(
            title: widget.template.name ?? '',
            resultSurvey: _cubit.isWeekTemplate ? '' : '2',
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: R.color.white,
              child: SafeArea(
                top: false,
                child: state is BloodSugarScheduleTempleteLoading
                    ? const SizedBox()
                    : _cubit.isWeekTemplate
                        ? _buildTempleteWeekSchedule()
                        : _buildTempleteDaySchedule(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTempleteWeekSchedule() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            //Part of the day
            Padding(
              padding: const EdgeInsets.only(top: 19, bottom: 7),
              child: Row(
                children: [
                  const SizedBox(width: 68),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Sáng',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: R.color.textDark,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Trưa',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: R.color.textDark,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Tối',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: R.color.textDark,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        R.string.sleep_time.tr(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: R.color.textDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //Schedule
            Column(
              children: List.generate(
                7,
                (index) {
                  return _buildDayInWeekSchedule(
                    index: index,
                    templateDetail: _cubit.getDayInWeek(index),
                  );
                },
              ),
            ),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTempleteDaySchedule() {
    final BloodSugarTemplateDetailResponse templeteDetail =
        _cubit.templeteDetailList.first;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Column(
        children: [
          _buildFoodItem(
            title: R.string.the_morning.tr(),
            isBeforeSelected: templeteDetail.isBeforeBreakfast,
            isAfterSelected: templeteDetail.isAfterBreakfast,
            onSelectBefore: (isSelected) {
              templeteDetail.isBeforeBreakfast = isSelected;
              _cubit.refreshState();
            },
            onSelectAfter: (isSelected) {
              templeteDetail.isAfterBreakfast = isSelected;
              _cubit.refreshState();
            },
          ),
          _buildFoodItem(
            title: R.string.the_noon.tr(),
            isBeforeSelected: templeteDetail.isBeforeLunch,
            isAfterSelected: templeteDetail.isAfterLunch,
            onSelectBefore: (isSelected) {
              templeteDetail.isBeforeLunch = isSelected;
              _cubit.refreshState();
            },
            onSelectAfter: (isSelected) {
              templeteDetail.isAfterLunch = isSelected;
              _cubit.refreshState();
            },
          ),
          _buildFoodItem(
            title: R.string.the_evening.tr(),
            isBeforeSelected: templeteDetail.isBeforeDinner,
            isAfterSelected: templeteDetail.isAfterDinner,
            onSelectBefore: (isSelected) {
              templeteDetail.isBeforeDinner = isSelected;
              _cubit.refreshState();
            },
            onSelectAfter: (isSelected) {
              templeteDetail.isAfterDinner = isSelected;
              _cubit.refreshState();
            },
          ),
          _buildSleepTimeItem(
              isSelected: templeteDetail.isBeforeSleeping ?? false,
              onSelected: (isSelected) {
                templeteDetail.isBeforeSleeping = isSelected;
                _cubit.refreshState();
              }),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildDayInWeekSchedule({
    required int index,
    required BloodSugarTemplateDetailResponse? templateDetail,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 68,
            alignment: Alignment.center,
            child: Text(
              getDayInWeekTitle(index),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: R.color.textDark,
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: R.color.color0xffE5B440),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _buildTestTimeItem(
                              testTime: 'Trước ăn',
                              isSelected: templateDetail?.isBeforeBreakfast,
                              onSelect: (isSelected) {
                                templateDetail?.isBeforeBreakfast = isSelected;
                                _cubit.refreshState();
                              },
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8))),
                          Container(
                            height: 1,
                            color: R.color.color0xffE5B440,
                          ),
                          _buildTestTimeItem(
                              testTime: 'Sau ăn',
                              isSelected: templateDetail?.isAfterBreakfast,
                              onSelect: (isSelected) {
                                templateDetail?.isAfterBreakfast = isSelected;
                                _cubit.refreshState();
                              },
                              borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(8))),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      color: R.color.color0xffE5B440,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          _buildTestTimeItem(
                            testTime: 'Trước ăn',
                            isSelected: templateDetail?.isBeforeLunch,
                            onSelect: (isSelected) {
                              templateDetail?.isBeforeLunch = isSelected;
                              _cubit.refreshState();
                            },
                          ),
                          Container(
                            height: 1,
                            color: R.color.color0xffE5B440,
                          ),
                          _buildTestTimeItem(
                            testTime: 'Sau ăn',
                            isSelected: templateDetail?.isAfterLunch,
                            onSelect: (isSelected) {
                              templateDetail?.isAfterLunch = isSelected;
                              _cubit.refreshState();
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      color: R.color.color0xffE5B440,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          _buildTestTimeItem(
                            testTime: 'Trước ăn',
                            isSelected: templateDetail?.isBeforeDinner,
                            onSelect: (isSelected) {
                              templateDetail?.isBeforeDinner = isSelected;
                              _cubit.refreshState();
                            },
                          ),
                          Container(
                            height: 1,
                            color: R.color.color0xffE5B440,
                          ),
                          _buildTestTimeItem(
                            testTime: 'Sau ăn',
                            isSelected: templateDetail?.isAfterDinner,
                            onSelect: (isSelected) {
                              templateDetail?.isAfterDinner = isSelected;
                              _cubit.refreshState();
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      color: R.color.color0xffE5B440,
                    ),
                    Expanded(
                      child: _buildTestTimeItem(
                        testTime: 'Trước khi đi ngủ',
                        isSelected: templateDetail?.isBeforeSleeping,
                        onSelect: (isSelected) {
                          templateDetail?.isBeforeSleeping = isSelected;
                          _cubit.refreshState();
                        },
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTestTimeItem({
    required String testTime,
    bool? isSelected,
    BorderRadius? borderRadius,
    Function(bool isSelected)? onSelect,
  }) {
    return GestureDetector(
      onTap: () {
        if (onSelect != null) {
          onSelect(!(isSelected ?? false));
        }
      },
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
            color:
                isSelected ?? false ? R.color.color0xffF4DBBD : R.color.white,
            borderRadius: borderRadius),
        child: Text(
          testTime,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: isSelected ?? false ? R.color.main_1 : R.color.gray,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        const SizedBox(height: 32),
        SizedBox(
          width: 208,
          child: ButtonWidget(
            title: 'Đặt làm lịch của tôi',
            onPressed: () {
              _cubit.onSubmitSchedule();
            },
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 208,
          child: ButtonWidget(
            title: 'Đặt lại lịch gợi ý',
            onPressed: () {
              _cubit.getTempleteDetail();
            },
            backgroundColor: R.color.white,
            borderColor: R.color.gray,
            textColor: R.color.gray,
          ),
        ),
      ],
    );
  }

  Widget _buildFoodItem({
    required String title,
    required bool? isBeforeSelected,
    required bool? isAfterSelected,
    Function(bool isSelected)? onSelectBefore,
    Function(bool isSelected)? onSelectAfter,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: R.color.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildSingleFoodItem(
                isBeforeEat: true,
                isSelected: isBeforeSelected ?? false,
                onSelect: onSelectBefore,
              ),
              const SizedBox(width: 16),
              _buildSingleFoodItem(
                isBeforeEat: false,
                isSelected: isAfterSelected ?? false,
                onSelect: onSelectAfter,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSingleFoodItem({
    required bool isBeforeEat,
    required bool isSelected,
    Function(bool isSelected)? onSelect,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (onSelect != null) {
            onSelect(!isSelected);
          }
        },
        child: Container(
          height: 60,
          decoration: BoxDecoration(
              color: isSelected
                  ? R.color.color0xffF4DBBD
                  : R.color.color0xffF5F7FA,
              border: Border.all(
                  color: isSelected
                      ? R.color.color0xffE5B440
                      : R.color.color0xffF5F7FA),
              borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                  isBeforeEat
                      ? isSelected
                          ? R.drawable.ic_before_eat_selected
                          : R.drawable.ic_before_eat
                      : isSelected
                          ? R.drawable.ic_after_eat_selected
                          : R.drawable.ic_after_eat,
                  width: 51,
                  height: 34),
              const SizedBox(width: 8),
              Text(
                isBeforeEat ? R.string.truoc_an.tr() : R.string.sau_an.tr(),
                style: TextStyle(
                    color: isSelected ? R.color.mainColor : R.color.gray,
                    fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSleepTimeItem({
    required bool isSelected,
    Function(bool isSelected)? onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Giờ ngủ',
              style: TextStyle(
                  color: R.color.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () {
              if (onSelected != null) {
                onSelected(!isSelected);
              }
            },
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                  color: isSelected
                      ? R.color.color0xffF4DBBD
                      : R.color.color0xffF5F7FA,
                  border: Border.all(
                      color: isSelected
                          ? R.color.color0xffE5B440
                          : R.color.color0xffF5F7FA),
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                      isSelected
                          ? R.drawable.ic_before_sleep_selected
                          : R.drawable.ic_before_sleep,
                      width: 51,
                      height: 34),
                  const SizedBox(width: 8),
                  Text(
                    isSelected ? R.string.truoc_an.tr() : R.string.sau_an.tr(),
                    style: TextStyle(
                        color: isSelected ? R.color.mainColor : R.color.gray,
                        fontSize: 16),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  String getDayInWeekTitle(int index) {
    if (index >= 0 && index < 6) return 'T${index + 2}';
    if (index == 6) return 'CN';
    return '';
  }
}
