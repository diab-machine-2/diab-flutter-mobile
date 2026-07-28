import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/my_benefit_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';

part 'benefit_introduce_bundle_state.dart';

class BenefitIntroduceBundleCubit extends Cubit<BenefitIntroduceBundleState> {
  BenefitIntroduceBundleCubit(this._repository)
      : super(const BenefitIntroduceBundleInitial());

  final AppRepository _repository;
  MyBenefitData? benefitData;

  Future<void> loadMyBenefit() async {
    emit(const BenefitIntroduceBundleLoading());
    await _fetchMyBenefit();
  }

  /// Re-fetches without emitting [BenefitIntroduceBundleLoading] — used by
  /// pull-to-refresh, where [BenefitIntroduceBundlePage] already shows its
  /// own [RefreshIndicator] spinner and shouldn't be replaced by the
  /// full-page loading state.
  Future<void> refreshMyBenefit() => _fetchMyBenefit();

  Future<void> _fetchMyBenefit() async {
    final ApiResult<MyBenefitResponse> result = await _repository.getMyBenefit();
    result.when(
      success: (MyBenefitResponse response) {
        benefitData = response.data;
        emit(BenefitIntroduceBundleSuccess(benefitData));
      },
      failure: (NetworkExceptions error) {
        emit(BenefitIntroduceBundleFailure(
            NetworkExceptions.getErrorMessage(error)));
      },
    );
  }
}
