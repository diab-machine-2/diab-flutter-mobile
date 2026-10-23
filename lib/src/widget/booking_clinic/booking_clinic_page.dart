import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/booking_clinic/helper/booking_clinic_helper.dart';
import 'package:medical/src/widget/booking_clinic/model/clinic_specialty_model.dart';
import 'package:medical/src/widget/booking_clinic/specialty_list_cubit.dart';
import 'package:medical/src/widget/booking_clinic/pages/booking_clinic_payment_page.dart';
import 'package:medical/src/widget/booking_clinic/pages/booking_clinic_provider_page.dart';
import 'package:medical/src/widget/booking_clinic/pages/booking_clinic_select_service.dart';
import 'package:medical/src/widget/booking_clinic/pages/other_diseases_page.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_state.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_appointment_history_page.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_booking_detail.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_booking_offline_page.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_booking_online_join_call_page.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_booking_select_datetime.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_clinic_detail_page.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_confirm_create_information_page.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_navigation_mixin.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_select_service_page.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/specialty_catalog.dart';
import 'package:medical/src/widgets/specialty_select_view.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_appointment_model.dart';

class BookingClinicPage extends StatefulWidget {
  final bool isExamination;
  final bool isExaminationAtClinic;
  final int? examinationClinicId;
  final String? examinationType;
  final String? smartGoalId;

  /// The examination activity being booked (sent back when completing it).
  final int? smartGoalExecuteDayTimes;
  final int? smartGoalAppointmentDate;

  const BookingClinicPage({
    Key? key,
    this.isExamination = false,
    this.isExaminationAtClinic = false,
    this.examinationClinicId,
    this.examinationType,
    this.smartGoalId,
    this.smartGoalExecuteDayTimes,
    this.smartGoalAppointmentDate,
  }) : super(key: key);

  @override
  _BookingClinicPageState createState() => _BookingClinicPageState();
}

class _BookingClinicPageState extends State<BookingClinicPage> {
  late DsmesAppointmentCubit _cubit;
  late final SpecialtyListCubit _specialtyCubit;
  String _currentRoute = '/';

  final _navigatorKey = DsmesNavigationMixin.createNavigatorKey();

  @override
  void initState() {
    super.initState();
    final AppRepository repository = AppRepository();
    _cubit = DsmesAppointmentCubit(repository);
    _specialtyCubit = SpecialtyListCubit(repository, isTelemedicine: false);
    DsmesNavigationMixin.setActiveNavigator(_navigatorKey);
    _warmupLocation();
    // Initialize Docosan user & location. Booked appointments are no longer
    // listed here; they live behind the "Lịch hẹn" button.
    _cubit.initDsmesBooking(isLoadAppointments: false);
    // Also in the examination flow: backing out of it lands on this grid.
    _specialtyCubit.load();

    if (widget.isExamination) {
      // Delay navigation to ensure nested navigator is ready.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.isExaminationAtClinic) {
          _startExaminationAtClinicFlow();
        } else {
          _startExaminationAtHomeFlow();
        }
      });
    }
  }

  Future<void> _warmupLocation() async {
    final cancel = BotToast.showLoading(allowClick: false);
    try {
      await resolveBookingProvidersPosition().timeout(
        const Duration(seconds: 6),
        onTimeout: () => null,
      );
    } catch (_) {
      // Best-effort warmup only.
    } finally {
      cancel();
    }
  }

  @override
  void dispose() {
    BotToast.closeAllLoading();
    _specialtyCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: R.color.backgroundColorNew,
        ),
        child: BlocProvider(
          create: (context) => _cubit,
          child: WillPopScope(
            onWillPop: () async {
              print('[POP] root pop scope');
              if (_currentRoute == NavigatorName.dsmes_booking_detail) {
                FocusScope.of(
                        DsmesNavigationMixin.getNavigationKey().currentContext!)
                    .unfocus();

                // final route = ModalRoute.of(
                //         DsmesNavigationMixin.getNavigationKey().currentContext!)
                //     ?.settings;
                // print('[POP] route: $route');
                // final args = route?.arguments as Map<String, dynamic>?;
                // print('[POP] Args: ${route?.arguments}');
                // final previousRoute = args?['previousRoute'] as String?;

                // if (previousRoute == NavigatorName.dsmes_booking_history ||
                //     previousRoute == NavigatorName.dsmes_clinic_detail) {
                //   DsmesNavigationMixin.getNavigationKey().currentState?.pop();
                //   return false;
                // }
                DsmesNavigationMixin.getNavigationKey()
                    .currentState
                    ?.popUntil((route) => route.isFirst);
                return false;
              }

              final route = ModalRoute.of(
                      DsmesNavigationMixin.getNavigationKey().currentContext!)
                  ?.settings;
              final args = route?.arguments as Map<String, dynamic>?;
              final isEditing = args?['isEditing'] ?? false;
              final previousRoute = args?['previousRoute'];

              if (isEditing && previousRoute != null) {
                DsmesNavigationMixin.getNavigationKey()
                    .currentState
                    ?.pushReplacementNamed(previousRoute, arguments: {
                  'serviceType': args?['serviceType'],
                  'action': args?['action'],
                });
                return false;
              }

              if (DsmesNavigationMixin.getNavigationKey()
                      .currentState
                      ?.canPop() ??
                  false) {
                DsmesNavigationMixin.getNavigationKey().currentState?.pop();
                return false;
              } else {
                BotToast.closeAllLoading();
                Navigator.of(context, rootNavigator: true).pop();
              }
              return true;
            },
            child: Navigator(
              key: DsmesNavigationMixin.getNavigationKey(),
              onGenerateRoute: (settings) {
                // Log current route name
                print('[ROUTE] Current Route: ${settings.name}');
                _currentRoute = settings.name ?? '/';
                // Log full navigator stack
                print(
                    '[ROUTE] Navigator Stack: ${DsmesNavigationMixin.getNavigationKey().currentState?.toString()}');
                switch (settings.name) {
                  case '/':
                    return MaterialPageRoute(
                      builder: (_) => _buildMainContent(context),
                    );
                  case NavigatorName.dsmes_booking_history:
                    Map<String, dynamic>? args =
                        settings.arguments as Map<String, dynamic>?;
                    // Fresh cubit, decoupled from this page's shared _cubit:
                    // this history page fetches its own appointment list on
                    // mount, and doing so on the shared cubit would make
                    // this page's ambient BlocConsumer above react to that
                    // fetch too, flashing its loading toast on top of the
                    // history page's own shimmer skeleton.
                    return _buildRoute(
                      settings,
                      BlocProvider<DsmesAppointmentCubit>.value(
                        value: DsmesAppointmentCubit(AppRepository()),
                        child: DsmesAppointmentHistoryPage(
                          bookingType: args!["bookingType"],
                        ),
                      ),
                    );
                  case NavigatorName.dsmes_booking_offline:
                    Map<String, dynamic>? args =
                        settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(
                      settings,
                      DsmesBookingOfflinePage(
                        serviceType: args!["serviceType"],
                      ),
                    );
                  case NavigatorName.dsmes_booking_select_date:
                    {
                      Map<String, dynamic>? args =
                          settings.arguments as Map<String, dynamic>?;
                      return _buildRoute(
                        settings,
                        DsmesCalendarSection(
                          serviceType: args!["serviceType"],
                          action: args["action"],
                          appointmentId: args["appointmentId"],
                          isMergedSchedule: args["isMergedSchedule"] ?? false,
                          bookingType: args["bookingType"],
                        ),
                      );
                    }
                  case NavigatorName.dsmes_confirm_information:
                    {
                      Map<String, dynamic>? args =
                          settings.arguments as Map<String, dynamic>?;
                      return _buildRoute(
                        settings,
                        DsmesConfirmCreateInformation(
                          serviceType: args!["serviceType"],
                          action: args["action"],
                          appointmentId: args["appointmentId"],
                          bookingType: args["bookingType"],
                        ),
                      );
                    }
                  case NavigatorName.dsmes_booking_detail:
                    {
                      Map<String, dynamic>? args =
                          settings.arguments as Map<String, dynamic>?;
                      // Fresh cubit, decoupled from this page's shared _cubit:
                      // when appointment/branch ids are given (no pre-resolved
                      // appointment), this page fetches its own detail data,
                      // and doing so on the list page's cubit would make the
                      // list's ambient BlocConsumer above react to those
                      // fetches too, flashing its loading toast a second time.
                      return _buildRoute(
                        settings,
                        BlocProvider<DsmesAppointmentCubit>.value(
                          value: DsmesAppointmentCubit(AppRepository()),
                          child: DsmesBookingDetail(
                            serviceType: args!["serviceType"],
                            appointment: args["appointment"],
                            appointmentId: args["appointmentId"] as int?,
                            branchId: args["branchId"] as int?,
                            bookingType: args["bookingType"],
                          ),
                        ),
                      );
                    }
                  case NavigatorName.dsmes_clinic_detail:
                    {
                      Map<String, dynamic>? args =
                          settings.arguments as Map<String, dynamic>?;
                      return _buildRoute(
                        settings,
                        DsmesClinicDetailPage(
                          clinicId: args!["clinicId"],
                          bookingType: args["bookingType"],
                        ),
                      );
                    }
                  case NavigatorName.dsmes_select_service:
                    {
                      Map<String, dynamic>? args =
                          settings.arguments as Map<String, dynamic>?;
                      return _buildRoute(
                        settings,
                        DsmesSelectServicePage(
                          serviceType: args!["serviceType"],
                          action: args["action"],
                          clinic: args["clinic"],
                        ),
                      );
                    }

                  case NavigatorName.dsmes_booking_online_join_room:
                    {
                      Map<String, dynamic>? args =
                          settings.arguments as Map<String, dynamic>?;
                      return _buildRoute(
                        settings,
                        WebViewScreen(
                          telemedicineId: args!["telemedicineId"],
                        ),
                      );
                    }
                  case NavigatorName.other_diseases:
                    {
                      Map<String, dynamic>? args =
                          settings.arguments as Map<String, dynamic>?;
                      return _buildRoute(
                        settings,
                        OtherDiseasesPage(
                          specialties: args!["specialties"],
                        ),
                      );
                    }
                  case NavigatorName.clinic_providers:
                    {
                      Map<String, dynamic>? args =
                          settings.arguments as Map<String, dynamic>?;
                      return _buildRoute(
                        settings,
                        BookingClinicProvidersPage(
                          specialtyId: args!["specialtyId"],
                          examinationType: args["examinationType"],
                          isExamination: args["isExamination"] ?? false,
                        ),
                      );
                    }
                  case NavigatorName.clinic_select_service:
                    {
                      Map<String, dynamic>? args =
                          settings.arguments as Map<String, dynamic>?;
                      return _buildRoute(
                        settings,
                        BookingCLinicSelectServicePage(
                          clinic: args!["clinic"],
                          serviceType: args["serviceType"],
                          action: args["action"],
                          bookingType: args["bookingType"],
                        ),
                      );
                    }
                  case NavigatorName.clinic_payment:
                    {
                      Map<String, dynamic>? args =
                          settings.arguments as Map<String, dynamic>?;
                      return _buildRoute(
                        settings,
                        BookingClinicPaymentPage(
                          totalPrice: args!["totalPrice"],
                          serviceType: args["serviceType"],
                          bookingType: args["bookingType"],
                        ),
                      );
                    }
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

  Widget _buildMainContent(BuildContext context) {
    return BlocConsumer<DsmesAppointmentCubit, DsmesAppointmentState>(
      listener: (context, state) {
        print('Current state: $state');
        // For examination flow, we manage loading manually so that it stays
        // visible until the datetime page has finished loading.
        if (!widget.isExamination) {
          if (state is DsmesAppointmentFailure) {
            BotToast.closeAllLoading();
            Message.showToastMessage(context, state.error);
          } else {
            BotToast.closeAllLoading();
          }
        }
      },
      builder: (
        BuildContext context,
        DsmesAppointmentState state,
      ) {
        print('Building with state: $state');
        if (!widget.isExamination) {
          if (state is DsmesAppointmentLoading) {
            BotToast.showLoading(allowClick: false);
          } else if (state is! InitialDsmesAppointmentState) {
            // Not on the first build: that would close _warmupLocation's
            // loading while the location permission prompt is still open.
            BotToast.closeAllLoading();
          }
        }
        return _buildPage(context);
      },
    );
  }

  Widget _buildPage(BuildContext context) {
    return BlocBuilder<SpecialtyListCubit, SpecialtyListState>(
      bloc: _specialtyCubit,
      builder: (context, state) => SpecialtySelectView(
        status: switch (state) {
          SpecialtyListSuccess() => SpecialtySelectStatus.ready,
          SpecialtyListError() => SpecialtySelectStatus.error,
          _ => SpecialtySelectStatus.loading,
        },
        items: [
          if (state is SpecialtyListSuccess)
            for (final specialty in state.specialties)
              SpecialtyCatalog.gridItem(specialty,
                  onTap: () => _onTapDiabSpecialty(specialty)),
        ],
        onRetry: _specialtyCubit.load,
        onBack: () => Navigator.of(context, rootNavigator: true).pop(),
        actions: [
          SpecialtyHistoryButton(
            onTap: () {
              _cubit.clearAppointments();

              DsmesNavigationMixin.getNavigationKey()
                  .currentState
                  ?.pushNamed(NavigatorName.dsmes_booking_history, arguments: {
                'bookingType': Const.BOOKING_TYPE_CLINIC,
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _startExaminationAtHomeFlow() async {
    // Show a global loading overlay to prevent user interaction on the
    // intermediate booking clinic container while we prepare the
    // examination flow and navigate to the datetime screen.
    BotToast.showLoading(allowClick: false);

    final clinicId =
        widget.examinationClinicId ?? Const.EXAMINATION_DEFAULT_CLINIC_ID;

    final detailSuccess =
        await _cubit.getClinicDetail(id: clinicId, isLoading: false);

    if (!detailSuccess || _cubit.selectedClinic == null) {
      BotToast.closeAllLoading();
      Message.showToastMessage(context, R.string.not_exist_clinic.tr());
      Navigator.of(context, rootNavigator: true).pop();
      return;
    }

    _cubit.setExaminationData(
      isExamination: true,
      examinationType: widget.examinationType,
      examinationLocation: Const.EXAMINATION_LOCATION_HOME,
      smartGoalId: widget.smartGoalId,
      smartGoalExecuteDayTimes: widget.smartGoalExecuteDayTimes,
      smartGoalAppointmentDate: widget.smartGoalAppointmentDate,
    );

    _cubit.initCreateDsmesBookingRequest(
        locale: DsmesNavigationMixin.getNavigationKey()
                .currentContext
                ?.locale
                .languageCode ??
            'vi',
        clearExamination: false);

    DsmesNavigationMixin.getNavigationKey().currentState?.pushNamed(
      NavigatorName.dsmes_booking_select_date,
      arguments: {
        'serviceType': DsmesAppointmentMode.telemedicine.toString(),
        'action': 'create',
        'bookingType': Const.BOOKING_TYPE_CLINIC,
        'isMergedSchedule': false,
      },
    );
  }

  Future<void> _startExaminationAtClinicFlow() async {
    // Set examination data in cubit
    _cubit.setExaminationData(
      isExamination: true,
      examinationType: widget.examinationType,
      examinationLocation: Const.EXAMINATION_LOCATION_CLINIC,
      smartGoalId: widget.smartGoalId,
      smartGoalExecuteDayTimes: widget.smartGoalExecuteDayTimes,
      smartGoalAppointmentDate: widget.smartGoalAppointmentDate,
    );

    // Navigate to provider page with empty specialtyId and examinationType
    DsmesNavigationMixin.getNavigationKey().currentState?.pushNamed(
      NavigatorName.clinic_providers,
      arguments: {
        'specialtyId': 0,
        'examinationType': widget.examinationType,
        'isExamination': true,
      },
    );
  }

  Future<void> _onTapDiabSpecialty(ClinicSpecialty specialty) async {
    // Picking a specialty is a normal booking: drop any examination the user
    // backed out of, so it can't complete that activity.
    _cubit.clearExaminationData();
    // Docosan id 0 = backend hasn't mapped this specialty yet (BE-5). The
    // provider search treats 0 as "no specialty" and would list unrelated
    // clinics, so stop here.
    if (specialty.id == 0) {
      BotToast.showSimpleNotification(
          title: R.string.empty_clinic_content.tr());
      return;
    }
    _cubit.clearClinicProviders();
    DsmesNavigationMixin.getNavigationKey()
        .currentState
        ?.pushNamed(NavigatorName.clinic_providers, arguments: {
      "specialtyId": specialty.id,
      "bookingType": Const.BOOKING_TYPE_CLINIC,
    });
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
