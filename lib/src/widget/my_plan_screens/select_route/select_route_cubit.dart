import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';

import 'select_route.dart';

class SelectRouteCubit extends Cubit<SelectRouteState> {
  SelectRouteCubit(this.repository) : super(const SelectRouteInitial());

  final AppRepository repository;
  
}
