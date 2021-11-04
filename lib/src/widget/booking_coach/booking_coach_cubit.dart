import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/extention.dart';

import 'booking_coach.dart';

class BookingCoachCubit extends Cubit<BookingCoachState> {
  BookingCoachCubit(this.repository) : super(InitialBookingCoachState());

  final AppRepository repository;

  DateTime startDateTime = DateTime.now().goToBeginOfTheDay();
  DateTime endDateTime =
      DateTime.now().goToBeginOfTheDay().add(const Duration(hours: 1));

  bool showSelectHour = false;
  bool showSelectMinute = false;

  int startHour = 0;
  int startMinute = 0;

  void pickDate(DateTime date) {
    emit(BookingCoachLoading());
    this.startDateTime = date;
    emit(SelectedDateSuccess());
  }

  void pickTime() {
    emit(BookingCoachLoading());

    startDateTime = startDateTime.copyTime(
      hour: startHour,
      minute: startMinute,
    );

    endDateTime = startDateTime.add(const Duration(hours: 1));

    emit(SelectedDateSuccess());
  }

  void closeSelectTime() {
    showSelectHour = false;
    showSelectMinute = false;
    pickTime();
  }

  Future<void> submitBooking() async {
    emit(BookingCoachLoading());
    await Future.delayed(const Duration(seconds: 1));
    print('LOG book time $startDateTime');
    emit(BookingCoachSuccess());
  }
}
