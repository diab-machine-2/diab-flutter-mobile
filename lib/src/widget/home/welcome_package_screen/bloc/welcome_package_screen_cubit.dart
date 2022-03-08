import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../model/repository/app_repository.dart';
import '../../../../model/request/complete_smart_goal_request.dart';
import '../../../../model/request/read_welcome_request.dart';
import '../../../../model/response/common_response.dart';
import '../../../../model/service/api_result.dart';
import '../../../../model/service/network_exceptions.dart';
import '../welcome_package_screen.dart';

class WelcomePackageScreenCubit extends Cubit<WelcomePackageScreenState> {

  final AppRepository repository;

  WelcomePackageScreenCubit(this.repository): super(WelcomePackageScreenInitial()) {
    
  }

   Future<void> markDisplayedWelcome() async {
    emit(WelcomePackageScreenLoading());
    // final ReadWelcomeRequest request =
    //     ReadWelcomeRequest(id: '');
    final ApiResult<CommonResponse> apiResult = await repository.markDisplayedWelcome();
    apiResult.when(success: (CommonResponse response) {
       emit(const WelcomePackageScreenSuccess());
    }, failure: (NetworkExceptions error) {
      emit(WelcomePackageScreenFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }
}