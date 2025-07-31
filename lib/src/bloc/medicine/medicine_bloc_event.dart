part of 'medicine_bloc.dart';

@immutable
abstract class MedicineEvent {}

class SearchMedicineEvent extends MedicineEvent {
  final String searchText;
  SearchMedicineEvent(this.searchText);
}