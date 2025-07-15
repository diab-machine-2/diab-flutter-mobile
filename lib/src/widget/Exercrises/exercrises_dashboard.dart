import 'dart:async';
import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/firebase_tracking/activity_list_tracking.dart';
import 'package:medical/src/utils/app_log.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Exercrises/widget/exercrises_lesson.dart';
import 'package:medical/src/widget/Exercrises/widget/exercrises_lesson_section.dart';
import 'package:medical/src/widget/Exercrises/widget/exercrises_trend_calo_chart.dart';
import 'package:medical/src/widget/Exercrises/widget/exercrises_trend_time_chart.dart';
import 'package:medical/src/widget/Food/widget/food_chart.dart';
import 'package:medical/src/widget/Exercrises/widget/health_connect_button.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/home/fliter_enum.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/lesson_detail.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widget/Exercrises/widget/filter_segment_button.dart';
import '../../../../../res/R.dart';
import '../../utils/app_storages.dart';

class ExercriseDashboard extends StatefulWidget {
  const ExercriseDashboard({Key? key}) : super(key: key);

  @override
  _ExercriseDashboardState createState() => _ExercriseDashboardState();
}

class _ExercriseDashboardState extends State<ExercriseDashboard>
    with WidgetsBindingObserver, Observer {
  GlobalKey<FoodChartState> foodChartKey = GlobalKey();
  GlobalKey<ExercrisesTrendCaloChartState> caloChartKey = GlobalKey();
  GlobalKey<ExercrisesTrendTimeChartState> exercrisesTrendTimeChartKey =
      GlobalKey();
  GlobalKey<ExercrisesLessonSectionState> exercrisesLessonKey = GlobalKey();
  bool _isLoading = true;
  int periodFilterType = 0;
  bool isConnectHealthApp = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkConnectHealthApp();
    });
    firebaseSetup();
    _initPeriodFilterType();
  }

  Future firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
        screenName: "exercrise-dashboard", screenClass: "ExercriseDashboard");
    AppSettings.currentScreenName = 'exercrise-dashboard';
  }

  @override
  void update(
      Observable observable, String? notifyName, Map<dynamic, dynamic>? map) {
    if (notifyName == 'active_change_data_v2') {
      // overViewKey.currentState!.reloadData(periodFilterType);
    }
  }

  @override
  void dispose() {
    Observable.instance.removeObserver(this);
    AppSettings.syncDataFromHealthApp().catchError((error) {
      Console.log('Error during sync: $error');
    }).whenComplete(() {
      super.dispose();
    });
  }

  Future<void> checkConnectHealthApp() async {
    bool? hasHealthConnection = await AppStorages.getHealthAppPermission();
    if (hasHealthConnection == true) {
      isConnectHealthApp = true;
    } else {
      isConnectHealthApp = false;
    }
    setState(() {});
  }

  void _goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        NavigatorName.tabbar,
        (route) => false,
      );
    } else {
      BotToast.showText(
        text: 'Opps! You can not go back',
        duration: Duration(seconds: 2),
        backgroundColor: R.color.black,
        textStyle: TextStyle(color: R.color.white),
      );
    }
  }

  _initPeriodFilterType() async {
    final periodFilterTypeStr =
        await AppSettings.getPeriodByScreen(ScreenList.EXERCISE.index);
    final newFilterType = (int.tryParse(periodFilterTypeStr) ?? 0) > 0
        ? (int.tryParse(periodFilterTypeStr) ?? 0)
        : 0;
    // Update the state after the async operation
    setState(() {
      periodFilterType = newFilterType;
      reloadData(newFilterType);
    });
  }

  reloadData(int periodFilterType) {
    if (caloChartKey.currentState != null) {
      caloChartKey.currentState!.reloadData(periodFilterType);
    } else {
      Console.log('caloChartKey.currentState is null');
    }
    if (foodChartKey.currentState != null) {
      foodChartKey.currentState!.reloadData(periodFilterType);
    } else {
      Console.log('foodChartKey.currentState is null');
    }
    if (exercrisesTrendTimeChartKey.currentState != null) {
      exercrisesTrendTimeChartKey.currentState!.reloadData(periodFilterType);
    } else {
      Console.log('exercrisesTrendTimeChartKey.currentState is null');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
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
            leadingWidth: 30,
            leading: IconButton(
                splashColor: R.color.transparent,
                highlightColor: R.color.transparent,
                icon: Icon(Icons.arrow_back, color: R.color.white),
                onPressed: _goBack),
            title: Align(
              alignment: Alignment.topLeft,
              child: Text(
                R.string.exercise.tr(),
                style: TextStyle(
                  color: R.color.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 20 * 0.002,
                ),
              ),
            ),
            actions: [
              Container(
                margin: EdgeInsets.only(right: 8),
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, NavigatorName.exercrise_guide);
                  },
                  child: Text(
                    R.string.exercrise_step_onboarding_action_btn.tr(),
                    style: TextStyle(
                      color: R.color.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
            backgroundColor: R.color.transparent, //No more green
            elevation: 0.0, //Shadow gone
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
          body: _buildContainer(),
        ),
      ),
    );
  }

  void _navigateToLessonDetail(String? id, int type) async {
    ActivityListTracking.clickLessonItem(
      objectId: id,
      objectIndex: null,
      objectTitle: null,
    );

    await NavigationUtil.navigatePage(
      context,
      LessonDetailPage(
        lessonType: type,
        lessonId: id ?? '',
        onComplete: (_, __) {},
      ),
    );
  }

  Widget _buildContainer() {
    return Stack(
      children: [
        ListView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.only(
              bottom: 80, top: 70), // Add padding for the button
          children: [
            periodFilterType > 0
                ? ExercrisesTrendTimeChart(
                    key: exercrisesTrendTimeChartKey,
                    periodFilterType: periodFilterType,
                    filterName: 'filter_name',
                    onFilterChanged: () {
                      Message.showToastMessage(context, 'Filter changed');
                    },
                    onViewListing: _viewListing,
                  )
                : const SizedBox(),
            const SizedBox(height: 16),
            ExercrisesTrendCaloChart(
              key: caloChartKey,
              showAddButton: false,
              gutterGhost: true,
              periodFilterType: periodFilterType,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ExercrisesLessonSection(
                key: exercrisesLessonKey,
                onLessonTap: (lesson) => _navigateToLessonDetail(
                    lesson.id, lesson.name == 'exercise' ? 1 : 2),
              ),
            ),
            if (!isConnectHealthApp)
              HealthConnectButton(
                callback: () {
                  print('HealthConnectButton pressed');
                  checkConnectHealthApp();
                },
              ),
          ],
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: FilterSegmentButton(
            initialFilterType: periodFilterType,
            onFilterChanged: (newFilterType) {
              setState(() {
                periodFilterType = newFilterType;
                reloadData(periodFilterType);
              });
            },
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            // height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            child: ButtonWidget(
              title: R.string.nhap_chi_so_van_dong.tr(),
              onPressed: () {
                Navigator.pushNamed(context, NavigatorName.exercrise_add_v2);
              },
            ),
          ),
        )
      ],
    );
  }

  void _viewListing() {
    Message.showToastMessage(context, 'View listing');
  }
}
