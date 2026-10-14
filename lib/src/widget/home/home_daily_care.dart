import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_sharing.dart';
import 'package:medical/src/app_setting/branchio_link_config.dart';
import 'package:medical/src/app_setting/firebase_remote_config.dart';
import 'package:medical/src/model/response/my_benefit_response.dart';
import 'package:medical/src/utils/app_log.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/home/home_remote_config.dart';
import 'package:medical/src/widget/home/schema/home_schema.dart';

/// Every "Chăm sóc hằng ngày" entry, keyed by the slugs Remote Config
/// `HOME_DAILY_CARE_CONFIG` lists (see [HomeDailyCareSlug]).
class HomeDailyCareCatalog {
  HomeDailyCareCatalog._();

  /// Non-route actions handled by [HomeDailyCareNavigator.open].
  static const String actionShare = 'share';
  static const String actionAtHome = 'at_home';

  static List<HomeUtilityData> items(Iterable<String> slugs) =>
      slugs.map(item).whereType<HomeUtilityData>().toList();

  /// The "Xem tất cả" tile closing the Home grid.
  static HomeUtilityData get viewAll => HomeUtilityData(
        icon: R.icons.ic_ti_xem_tat_ca,
        title: R.string.view_all.tr(),
        slug: HomeDailyCareSlug.viewAll,
        navigatorName: NavigatorName.utilities,
      );

  static HomeUtilityData? item(String slug) {
    switch (slug) {
      case HomeDailyCareSlug.healthProfile:
        return HomeUtilityData(
          icon: R.icons.ic_ti_ho_so_suc_khoe,
          title: R.string.health_profile.tr(),
          subtitle: R.string.home_daily_care_desc_health_profile.tr(),
          slug: slug,
          navigatorName: NavigatorName.view_test_result,
        );
      case HomeDailyCareSlug.atClinic:
        return HomeUtilityData(
          icon: R.icons.ic_ti_dat_lich_kham,
          title: R.string.kham_tai_phong_kham.tr(),
          gridTitle: R.string.home_book_clinic_short.tr(),
          subtitle: R.string.home_benefit_at_clinic_desc.tr(),
          slug: slug,
          navigatorName: NavigatorName.booking_clinic,
        );
      case HomeDailyCareSlug.telemedicine:
        return HomeUtilityData(
          icon: R.icons.ic_ti_kham_tu_xa,
          title: R.string.kham_tu_xa.tr(),
          subtitle: R.string.home_benefit_telemedicine_desc.tr(),
          slug: slug,
          navigatorName: NavigatorName.booking_doctor,
        );
      case HomeDailyCareSlug.labTest:
        return HomeUtilityData(
          icon: R.icons.ic_ti_xet_nghiem,
          title: R.string.benefit_lab_testing.tr(),
          gridTitle: R.string.examination.tr(),
          subtitle: R.string.home_daily_care_desc_lab_test.tr(),
          slug: slug,
          navigatorName: NavigatorName.benefit_lab_test_intro,
        );
      case HomeDailyCareSlug.buyMedicine:
        return HomeUtilityData(
          icon: R.icons.ic_ti_mua_thuoc,
          title: R.string.benefit_medicine.tr(),
          subtitle: R.string.home_daily_care_desc_buy_medicine.tr(),
          slug: slug,
          navigatorName: NavigatorName.benefit_medicine_intro,
        );
      case HomeDailyCareSlug.medicineReminder:
        return HomeUtilityData(
          icon: R.icons.ic_ti_nhac_uong_thuoc,
          title: R.string.home_medicine_reminder.tr(),
          subtitle: R.string.home_daily_care_desc_medicine_reminder.tr(),
          slug: slug,
          navigatorName: NavigatorName.medicine_check,
        );
      case HomeDailyCareSlug.connectDevice:
        return HomeUtilityData(
          icon: R.icons.ic_ti_ket_noi_thiet_bi,
          title: R.string.connect_device_home.tr(),
          subtitle: R.string.home_daily_care_desc_connect_device.tr(),
          slug: slug,
          navigatorName: NavigatorName.connect_device_app,
        );
      case HomeDailyCareSlug.sampleMenu:
        return HomeUtilityData(
          icon: R.icons.ic_ti_thuc_don_mau,
          title: R.string.sample_menu.tr(),
          subtitle: R.string.home_daily_care_desc_sample_menu.tr(),
          slug: slug,
          navigatorName: NavigatorName.food_menu,
        );
      case HomeDailyCareSlug.glucoseSchedule:
        return HomeUtilityData(
          icon: R.icons.ic_ti_lich_do_duong_huyet,
          title: R.string.blood_sugar_schedule_single_line.tr(),
          subtitle: R.string.home_daily_care_desc_glucose_schedule.tr(),
          slug: slug,
          navigatorName: NavigatorName.schedule_glucose,
        );
      case HomeDailyCareSlug.goalSetting:
        return HomeUtilityData(
          icon: R.icons.ic_ti_thiet_lap_muc_tieu,
          title: R.string.goal_setting.tr(),
          subtitle: R.string.home_daily_care_desc_goal.tr(),
          slug: slug,
          navigatorName: NavigatorName.goal_setting,
        );
      case HomeDailyCareSlug.reminder:
        return HomeUtilityData(
          icon: R.icons.ic_ti_lich_nhac_nho,
          title: R.string.reminder_calendar.tr(),
          subtitle: R.string.home_daily_care_desc_reminder.tr(),
          slug: slug,
          navigatorName: NavigatorName.reminder,
        );
      case HomeDailyCareSlug.homeVisit:
        // Opens the partner from BENEFIT_AT_HOME_INFO; no config, no tile.
        final atHome = FirebaseRemoteSetting.instance.benefitAtHomeInfo;
        if (atHome == null || atHome.trim().isEmpty) return null;
        return HomeUtilityData(
          icon: R.icons.ic_ti_kham_tai_nha,
          title: R.string.benefit_at_home.tr(),
          subtitle: R.string.home_daily_care_desc_home_visit.tr(),
          slug: slug,
          navigatorName: actionAtHome,
        );
      case HomeDailyCareSlug.healthConsulting:
        return HomeUtilityData(
          icon: R.icons.ic_ql_tu_van_bac_si,
          title: R.string.health_consulting.tr(),
          subtitle: R.string.home_daily_care_desc_health_consulting.tr(),
          slug: slug,
          navigatorName: NavigatorName.dsmes_booking,
        );
      case HomeDailyCareSlug.referral:
        return HomeUtilityData(
          icon: R.icons.ic_nv_ket_noi,
          title: R.string.diab_refferal.tr(),
          subtitle: R.string.home_daily_care_desc_referral.tr(),
          slug: slug,
          navigatorName: actionShare,
        );
    }
    return null;
  }
}

class HomeDailyCareNavigator {
  HomeDailyCareNavigator._();

  /// Opens [item]. "Xem tất cả" is handled by the caller (it needs the list).
  static void open(BuildContext context, HomeUtilityData item) {
    final routeName = item.navigatorName;
    switch (routeName) {
      case HomeDailyCareCatalog.actionShare:
        final shareLink = BranchioLinkConfig.instance.shareLink;
        if (shareLink != null) {
          AppShare.instance.userReferralCode(context, shareLink);
        }
        return;
      case HomeDailyCareCatalog.actionAtHome:
        openAtHome(context);
        return;
    }
    if (routeName.startsWith('/')) {
      Navigator.pushNamed(context, routeName);
      return;
    }
    Console.log('missing handler for routeName: $routeName');
  }

  /// "Khám tại nhà": partner intro configured by Remote Config
  /// `BENEFIT_AT_HOME_INFO`. Missing or malformed config → nothing to open.
  static void openAtHome(BuildContext context) {
    final raw = FirebaseRemoteSetting.instance.benefitAtHomeInfo;
    if (raw == null || raw.isEmpty) return;
    try {
      final payload = jsonDecode(raw) as Map<String, dynamic>;
      Navigator.pushNamed(
        context,
        NavigatorName.benefit_partner_intro,
        arguments: {'item': MyBenefitItem.fromJson(payload)},
      );
    } catch (_) {
      // Same as before the redesign: a bad config just does nothing.
    }
  }
}
