import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/blood_sugar_template_response.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/blood_sugar_result_layout_widget.dart';
import 'package:medical/src/widgets/button_widget.dart';

import 'blood_sugar_schedule_template.dart';

class BloodSugarScheduleTemplatePage extends StatefulWidget {
  const BloodSugarScheduleTemplatePage(this.templateDetail);
  final BloodSugarTemplateResponseData templateDetail;

  @override
  State<BloodSugarScheduleTemplatePage> createState() =>
      _BloodSugarScheduleTemplatePageState();
}

class _BloodSugarScheduleTemplatePageState
    extends State<BloodSugarScheduleTemplatePage> {
  late final BloodSugarScheduleTemplateCubit _cubit;

  @override
  void initState() {
    super.initState();
    final AppRepository repository = AppRepository();
    _cubit = BloodSugarScheduleTemplateCubit(
      repository,
      initialTemplateDetail: widget.templateDetail,
    );
    _cubit.resetTemplateDetail();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: BlocConsumer<BloodSugarScheduleTemplateCubit,
          BloodSugarScheduleTemplateState>(
        listener: (context, state) {
          if (state is BloodSugarScheduleTemplateFailure) {
            Message.showToastMessage(context, state.error ?? '');
          }
          if (state is BloodSugarScheduleSaveSuccess) {
            //TODO: Tuyen navigate to blood sugar test schedule screen
          }
        },
        builder: (context, state) {
          if (state is BloodSugarScheduleTemplateLoading) {
            BotToast.showLoading();
          } else {
            BotToast.closeAllLoading();
          }
          return BloodSugarResultLayoutWidget(
            title: R.string.result.tr(),
            timeToTestPerDay: _cubit.templateDetail.timePerDay,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: R.color.white,
              child: SafeArea(
                top: false,
                child: state is BloodSugarScheduleTemplateLoading
                    ? const SizedBox()
                    : _cubit.isWeekTemplate
                        ? _buildTemplateWeekSchedule()
                        : _buildTemplateDaySchedule(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTemplateWeekSchedule() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(right: 16.w),
        child: Column(
          children: [
            //Part of the day
            Padding(
              padding: EdgeInsets.only(top: 19.h, bottom: 7.h),
              child: Row(
                children: [
                  SizedBox(width: 68.w),
                  Expanded(
                    child: Center(
                      child: Text(
                        R.string.morning_first_upper_case.tr(),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: R.color.textDark,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        R.string.noon_first_upper_case.tr(),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: R.color.textDark,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        R.string.evening_first_upper_case.tr(),
                        style: TextStyle(
                          fontSize: 16.sp,
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
                          fontSize: 16.sp,
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

  Widget _buildTemplateDaySchedule() {
    if (_cubit.templateDetail.schedules?.isNotEmpty != true)
      return const SizedBox();
    final BloodSugarTemplateResponseDataSchedules? templeteDetail =
        _cubit.templateDetail.schedules?.first;
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0),
      child: Column(
        children: [
          _buildFoodItem(
            title: R.string.the_morning.tr(),
            isBeforeSelected: templeteDetail?.isBeforeBreakfast,
            isAfterSelected: templeteDetail?.isAfterBreakfast,
            onSelectBefore: (isSelected) {
              templeteDetail?.isBeforeBreakfast = isSelected;
              _cubit.refreshState();
            },
            onSelectAfter: (isSelected) {
              templeteDetail?.isAfterBreakfast = isSelected;
              _cubit.refreshState();
            },
          ),
          _buildFoodItem(
            title: R.string.the_noon.tr(),
            isBeforeSelected: templeteDetail?.isBeforeLunch,
            isAfterSelected: templeteDetail?.isAfterLunch,
            onSelectBefore: (isSelected) {
              templeteDetail?.isBeforeLunch = isSelected;
              _cubit.refreshState();
            },
            onSelectAfter: (isSelected) {
              templeteDetail?.isAfterLunch = isSelected;
              _cubit.refreshState();
            },
          ),
          _buildFoodItem(
            title: R.string.the_evening.tr(),
            isBeforeSelected: templeteDetail?.isBeforeDinner,
            isAfterSelected: templeteDetail?.isAfterDinner,
            onSelectBefore: (isSelected) {
              templeteDetail?.isBeforeDinner = isSelected;
              _cubit.refreshState();
            },
            onSelectAfter: (isSelected) {
              templeteDetail?.isAfterDinner = isSelected;
              _cubit.refreshState();
            },
          ),
          _buildSleepTimeItem(
              isSelected: templeteDetail?.isBeforeSleeping ?? false,
              onSelected: (isSelected) {
                templeteDetail?.isBeforeSleeping = isSelected;
                _cubit.refreshState();
              }),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildDayInWeekSchedule({
    required int index,
    required BloodSugarTemplateResponseDataSchedules? templateDetail,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Container(
            width: 68.w,
            alignment: Alignment.center,
            child: Text(
              Utils.getDayInWeekTitle(index),
              style: TextStyle(
                fontSize: 16.sp,
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
                              testTime: R.string.truoc_an.tr(),
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
                              testTime: R.string.sau_an.tr(),
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
                            testTime: R.string.truoc_an.tr(),
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
                            testTime: R.string.sau_an.tr(),
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
                            testTime: R.string.truoc_an.tr(),
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
                            testTime: R.string.sau_an.tr(),
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
                        testTime: R.string.before_go_to_sleep.tr(),
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
          _cubit.scheduleChanged();
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
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
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
        SizedBox(height: 32.h),
        SizedBox(
          width: 208.w,
          child: ButtonWidget(
            title: R.string.set_as_my_schedule.tr(),
            onPressed: () {
              _cubit.onSubmitSchedule();
            },
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          width: 208.w,
          child: ButtonWidget(
            title: R.string.reset_schedule.tr(),
            onPressed: () {
              _cubit.refreshTemplateDetail();
            },
            backgroundColor: R.color.white,
            borderColor: _cubit.isChanged ? R.color.greenGradientBottom : R.color.gray,
            textColor: _cubit.isChanged ? R.color.greenGradientBottom : R.color.gray,
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
      padding: EdgeInsets.only(top: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: R.color.black,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700)),
          SizedBox(height: 6.h),
          Row(
            children: [
              _buildSingleFoodItem(
                isBeforeEat: true,
                isSelected: isBeforeSelected ?? false,
                onSelect: onSelectBefore,
              ),
              SizedBox(width: 16.h),
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
            _cubit.scheduleChanged();
          }
        },
        child: Container(
          height: 60.h,
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
                  width: 51.w,
                  height: 34.h),
              const SizedBox(width: 8),
              Text(
                isBeforeEat ? R.string.truoc_an.tr() : R.string.sau_an.tr(),
                style: TextStyle(
                    color: isSelected ? R.color.mainColor : R.color.gray,
                    fontSize: 16.sp),
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
      padding: EdgeInsets.only(top: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(R.string.sleep_time.tr(),
              style: TextStyle(
                  color: R.color.black,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () {
              if (onSelected != null) {
                onSelected(!isSelected);
                _cubit.scheduleChanged();
              }
            },
            child: Container(
              height: 60.h,
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
                      width: 51.w,
                      height: 34.h),
                  const SizedBox(width: 8),
                  Text(
                    isSelected ? R.string.truoc_an.tr() : R.string.sau_an.tr(),
                    style: TextStyle(
                        color: isSelected ? R.color.mainColor : R.color.gray,
                        fontSize: 16.sp),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
