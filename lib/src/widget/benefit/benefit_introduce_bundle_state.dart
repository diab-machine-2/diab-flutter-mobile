part of 'benefit_introduce_bundle_cubit.dart';

abstract class BenefitIntroduceBundleState {
  const BenefitIntroduceBundleState();
}

class BenefitIntroduceBundleInitial extends BenefitIntroduceBundleState {
  const BenefitIntroduceBundleInitial();
}

class BenefitIntroduceBundleLoading extends BenefitIntroduceBundleState {
  const BenefitIntroduceBundleLoading();
}

class BenefitIntroduceBundleSuccess extends BenefitIntroduceBundleState {
  const BenefitIntroduceBundleSuccess(this.data);
  final MyBenefitData? data;
}

class BenefitIntroduceBundleFailure extends BenefitIntroduceBundleState {
  const BenefitIntroduceBundleFailure(this.message);
  final String message;
}
