import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';

import 'food_menu.dart';

class FoodMenuCubit extends Cubit<FoodMenuState> {
  FoodMenuCubit(this.repository) : super(const FoodMenuInitial());

  final AppRepository repository;
}
