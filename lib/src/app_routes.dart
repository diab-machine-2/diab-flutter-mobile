import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/repository/weight_repository.dart';
import 'package:medical/src/widget/BloodSugar/widget/blood_sugar_image_capture.dart';
import 'package:medical/src/widget/booking_clinic/booking_clinic_page.dart';
import 'package:medical/src/widget/BloodPressure/bloodpressure_result.dto.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_bloc.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_input_bloc.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi/add_bmi_page.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi/revise_weight_page.dart';
import 'package:medical/src/widget/Bmi/views/bmi_instruction/bmi_instruction_page.dart';
import 'package:medical/src/widget/Bmi/views/bmi_on_boarding/bmi_on_boarding_page.dart';
import 'package:medical/src/widget/Bmi/views/bmi_overview.dart/bmi_overview_page.dart';
import 'package:medical/src/widget/Bmi/views/bmi_statistical_data/bmi_statistical_data_page.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_page.dart';
import 'package:medical/src/widget/medicine/medicine_check_page.dart';
import 'package:medical/src/widget/medicine/photo_picker_page.dart';
import 'package:medical/src/widget/medicine/prescription_add_page.dart';
import 'package:medical/src/widget/medicine/tutorial_page.dart';
import 'package:medical/src/widget/meeting/meeting_prepare_page.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/create_goal/create_goal.dart';
import 'package:medical/src/widget/subscription/pages/paywall_screen.dart';
import 'package:medical/src/widget/utilities/utilities_page.dart';
import 'package:medical/src/widget/phone_update/update_phone_number_page.dart';
import 'package:medical/src/widget/phone_update/confirm_phone_verify_otp_page.dart';

import 'modal/food/food_model.dart';
import 'utils/navigator_name.dart';
import 'widget/BloodPressure/add_bloodpressure_result.dart';
import 'widget/BloodPressure/bloodPressure_detail_listing.dart';
import 'widget/BloodPressure/intro/bloodpressure_intro_1st_page.dart';
import 'widget/BloodPressure/intro/bloodpressure_intro_2nd_page.dart';
import 'widget/BloodSugar/add_bloodSugar_result.dart';
import 'widget/BloodSugar/bloodSugar_detail.dart';
import 'widget/BloodSugar/bloodSugar_result.dto.dart';
import 'widget/Food/confirm_gen_food.dart';
import 'widget/Food/daily_nutrition/daily_nutrition.dart';
import 'widget/Food/food_image_capture.dart';
import 'widget/food_menu_screens/food_menu/food_menu.dart';
import 'widget/glucose_intro/glucose_intro_1st_page.dart';
import 'widget/glucose_intro/glucose_intro_2nd_page.dart';
import 'widget/home/schema/home_schema.dart';
import 'widget/medicine/capture_prescription_page.dart';
import 'widget/medicine/medicine_add_page.dart';
import 'widget/medicine/medicine_search_page.dart';
import 'widget/medicine/onboarding_page.dart';
import 'widget/medicine/prescription_list_page.dart';
import 'widget/medicine/prescription_remind_page.dart';
import 'widget/tabbar/tabbar_v2.dart';

class AppRoutes {
  static Route<dynamic>? tryGenerateNewRoutes(RouteSettings settings) {
    Widget? page;
    switch (settings.name) {
      // Override tabbar + home to new UI
      case NavigatorName.tabbar:
        {
          String sharedCode = '';
          bool isRedirectFromNotification = false;
          if (settings.arguments != null) {
            if (settings.arguments is String) {
              sharedCode = settings.arguments! as String;
            } else if (settings.arguments is Map<String, dynamic>) {
              final data = settings.arguments as Map<String, dynamic>?;
              isRedirectFromNotification = data!['isRedirectFromNotification'];
            }
          }

          // Wrap with Weight (BMI) Bloc
          page = BlocProvider(
            create: (_) => BmiBloc(WeightRepository.instance),
            child: TabbarController(
              sharedCode: sharedCode,
              isRedirectFromNotification: isRedirectFromNotification,
            ),
          );
          break;
        }
      case NavigatorName.food_menu:
        {
          final data = settings.arguments as Map<String, dynamic>?;
          // empty goal
          page = FoodMenuPage(
            smartGoal: data?['smartGoal'],
          );
          break;
        }
      case NavigatorName.utilities:
        {
          final utilities = settings.arguments as List<HomeUtilityData>;
          page = UtilitiesPage(utilities: utilities);
          break;
        }
      case NavigatorName.add_nutrition:
        {
          page = DailyNutritionPage(type: "input", id: null);
          break;
        }
      case NavigatorName.add_goal:
        {
          page = CreateGoalPage(AppSettings.smartGoalDayList);
          break;
        }
      case NavigatorName.meeting_prepare:
        {
          page = MeetingPreparePage();
          break;
        }
      case NavigatorName.dsmes_booking:
        {
          final data = settings.arguments as Map<String, dynamic>?;
          page = DsmesAppointmentPage(
            pendingOnlineDeeplink: data?['pendingOnlineDeeplink'],
            pendingClinicId: data?['pendingClinicId'],
            pendingMode: data?['pendingMode'],
          );
          break;
        }
      case NavigatorName.booking_clinic:
        {
          page = BookingClinicPage();
          break;
        }
      case NavigatorName.add_blood_sugar_result:
        page = PageAddBloodSugarResult(
            data: settings.arguments as BloodSugarResultDto);
        break;
      case NavigatorName.glucose_intro_1st_page:
        final data = settings.arguments as Map<String, dynamic>?;
        page = GlucoseIntro1stPage(
          goalId: data?['goalId'],
        );
        break;
      case NavigatorName.glucose_intro_2nd_page:
        page = GlucoseIntro2ndPage();
        break;
      case NavigatorName.detail_blood_sugar_listing:
        final data = settings.arguments as Map<String, dynamic>?;
        page = BloodSugarDetailController(
          glucoseID: data?['glucoseID'],
          initPeriodFilterType: data?['initPeriodFilterType'],
          glucoseDistributionType: data?['glucoseDistributionType'],
        );
        break;
      case NavigatorName.blood_sugar_image_capture:
        final data = settings.arguments as Map<String, dynamic>?;
        page = BloodSugarImageCapture();
        break;
      case NavigatorName.paywall_screen:
        {
          page = PaywallScreen();
          break;
        }
      // ~ Huyet Ap (mới) ~
      case NavigatorName.blood_pressure_intro_1st_page:
        final data = settings.arguments as Map<String, dynamic>?;
        page = BloodPressureIntro1stPage(
          goalId: data?['goalId'],
        );
        break;
      case NavigatorName.blood_pressure_intro_2nd_page:
        page = BloodPressureIntro2ndPage();
        break;
      case NavigatorName.add_bloodpressure_result:
        page = PageAddBloodPressureResult(
            data: settings.arguments as BloodPressureResultDto);
        break;
      case NavigatorName.detail_bloodpressure_listing:
        final data = settings.arguments as Map<String, dynamic>?;
        page = BloodPressureDetailListingController(
          initBloodPressureID: data?['initBloodPressureID'],
          initPeriodFilterType: data?['initPeriodFilterType'],
          initBloodPressureRangeType: data?['initBloodPressureRangeType'],
        );
        break;
      // ~ END: Huyet Ap (mới) ~
      // 00 -- 00
      // ~ Dinh Duong (mới) ~
      case NavigatorName.confirm_food:
        final data = settings.arguments as Map<String, dynamic>?;
        page = ConfirmGeneratedFood(
          generatedFoods: (data?['foods'] ?? []) as List<FoodModel>,
          timeframe: data?['timeframe'] ?? '-',
          timeframeId: data?['timeframeId'] ?? '-',
          files: data?['files'] != null ? List<String>.from(data!['files']) : [],
        );
        break;
      case NavigatorName.food_image_capture:
        final data = settings.arguments as Map<String, dynamic>?;
        page = FoodImageCapture(
          timeframe: data?['timeframe'] ?? '-',
          timeframeId: data?['timeframeId'] ?? '-',
        );
        break;
      // ~ END: Dinh Duong (mới) ~
      case NavigatorName.add_bmi:
        final data = settings.arguments as Map<String, dynamic>?;
        page = (data?[BmiOnBoardingPage.bmiBlocKey] != null)
            ? BlocProvider<BmiBloc>.value(
                value: data?[BmiOnBoardingPage.bmiBlocKey],
                child: BmiOnBoardingPage(
                  type: data?['type'],
                  id: data?['id'],
                  goalId: data?['goalId'],
                  isCurrentBmi: data?['isCurrentBmi'],
                ),
              )
            : BlocProvider<BmiBloc>(
                create: (_) => BmiBloc(WeightRepository.instance),
                child: BmiOnBoardingPage(
                  type: data?['type'],
                  id: data?['id'],
                  goalId: data?['goalId'],
                  isCurrentBmi: data?['isCurrentBmi'],
                ),
              );
      case NavigatorName.bmiInputPage:
        final data = settings.arguments as Map<String, dynamic>?;
        page = MultiBlocProvider(
          providers: [
            BlocProvider<BmiInputBloc>(
              create: (_) => BmiInputBloc(WeightRepository.instance),
            ),
            (data?[AddBmiPage.bmiBlocKey] != null)
                ? BlocProvider<BmiBloc>.value(
                    value: data?[AddBmiPage.bmiBlocKey],
                  )
                : BlocProvider<BmiBloc>(
                    create: (_) => BmiBloc(WeightRepository.instance),
                  ),
          ],
          child: AddBmiPage(goalId: data?['goalId']),
        );
      case NavigatorName.bmiReviseRecordPage:
        final data = settings.arguments as Map<String, dynamic>?;
        page = MultiBlocProvider(
          providers: [
            BlocProvider<BmiInputBloc>(
              create: (_) => BmiInputBloc(WeightRepository.instance),
            ),
            BlocProvider<BmiBloc>.value(
              value: data?[ReviseWeightPage.bmiBlocKey],
            )
          ],
          child: const ReviseWeightPage(),
        );
      case NavigatorName.bmiOverviewPage:
        final data = settings.arguments as Map<String, dynamic>?;

        page = MultiBlocProvider(
          providers: [
            BlocProvider<BmiInputBloc>.value(
              value: data?[BmiOverviewPage.bmiInputBlocKey],
            ),
            BlocProvider<BmiBloc>.value(
              value: data?[AddBmiPage.bmiBlocKey],
            )
          ],
          child: const BmiOverviewPage(),
        );
      case NavigatorName.bmiHistoricalPage:
        final data = settings.arguments as Map<String, dynamic>?;
        page = BlocProvider<BmiBloc>.value(
          value: data?[BmiStatisticalDataPage.bmiBlocKey],
          child: const BmiStatisticalDataPage(),
        );
      case NavigatorName.bmiInstructionPage:
        final data = settings.arguments as Map<String, dynamic>?;
        page = BlocProvider<BmiBloc>.value(
          value: data?[BmiInstructionPage.bmiBlocKey],
          child: const BmiInstructionPage(),
        );
      // end region weight
      // Phone Update Flow
      case NavigatorName.update_phone_number:
        page = UpdatePhoneNumberPage();
        break;
      case NavigatorName.confirm_phone_verify_otp:
        final data = settings.arguments as Map<String, dynamic>?;
        page = ConfirmPhoneNumberVerifyOTPPage(
          phone: data?['phone'] ?? '',
          isPhoneNumberExist: data?['isPhoneNumberExist'] ?? false,
        );
        break;

      // Lịch dùng thuốc

      case NavigatorName.medicine_check:
        page = MedicineCheckPage();
        break;
      case NavigatorName.medicine:
        page = OnboardingPage();
        break;
      case NavigatorName.medicine_tutorial:
        page = TutorialPage();
        break;
      case NavigatorName.prescription_capture:
        page = CapturePrescriptionPage();
        break;
      case NavigatorName.medicine_photo_picker:
        page = PhotoPickerPage();
        break;
      case NavigatorName.medicine_search:
        final data = settings.arguments as Map<String, dynamic>?;
        final mode = data?['mode'] as MedicineMode?;
        final index = data?['index'];
        page = MedicineSearchPage(medicineMode: mode, index: index);
        break;
      case NavigatorName.medicine_add:
        final data = settings.arguments as Map<String, dynamic>?;
        final mode = data?['mode'] as MedicineMode?;
        final medicineItem = data?['medicineItem'];
        final medicine = data?['medicine'];
        final index = data?['index'];
        final isFromReuse = data?['isReuse'] as bool? ?? false;
        page = MedicineAddPage(
          medicineMode: mode,
          medicineTablet: medicineItem,
          medicine: medicine,
          index: index,
          isFromReuse: isFromReuse,
        );
        break;
      case NavigatorName.prescription_add:
        final data = settings.arguments as Map<String, dynamic>?;
        final mode = data?['mode'] as PrescriptionMode?;
        final medicineItem = data?['medicineItem'];
        final medicineItems = data?['medicineItems'];
        final prescription = data?['prescription'];
        page = PrescriptionAddPage(
          prescriptionMode: mode,
          medicineItem: medicineItem,
          medicineItems: medicineItems,
          prescription: prescription,
        );
        break;
      case NavigatorName.prescription_remind:
        final data = settings.arguments as Map<String, dynamic>?;
        final prescription = data?['prescription'];
        final paths = data?['paths'];
        page = PrescriptionRemindPage(prescription: prescription, paths: paths);
        break;
      case NavigatorName.prescription:
        final prescriptionData = settings.arguments as Map<String, dynamic>?;
        final initialBottomIndex = prescriptionData?['initialBottomIndex'] as int?;
        page = PrescriptionListPage(initialBottomIndex: initialBottomIndex);
        break;

      // ~ END: Lịch dùng thuốc ~

      default:
        break;
    }
    return page != null
        ? MaterialPageRoute(settings: settings, builder: (_) => page!)
        : null;
  }
}
