import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/booking_clinic/pages/booking_clinic_payment_page.dart';
import 'package:medical/src/widget/booking_clinic/pages/booking_clinic_select_service.dart';
import 'package:medical/src/widget/booking_clinic/pages/other_diseases_page.dart';
import 'package:medical/src/widget/booking_doctor/pages/booking_doctor_detail_page.dart';
import 'package:medical/src/widget/booking_doctor/pages/booking_doctor_provider_page.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_appointment_history_page.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_booking_detail.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_booking_offline_page.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_booking_online_join_call_page.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_booking_select_datetime.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_confirm_create_information_page.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_navigation_mixin.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_select_service_page.dart';

class BookingDoctorPage extends StatefulWidget {
  final int? pendingDoctorId;
  final bool fromWebinar;

  const BookingDoctorPage({
    Key? key,
    this.pendingDoctorId,
    this.fromWebinar = false,
  }) : super(key: key);

  @override
  _BookingDoctorPageState createState() => _BookingDoctorPageState();
}

class _BookingDoctorPageState extends State<BookingDoctorPage> {
  late DsmesAppointmentCubit _cubit;
  String _currentRoute = '/';

  final _navigatorKey = DsmesNavigationMixin.createNavigatorKey();

  @override
  void initState() {
    super.initState();
    final AppRepository repository = AppRepository();
    _cubit = DsmesAppointmentCubit(repository);
    DsmesNavigationMixin.setActiveNavigator(_navigatorKey);
    // The root route is the doctor list (no specialty step); booked
    // appointments live behind its "Lịch hẹn" button. Keep user registration
    // logic inside initDsmesBooking.
    _cubit.initDsmesBooking(isLoadAppointments: false);

    // Auto-navigate to doctor detail if pendingDoctorId is provided
    if (widget.pendingDoctorId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToDoctorDetail();
      });
    }
  }

  Future<void> _navigateToDoctorDetail() async {
    if (widget.pendingDoctorId == null) return;

    // Show loading if coming from webinar
    if (widget.fromWebinar) {
      BotToast.showLoading();
    }

    try {
      // Fetch doctor detail to get clinic information
      final detailSuccess = await _cubit.getDoctorDetail(
        id: widget.pendingDoctorId!,
        isLoading: false,
      );

      if (!detailSuccess) {
        if (widget.fromWebinar) BotToast.closeAllLoading();
        return;
      }

      final ownerClinic = _cubit.selectedDoctor?.getFirstOwnerClinic();

      if (ownerClinic == null) {
        if (widget.fromWebinar) BotToast.closeAllLoading();
        return;
      }

      // Fetch doctor rate
      await _cubit.getDoctorRate(id: widget.pendingDoctorId!);

      // Fetch clinic detail
      final clinicDetailSuccess = await _cubit.getClinicDetail(
        id: ownerClinic.id,
        isLoading: false,
      );

      if (detailSuccess && clinicDetailSuccess) {
        // When fromWebinar, keep loading visible until detail page appears (it closes in initState)
        if (!widget.fromWebinar) BotToast.closeAllLoading();
        DsmesNavigationMixin.getNavigationKey()
            .currentState
            ?.pushNamed(NavigatorName.doctor_detail, arguments: {
          'clinicId': ownerClinic.id,
          'doctorId': widget.pendingDoctorId,
          'bookingType': Const.BOOKING_TYPE_DOCTOR,
          'fromWebinar': widget.fromWebinar,
        });
      } else {
        // Close loading if navigation fails
        if (widget.fromWebinar) BotToast.closeAllLoading();
      }
    } catch (e) {
      if (widget.fromWebinar) BotToast.closeAllLoading();
      print('Error navigating to doctor detail: $e');
    }
  }

  @override
  void dispose() {
    BotToast.closeAllLoading();
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

              // If from webinar, always allow root pop to go back to webinar page
              // Return true to allow the pop to proceed
              if (widget.fromWebinar) {
                BotToast.closeAllLoading();
                return true; // Allow the pop to proceed
              }

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
                      builder: (_) => BookingDoctorProvidersPage(
                        specialtyId: 0,
                        bookingType: Const.BOOKING_TYPE_DOCTOR,
                      ),
                    );
                  case NavigatorName.dsmes_booking_history:
                    Map<String, dynamic>? args =
                        settings.arguments as Map<String, dynamic>?;
                    // Fresh cubit, decoupled from this page's shared _cubit
                    // — see the identical fix in booking_clinic_page.dart's
                    // same route case for why.
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
                  case NavigatorName.doctor_detail:
                    {
                      Map<String, dynamic>? args =
                          settings.arguments as Map<String, dynamic>?;
                      return _buildRoute(
                        settings,
                        BookingDoctorDetailPage(
                          clinicId: args!["clinicId"],
                          doctorId: args["doctorId"],
                          bookingType: args["bookingType"],
                          fromWebinar: args["fromWebinar"] ?? false,
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
                          bookingType: args["bookingType"],
                        ),
                      );
                    }
                  case NavigatorName.doctor_providers:
                    {
                      Map<String, dynamic>? args =
                          settings.arguments as Map<String, dynamic>?;
                      return _buildRoute(
                        settings,
                        BookingDoctorProvidersPage(
                          specialtyId: args!["specialtyId"],
                          specialtyName: args["specialtyName"],
                          bookingType: args["bookingType"],
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
