import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';

import 'upgrade_account.dart';

class UpgradeAccountCubit extends Cubit<UpgradeAccountState> {

  final AppRepository appRepository;

  UpgradeAccountCubit(this.appRepository) : super(UpgradeAccountInitial());

}
