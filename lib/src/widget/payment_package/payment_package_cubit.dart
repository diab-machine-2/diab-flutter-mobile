import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';

import 'payment_package.dart';

class PaymentPackageCubit extends Cubit<PaymentPackageState> {

  final AppRepository appRepository;
  int? selectedIndex;

  PaymentPackageCubit(this.appRepository) : super(PaymentPackageInitial());

  void selectOption(int index) {
    emit(PaymentPackageLoading());
    selectedIndex = index;
    emit(PaymentPackageInitial());
  }

}
