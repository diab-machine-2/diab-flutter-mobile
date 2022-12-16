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

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {
    if (event is FetchHome) {
      yield* _fetchHomes();
    }
    if (event is SyncHealthApp) {
      yield* _syncHealthApp();
    }
  }

  Stream<HomeState> _fetchHomes() async* {
    try {
      final client = HomeClient();

      yield HomeLoading(model: await AppSettings.getHome());
      yield HomeLoaded(model: await client.fetchHomes());
    } catch (e, _) {
      if (e is Error) {
        yield HomeError(message: e.message);
      } else {
        yield HomeError(message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<HomeState> _syncHealthApp() async* {
    
  }
}
