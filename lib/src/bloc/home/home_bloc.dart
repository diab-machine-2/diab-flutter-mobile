import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/home/home_model.dart';
import 'package:medical/src/repo/home/home_client.dart';
import 'package:meta/meta.dart';
import 'package:medical/src/modal/error/error_model.dart';
part 'home_bloc_event.dart';
part 'home_bloc_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  @override
  HomeState get initialState => HomeInitial();

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {
    if (event is FetchHome) {
      yield* _fetchHomes();
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
        yield HomeError(
            message:
                'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi');
      }
    }
  }
}
