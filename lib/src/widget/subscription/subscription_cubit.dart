import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/subscription/model/subscription_banner_model.dart';
import 'package:medical/src/widget/subscription/services/revenue_cat_service.dart';
import 'package:medical/src/widget/subscription/subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit() : super(SubscriptionInitial());

  bool hasActiveSubscription = false;
  List<BannerModel> banners = [];
  bool isBannersLoaded = false;

  Future<void> checkSubscriptionStatus() async {
    try {
      emit(SubscriptionLoading());

      // Check if user has an active subscription
      hasActiveSubscription = await RevenueCatService.hasActiveSubscription();

      // Load banners if not already loaded
      if (!isBannersLoaded) {
        await fetchBanners();
      }

      emit(SubscriptionSuccess(banners: banners));
    } catch (e) {
      emit(SubscriptionFailure(error: e.toString()));
    }
  }

  Future<void> fetchBanners() async {
    try {
      // Mock API call to fetch banners
      // In real implementation, replace with actual API endpoint
      await Future.delayed(
          Duration(milliseconds: 800)); // Simulate network delay

      // Mock response
      final mockResponse = {
        'success': true,
        'data': [
          {
            'id': '1',
            'image_url':
                'https://res.cloudinary.com/ddcgjzunn/image/upload/v1742441889/img/fcavyltz5g1ud91jp8zv.png',
            'title': 'Giảm HbA1c,\nngừa biến chứng',
            'order': 1
          },
          {
            'id': '2',
            'image_url':
                'https://res.cloudinary.com/ddcgjzunn/image/upload/v1742441889/img/on4igf1bndvphozbdyog.png',
            'title': 'Giảm 5% cân nặng\nphòng ngừa bệnh',
            'order': 2
          },
          {
            'id': '3',
            'image_url':
                'https://res.cloudinary.com/ddcgjzunn/image/upload/v1742441888/img/ox61ixkraw609yellkbf.png',
            'title': 'Đạt thành tựu\nkhoa học',
            'order': 3
          }
        ]
      };

      // Parse response
      final List<dynamic> bannersData = mockResponse['data'] as List<dynamic>;
      banners = bannersData
          .map((bannerData) => BannerModel.fromJson(bannerData))
          .toList();

      // Sort banners by order
      banners.sort((a, b) => a.order.compareTo(b.order));
      isBannersLoaded = true;
    } catch (e) {
      print('Error fetching banners: $e');
      // If API fails, use default banners
      _useDefaultBanners();
    }
  }

  // // Actual API implementation (Replace mock with this for production)
  // Future<void> _fetchBannersFromApi() async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse('${AppSettings.apiBaseUrl}/banners'),
  //       headers: {
  //         'Authorization': 'Bearer ${AppSettings.authToken}',
  //         'Content-Type': 'application/json',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> data = json.decode(response.body);
  //       final List<dynamic> bannersData = data['data'] as List<dynamic>;
  //       banners = bannersData
  //           .map((bannerData) => BannerModel.fromJson(bannerData))
  //           .toList();

  //       // Sort banners by order
  //       banners.sort((a, b) => a.order.compareTo(b.order));
  //       isBannersLoaded = true;
  //     } else {
  //       throw Exception('Failed to load banners');
  //     }
  //   } catch (e) {
  //     print('Error fetching banners: $e');
  //     _useDefaultBanners();
  //   }
  // }

  void _useDefaultBanners() {
    // Fallback to default banners if API fails
    banners = [
      BannerModel(
        id: '1',
        imageUrl: R.drawable.subscription_program_1,
        title: 'Giảm HbA1c,\nngừa biến chứng',
        order: 1,
      ),
      BannerModel(
        id: '2',
        imageUrl: R.drawable.subscription_program_2,
        title: 'Giảm 5% cân nặng\nphòng ngừa bệnh',
        order: 2,
      ),
      BannerModel(
        id: '3',
        imageUrl: R.drawable.subscription_program_3,
        title: 'Đạt thành tựu\nkhoa học',
        order: 3,
      ),
    ];
    isBannersLoaded = true;
  }
}
