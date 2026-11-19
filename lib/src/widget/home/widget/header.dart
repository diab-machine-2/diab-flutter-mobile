import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/branchio_link_config.dart';
import 'package:medical/src/app_setting/deep_link_config.dart';
import 'package:medical/src/repo/notification/notification_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/home/widget/home_support_functions.dart';
import 'package:medical/src/widgets/share_profile_popup.dart';

import '../../../modal/user/user_model.dart';
import '../../../modal/home/home_model.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({this.sharedCode, this.homeModel});
  final String? sharedCode;
  final HomeModel? homeModel;

  /// Text of the unread badge on the bell: "1"–"9", "9+" above that, null
  /// (no badge) when there is nothing unread.
  static String? badgeLabel(int? count) {
    if (count == null || count <= 0) return null;
    return count > 9 ? '9+' : '$count';
  }

  @override
  _HomeHeaderState createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader>
    with Observer, WidgetsBindingObserver {
  static const double _avatarSize = 44;

  int? notificationCount = 0;
  int _countRequestSeq = 0;
  late UserModel? user;

  @override
  void initState() {
    super.initState();
    Observable.instance.addObserver(this);
    WidgetsBinding.instance.addObserver(this);
    DeepLinkConfig.setUpHandleDeepLink(onHaveLink: (code) {
      final String? meetingId = BranchioLinkConfig.instance.meetingId;
      if (code?.isNotEmpty == true && meetingId == null) {
        ShareProfilePopup.instance
            .onHasSharedCode(context: context, code: code!);
      }
    });
    initData();
  }

  @override
  void update(
      Observable observable, String? notifyName, Map<dynamic, dynamic>? map) {
    if (notifyName == 'user_info_change') {
      user = AppSettings.userInfo;
      setState(() {});
    }
    if (notifyName == 'reload_notification' ||
        notifyName == 'read_notification_success') {
      loadNotification();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) loadNotification();
  }

  @override
  void dispose() {
    Observable.instance.removeObserver(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> initData() async {
    user = AppSettings.userInfo;
    await loadNotification();
    final String? meetingId = BranchioLinkConfig.instance.meetingId;
    if (widget.sharedCode?.isNotEmpty == true && meetingId == null) {
      ShareProfilePopup.instance.onHasSharedCode(
          context: context, code: widget.sharedCode.toString());
    }
    if (AppSettings.isGetUser == false) {
      user = await UserClient().fetchUser(skipNotifiUI: true);
      if (mounted) setState(() {});
    }
  }

  Future<void> loadNotification() async {
    // Several triggers can fire together; only the latest request may write.
    final seq = ++_countRequestSeq;
    try {
      final count = await NotificationClient().fetchNotificationCount();
      if (!mounted || seq != _countRequestSeq) return;
      setState(() => notificationCount = count);
    } catch (e, s) {
      // Keep the last known badge; the next reload trigger retries.
      TrackingManager.recordError(e, s);
    }
  }

  String get _subtitle {
    final programName = widget.homeModel?.tranServicePackageName;
    if (programName?.isNotEmpty == true) return programName!;
    if (user?.packageName?.isNotEmpty == true) return user!.packageName!;
    return R.string.home_header_tagline.tr();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        // Right 12 (not 4): room for the bell badge, which now sticks out
        // past the bell's top-right corner.
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.pushNamed(context, NavigatorName.profile);
                },
                child: Row(children: [
                  _buildAvatar(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName?.trim() ?? '',
                          style: TextStyle(
                            color: R.color.white,
                            fontSize: 15,
                            height: 1.46,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Program name: up to 2 lines so older users can
                        // read the whole name instead of "Chương trình…".
                        Text(
                          _subtitle,
                          style: TextStyle(
                            color: R.color.white,
                            fontSize: 14,
                            height: 1.4,
                            letterSpacing: 0.2,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
            // Gaps are Figma's 16 minus the 8px tap padding around each icon.
            const SizedBox(width: 8),
            _buildAction(
              icon: R.icons.ic_home_phone,
              // Hotline / Zalo contact sheet.
              onTap: () => HomeSupportFunctions.showModalAddData(context),
            ),
            _buildAction(
              icon: R.icons.ic_home_bell,
              badge: HomeHeader.badgeLabel(notificationCount),
              onTap: () =>
                  Navigator.pushNamed(context, NavigatorName.notification),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final url = user?.imageUrl?.url;
    final fallback =
        Icon(Icons.person, size: _avatarSize - 2, color: R.color.mainColor);
    return Stack(
      clipBehavior: Clip.none,
      alignment: AlignmentDirectional.bottomEnd,
      children: [
        Padding(
          padding: AppSettings.isOwnPackage
              ? EdgeInsets.zero
              : const EdgeInsets.only(right: 4, bottom: 4),
          child: Container(
            width: _avatarSize,
            height: _avatarSize,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: R.color.white,
              shape: BoxShape.circle,
            ),
            // Over the photo, which would otherwise cover the ring.
            foregroundDecoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: R.color.color0xffDADEDF),
            ),
            child: url == null
                ? fallback
                : Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => fallback,
                  ),
          ),
        ),
        if (AppSettings.isOwnPackage)
          Positioned(
            bottom: -8,
            left: 0,
            right: 0,
            child: Container(
              height: _avatarSize - 4,
              alignment: Alignment.bottomCenter,
              child: Image.network(user?.ownPackage?.logo ?? ""),
            ),
          )
        else
          Container(
            width: 20,
            height: 20,
            padding: const EdgeInsets.all(4),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: R.color.white,
            ),
            child: Image.asset(R.drawable.ic_crown_green),
          ),
      ],
    );
  }

  Widget _buildAction(
      {required String icon, required VoidCallback onTap, String? badge}) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      // 40x40 tap target around the 24px icon.
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Center(child: SvgPicture.asset(icon)),
          ),
          // On the bell's top-right corner (the 24px icon spans 8..32 of the
          // 40px box), covering about a quarter of it instead of two
          // thirds; the white ring separates it from icon and header.
          if (badge != null)
            Positioned(
              top: 0,
              left: 22,
              child: Container(
                constraints: const BoxConstraints(minWidth: 20),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: R.color.homeAlertRed,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: R.color.white, width: 1.5),
                ),
                child: Text(
                  badge,
                  // A big system font grew the badge back over the bell.
                  textScaler: MediaQuery.textScalerOf(context)
                      .clamp(maxScaleFactor: 1.2),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: R.color.white,
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
