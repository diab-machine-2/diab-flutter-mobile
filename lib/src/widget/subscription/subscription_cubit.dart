import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/notify_subscription_request.dart';
import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/response/get_subscription_banners_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/widget/subscription/model/subscription_banner_model.dart';
import 'package:medical/src/widget/subscription/model/subscription_package_model.dart';
import 'package:medical/src/widget/subscription/services/revenue_cat_service.dart';
import 'package:medical/src/widget/subscription/subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final AppRepository repository;

  SubscriptionCubit(this.repository) : super(SubscriptionInitial());

  bool hasActiveSubscription = false;
  List<BannerModel> banners = [];
  bool isBannersLoaded = false;
  SubscriptionPackage? selectedPackage;

  void setSelectedPackage(SubscriptionPackage package) {
    selectedPackage = package;
  }

  Future<void> checkSubscriptionStatus() async {
    try {
      emit(SubscriptionLoading());

      // Check if user has an active subscription
      hasActiveSubscription = await RevenueCatService.hasActiveSubscription();

      // Load banners if not already loaded
      if (!isBannersLoaded) {
        await getSubscriptionBanners();
        // await fetchBanners();
      }

      emit(SubscriptionSuccess(banners: banners));
    } catch (e) {
      emit(SubscriptionFailure(error: e.toString()));
    }
  }

  String getTitlePackage() {
    if (selectedPackage == null) {
      return R.string.basic_program.tr();
    }

    if (selectedPackage?.id == 'dong_hanh') {
      return R.string.chuong_trinh_dong_hanh.tr();
    } else if (selectedPackage?.id == 'thau_cam') {
      return R.string.chuong_trinh_thau_cam.tr();
    } else {
      return R.string.basic_program.tr();
    }
  }

  // Future<void> fetchBanners() async {
  //   try {
  //     // Mock API call to fetch banners
  //     // In real implementation, replace with actual API endpoint
  //     await Future.delayed(
  //         Duration(milliseconds: 800)); // Simulate network delay

  //     // Mock response
  //     final mockResponse = {
  //       'success': true,
  //       'data': [
  //         {
  //           'value':
  //               'https://res.cloudinary.com/ddcgjzunn/image/upload/v1744168214/img/slkjblk70nukttd7xonb.png',
  //           'title': 'Giảm HbA1c, ổn định đường huyết',
  //           'subtitle': 'Đã được chứng minh lâm sàng',
  //           'order': 1
  //         },
  //         {
  //           'value':
  //               'https://res.cloudinary.com/ddcgjzunn/image/upload/v1744168215/img/szzmzwy6yjorkjnbseei.png',
  //           'title': 'Ngăn ngừa bệnh và biến chứng',
  //           'subtitle': '',
  //           'order': 2
  //         },
  //         {
  //           'value':
  //               'https://res.cloudinary.com/ddcgjzunn/image/upload/v1744168215/img/ygv0eblyejhgyomsigtb.png',
  //           'title': 'Cải thiện chất lượng cuộc sống',
  //           'subtitle': '',
  //           'order': 3
  //         }
  //       ]
  //     };

  //     // Parse response
  //     final List<dynamic> bannersData = mockResponse['data'] as List<dynamic>;
  //     banners = bannersData
  //         .map((bannerData) => BannerModel.fromJson(bannerData))
  //         .toList();

  //     // Sort banners by order
  //     banners.sort((a, b) => a.order.compareTo(b.order));
  //     isBannersLoaded = true;
  //   } catch (e) {
  //     print('Error fetching banners: $e');
  //     // If API fails, use default banners
  //     _useDefaultBanners();
  //   }
  // }

  Future<void> getSubscriptionBanners() async {
    try {
      final ApiResult<GetSubscriptionBannersResponse> apiResult =
          await repository.getSubscriptionBanners();
      apiResult.when(success: (GetSubscriptionBannersResponse response) {
        banners = response.data;
        // Sort banners by order
        banners.sort((a, b) => a.order.compareTo(b.order));
        isBannersLoaded = true;
      }, failure: (NetworkExceptions error) {
        _useDefaultBanners();
        emit(SubscriptionFailure(error: "Lỗi khi lấy banner"));
      });
    } catch (e) {
      print('Error fetching banners: $e');
      _useDefaultBanners();
    }
  }

  Future<void> notifySubscriptionSuccess(
      NotifySubscriptionRequest request) async {
    final ApiResult<CommonResponse> apiResult =
        await repository.notifySubscription(request);
    apiResult.when(success: (CommonResponse response) async {
      return;
    }, failure: (NetworkExceptions error) {
      emit(SubscriptionFailure(error: "Xác nhận tiếp nhận tư vấn thất bại"));
    });
  }

  void _useDefaultBanners() {
    // Fallback to default banners if API fails
    banners = [
      BannerModel(
        value: R.drawable.subscription_program_1,
        title: 'Giảm HbA1c, ổn định đường huyết',
        subtitle: 'Đã được chứng minh lâm sàng',
        order: 1,
      ),
      BannerModel(
        value: R.drawable.subscription_program_2,
        title: 'Ngăn ngừa bệnh và biến chứng',
        subtitle: '',
        order: 2,
      ),
      BannerModel(
        value: R.drawable.subscription_program_3,
        title: 'Cải thiện chất lượng cuộc sống',
        subtitle: '',
        order: 3,
      ),
    ];
    isBannersLoaded = true;
  }
}
