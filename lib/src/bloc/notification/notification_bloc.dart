import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:medical/src/modal/notification/notification_data_model.dart';
import 'package:medical/src/repo/notification/notification_client.dart';
import 'package:meta/meta.dart';
import 'package:medical/src/modal/error/error_model.dart';
part 'notification_bloc_event.dart';
part 'notification_bloc_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {

  NotificationBloc() : super(NotificationInitial());

  @override
  Stream<NotificationState> mapEventToState(NotificationEvent event) async* {
    if (event is FetchNotification) {
      yield* fetchNotifications(event.isRead, event.page);
    }
  }

  Stream<NotificationState> fetchNotifications(bool isRead, int page) async* {
    try {
      final client = NotificationClient();
      final currenState = state;
      // yield HbA1CLoading();
      var model = await client.fetchNotifications(isRead, page);

      if (currenState is NotificationLoaded) {
        if (currenState.model != null && page != 1) {
          model.models.insertAll(0, currenState.model.models);
        }
      }
      yield NotificationLoaded(model: model);
    } catch (e, _) {
      if (e is Error) {
        yield NotificationError(message: e.message);
      } else {
        yield NotificationError(
            message:
                'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi');
      }
    }
  }
}
