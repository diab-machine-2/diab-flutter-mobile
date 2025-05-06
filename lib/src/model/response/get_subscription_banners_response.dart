import 'package:medical/src/widget/subscription/model/subscription_banner_model.dart';

class GetSubscriptionBannersResponse {
  final List<BannerModel> data;

  GetSubscriptionBannersResponse({
    required this.data,
  });

  factory GetSubscriptionBannersResponse.fromJson(Map<String, dynamic> json) {
    return GetSubscriptionBannersResponse(
      data: (json['data'] as List?)
              ?.map((e) => BannerModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
