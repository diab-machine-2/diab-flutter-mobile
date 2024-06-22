import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/home/home_model.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/smart_goal_list_reponse.dart';
import 'package:medical/src/repo/home/home_client.dart';
import 'package:medical/src/repo/learning/learning_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/home/schema/measurement_schema.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/activity_tab/models/schedule_type.dart';
import 'package:meta/meta.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:easy_localization/easy_localization.dart';

part 'home_bloc_event.dart';
part 'home_bloc_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial());
  final timeToRetry = 10;

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {
    if (event is FetchHome) {
      yield* _fetchHomes();
    }
    // if (event is SyncHealthApp) {
    //   yield* _syncHealthApp();
    // }
  }

  Stream<HomeState> _fetchHomes() async* {
    final repository = AppRepository();
    final client = HomeClient();

    int retry = 1;
    while (retry <= 10) {
      try {
        // Load cached home data
        final cachedHome = await AppSettings.getHome();
        if (cachedHome != null) {
          cachedHome.utilities = client.getUtilities(full: false);
        }
        yield HomeLoading(model: cachedHome);

        // Load home data from server
        final home = await client.fetchHomes();
        yield HomeLoaded(model: home);

        // load today target
        final currentDay = 0;
        final currentWeek = 1;
        final apiResult = await repository.getListSmartGoal(day: currentDay, week: currentWeek);
        apiResult.when(
          success: (SmartGoalListReponse response) {
            if (response.data?.daily != null) {
              final activities =
                  response.data!.daily!.where((e) => e != null).map((e) => e!).map((e) {
                final ScheduleType type = ScheduleTypeExtend.getTypeFromIndex(e.type);
                // TODO: Map to icon
                return HomeActivityData(
                  icon: R.drawable.ic_home_activity,
                  title: e.name ?? "-",
                  description: e.description,
                );
              }).toList();
              home.activities = activities;
            }
          },
          failure: (error) {},
        );
        yield HomeLoaded(model: home);

        final remindersResponse = await UserClient().fetchScheduleReminders();
        if (remindersResponse.models.isNotEmpty) {
          final reminders = remindersResponse.models.map((e) {
            return HomeReminderData(
              icon: R.drawable.ic_home_measurement_glucose_inactive,
              title: e.name ?? "-",
              time: "today",
              // TODO: Map to navigator
              navigatorName: "TODO",
            );
          }).toList();
          home.reminders = reminders;
        }
        AppSettings.saveHome(home.toJson()).catchError((e) {
          print(e);
          return true;
        });
        yield HomeLoaded(model: home);

        // Learning post
        final lessonsResponse = await LearningClient().fetchLearningPost(null);
        if (lessonsResponse.isNotEmpty) {
          final lessons = lessonsResponse.map((e) {
            return HomeLessonData(
              id: e.id!,
              icon: R.drawable.ic_lesson_category,
              category: "Bài học",
              title: e.title,
              imageUrl: e.imageUrl.url,
            );
          }).toList();
          home.lessons = lessons;
        }
        yield HomeLoaded(model: home);

        break; // Break the loop if successful
      } catch (e, _) {
        if (e is Error) {
          await Future.delayed(Duration(seconds: timeToRetry));
        } else {
          yield HomeError(message: R.string.error_can_not_connect_to_server.tr());
          break; // Break the loop if a non-retryable error occurs
        }
      }
      retry++;
    }

    if (retry == 10) {
      yield HomeError(message: "Maximum retry limit reached");
    }
  }

  List<HomeUtilityData> getAllUtilities() {
    return HomeClient().getUtilities(full: true);
  }

  List<HomeMeasurementIndex> getAllMeasurements() {
    return [
      HomeMeasurementIndex(
        title: R.string.duong_huyet.tr(),
        icon: R.drawable.ic_home_measurement_glucose,
        navigatorName: NavigatorName.add_blood_sugar_new,
        args: {'type': 'input'},
      ),
      HomeMeasurementIndex(
        title: R.string.huyet_ap.tr(),
        icon: R.drawable.ic_home_measurement_blood,
        navigatorName: NavigatorName.add_blood_pressure,
        args: {'type': 'input', 'id': null},
      ),
      HomeMeasurementIndex(
        title: R.string.van_dong.tr(),
        icon: R.drawable.ic_home_measurement_exercise,
        navigatorName: NavigatorName.add_exercrises,
        args: {'type': 'input'},
      ),
      HomeMeasurementIndex(
        title: R.string.dinh_duong.tr(),
        icon: R.drawable.ic_home_measurement_nutrition,
        navigatorName: NavigatorName.add_nutrition,
      ),
      HomeMeasurementIndex(
        title: R.string.cam_xuc.tr(),
        icon: R.drawable.ic_home_measurement_emotion,
        navigatorName: NavigatorName.add_emo,
        args: {'type': 'input', 'id': null},
      ),
      HomeMeasurementIndex(
        title: R.string.hba1c.tr(),
        icon: R.drawable.ic_home_measurement_hb1ac,
        navigatorName: NavigatorName.add_hba1c,
        args: {'type': 'input', 'id': null},
      ),
      HomeMeasurementIndex(
        title: R.string.can_nang.tr(),
        icon: R.drawable.ic_home_measurement_weight,
        navigatorName: NavigatorName.add_bmi,
        args: {'type': 'input', 'id': null},
      ),
    ];
  }

  // Stream<HomeState> _syncHealthApp() async* {}
}
