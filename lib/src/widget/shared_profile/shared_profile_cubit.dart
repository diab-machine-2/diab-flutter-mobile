import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';

import 'shared_profile.dart';

class SharedProfileCubit extends Cubit<SharedProfileState> {
  SharedProfileCubit(this.repository) : super(const SharedProfileInitial());

  final AppRepository repository;
}
