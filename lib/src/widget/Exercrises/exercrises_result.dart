import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Exercrises/widget/circular_arch_progress_bar.dart';
import 'package:medical/src/widget/Exercrises/widget/exercrises_ai_suggestion.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/network_image_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/bloc/exercrises/exercrises_bloc.dart';
import 'package:medical/src/modal/exercrises/exercrise_input.dart';
import 'package:medical/src/modal/exercrises/exercrise_summary.dart';
import 'package:medical/src/modal/exercrises/exercrise_walk_summary.dart';
import 'package:medical/src/app_setting/app_setting.dart';

class ExercisesResult extends StatefulWidget {
  final int periodFilterType;
  final DateTime date;

  const ExercisesResult({
    Key? key,
    this.periodFilterType = 1,
    required this.date,
  }) : super(key: key);

  @override
  _ExercisesResultState createState() => _ExercisesResultState();
}

class _ExercisesResultState extends State<ExercisesResult>
    with WidgetsBindingObserver, Observer {
  late int periodFilterType;
  late DateTime date;
  late BuildContext currentContext;

  // Dùng cho _buildActivityList
  List<InputDataExercriseModel> inputDataExercrises = [];
  bool? hasMore = false;

  // Dùng cho _buildProgressSection
  ExercriseSummaryModel? exerciseSummary;
  ExercriseWalkSummaryModel? walkSummary;

  @override
  void update(
      Observable observable, String? notifyName, Map<dynamic, dynamic>? map) {
    if (notifyName == 'active_change_data_v2') {
      _refresh();
    }
  }

  @override
  void initState() {
    super.initState();
    periodFilterType = widget.periodFilterType;
    date = widget.date;
    Observable.instance.addObserver(this);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Observable.instance.removeObserver(this);
    super.dispose();
  }

  // Cải thiện cơ chế refresh data
  Future<void> _refresh() async {
    final dateString = '${date.millisecondsSinceEpoch ~/ 1000}';
    debugPrint('dateString: $dateString');
    // Lấy dữ liệu cho activity list
    BlocProvider.of<ExercrisesBloc>(currentContext).add(FetchInputExercrises(
        currentDateTime: dateString,
        periodFilterType: "0",
        page: 1));

    // Lấy dữ liệu cho progress section
    BlocProvider.of<ExercrisesBloc>(currentContext)
        .add(FetchDataDaily(currentDateTime: dateString));
  }

  void _goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pushNamed(context, NavigatorName.exercrise_dashboard);
    } else {
      BotToast.showText(
        text: 'Opps! You can not go back',
        duration: Duration(seconds: 2),
        backgroundColor: R.color.black,
        textStyle: TextStyle(color: R.color.white),
      );
    }
  }

  String formatVietnameseDate(DateTime dateTime) {
    // Danh sách các thứ bằng tiếng Việt
    const weekdays = [
      '',
      'Thứ hai',
      'Thứ ba',
      'Thứ tư',
      'Thứ năm',
      'Thứ sáu',
      'Thứ bảy',
      'Chủ nhật'
    ];

    String weekdayStr = weekdays[dateTime.weekday];
    String formattedDate = DateFormat('d/M/yyyy').format(dateTime);

    return '$weekdayStr, $formattedDate';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ExercrisesBloc>(
      create: (context) => ExercrisesBloc(),
      child: BlocBuilder<ExercrisesBloc, ExercrisesState>(
        builder: (context, state) {
          currentContext = context;
          if (state is ExercrisesInitial) {
            _refresh();
          }

          return BlocListener<ExercrisesBloc, ExercrisesState>(
            listener: (context, state) {
              if (state is ExercrisesDataLoaded) {
                setState(() {
                  inputDataExercrises = state.inputExercrisesModel;
                  hasMore = state.hasMore;
                });
              } else if (state is ExercriseDataDailyLoaded) {
                setState(() {
                  exerciseSummary = state.exercriseSummaryModel;
                  walkSummary = state.exercriseWalkSummaryModel;
                });
              } else if (state is ExercrisesError) {
                Message.showToastMessage(context, state.message);
              }
            },
            child: WillPopScope(
              onWillPop: () async {
                _goBack();
                return false;
              },
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  backgroundColor: R.color.backgroundColorNew,
                  appBar: AppBar(
                    leading: IconButton(
                        splashColor: R.color.transparent,
                        highlightColor: R.color.transparent,
                        icon: Icon(Icons.arrow_back, color: R.color.white),
                        onPressed: _goBack),
                    title: Transform(
                      transform: Matrix4.translationValues(-30, 0.0, 0.0),
                      child: Text(
                        formatVietnameseDate(date),
                        style: TextStyle(
                          color: R.color.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 20 * 0.002,
                          fontFamily: 'SFPro',
                        ),
                      ),
                    ),
                    centerTitle: true,
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                              context, NavigatorName.exercrise_guide);
                        },
                        child: Text(
                          R.string.exercrise_step_onboarding_action_btn.tr(),
                          style: TextStyle(
                            color: R.color.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'SFPro',
                          ),
                        ),
                      ),
                    ],
                    backgroundColor: R.color.transparent,
                    elevation: 0.0,
                    flexibleSpace: Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                            Color(0xFF0DAB9C),
                            Color(0xFF01847A),
                          ])),
                    ),
                  ),
                  body: RefreshIndicator(
                    onRefresh: () async => _refresh(),
                    child: _buildMainContent(state),
                  ),
                  bottomNavigationBar: KeyboardVisibilityProvider(
                    child: KeyboardVisibilityBuilder(
                      builder: (context, isKeyboardVisible) {
                        return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            height: isKeyboardVisible ? 0 : 90,
                            width: double.infinity,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: R.color.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: ButtonWidget(
                                      title: R.string.share.tr(),
                                      backgroundColor: R.color.white,
                                      borderColor: R.color.greenGradientBottom,
                                      textColor: R.color.textDark,
                                      onPressed: () {},
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 1,
                                    child: ButtonWidget(
                                      title: R.string.completed.tr(),
                                      backgroundColor: R.color.greenGradientMid,
                                      textColor: R.color.white,
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          NavigatorName.exercrise_dashboard,
                                        );
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ));
                      },
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

  Widget _buildMainContent(ExercrisesState state) {
    if (state is ExercrisesLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Section
          _buildProgressSection(),

          // Suggestion Section
          _buildSuggestionSection(),

          // Nút "Thêm vận động"
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
              child: ButtonWidget(
                title: R.string.them_hoat_dong.tr(),
                backgroundColor: R.color.white,
                textSize: 14,
                borderColor: R.color.greenGradientBottom,
                textColor: R.color.greenGradientBottom,
                wIcon: Icon(
                  Icons.add_circle_outline,
                  color: R.color.greenGradientBottom,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, NavigatorName.exercrise_add_v2);
                },
              ),
            ),
          ),
          SizedBox(height: 8.h),

          // Activity List
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: _buildActivityList(),
          ),

          SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    final containerSize = MediaQuery.of(context).size.width * 0.65;

    // Giá trị mặc định khi chưa có dữ liệu
    int completedMinutes = 0;
    int targetMinutes = 0;
    int completedCalories = 0;
    int targetCalories = 0;
    double progressPercentage = 0;

    // Nếu có dữ liệu từ API, cập nhật các giá trị
    if (exerciseSummary != null) {
      completedMinutes = exerciseSummary?.factDuration?.toInt() ?? 0;
      targetMinutes = exerciseSummary?.targetDuration?.toInt() ?? 0;
      completedCalories = exerciseSummary?.burnedCalories?.toInt() ?? 0;
      targetCalories = AppSettings.userInfo?.energyGoal?.toInt() ?? 0;

      // Tính phần trăm hoàn thành (đảm bảo không vượt quá 100%)
      progressPercentage =
          (completedMinutes / (targetMinutes > 0 ? targetMinutes : 1)) * 100;
      progressPercentage = progressPercentage > 100 ? 100 : progressPercentage;
    }

    return Container(
      padding: EdgeInsets.all(24.w),
      color: R.color.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Tiêu đề với RichText
          Padding(
            padding: EdgeInsets.all(4.w),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Bạn hoàn thành ',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: R.color.textDark,
                    ),
                  ),
                  TextSpan(
                    text: '$completedMinutes/$targetMinutes phút',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: R.color.greenGradientBottom,
                    ),
                  ),
                  TextSpan(
                    text: ' mục tiêu!',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: R.color.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Circular Progress
          Padding(
            padding: EdgeInsets.all(8.w),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularArchProgressBar(
                  value: progressPercentage,
                  strokeWidth: 28,
                  fillColor: R.color.greenGradientBottom,
                  backgroundColor: R.color.textDark.withOpacity(0.1),
                  width: containerSize,
                ),
                Positioned(
                  bottom: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$completedMinutes',
                        style: TextStyle(
                          fontSize: 55.sp,
                          fontFamily: 'SFPro',
                          fontWeight: FontWeight.bold,
                          color: R.color.textDark,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Baseline(
                        baseline: -14.sp,
                        baselineType: TextBaseline.alphabetic,
                        child: Text(
                          'Phút',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontFamily: 'SFPro',
                            color: R.color.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),

          // Calories Info
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Calories:',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: R.color.yellow,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                '$completedCalories/$targetCalories ${R.string.kcal.tr()}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: R.color.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Progress Bar for Calories
          Container(
            height: 12.h,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: R.color.textDark.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: R.color.textDark.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: (MediaQuery.of(context).size.width) *
                          (targetCalories > 0 ? completedCalories / targetCalories : 0),
                      decoration: BoxDecoration(
                        color: R.color.yellow,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSuggestionSection() {
    return Container(
      padding: EdgeInsets.all(12.w),
      color: R.color.backgroundColorNew,
      child: ExercrisesAISuggestion(
        periodFilterType: periodFilterType,
        date: DateTime.now().subtract(Duration(days: 1)),
        titleButton: R.string.roadmap_for_beginners.tr(),
      ),
    );
  }

  Widget _buildActivityList() {
    for (var i = 0; i < inputDataExercrises.length; i++) {
      for (var j = 0; j < inputDataExercrises[i].exerciseInput.length; j++) {
        if (inputDataExercrises[i].exerciseInput[j].exercise.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Text(
                'Chưa có hoạt động nào!',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: R.color.textDark,
                ),
              ),
            ),
          );
        }
      }
    }

    return Column(
      children: List.generate(inputDataExercrises.length, (index) {
        final item = inputDataExercrises[index];
        return Column(
            children: List.generate(item.exerciseInput.length, (index2) {
          return Column(
              children: List.generate(
                  item.exerciseInput[index2].exercise.length, (index3) {
            final exercise = item.exerciseInput[index2].exercise[index3];
            final exerciseInputId = item.exerciseInput[index2].id;
            String timeStr = '';
            DateTime time = DateTime.now();
            if (item.exerciseInput[index2].date != null) {
              time = DateTime.fromMillisecondsSinceEpoch(
                  item.exerciseInput[index2].date! * 1000);
              timeStr = DateFormat('HH:mm').format(time);
            }
            return _buildExerciseInputs(
              exercise,
              timeStr,
              exerciseInputId!,
              time,
            );
          }));
        }));
      }),
    );
  }

  Widget _buildExerciseInputs(
    ListExercriseModel exercise,
    String timeStr,
    String exerciseInputId,
    DateTime exerciseInputDate,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 0.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(200),
            child: Container(
              width: 48.w,
              height: 48.h,
              padding: EdgeInsets.all(8),
              color: R.color.main_1.withOpacity(0.8),
              child: NetWorkImageWidget(
                imageUrl: exercise.imageUrl.url ?? '',
                width: 48.w,
                height: 48.h,
                isSelected: true,

                /// set color white for icon
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      exercise.category ?? 'Hoạt động',
                      style: TextStyle(
                        color: R.color.greenGradientBottom,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        Icons.fiber_manual_record,
                        size: 10,
                        color: R.color.primaryGreyColor,
                      ),
                    ),
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: R.color.textDark,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  '${exercise.duration != null ? exercise.duration!.round() : 0} Phút   |   ${exercise.burnedCalorie ?? 0} ${R.string.kcal.tr()}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: R.color.textDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                NavigatorName.exercrise_add_v2,
                arguments: {
                  'isUpdate': true,
                  'exerciseInputId': exerciseInputId,
                },
              );
            },
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: R.color.greenGradientBottom.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Image.asset(
                R.drawable.ic_edit,
                width: 16.w,
                height: 16.h,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
