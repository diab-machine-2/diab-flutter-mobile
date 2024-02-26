import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/home/home_model.dart';
import 'package:medical/src/repo/home/home_client.dart';
import 'package:meta/meta.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:easy_localization/easy_localization.dart';

part 'home_bloc_event.dart';
part 'home_bloc_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial());
  final timeToRetry = 5;

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
    int retry = 1;
    while (retry <= 10) {
      try {
        final client = HomeClient();

        yield HomeLoading(model: await AppSettings.getHome());
        yield HomeLoaded(model: await client.fetchHomes());
        break; // Break the loop if successful
      } catch (e, _) {
        if (e is Error) {
          await Future.delayed(Duration(seconds: timeToRetry));
        } else {
          yield HomeError(
              message: R.string.error_can_not_connect_to_server.tr());
          break; // Break the loop if a non-retryable error occurs
        }
      }
      retry++;
    }

    if (retry == 10) {
      yield HomeError(message: "Maximum retry limit reached");
    }
  }

  Stream<HomeState> _syncHealthApp() async* {
    
  }
}
