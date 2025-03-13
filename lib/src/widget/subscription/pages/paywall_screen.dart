import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/subscription/services/revenue_cat_service.dart';
import 'package:medical/src/widget/subscription/model/subscription_package_model.dart';
import 'package:medical/src/widget/subscription/services/subscription_service.dart';
import 'package:medical/src/widget/subscription/widgets/package_detail_bottom_sheet.dart';
import 'package:medical/src/widgets/gap_widget.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PaywallScreen extends StatefulWidget {
  @override
  _PaywallScreenState createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  List<Package> _revenueCatPackages = [];
  List<SubscriptionPackage> _localPackages = [];
  Map<String, SubscriptionPackage> _packageMap = {};
  bool _isLoading = true;
  int _selectedPackageIndex = 0;

  @override
  void initState() {
    super.initState();
    Observable.instance.notifyObservers([], notifyName: 'hide_bottom_bar');
    _loadPackages();
  }

  @override
  void dispose() {
    // Notify to show bottom bar when this screen closes
    Observable.instance.notifyObservers([], notifyName: 'show_bottom_bar');
    super.dispose();
  }

  Future<void> _loadPackages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load local package data
      final localPackages = await SubscriptionService.getLocalPackages();

      // Load RevenueCat packages
      final revenueCatPackages = await RevenueCatService.getOfferings();

      // Map RevenueCat packages to local packages
      final packageMap = await SubscriptionService.mapLocalPackagesToRevenueCat(
          localPackages, revenueCatPackages);

      setState(() {
        _localPackages = localPackages;
        _revenueCatPackages = revenueCatPackages;
        _packageMap = packageMap;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading packages: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showPackageDetails(
      SubscriptionPackage package, Package revenueCatPackage) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: R.color.transparent,
      builder: (context) => PackageDetailBottomSheet(
        package: package,
        onPurchase: () async {
          Navigator.pop(context);
          final purchased =
              await RevenueCatService.purchasePackage(revenueCatPackage);
          if (purchased) {
            Observable.instance.notifyObservers([], notifyName: "refresh_home");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Purchase successful!')),
            );
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Make sure bottom bar is shown when going back
        Observable.instance.notifyObservers([], notifyName: 'show_bottom_bar');
        return true;
      },
      child: Scaffold(
        body: _isLoading
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

                      // Back arrow positioned at top
                      Positioned(
                        top: 40,
                        left: 16,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back,
                              color: R.color.greenGradientTop02),
                          onPressed: () {
                            // Make sure bottom bar shows when navigating back
                            Observable.instance.notifyObservers([],
                                notifyName: 'show_bottom_bar');
                            Navigator.of(context).pop();
                          },
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
                                _localPackages[_selectedPackageIndex],
                                _revenueCatPackages.firstWhere(
                                  (p) =>
                                      p.storeProduct.identifier ==
                                      _localPackages[_selectedPackageIndex].id,
                                  orElse: () => _revenueCatPackages.first,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildPackageCard(
      SubscriptionPackage package, Package revenueCatPackage) {
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
                    _showPackageDetails(package, revenueCatPackage);
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
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
                            GapH(4),
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
          onTap: () async {
            // final revenueCatPackage = _revenueCatPackages.firstWhere(
            //   (p) =>
            //       p.storeProduct.identifier ==
            //       _localPackages[_selectedPackageIndex].id,
            //   orElse: () => _revenueCatPackages.first,
            // );

            // final purchased =
            //     await RevenueCatService.purchasePackage(revenueCatPackage);
            // if (purchased) {
            //   Observable.instance
            //       .notifyObservers([], notifyName: "refresh_home");
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     SnackBar(content: Text('Purchase successful!')),
            //   );
            //   Navigator.pop(context);
            // }
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
}
