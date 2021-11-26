import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';

import 'my_booking.dart';

class MyBookingCubit extends Cubit<MyBookingState> {
  final AppRepository repository;
  DateTime? selectedDate;
  String? selectedTime;

  MyBookingCubit(this.repository) : super(InitialMyBookingState());

  void pickDate(DateTime date) {
    emit(MyBookingLoading());
    this.selectedDate = date;
    emit(SelectedDateSuccess());
  }

  void pickTime(String time) {
    emit(MyBookingLoading());
    this.selectedTime = time;
    emit(InitialMyBookingState());
  }
}
