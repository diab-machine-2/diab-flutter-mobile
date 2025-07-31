part of 'medicine_bloc.dart';

@immutable
abstract class MedicineState extends Equatable {
  const MedicineState();

  @override
  List<Object> get props => [];
}

class MedicineInitial extends MedicineState {}

class MedicineNoData extends MedicineState {}

class MedicineError extends MedicineState {
  final String? message;

  MedicineError({
    required this.message,
  });
}

class MedicineLoading extends MedicineState {

}

class MedicineLoaded extends MedicineState {
  
}

class MedicineSearchSuccess extends MedicineState {
  final SearchMedicineResultModel? searchResult;

  MedicineSearchSuccess(this.searchResult);
}

