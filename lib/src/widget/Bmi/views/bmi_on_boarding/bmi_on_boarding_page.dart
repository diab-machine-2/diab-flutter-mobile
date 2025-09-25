import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/firebase_tracking/activity_list_tracking.dart';
import 'package:medical/src/modal/blood_pressure/bloodpressure_lesson.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/bmi/bloc/bmi_bloc.dart';
import 'package:medical/src/widget/bmi/bloc/bmi_state.dart';
import 'package:medical/src/widget/bmi/views/add_bmi/add_bmi_page.dart';
import 'package:medical/src/widget/bmi/views/bmi_height_input_dialog.dart';
import 'package:medical/src/widget/bmi/views/bmi_input_type_bottom_sheet.dart';
import 'package:medical/src/widget/bmi/views/bmi_on_boarding/widgets/bmi_instruction_session.dart';
import 'package:medical/src/widget/bmi/views/bmi_on_boarding/widgets/bmi_on_boarding_app_bar.dart';
import 'package:medical/src/widget/bmi/views/bmi_on_boarding/widgets/bmi_on_boarding_chart_session.dart';
import 'package:medical/src/widget/bmi/views/bmi_on_boarding/widgets/bmi_on_boarding_introducing_session.dart';
import 'package:medical/src/widget/bmi/views/bmi_on_boarding/widgets/bmi_onboarding_avarage_bmi_session.dart';
import 'package:medical/src/widget/bmi/views/bmi_on_boarding/widgets/bmi_onboarding_current_height_widget.dart';
import 'package:medical/src/widget/bmi/views/bmi_on_boarding/widgets/bmi_onboarding_weight_goal_widget.dart';
import 'package:medical/src/widget/bmi/views/bmi_on_boarding/widgets/bmi_post_session.dart';
import 'package:medical/src/widget/bmi/views/bmi_statistical_data/bmi_statistical_data_page.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/lesson_detail.dart';
import 'package:medical/src/widgets/button/primary_rounded_button.dart';
import 'package:medical/src/widgets/network_image_widget.dart';

// import 'widgets/bloodpresure_lesson_section.dart';

class BmiOnBoardingPage extends StatefulWidget {
  final String? type;
  final String? id;
  final String? goalId;
  final bool? isCurrentBmi;

  const BmiOnBoardingPage({
    super.key,
    this.type,
    this.id,
    this.goalId,
    this.isCurrentBmi,
  });

  @override
  State<BmiOnBoardingPage> createState() => _BmiOnBoardingPageState();
}

class _BmiOnBoardingPageState extends State<BmiOnBoardingPage> {
  final List<BloodPressureLesson> _pinedLessons = [];
  late BmiBloc _bmiBloc;

  @override
  void initState() {
    _bmiBloc = context.read<BmiBloc>();
    _bmiBloc.init();
    super.initState();
    // _loadLessons();
  }

  // void _loadLessons() async {
  //   try {
  //     _pinedLessons.clear();
  //     final lessons = await BloodPressureClient().fetchBloodPressureLessons();
  //     if (lessons != null) {
  //       setState(() {
  //         _pinedLessons.addAll(lessons);
  //       });
  //     }
  //   } catch (e, s) {
  //     TrackingManager.recordError(e, s);
  //   }
  // }

  void _navigateToInputSelection() async {
    // bool? hasHealthConnection = await AppStorages.getHealthAppPermission();
    // // Grant access to HealthKit already
    // if (hasHealthConnection == true) {
    //   Navigator.pushNamed(
    //     context,
    //     NavigatorName.add_blood_pressure,
    //     arguments: {'type': 'input', 'goalId': widget.goalId},
    //   );
    //   return;
    // }
    // // Show the modal to choose methods
    // BloodPressureFunctions.showModalAddData(context,
    //     popPrevious: true, goalId: widget.goalId);
  }

  void _navigateToLessonDetail(String id, int type) async {
    ActivityListTracking.clickLessonItem(
      objectId: id,
      objectIndex: null,
      objectTitle: null,
    );

    await NavigationUtil.navigatePage(
      context,
      LessonDetailPage(
        lessonType: type,
        lessonId: id,
        onComplete: (_, __) {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BmiBloc, BmiState>(
        buildWhen: (_, state) => state is BmiGetWaistStatisticalState,
        builder: (context, state) {
          return Scaffold(
            backgroundColor: R.color.glucose_bg_color,
            resizeToAvoidBottomInset: true,
            appBar: const BmiOnBoardingAppBar(),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  if (!_bmiBloc.hasStatisticalData) ...[
                    const SizedBox(height: 24),
                    const BmiOnBoardingIntroducingSession(),
                    const SizedBox(height: 12),
                    const BmiInstructionSession(),
                    const SizedBox(height: 12),
                  ] else ...[
                    const BmiOnBoardingChartSession(),
                    const SizedBox(height: 12),
                    const BmiOnboardingAvarageBmiSession(),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          const Expanded(
                              child: BmiOnboardingCurrentHeightWidget()),
                          const SizedBox(
                            width: 12,
                          ),
                          const Expanded(
                              child: BmiOnboardingWeightGoalWidget()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  // _buildPinnedLessonsSection()
                  const BmiPostSession(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            bottomNavigationBar:
                _bmiBloc.hasStatisticalData ? const _BottomBar() : null,
          );
        });
  }

  Widget _buildPinnedLessonsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              R.string.bloodpressure_intro_help_title.tr(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 24 / 18,
                color: R.color.dark,
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (_pinedLessons.isNotEmpty) ...[
            Row(
              children: [
                Expanded(child: _buildPinnedLessonItem(_pinedLessons[0])),
                const SizedBox(width: 8),
                Expanded(
                    child: _pinedLessons.length > 1
                        ? _buildPinnedLessonItem(_pinedLessons[1])
                        : const SizedBox()),
              ],
            ),
            const SizedBox(height: 8),
          ],
          if (_pinedLessons.isNotEmpty && _pinedLessons.length > 2) ...[
            Row(
              children: [
                Expanded(child: _buildPinnedLessonItem(_pinedLessons[2])),
                const SizedBox(width: 8),
                Expanded(
                    child: _pinedLessons.length > 3
                        ? _buildPinnedLessonItem(_pinedLessons[3])
                        : const SizedBox()),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Widget _buildLessonSection() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 12),
  //     child: BloodPressureLessonSection(
  //       onLessonTap: (lesson) =>
  //           _navigateToLessonDetail(lesson.id, lesson.type),
  //     ),
  //   );
  // }

  Widget _buildPinnedLessonItem(BloodPressureLesson lesson) {
    String title = lesson.name;
    String? imageUrl = lesson.imageUrl;
    return InkWell(
      onTap: () => _navigateToLessonDetail(lesson.id, lesson.type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        height: 152.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(16)),
          border: Border.all(color: R.color.grayComponentBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            NetWorkImageWidget(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              width: 72,
              height: 72,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 20 / 14,
                fontWeight: FontWeight.w400,
                color: R.color.primaryGreyColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 16,
      ),
      color: Colors.white,
      child: Row(
        children: [
          _StatisticalDataViewButton(),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: PrimaryRoundedButton(
              title: R.string.enter_weight.tr(),
              onPressed: () {
                BmiInputTypeBottomSheet.show(
                  context,
                  onSelected: () => _onSelectMethodInput(context),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onSelectMethodInput(BuildContext context) {
    BmiHeightInputDialog.show(
      context,
      onConfirmed: (height) {
        Navigator.pushNamed(
          context,
          NavigatorName.bmiInputPage,
          arguments: {AddBmiPage.bmiInputCurrentHeightKey: height},
        );
      },
    );
  }
}

class _StatisticalDataViewButton extends StatelessWidget {
  const _StatisticalDataViewButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    BmiBloc _bmiBloc = context.read();

    return InkWell(
      onTap: () {
        _bmiBloc.fetchHistoricalWeight();

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                    value: _bmiBloc, child: BmiStatisticalDataPage())));
      },
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            child: Icon(Icons.list_rounded),
            height: R.dimen.default_button_height,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
                color: R.color.backgroundColorNew,
                borderRadius: BorderRadius.all(Radius.circular(50))),
          ),
          Container(
            height: 12,
            width: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red,
            ),
          )
        ],
      ),
    );
  }
}





// class AddBmiView extends StatefulWidget with AddBmiMixin {
//   final String? type;
//   final String? id;
//   final String? goalId;
//   final bool? isCurrentBmi;

//   AddBmiView({
//     this.type,
//     this.id,
//     this.goalId,
//     this.isCurrentBmi,
//   });

//   @override
//   State<AddBmiView> createState() => _AddBmiViewState();
// }

// class _AddBmiViewState extends State<AddBmiView> {
//   late AddBmiCubit _cubit;

//   @override
//   void initState() {
//     _cubit = AddBmiCubit(
//       type: widget.type,
//       id: widget.id,
//       goalId: widget.goalId,
//       isCurrentBmi: widget.isCurrentBmi,
//     );
//     firebaseSetup();
//     super.initState();
//   }

//   Future firebaseSetup() async {
//     await TrackingManager.analytics.logScreenView(
//       screenName: "kpi_body_weight_add",
//       screenClass: "AddBmiController",
//     );
//     // await TrackingManager.analytics.logEvent(
//     //   name: 'kpi_add_begin',
//     //   parameters: {
//     //     "screen_name": 'kpi_body_weight_add',
//     //     'object_type': 'kpi_body_weight',
//     //     'object_title': 'Chỉ số cân nặng'
//     //   },
//     // );
//     AppSettings.currentScreenName = 'kpi_body_weight_add';
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => _cubit,
//       child: GestureDetector(
//         onTap: () {
//           FocusScope.of(context).unfocus();
//         },
//         child: WillPopScope(
//           onWillPop: () async {
//             widget.showDialogSave(context, cubit: _cubit);
//             return false;
//           },
//           child: Scaffold(
//             backgroundColor: R.color.backgroundColor,
//             body: Container(
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                     image: AssetImage(R.drawable.bg_splash), fit: BoxFit.cover),
//               ),
//               child: BlocConsumer<AddBmiCubit, CubitBaseState>(
//                   listener: (context, state) async {
//                 if (state is ErrorState) {
//                   Message.showToastMessage(context, state.failure.message);
//                 }
//                 if (state is DataLoadedState) {
//                   // if (_cubit.isPregnancy) {
//                   //   await UserClient().fetchUser();
//                   // }
//                   if (_cubit.isDelete) {
//                     Message.showToastMessage(
//                         context, R.string.xoa_thanh_cong.tr());
//                   } else {
//                     Message.showToastMessage(
//                         context, R.string.luu_thanh_cong.tr());
//                   }
//                 }
//               }, builder: (context, state) {
//                 if (state is LoadingState) {
//                   BotToast.showLoading();
//                 } else {
//                   BotToast.closeAllLoading();
//                 }
//                 return Column(
//                   children: [
//                     SectionAppBar(cubit: _cubit),
//                     Expanded(
//                       child: ListView(
//                         padding: EdgeInsets.all(15),
//                         children: [
//                           Container(
//                             padding: EdgeInsets.all(15),
//                             decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(20)),
//                             child: SpacingColumn(
//                               spacing: 40,
//                               children: [
//                                 SectionInputKpi(cubit: _cubit),
//                                 SectionWeightRanges(cubit: _cubit),
//                                 SectionDateTime(cubit: _cubit),
//                               ],
//                             ),
//                           ),
//                           SizedBox(height: 15),
//                           Container(
//                             padding: EdgeInsets.all(15),
//                             decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(20)),
//                             child: SpacingColumn(
//                               separator: Divider(
//                                 color: R.color.color0xffE5E5E5,
//                               ),
//                               children: [
//                                 SectionInputNote(cubit: _cubit),
//                                 SectionSelectImage(cubit: _cubit),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SectionFooter(cubit: _cubit),
//                   ],
//                 );
//               }),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   showActionFilter(BuildContext context) {
//     showModalBottomSheet(
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
//         backgroundColor: R.color.white,
//         context: context,
//         isScrollControlled: true,
//         builder: (context) => ActionListTrend(
//             selected: _cubit.selectedTimeFrame,
//             callback: (value) {
//               setState(() {
//                 _cubit.selectedTimeFrame = value;
//               });
//             }));
//   }

//   handleBMI() async {
//     BotToast.showLoading();
//     if (_cubit.selectedWeight != 0 && _cubit.selectedHeight != 0) {
//       final result = await WeightClient()
//           .fetchCaculateBMI(_cubit.selectedWeight, _cubit.selectedHeight);
//       _cubit.bmiNumber = result.bmi;
//       Observable.instance.notifyObservers([], notifyName: "refresh_home");
//     }
//     BotToast.closeAllLoading();

//     setState(() {});
//   }
// }
