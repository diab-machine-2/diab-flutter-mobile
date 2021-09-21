import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';

import 'list_service.dart';

class ListServiceCubit extends Cubit<ListServiceState> {

  final AppRepository appRepository;

  ListServiceCubit(this.appRepository) : super(ListServiceInitial());

}
