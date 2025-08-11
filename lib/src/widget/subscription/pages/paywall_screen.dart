import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/firebase_remote_config.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/subscription/pages/package_program_detail_page.dart';
import 'package:medical/src/widget/subscription/pages/welcome_program_page.dart';
import 'package:medical/src/widget/subscription/services/revenue_cat_service.dart';
import 'package:medical/src/widget/subscription/model/subscription_package_model.dart';
import 'package:medical/src/widget/subscription/services/subscription_service.dart';
import 'package:medical/src/widget/subscription/subscription_cubit.dart';
import 'package:medical/src/widget/subscription/subscription_navigation_mixin.dart';
import 'package:medical/src/widget/subscription/subscription_tracking.dart';
import 'package:medical/src/widget/subscription/widgets/package_detail_bottom_sheet.dart';
import 'package:medical/src/widget/subscription/pages/package_program_list_page.dart';
import 'package:medical/src/widgets/gap_widget.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PaywallScreen extends StatefulWidget {
  final bool autoTriggerBasicBottomSheet;
  const PaywallScreen({Key? key, this.autoTriggerBasicBottomSheet = false})
      : super(key: key);

  @override
  _PaywallScreenState createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  List<SubscriptionPackage> _localPackages = [];
  List<Package> _revenueCatPackages = [];
  bool _isLoading = true;
  int _selectedPackageIndex = 0;
  String _currentRoute = '/';
  late SubscriptionCubit _cubit;

  bool _autoTriggerBasicBottomSheet = false;

  @override
  void initState() {
    super.initState();
    final AppRepository repository = AppRepository();
    _cubit = SubscriptionCubit(repository);
    _autoTriggerBasicBottomSheet = widget.autoTriggerBasicBottomSheet;
    _loadPackages();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _triggerBasicBottomSheet() {
    int basicIndex = _localPackages.indexWhere((p) => p.id == 'co_ban');
    if (basicIndex == -1) return;
    setState(() {
      _selectedPackageIndex = basicIndex;
    });
    final package = _localPackages[_selectedPackageIndex];
    _cubit.setSelectedPackage(package);
    SubscriptionTracking.programServiceRegister(
      screenName: 'program_service',
      objectTitle: package.title,
    );
    if (package.id == 'co_ban' && _revenueCatPackages.isNotEmpty) {
      SubscriptionService.showSubscriptionOptionsSheet(context, package);
    } else {
      SubscriptionNavigationMixin.navigationKey.currentState
          ?.pushNamed(NavigatorName.package_program_list);
    }
  }

  Future<void> _loadPackages() async {
    try {
      // Try to load from Firebase Remote Config first, fallback to local packages
      List<SubscriptionPackage> localPackages = [];
      try {
        final packageInfo =
            FirebaseRemoteSetting.instance.subscriptionPackageInfo;
        if (packageInfo != null && packageInfo.isNotEmpty) {
          localPackages =
              SubscriptionPackage.fromList(jsonDecode(packageInfo)['packages']);
        }
        if (localPackages.isEmpty) {
          localPackages = await SubscriptionService.getLocalPackages();
        }
      } catch (e) {
        print('Error loading remote packages, falling back to local: $e');
        localPackages = await SubscriptionService.getLocalPackages();
      }

      _revenueCatPackages = await RevenueCatService.getOfferings();

      setState(() {
        _localPackages = localPackages;
        _isLoading = false;
        if (_autoTriggerBasicBottomSheet) {
          _autoTriggerBasicBottomSheet = false;
          _triggerBasicBottomSheet();
        }
      });

      if (_localPackages.isNotEmpty) {
        SubscriptionTracking.programServiceSelect(
            objectTitle: _localPackages.first.title);
      }
    } catch (e) {
      print('Error loading packages: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showPackageDetails(SubscriptionPackage package) {
    // Find matching RevenueCat package if available and it's the "cơ bản" package

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: R.color.transparent,
      builder: (context) => PackageDetailBottomSheet(
        package: package,
        onPurchase: () async {
          Navigator.pop(context);
          _cubit.setSelectedPackage(_localPackages[_selectedPackageIndex]);

          SubscriptionTracking.programServiceRegister(
              screenName: 'program_service',
              objectTitle: _localPackages[_selectedPackageIndex].title);

          if (_localPackages[_selectedPackageIndex].id == 'co_ban' &&
              _revenueCatPackages.isNotEmpty) {
            // Show subscription options sheet only for "cơ bản" package
            SubscriptionService.showSubscriptionOptionsSheet(context, package);

            return;
          } else {
            // Navigate to package program list using the SubscriptionNavigationMixin for other packages
            SubscriptionNavigationMixin.navigationKey.currentState
                ?.pushNamed(NavigatorName.package_program_list);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: WillPopScope(
        onWillPop: () async {
          print('[ROUTE] onWillPop _currentRoute: $_currentRoute');
          // Check if the inner navigator can handle the back button press
          final NavigatorState? navigator =
              SubscriptionNavigationMixin.navigationKey.currentState;

          if (navigator != null && navigator.canPop()) {
            navigator.pop();
            return false;
          }

          // Otherwise, handle the back button normally (return to subscription page)
          return true;
        },
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              color: R.color.backgroundColorNew,
            ),
            child: Navigator(
              key: SubscriptionNavigationMixin.navigationKey,
              onGenerateRoute: (settings) {
                print('[ROUTE] Current Route: ${settings.name}');
                _currentRoute = settings.name ?? '/';
                print(
                    '[ROUTE] Navigator Stack: ${SubscriptionNavigationMixin.navigationKey.currentState?.toString()}');

                switch (settings.name) {
                  case '/':
                    return MaterialPageRoute(
                      builder: (_) => _buildMainContent(),
                    );
                  case NavigatorName.package_program_list:
                    return _buildRoute(
                      settings,
                      ProgramsListPage(),
                    );
                  case NavigatorName.package_program_detail:
                    Map<String, dynamic>? args =
                        settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(
                      settings,
                      ProgramDetailPage(
                        program: args?['program'],
                      ),
                    );
                  case NavigatorName.welcome_program:
                    Map<String, dynamic>? args =
                        settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(
                      settings,
                      WelcomeProgramPage(
                        program: args?['program'],
                      ),
                    );
                  default:
                    return null;
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : _localPackages.isEmpty
            ? Center(child: Text('No subscription options available'))
            : Stack(
                children: [
                  // Background image with proper alignment
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Image.asset(
                      SubscriptionService.getBackgroundImageFromId(
                          _localPackages[_selectedPackageIndex].id),
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.topCenter,
                    ),
                  ),

                  // Main content aligned to bottom
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.only(top: 180),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            R.color.transparent,
                            R.color.white.withOpacity(0.3),
                            R.color.white.withOpacity(0.7),
                            R.color.white.withOpacity(0.9),
                            R.color.white,
                          ],
                          stops: [0.0, 0.15, 0.5, 0.7, 0.85],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildPackageCard(
                              _localPackages[_selectedPackageIndex]),
                        ],
                      ),
                    ),
                  ),

                  // Back arrow positioned at top
                  Positioned(
                    top: 16,
                    left: 16,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back,
                          color: R.color.greenGradientTop02),
                      onPressed: () {
                        // Make sure bottom bar shows when navigating back
                        Observable.instance
                            .notifyObservers([], notifyName: 'show_bottom_bar');
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              );
  }

  Widget _buildPackageCard(SubscriptionPackage package) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info card with title, features
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: R.color.transparent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title and subtitle
              Text(
                package.title,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: R.color.greenGradientBottom,
                ),
              ),
              Text(
                package.subtitle,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: R.color.color0xff111515,
                ),
              ),
              GapH(16),

              // Features list (showing first 3)
              ...package.features.take(3).map((feature) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Image.asset(
                        R.drawable.ic_subscription_bullet,
                        width: 20,
                        height: 20,
                      ),
                      GapW(8),
                      Expanded(
                        child: feature.richText.isNotEmpty
                            ? RichText(
                                text: TextSpan(
                                  children: feature.richText,
                                ),
                              )
                            : Text(
                                feature.text,
                                style: TextStyle(
                                  color: R.color.color0xff111515,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                      ),
                    ],
                  ),
                );
              }).toList(),

              // "See more" button
              Center(
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () {
                    SubscriptionTracking.serviceView(
                        objectTitle: package.title);
                    _showPackageDetails(package);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        R.string.more.tr(),
                        style: TextStyle(
                          color: R.color.color0xff111515,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: R.color.color0xff111515,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        GapH(16),

        // Package options
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: _localPackages.map((p) {
              final isSelected = p.id == package.id;
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () {
                    final index = _localPackages.indexOf(p);
                    if (index >= 0) {
                      setState(() {
                        _selectedPackageIndex = index;
                        SubscriptionTracking.programServiceSelect(
                            objectTitle: p.title);
                      });
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: R.color.white,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: isSelected
                            ? R.color.greenGradientTop02
                            : R.color.color0xffEDEEEE,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        isSelected
                            ? Icon(
                                Icons.radio_button_checked,
                                size: 25,
                                color: R.color.greenGradientTop02,
                              )
                            : Icon(
                                Icons.radio_button_unchecked,
                                size: 25,
                                color: R.color.color0xffEDEEEE,
                              ),
                        GapW(12),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    p.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: R.color.greenGradientTop02,
                                    ),
                                  ),
                                  GapW(8),
                                  Visibility(
                                    visible: p.isRecommended,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: LinearGradient(
                                          colors: [
                                            R.color.gradientGold1,
                                            R.color.gradientGold2,
                                            R.color.gradientGold3,
                                            R.color.gradientGold4,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          stops: [0.0, 0.25, 0.63, 1],
                                        ),
                                      ),
                                      child: Text(
                                        R.string.recommended.tr(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: R.color.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // GapW(4),
                              Flexible(
                                child: Text(
                                  p.priceText,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: R.color.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        GapH(16),

        // Register button
        GestureDetector(
          onTap: () {
            _cubit.setSelectedPackage(_localPackages[_selectedPackageIndex]);

            SubscriptionTracking.programServiceRegister(
                screenName: 'program_service',
                objectTitle: _localPackages[_selectedPackageIndex].title);

            if (_localPackages[_selectedPackageIndex].id == 'co_ban' &&
                _revenueCatPackages.isNotEmpty) {
              // Show subscription options sheet only for "cơ bản" package
              SubscriptionService.showSubscriptionOptionsSheet(
                  context, package);

              return;
            } else {
              // Navigate to package program list using the SubscriptionNavigationMixin for other packages
              SubscriptionNavigationMixin.navigationKey.currentState
                  ?.pushNamed(NavigatorName.package_program_list);
            }
          },
          child: Container(
            margin: EdgeInsets.fromLTRB(16, 0, 16, 24),
            width: double.infinity,
            child: Container(
              height: 48,
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
                child: Text(
                  R.string.sign_up.tr(),
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
      ],
    );
  }

  PageRoute _buildRoute(
    RouteSettings settings,
    Widget builder,
  ) {
    return MaterialPageRoute(
      settings: settings,
      builder: (ctx) => builder,
    );
  }
}
