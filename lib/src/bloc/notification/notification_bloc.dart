import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/notification/notification_data_model.dart';
import 'package:medical/src/repo/notification/notification_client.dart';
import 'package:meta/meta.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:easy_localization/easy_localization.dart';

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

  Stream<NotificationState> fetchNotifications(bool? isRead, int page) async* {
    try {
      final client = NotificationClient();
      final NotificationState currenState = state;
      // yield HbA1CLoading();
      var model = await client.fetchNotifications(isRead, page);

      if (currenState is NotificationLoaded) {
        if (currenState.model != null && page != 1) {
          model!.models.insertAll(0, currenState.model!.models);
        }
      }
      yield NotificationLoaded(model: model);
    } catch (e, _) {
      if (e is Error) {
        yield NotificationError(message: e.message);
      } else {
        yield NotificationError(
            message:
                R.string.error_can_not_connect_to_server.tr());
      }
    }
  }
}
