import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/subscription/model/subscription_banner_model.dart';
import 'package:medical/src/widget/subscription/pages/paywall_screen.dart';
import 'package:medical/src/widget/subscription/services/revenue_cat_service.dart';
import 'package:medical/src/widget/subscription/subscription_cubit.dart';
import 'package:medical/src/widget/subscription/subscription_payment_state.dart';
import 'package:medical/src/widget/subscription/subscription_state.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/subscription/subscription_tracking.dart';
import 'package:medical/src/widgets/gap_widget.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> with Observer {
  late SubscriptionCubit _cubit;
  int _currentCarouselIndex = 0;
  final CarouselController _carouselController = CarouselController();

  // Subscription state
  CustomerInfo? customerInfo;
  String packageTitle = '';
  SubscriptionPaymentState? subscriptionState;

  // Fallback carousel data in case API fails
  final List<Map<String, dynamic>> _fallbackCarouselItems = [
    {
      'image': R.drawable.subscription_image_1,
      'title': 'Giảm HbA1c, ổn định đường huyết',
      'subtitle': 'Đã được chứng minh lâm sàng',
    },
    {
      'image': R.drawable.subscription_image_2,
      'title': 'Ngăn ngừa bệnh và biến chứng',
      'subtitle': '',
    },
    {
      'image': R.drawable.subscription_image_3,
      'title': 'Cải thiện chất lượng cuộc sống',
      'subtitle': '',
    },
  ];

  @override
  void initState() {
    super.initState();
    Observable.instance.addObserver(this);
    try {
      // Try to get the cubit from context
      _cubit = context.read<SubscriptionCubit>();
      // Check if we need to load data
      if (_cubit.state is SubscriptionInitial || !_cubit.isBannersLoaded) {
        _cubit.checkSubscriptionStatus();
      }
    } catch (e) {
      // If reading from context fails, create a new cubit
      print('Error accessing SubscriptionCubit: $e');
      _cubit = SubscriptionCubit(AppRepository());
      _cubit.checkSubscriptionStatus();
    }

    initSubscriptionState();
  }

  void initSubscriptionState() async {
    final accountId = AppSettings.userInfo?.accountId ?? '';
    if (accountId.isEmpty) {
      return;
    }

    try {
      // Login to RevenueCat with the user's accountId
      log('[SUBSCRIPTION] revenueCate login accountId: $accountId');
      await RevenueCatService.login(accountId);

      // Get the latest customer info
      customerInfo = await RevenueCatService.getCustomerInfo();
      log('[SUBSCRIPTION] customerInfo: $customerInfo');

      // Check subscription state
      subscriptionState = await checkSubscriptionPaymentState();

      // Update UI with current subscription info
      final offering = await RevenueCatService.getCurrentOffering();
      if (offering != null) {
        packageTitle = await getActiveSubscriptionDescription();
        if (mounted) setState(() {});
      }

      log('[SUBSCRIPTION] customerInfo activeSubscriptions: ${customerInfo?.activeSubscriptions}');
      log('[SUBSCRIPTION] customerInfo entitlements: ${customerInfo?.entitlements}');
      log('[SUBSCRIPTION] subscriptionState: ${subscriptionState?.expirationDate?.toLocal()}');

      // Set up a listener for subscription changes
      Purchases.addCustomerInfoUpdateListener((info) {
        if (mounted) {
          setState(() {
            customerInfo = info;
            _updateSubscriptionStatus();
          });
        }
      });
    } catch (e) {
      print("RevenueCat login error: $e");
    }
  }

  void _updateSubscriptionStatus() async {
    try {
      // Update subscription state
      subscriptionState = await checkSubscriptionPaymentState();

      final offering = await RevenueCatService.getCurrentOffering();
      if (offering != null) {
        packageTitle = await getActiveSubscriptionDescription();
        if (mounted) setState(() {});
      }
    } catch (e) {
      print("Error updating subscription status: $e");
    }
  }

  void refreshSubscriptionStatus() async {
    try {
      await Purchases.syncPurchases();
      customerInfo = await RevenueCatService.getCustomerInfo();
      subscriptionState = await checkSubscriptionPaymentState();
      if (mounted)
        setState(() {
          _updateSubscriptionStatus();
        });
    } catch (e) {
      print("Error refreshing subscription: $e");
    }
  }

  Future<SubscriptionPaymentState> checkSubscriptionPaymentState() async {
    // Get updated customer info
    final customerInfo = await RevenueCatService.getCustomerInfo();

    if (customerInfo == null) return SubscriptionPaymentState.none();

    // Check for active entitlements
    if (customerInfo.isActivelySubscribed) {
      // Check each active entitlement
      for (final entitlementId in customerInfo.entitlements.active.keys) {
        final entitlement = customerInfo.entitlements.active[entitlementId]!;

        // If this is cancelled but still active
        if (entitlement.isActive && !entitlement.willRenew) {
          return SubscriptionPaymentState.activeCancelled(
              entitlementId: entitlementId,
              expirationDate: DateTime.parse(entitlement.expirationDate!),
              productId: entitlement.productIdentifier);
        }

        // If this is active and will renew
        if (entitlement.isActive && entitlement.willRenew) {
          return SubscriptionPaymentState.activeRenewing(
              entitlementId: entitlementId,
              expirationDate: DateTime.parse(entitlement.expirationDate!),
              productId: entitlement.productIdentifier);
        }
      }
      log('[SUBSCRIPTION] customerInfo.allPurchasedProductIdentifiers: ${customerInfo.allPurchasedProductIdentifiers}');
      // log expiration date
      log('[SUBSCRIPTION] customerInfo.allExpirationDates: ${customerInfo.allExpirationDates}');
      return SubscriptionPaymentState.active(
        entitlementId: '-',
        expirationDate: DateTime.now().add(Duration(days: 30)),
        productId: customerInfo.allPurchasedProductIdentifiers.isNotEmpty
            ? customerInfo.allPurchasedProductIdentifiers.first
            : '-',
      );
    }

    // No active subscriptions
    return SubscriptionPaymentState.none();
  }

  Future<String> getActiveSubscriptionDescription() async {
    final offering = await RevenueCatService.getCurrentOffering();

    // Get active entitlements
    final activeEntitlements =
        customerInfo?.entitlements.active.values.toList() ?? [];

    for (var entitlement in activeEntitlements) {
      // Create identifier in format "productIdentifier:productPlanIdentifier"
      final identifier =
          "${entitlement.productIdentifier}:${entitlement.productPlanIdentifier}";

      // Find matching package in offerings
      final package = offering?.availablePackages.firstWhereOrNull(
        (package) => package.storeProduct.identifier == identifier,
      );

      if (package != null) {
        return package.storeProduct.title;
      }
    }
    if (customerInfo?.allPurchasedProductIdentifiers.isNotEmpty ?? false) {
      final productId = customerInfo?.allPurchasedProductIdentifiers.first;
      final package = offering?.availablePackages.firstWhereOrNull(
        (package) => package.storeProduct.identifier == productId,
      );
      if (package != null) {
        return package.storeProduct.title;
      }
    }
    return '';
  }

  Widget _buildSubscriptionStatusWidget() {
    if (subscriptionState == null) {
      return SizedBox.shrink();
    }

    if (subscriptionState!.isActive && !subscriptionState!.willRenew) {
      return Container(
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.amber.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your subscription is ending soon",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              "Access until: ${DateFormat('yyyy-MM-dd, HH:mm').format(subscriptionState!.expirationDate!.toLocal())}",
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 8),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaywallScreen()),
                );
              },
              child: Text(
                "Renew now",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (subscriptionState!.isActive && subscriptionState!.willRenew) {
      return Container(
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Active subscription",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
            SizedBox(height: 4),
            Text(
              packageTitle,
              style: TextStyle(fontSize: 14),
            ),
            Text(
              "Renews: ${DateFormat('yyyy-MM-dd').format(subscriptionState!.expirationDate!.toLocal())}",
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
    }

    return SizedBox.shrink();
  }

  @override
  void dispose() {
    BotToast.closeAllLoading();
    Observable.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void update(
      Observable observable, String? notifyName, Map<dynamic, dynamic>? map) {
    if (notifyName == 'refresh_subscription') {
      _cubit.checkSubscriptionStatus();
      refreshSubscriptionStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: R.color.backgroundColorNew,
        ),
        child: _buildMainContent(context),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    // Make sure we provide a cubit if one doesn't exist in context
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<SubscriptionCubit, SubscriptionState>(
        listener: (context, state) {
          if (state is SubscriptionFailure) {
            BotToast.closeAllLoading();
            Message.showToastMessage(context, state.error);
          } else if (state is SubscriptionLoading) {
            BotToast.showLoading(allowClick: false);
          } else {
            BotToast.closeAllLoading();
          }
        },
        builder: (BuildContext context, SubscriptionState state) {
          return _buildPage(context, state);
        },
      ),
    );
  }

  Widget _buildPage(BuildContext context, SubscriptionState state) {
    // Get the banners from the state or use fallback
    List<dynamic> carouselItems = [];

    if (state is SubscriptionSuccess && state.banners.isNotEmpty) {
      carouselItems = state.banners;
    } else {
      carouselItems = _fallbackCarouselItems;
    }

    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen =
        screenSize.height < 650; // Adjust for Galaxy A5 and similar
    final isMobile = screenSize.width < Const.TABLET_BREAKPOINT;

    // Bottom button height + padding + bottom navigation padding
    final bottomButtonAreaHeight =
        48 + 16 + 24; // button height + margins + bottom nav spacing

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive spacing
          final double topSpacing = isSmallScreen ? 16 : 32;
          final double contentSpacing = isSmallScreen ? 8 : 16;

          // Calculate available height for content
          final availableHeight =
              constraints.maxHeight - bottomButtonAreaHeight;

          // Calculate space for the titles and subtitle
          final double titleSpace =
              90; // Approximate space for titles and subtitle

          // Calculate carousel max height
          final double carouselMaxHeight = availableHeight -
              titleSpace -
              (topSpacing * 2) -
              (contentSpacing * 3);

          final double imagePercent = isSmallScreen ? 0.65 : 0.65;

          // Calculate image size with a maximum percentage of available height
          final double imageHeight = carouselMaxHeight * imagePercent;

          return Stack(
            children: [
              // Main content - scrollable if needed
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GapH(topSpacing),
                    // Title block
                    MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaler: TextScaler.linear(MediaQuery.of(context)
                            .textScaleFactor
                            .clamp(1.0, 1.3)),
                      ),
                      child: Text(
                        R.string.subscription_title_1.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF01645A),
                        ),
                      ),
                    ),
                    MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaler: TextScaler.linear(MediaQuery.of(context)
                            .textScaleFactor
                            .clamp(1.0, 1.3)),
                      ),
                      child: Text(
                        R.string.subscription_title_2.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB4802D),
                        ),
                      ),
                    ),
                    GapH(contentSpacing),

                    // Subtitle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        R.string.subscription_subtitle.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                          color: R.color.color0xff111515,
                        ),
                      ),
                    ),
                    GapH(contentSpacing),

                    // Carousel Container with fixed aspect ratio
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: carouselMaxHeight,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          GapH(8),
                          // Image carousel
                          SizedBox(
                            height: imageHeight,
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              child: CarouselSlider(
                                carouselController: _carouselController,
                                options: CarouselOptions(
                                  height: imageHeight,
                                  viewportFraction: 1.0,
                                  enlargeCenterPage: false,
                                  autoPlay: true,
                                  autoPlayInterval: Duration(seconds: 5),
                                  autoPlayAnimationDuration:
                                      Duration(milliseconds: 800),
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      _currentCarouselIndex = index;
                                    });
                                  },
                                ),
                                items: carouselItems.map((item) {
                                  return Builder(
                                    builder: (BuildContext context) {
                                      return _buildBannerImage(item);
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          ),

                          // Title, subtitle, and indicators in remaining space
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: isSmallScreen ? 4.0 : 8.0,
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Title text with adjusted size based on screen
                                  Text(
                                    _getItemTitle(
                                        carouselItems[_currentCarouselIndex]),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF111515),
                                    ),
                                  ),
                                  // Subtitle text with adjusted size
                                  Text(
                                    _getItemSubtitle(
                                        carouselItems[_currentCarouselIndex]),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF111515),
                                    ),
                                  ),
                                  // Page indicator
                                  SmoothPageIndicator(
                                    controller: PageController(
                                        initialPage: _currentCarouselIndex),
                                    count: carouselItems.length,
                                    effect: ExpandingDotsEffect(
                                      dotHeight: isSmallScreen ? 6 : 8,
                                      dotWidth: isSmallScreen ? 6 : 8,
                                      spacing: 4,
                                      expansionFactor: 2,
                                      activeDotColor: Color(0xFF01645A),
                                      dotColor: Color(0xFFDFE4E4),
                                    ),
                                    onDotClicked: (index) {
                                      _carouselController.animateToPage(index);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Add extra space at bottom to ensure content doesn't get hidden behind the fixed button
                    GapH(bottomButtonAreaHeight.toDouble()),
                  ],
                ),
              ),

              // Fixed button at the bottom
              Positioned(
                left: 0,
                right: 0,
                bottom: 24,
                child: Center(
                  child:
                      // subscriptionState != null && subscriptionState!.isActive
                      //     ? _buildSubscriptionStatusWidget()
                      //     :
                      GestureDetector(
                    onTap: () {
                      SubscriptionTracking.programExplore(
                          _currentCarouselIndex + 1);
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (context) => PaywallScreen(),
                          fullscreenDialog: true,
                        ),
                      );
                    },
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(vertical: isSmallScreen ? 8 : 8),
                      height: 48,
                      width: 170,
                      decoration: BoxDecoration(
                        color: R.color.mainColor,
                        borderRadius: BorderRadius.circular(200),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.centerRight,
                          colors: [
                            R.color.greenGradientTop,
                            R.color.greenGradientBottom,
                            R.color.greenGradientBottom,
                          ],
                        ),
                      ),
                      child: Center(
                        child: MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                            textScaler: TextScaler.linear(MediaQuery.of(context)
                                .textScaleFactor
                                .clamp(1.0, 1.3)),
                          ),
                          child: Text(
                            R.string.tim_hieu_them.tr(),
                            style: TextStyle(
                              color: R.color.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getItemTitle(dynamic item) {
    if (item is BannerModel) {
      return item.title;
    } else {
      return item['title'];
    }
  }

  String _getItemSubtitle(dynamic item) {
    if (item is BannerModel) {
      return item.subtitle;
    } else {
      return item['subtitle'];
    }
  }

  Widget _buildBannerImage(dynamic item) {
    // Check if item is a BannerModel or a fallback map
    if (item is BannerModel) {
      String imageUrl = item.value.startsWith('http')
          ? item.value
          : '${Utils.getHostUrl()}/image/${item.value}';

      // Use CachedNetworkImage for network images
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(
            color: Color(0xFF01A89E),
          ),
        ),
        errorWidget: (context, url, error) => Image.asset(
          R.drawable.subscription_image_1, // Fallback image
          fit: BoxFit.cover,
        ),
      );
    } else {
      // Use local asset image for fallback
      return Image.asset(
        item['image'],
        fit: BoxFit.cover,
      );
    }
  }
}
