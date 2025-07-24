import 'dart:developer';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/home/widget/home_support_functions.dart';
import 'package:medical/src/widget/subscription/services/revenue_cat_service.dart';
import 'package:medical/src/widget/subscription/model/subscription_package_model.dart';
import 'package:medical/src/widget/subscription/subscription_tracking.dart';
import 'package:medical/src/widgets/gap_widget.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionOptionsBottomSheet extends StatefulWidget {
  final SubscriptionPackage package;
  final Function(SubscriptionPackage) onPackageSelected;
  final Function() onPurchaseSuccess;

  const SubscriptionOptionsBottomSheet({
    Key? key,
    required this.package,
    required this.onPackageSelected,
    required this.onPurchaseSuccess,
  }) : super(key: key);

  @override
  _SubscriptionOptionsBottomSheetState createState() =>
      _SubscriptionOptionsBottomSheetState();
}

class _SubscriptionOptionsBottomSheetState
    extends State<SubscriptionOptionsBottomSheet> {
  int _selectedOptionIndex = 1; // Default to basic 12 months
  bool _isLoading = false;
  late SubscriptionPackage _package;
  bool _isLoadingPackages = true;
  bool _isPurchaseInProgress = false;

  // Store the 6-month and 12-month packages
  Package? _sixMonthPackage;
  Package? _twelveMonthPackage;

  @override
  void initState() {
    super.initState();
    _package = widget.package;
    _loadRevenueCatPackages();
  }

  Future<void> _loadRevenueCatPackages() async {
    setState(() {
      _isLoadingPackages = true;
    });

    try {
      // Get offerings from RevenueCat
      final offerings = await RevenueCatService.getOfferings();

      log('[Purchases] Offerings: $offerings');

      if (offerings.isNotEmpty) {
        // Filter packages for the "Cơ bản" plan
        final basicPackages = offerings
            .where((p) =>
                p.storeProduct.identifier.contains('co_ban') ||
                p.storeProduct.identifier.contains('base') ||
                p.storeProduct.title.toLowerCase().contains('cơ bản'))
            .toList();

        if (basicPackages.isNotEmpty) {
          // Find 6-month package
          _sixMonthPackage = basicPackages.firstWhere(
            (p) =>
                p.storeProduct.identifier.contains('6_month') ||
                p.storeProduct.identifier.contains('6-month') ||
                p.storeProduct.title.contains('6 tháng'),
            orElse: () => basicPackages.first,
          );

          // Find 12-month package
          _twelveMonthPackage = basicPackages.firstWhere(
            (p) =>
                p.storeProduct.identifier.contains('12_month') ||
                p.storeProduct.identifier.contains('12-month') ||
                p.storeProduct.title.contains('12 tháng'),
            orElse: () => basicPackages.last,
          );
        }

        setState(() {
          _isLoadingPackages = false;
        });
      } else {
        setState(() {
          _isLoadingPackages = false;
        });
      }
    } catch (e) {
      print('Error loading RevenueCat packages: $e');
      setState(() {
        _isLoadingPackages = false;
      });
    }
  }

  void _handlePurchase() async {
    // Prevent multiple taps
    if (_isPurchaseInProgress) {
      return;
    }

    setState(() {
      _isLoading = true;
      _isPurchaseInProgress = true;
    });

    try {
      // Get the selected RevenueCat package
      Package? packageToPurchase;

      if (_selectedOptionIndex == 0) {
        packageToPurchase = _sixMonthPackage;
      } else {
        packageToPurchase = _twelveMonthPackage;
      }

      if (packageToPurchase != null) {
        log('[SUBSCRIPTION] Purchasing package: ${packageToPurchase.storeProduct.identifier}');
        log('[SUBSCRIPTION] Package title: ${packageToPurchase.storeProduct.title}');
        log('[SUBSCRIPTION] Package price: ${packageToPurchase.storeProduct.priceString}');

        // First validate that no other user has active subscriptions
        // iOS package is non-subscription, so we can purchase it as much as we want
        final canPurchase = Platform.isIOS ||
            await RevenueCatService.validateNoOtherUserHasActiveSubscription();

        if (!canPurchase) {
          setState(() {
            _isLoading = false;
            _isPurchaseInProgress = false;
          });

          // Show a dialog informing the user that subscription exists on another account
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(R.string.subscription_already_active.tr()),
              content: Text(R.string.subscription_already_active_content.tr()),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          HomeSupportFunctions.showModalAddData(context);
                        },
                        child: Container(
                          height: 43,
                          margin: EdgeInsets.only(left: 12),
                          decoration: BoxDecoration(
                            color: R.color.white,
                            borderRadius: BorderRadius.circular(200),
                            border: Border.all(
                              color: R.color.greenGradientBottom,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              R.string.contact.tr(),
                              style: TextStyle(
                                color: R.color.greenGradientBottom,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    GapW(12),
                    Flexible(
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context, rootNavigator: true)
                              .pushNamedAndRemoveUntil(
                            NavigatorName.tabbar,
                            (route) =>
                                false, // This removes all routes from stack
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: R.color.white,
                          ),
                          child: Container(
                            height: 43,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  R.color.greenGradientTop02,
                                  R.color.greenGradientBottom,
                                  R.color.greenGradientBottom,
                                ],
                              ),
                            ),
                            child: Text(
                              R.string.back_home_page.tr(),
                              style: TextStyle(
                                  color: R.color.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
          return;
        }

        // Attempt to purchase the package
        final purchased =
            await RevenueCatService.purchasePackageWithiOSHandling(packageToPurchase);

        setState(() {
          _isLoading = false;
        });

        // Add debug information for iOS purchases
        // if (Platform.isIOS) {
        //   await _debugIOSPurchaseResult(packageToPurchase);
        // }

        if (purchased) {
          await TrackingManager.trackEvent(
            'program_subscribe',
            'program_service',
            params: {
              'object_title': packageToPurchase.storeProduct.title,
              'status': 'success',
            },
          );
          // Close the bottom sheet
          Navigator.pop(context);

          // Show success dialog
          _showPaymentSuccessDialog(context);

          // Notify parent
          widget.onPackageSelected(_package);

          // Track the event
          SubscriptionTracking.programServiceRegister(
            screenName: 'subscription_options',
            objectTitle: _package.title,
          );

          // Refresh home screen and subscription screen
          Observable.instance
              .notifyObservers([], notifyName: "refresh_subscription");
        } else {
          await TrackingManager.trackEvent(
            'program_subscribe',
            'program_service',
            params: {
              'object_title': packageToPurchase.storeProduct.title,
              'status': 'fail',
            },
          );
          // Show error
          _showPaymentFailedDialog(context);
        }
      } else {
        setState(() {
          _isLoading = false;
          _isPurchaseInProgress = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không tìm thấy gói đăng ký.')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isPurchaseInProgress = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi: $e')),
      );
    } finally {
      // Ensure the flag is reset after a delay, even if something goes wrong
      Future.delayed(Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isPurchaseInProgress = false;
          });
        }
      });
    }
  }

  void _showPaymentSuccessDialog(BuildContext context) {
    // Get the price from the selected package

    String price = _selectedOptionIndex == 0
        ? Utils.formatMoney(_sixMonthPackage?.storeProduct.price,
                currency: _sixMonthPackage?.storeProduct.currencyCode) ??
            '150.000₫'
        : Utils.formatMoney(_twelveMonthPackage?.storeProduct.price,
                currency: _sixMonthPackage?.storeProduct.currencyCode) ??
            '200.000₫';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            Navigator.pop(context);
            return false;
          },
          child: Container(
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              insetPadding: EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.close,
                            color: R.color.color0xff111515,
                            size: 24,
                          ),
                        )
                      ],
                    ),
                    GapH(16),
                    Image.asset(R.drawable.ic_dialog_success,
                        width: 43, height: 43),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 14.0),
                          child: Text(
                            R.string.payment_success.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: R.color.color0xff636A6B,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            price,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: R.color.greenGradientBottom,
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        R.string.confirm_booking_subtitle.tr(namedArgs: {
                          'time': DateFormat('HH:mm').format(DateTime.now()),
                          'date':
                              DateFormat('dd/MM/yyyy').format(DateTime.now()),
                        }),
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: R.color.color0xff777E90,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    GapH(40),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: R.color.greenGradientBottom,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onPurchaseSuccess();
                        },
                        child: Text(
                          R.string.begin_program.tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    GapH(16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPaymentFailedDialog(BuildContext context) {
    // Reset the purchase in progress flag
    setState(() {
      _isPurchaseInProgress = false;
    });

    // Get the price from the selected package
    String price = _selectedOptionIndex == 0
        ? Utils.formatMoney(_sixMonthPackage?.storeProduct.price) ?? '150.000đ'
        : Utils.formatMoney(_twelveMonthPackage?.storeProduct.price) ??
            '200.000đ';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            Navigator.pop(context);
            return false;
          },
          child: Container(
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              insetPadding: EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.close,
                            color: R.color.color0xff111515,
                            size: 24,
                          ),
                        )
                      ],
                    ),
                    GapH(16),
                    Image.asset(R.drawable.ic_dialog_failed,
                        width: 43, height: 43),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 14.0),
                          child: Text(
                            R.string.payment_failed.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: R.color.color0xff636A6B,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            price,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: R.color.attentionText,
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        R.string.confirm_booking_subtitle.tr(namedArgs: {
                          'time': DateFormat('HH:mm').format(DateTime.now()),
                          'date':
                              DateFormat('dd/MM/yyyy').format(DateTime.now()),
                        }),
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: R.color.color0xff777E90,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    GapH(40),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              HomeSupportFunctions.showModalAddData(context);
                            },
                            child: Container(
                              height: 48,
                              margin: EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: R.color.white,
                                borderRadius: BorderRadius.circular(200),
                                border: Border.all(
                                  color: R.color.greenGradientBottom,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  R.string.support.tr(),
                                  style: TextStyle(
                                    color: R.color.greenGradientBottom,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        GapW(12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              height: 48,
                              margin: EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 8),
                              decoration: BoxDecoration(
                                color: R.color.mainColor,
                                borderRadius: BorderRadius.circular(200),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    R.color.greenGradientTop,
                                    R.color.greenGradientMid,
                                    R.color.greenGradientBottom,
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  R.string.repayment.tr(),
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
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Debug method to help identify iOS purchase issues
  // Future<void> _debugIOSPurchaseResult(Package packageToPurchase) async {
  //   try {
  //     log('[SUBSCRIPTION] [DEBUG] Starting detailed iOS purchase analysis...');

  //     // Get customer info
  //     final customerInfo = await Purchases.getCustomerInfo();

  //     log('[SUBSCRIPTION] [DEBUG] === CUSTOMER INFO ANALYSIS ===');
  //     log('[SUBSCRIPTION] [DEBUG] Original App User ID: ${customerInfo.originalAppUserId}');
  //     log('[SUBSCRIPTION] [DEBUG] Request Date: ${customerInfo.requestDate}');
  //     log('[SUBSCRIPTION] [DEBUG] First Seen: ${customerInfo.firstSeen}');
  //     log('[SUBSCRIPTION] [DEBUG] Original Purchase Date: ${customerInfo.originalPurchaseDate}');
  //     log('[SUBSCRIPTION] [DEBUG] Management URL: ${customerInfo.managementURL}');

  //     log('[SUBSCRIPTION] [DEBUG] === ENTITLEMENTS ===');
  //     log('[SUBSCRIPTION] [DEBUG] All Entitlements: ${customerInfo.entitlements.all.keys.toList()}');
  //     log('[SUBSCRIPTION] [DEBUG] Active Entitlements: ${customerInfo.entitlements.active.keys.toList()}');

  //     log('[SUBSCRIPTION] [DEBUG] === SUBSCRIPTIONS ===');
  //     log('[SUBSCRIPTION] [DEBUG] Active Subscriptions: ${customerInfo.activeSubscriptions}');
  //     log('[SUBSCRIPTION] [DEBUG] All Purchase Dates: ${customerInfo.allPurchaseDates}');
  //     log('[SUBSCRIPTION] [DEBUG] All Expiration Dates: ${customerInfo.allExpirationDates}');
  //     log('[SUBSCRIPTION] [DEBUG] Latest Expiration Date: ${customerInfo.latestExpirationDate}');

  //     log('[SUBSCRIPTION] [DEBUG] === TRANSACTIONS ===');
  //     log('[SUBSCRIPTION] [DEBUG] All Purchased Product IDs: ${customerInfo.allPurchasedProductIdentifiers}');
  //     log('[SUBSCRIPTION] [DEBUG] Non-Subscription Transactions: ${customerInfo.nonSubscriptionTransactions.length}');

  //     // Check specific product
  //     final productId = packageToPurchase.storeProduct.identifier;
  //     final hasProduct = customerInfo.allPurchasedProductIdentifiers.contains(productId);
  //     final hasExpiration = customerInfo.allExpirationDates.containsKey(productId);
  //     final expirationDate = customerInfo.allExpirationDates[productId];
  //     final purchaseDate = customerInfo.allPurchaseDates[productId];
  //     log('[SUBSCRIPTION] [DEBUG] === SPECIFIC PRODUCT ANALYSIS ===');
  //     log('[SUBSCRIPTION] [DEBUG] Product ID: $productId');
  //     log('[SUBSCRIPTION] [DEBUG] Has Product: $hasProduct');
  //     log('[SUBSCRIPTION] [DEBUG] Has Expiration Entry: $hasExpiration');
  //     log('[SUBSCRIPTION] [DEBUG] Expiration Date: $expirationDate');
  //     log('[SUBSCRIPTION] [DEBUG] Purchase Date: $purchaseDate');
  //     // Check if this is a subscription vs non-consumable
  //     if (expirationDate == null && hasProduct) {
  //       log('[SUBSCRIPTION] [DEBUG] ⚠️  POTENTIAL ISSUE: Product has null expiration date');
  //       log('[SUBSCRIPTION] [DEBUG] ⚠️  This suggests the product might be configured as non-consumable instead of subscription');
  //       log('[SUBSCRIPTION] [DEBUG] ⚠️  Check App Store Connect product configuration');
  //     }
  //     for (final transaction in customerInfo.nonSubscriptionTransactions) {
  //         log('[SUBSCRIPTION] [DEBUG] - Revenue Cat ID: ${transaction.revenueCatIdentifier}');
  //         log('[SUBSCRIPTION] [DEBUG] - Purchase Date: ${transaction.purchaseDate}');
  //       }
  //     }
  //     log('[SUBSCRIPTION] [DEBUG] === VALIDATION RESULTS ===');
  //     final hasActiveEntitlements = customerInfo.entitlements.active.isNotEmpty;
  //     final hasActiveSubscriptions = customerInfo.activeSubscriptions.isNotEmpty;
  //     final hasPurchasedProduct = customerInfo.allPurchasedProductIdentifiers.contains(productId);

  //     log('[SUBSCRIPTION] [DEBUG] Has Active Entitlements: $hasActiveEntitlements');
  //     log('[SUBSCRIPTION] [DEBUG] Has Active Subscriptions: $hasActiveSubscriptions');
  //     log('[SUBSCRIPTION] [DEBUG] Has Purchased Product: $hasPurchasedProduct');

  //     final shouldBeSuccessful = hasActiveEntitlements || hasActiveSubscriptions || hasPurchasedProduct;
  //     log('[SUBSCRIPTION] [DEBUG] Should Be Successful: $shouldBeSuccessful');

  //     if (!shouldBeSuccessful) {
  //       log('[SUBSCRIPTION] [DEBUG] ❌ Purchase validation would fail');
  //     } else {
  //       log('[SUBSCRIPTION] [DEBUG] ✅ Purchase validation should pass');
  //     }
  //   } catch (e) {
  //     log('[SUBSCRIPTION] [DEBUG] Error during iOS debug analysis: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 16,
        right: 16,
        bottom: 16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  R.string.basic_program.tr().toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: R.color.color0xff111515,
                  ),
                ),
              ),
            ],
          ),
          GapH(20),

          // Show loading indicator while fetching packages
          if (_isLoadingPackages)
            Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  GapH(16),
                  Text(
                    "${R.string.loading_subscription_packages.tr()}...",
                    style: TextStyle(
                      fontSize: 14,
                      color: R.color.color0xff636A6B,
                    ),
                  ),
                  GapH(16),
                ],
              ),
            )
          else ...[
            // 6 month option
            _buildSubscriptionOption(0),

            GapH(16),

            // 12 month option
            _buildSubscriptionOption(1),
          ],

          GapH(24),

          // Payment button
          _isLoading || _isLoadingPackages
              ? SizedBox.shrink()
              : GestureDetector(
                  onTap: _isPurchaseInProgress
                      ? null
                      : _handlePurchase, // Disable if purchase in progress
                  child: Opacity(
                    opacity: _isPurchaseInProgress
                        ? 0.7
                        : 1.0, // Visual feedback that button is disabled
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: R.color.mainColor,
                        borderRadius: BorderRadius.circular(200),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            R.color.greenGradientTop02,
                            R.color.greenGradientBottom,
                            R.color.greenGradientBottom,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _isPurchaseInProgress
                              ? 'Đang xử lý...' // Show processing message
                              : R.string.payment.tr(),
                          style: TextStyle(
                            color: R.color.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionOption(int index) {
    // Get the package for this option
    final package = index == 0 ? _sixMonthPackage : _twelveMonthPackage;

    // Get duration text
    String duration = index == 0 ? '6 THÁNG' : '12 THÁNG';

    // Get price text
    String price = Utils.formatMoney(package?.storeProduct.price,
            currency: package?.storeProduct.currencyCode) ??
        (index == 0 ? '150.000đ' : '200.000đ');

    // Calculate monthly price for 12-month option
    String monthlyPrice = '';
    if (index == 1 && package != null) {
      try {
        final totalPrice = package.storeProduct.price;
        final monthly = totalPrice / 12;
        monthlyPrice =
            '${Utils.formatMoney(monthly, currency: package.storeProduct.currencyCode)}/ 1 tháng';
      } catch (e) {
        print('Error calculating monthly price: $e');
        monthlyPrice = '16.700đ/ 1 tháng';
      }
    }

    final isSelected = _selectedOptionIndex == index;

    return GestureDetector(
      onTap: _isPurchaseInProgress
          ? null
          : () {
              setState(() {
                _selectedOptionIndex = index;
              });
            },
      child: Opacity(
        opacity:
            _isPurchaseInProgress ? 0.7 : 1.0, // Dim options during purchase
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? R.color.greenGradientBottom
                  : R.color.color0xffDFE4E4,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              Utils.getBoxShadowDropCard(),
            ],
          ),
          child: Row(
            children: [
              // Radio button
              Radio(
                value: index,
                groupValue: _selectedOptionIndex,
                activeColor: R.color.greenGradientBottom,
                onChanged: _isPurchaseInProgress
                    ? null
                    : (int? value) {
                        if (value != null) {
                          setState(() {
                            _selectedOptionIndex = value;
                          });
                        }
                      },
              ),

              // Option content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 24, 12, 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            duration,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: R.color.color0xff636A6B,
                            ),
                          ),
                          if (index == 1) GapH(4),
                          if (index == 1) // Show badge for 12-month option
                            Container(
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
                                ),
                              ),
                              child: Text(
                                R.string.tiet_kiem_nhat.tr(),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            price,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: R.color.color0xff111515,
                            ),
                          ),
                          if (index == 1 && monthlyPrice.isNotEmpty) GapH(4),
                          if (index == 1 && monthlyPrice.isNotEmpty)
                            Text(
                              monthlyPrice,
                              style: TextStyle(
                                fontSize: 15,
                                color: R.color.color0xff636A6B,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
