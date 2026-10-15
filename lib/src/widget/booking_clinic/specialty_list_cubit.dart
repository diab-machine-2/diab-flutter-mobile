import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/widget/booking_clinic/model/clinic_specialty_model.dart';
import 'package:medical/src/widgets/specialty_catalog.dart';

part 'specialty_list_state.dart';

typedef SpecialtyArranger = List<ClinicSpecialty> Function(
  List<ClinicSpecialty> specialties, {
  required bool isTelemedicine,
});

/// Specialty list of the Home daily-care booking flows ("Khám tại phòng
/// khám" / "Khám từ xa"): the same `diseases-configuration-diab` list, Remote
/// Config filter and order as the benefit flow.
///
/// Kept apart from [DsmesAppointmentCubit] so loading the grid doesn't toggle
/// that cubit's page-wide loading toast, and so its `isBenefitFlow` endpoint
/// switch stays untouched.
class SpecialtyListCubit extends Cubit<SpecialtyListState> {
  SpecialtyListCubit(
    this._repository, {
    required this.isTelemedicine,
    this.arrange = SpecialtyCatalog.forBooking,
  }) : super(const SpecialtyListInitial());

  final AppRepository _repository;
  final bool isTelemedicine;
  final SpecialtyArranger arrange;

  Future<void> load() async {
    if (state is SpecialtyListLoading) return;
    emit(const SpecialtyListLoading());
    final result = await _repository.getCLinicSpecialtyListDiab();
    if (isClosed) return;
    result.when(
      success: (response) {
        List<ClinicSpecialty> specialties;
        try {
          specialties = arrange(response.data, isTelemedicine: isTelemedicine);
        } catch (_) {
          // Remote Config not ready (late fields): show the API order rather
          // than a skeleton stuck forever.
          specialties = response.data;
        }
        emit(SpecialtyListSuccess(specialties));
      },
      failure: (error) =>
          emit(SpecialtyListError(NetworkExceptions.getErrorMessage(error))),
    );
  }
}
