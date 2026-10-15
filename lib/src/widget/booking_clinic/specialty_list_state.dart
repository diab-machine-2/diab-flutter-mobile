part of 'specialty_list_cubit.dart';

sealed class SpecialtyListState {
  const SpecialtyListState();
}

class SpecialtyListInitial extends SpecialtyListState {
  const SpecialtyListInitial();
}

class SpecialtyListLoading extends SpecialtyListState {
  const SpecialtyListLoading();
}

class SpecialtyListSuccess extends SpecialtyListState {
  final List<ClinicSpecialty> specialties;

  const SpecialtyListSuccess(this.specialties);
}

class SpecialtyListError extends SpecialtyListState {
  final String message;

  const SpecialtyListError(this.message);
}
