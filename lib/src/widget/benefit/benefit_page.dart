import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/benefit/benefit_branch_page.dart';
import 'package:medical/src/widget/benefit/benefit_calendar_section.dart';
import 'package:medical/src/widget/benefit/benefit_clinic_list_page.dart';
import 'package:medical/src/widget/benefit/benefit_confirm_page.dart';
import 'package:medical/src/widget/benefit/benefit_select_service_page.dart';
import 'package:medical/src/widget/benefit/benefit_specialty_page.dart';
import 'package:medical/src/widget/booking_clinic/pages/booking_clinic_payment_page.dart';
import 'package:medical/src/widget/booking_clinic/pages/booking_clinic_select_service.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_state.dart';
import 'package:medical/src/widget/benefit/benefit_booking_detail_page.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_booking_select_datetime.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_clinic_detail_page.dart';
import 'package:medical/src/widget/benefit/benefit_navigator_scope.dart';
import 'package:medical/src/widget/helper/show_message.dart';

/// Entry-point wrapper for the "Quyền lợi" booking flows.
///
/// [bookingType] should be either [Const.BENEFIT_BOOKING_AT_CLINIC] or
/// [Const.BENEFIT_BOOKING_TELEMEDICINE].
class BenefitPage extends StatefulWidget {
  final String bookingType;
  final String? specialtyName;

  const BenefitPage({
    Key? key,
    required this.bookingType,
    this.specialtyName,
  }) : super(key: key);

  @override
  _BenefitPageState createState() => _BenefitPageState();
}

class _BenefitPageState extends State<BenefitPage> with Observer {
  late DsmesAppointmentCubit _cubit;
  String _currentRoute = '/';

  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    Observable.instance.addObserver(this);
    final AppRepository repository = AppRepository();
    _cubit = DsmesAppointmentCubit(repository);
    _cubit.isBenefitFlow = true;
    // Pre-call to register docosan user & get token (no appointments needed)
    _cubit.initDsmesBooking(isLoadAppointments: false);
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
    // No specific observable events needed here
  }

  Route<dynamic>? _buildRoute(RouteSettings settings, Widget page) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => page,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<DsmesAppointmentCubit, DsmesAppointmentState>(
        listener: (context, state) {
          if (state is DsmesAppointmentFailure) {
            BotToast.closeAllLoading();
            Message.showToastMessage(context, state.error);
          } else {
            BotToast.closeAllLoading();
          }
        },
        child: Scaffold(
          backgroundColor: R.color.backgroundColorNew,
          body: WillPopScope(
            onWillPop: () async {
              if (_navigatorKey.currentState?.canPop() ?? false) {
                _navigatorKey.currentState?.pop();
                return false;
              } else {
                BotToast.closeAllLoading();
                Navigator.of(context, rootNavigator: true).pop();
              }
              return true;
            },
            child: BenefitNavigatorScope(
              navigatorKey: _navigatorKey,
              child: Navigator(
                key: _navigatorKey,
              onGenerateRoute: (settings) {
                _currentRoute = settings.name ?? '/';
                switch (settings.name) {
                  case '/':
                    return MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: _cubit,
                        child: BenefitSpecialtyPage(
                          bookingType: widget.bookingType,
                          specialtyName: widget.specialtyName,
                        ),
                      ),
                    );

                  case NavigatorName.benefit_clinic_list:
                    {
                      final args =
                          settings.arguments as Map<String, dynamic>?;
                      return _buildRoute(
                        settings,
                        BenefitClinicListPage(
                          bookingType: args!['bookingType'] ?? widget.bookingType,
                          clinicIds: (args['clinicIds'] as List<dynamic>?)?.cast<String>() ?? [],
                          specialtyName: args['specialtyName'] as String?,
                        ),
                      );
                    }

                  case NavigatorName.benefit_calendar:
                    {
                      final args =
                          settings.arguments as Map<String, dynamic>?;
                      return _buildRoute(
                        settings,
                        BenefitCalendarSection(
                          serviceType: args!['serviceType'],
                          action: args['action'],
                          appointmentId: args['appointmentId'],
                          bookingType: args['bookingType'],
                          specialtyName: args['specialtyName'] as String?,
                        ),
                      );
                    }

                  case NavigatorName.dsmes_booking_select_date:
                    {
                      final args =
                          settings.arguments as Map<String, dynamic>?;
                      return _buildRoute(
                        settings,
                        DsmesCalendarSection(
                          serviceType: args!['serviceType'],
                          action: args['action'],
                          appointmentId: args['appointmentId'],
                          isMergedSchedule: args['isMergedSchedule'] ?? false,
                          bookingType: args['bookingType'],
                        ),
                      );
                    }

                  case NavigatorName.benefit_confirm_information:
                    {
                      final args =
                          settings.arguments as Map<String, dynamic>?;

                      // For at-clinic benefit flow, show branch selection first
                      if (widget.bookingType ==
                              Const.BENEFIT_BOOKING_AT_CLINIC &&
                          _cubit.selectedClinicBranches != null &&
                          _cubit.selectedClinicBranches!.isNotEmpty) {
                        return _buildRoute(
                          settings,
                          BenefitBranchPage(
                            serviceType: args!['serviceType'],
                            action: args['action'] ?? 'create',
                            appointmentId: args['appointmentId'],
                            bookingType: args['bookingType'] ??
                                Const.BENEFIT_BOOKING_AT_CLINIC,
                            isBypassPayment: false,
                            specialtyName:
                                args['specialtyName'] as String?,
                          ),
                        );
                      }

                      // Telemedicine or at-clinic without branches → confirm directly
                      return _buildRoute(
                        settings,
                        BenefitConfirmPage(
                          serviceType: args!['serviceType'],
                          action: args['action'] ?? 'create',
                          appointmentId: args['appointmentId'],
                          bookingType: args['bookingType'] ??
                              Const.BENEFIT_BOOKING_AT_CLINIC,
                          isBypassPayment: widget.bookingType ==
                              Const.BENEFIT_BOOKING_TELEMEDICINE,
                          branchName: args['branchName'] as String?,
                          branchAddress: args['branchAddress'] as String?,
                          branchId: args['branchId'] as int?,
                          specialtyName:
                              args['specialtyName'] as String?,
                        ),
                      );
                    }

                  case NavigatorName.benefit_booking_detail:
                    {
                      final args =
                          settings.arguments as Map<String, dynamic>?;
                      return _buildRoute(
                        settings,
                        BenefitBookingDetailPage(
                          serviceType: args!['serviceType'],
                          appointment: args['appointment'],
                          bookingType: args['bookingType'],
                          previousRoute: args['previousRoute'] as String?,
                        ),
                      );
                    }

                  case NavigatorName.dsmes_clinic_detail:
                    {
                      final args =
                          settings.arguments as Map<String, dynamic>?;
                      return _buildRoute(
                        settings,
                        DsmesClinicDetailPage(
                          clinicId: args!['clinicId'],
                          bookingType: args['bookingType'],
                        ),
                      );
                    }

                  case NavigatorName.benefit_branch:
                    {
                      final args =
                          settings.arguments as Map<String, dynamic>?;
                      return _buildRoute(
                        settings,
                        BenefitBranchPage(
                          serviceType: args!['serviceType'],
                          action: args['action'] ?? 'create',
                          appointmentId: args['appointmentId'],
                          bookingType: args['bookingType'] ??
                              Const.BENEFIT_BOOKING_AT_CLINIC,
                          isBypassPayment: false,
                          specialtyName:
                              args['specialtyName'] as String?,
                        ),
                      );
                    }

                  case NavigatorName.benefit_select_service:
                    {
                      final args =
                          settings.arguments as Map<String, dynamic>?;
                      return _buildRoute(
                        settings,
                        BenefitSelectServicePage(
                          serviceType: args!['serviceType'],
                          action: args['action'] ?? 'create',
                          appointmentId: args['appointmentId'] as int?,
                          bookingType: args['bookingType'] ??
                              Const.BOOKING_TYPE_CLINIC,
                          specialtyName: args['specialtyName'] as String?,
                          branchName: args['branchName'] as String?,
                          branchAddress: args['branchAddress'] as String?,
                          branchId: args['branchId'] as int?,
                        ),
                      );
                    }

                  case NavigatorName.clinic_select_service:
                    {
                      final args =
                          settings.arguments as Map<String, dynamic>?;
                      return _buildRoute(
                        settings,
                        BookingCLinicSelectServicePage(
                          clinic: args!['clinic'],
                          serviceType: args['serviceType'],
                          action: args['action'],
                          bookingType: args['bookingType'],
                        ),
                      );
                    }

                  case NavigatorName.clinic_payment:
                    {
                      final args =
                          settings.arguments as Map<String, dynamic>?;
                      return _buildRoute(
                        settings,
                        BookingClinicPaymentPage(
                          totalPrice: args!['totalPrice'],
                          serviceType: args['serviceType'],
                          bookingType: args['bookingType'],
                        ),
                      );
                    }

                  default:
                    return null;
                }
              },
            ),
            ),  // BenefitNavigatorScope
          ),
        ),
      ),
    );
  }
}
