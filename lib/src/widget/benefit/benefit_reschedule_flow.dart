import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/benefit/benefit_calendar_section.dart';
import 'package:medical/src/widget/benefit/benefit_confirm_page.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_navigation_mixin.dart';

/// A self-contained reschedule sub-flow: Calendar → Confirm → success navigates
/// back to a refreshed [BenefitBookingDetailPage].
///
/// Sets itself as the active [DsmesNavigationMixin] navigator so that
/// [BenefitCalendarSection] can push [BenefitConfirmPage] internally.
/// [previousRoute] is passed through to [BenefitConfirmPage] so the success
/// navigation can restore the correct stack (history vs. tabbar).
class BenefitRescheduleFlow extends StatefulWidget {
  final DsmesAppointmentCubit cubit;
  final String serviceType;
  final int appointmentId;
  final String bookingType;
  final String? previousRoute;

  const BenefitRescheduleFlow({
    Key? key,
    required this.cubit,
    required this.serviceType,
    required this.appointmentId,
    required this.bookingType,
    this.previousRoute,
  }) : super(key: key);

  @override
  State<BenefitRescheduleFlow> createState() => _BenefitRescheduleFlowState();
}

class _BenefitRescheduleFlowState extends State<BenefitRescheduleFlow> {
  final _navKey = DsmesNavigationMixin.createNavigatorKey();

  @override
  void initState() {
    super.initState();
    DsmesNavigationMixin.setActiveNavigator(_navKey);
  }

  Route<dynamic>? _buildRoute(RouteSettings settings, Widget child) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => BlocProvider.value(value: widget.cubit, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_navKey.currentState?.canPop() ?? false) {
          _navKey.currentState?.pop();
          return false;
        }
        return true;
      },
      child: Navigator(
        key: _navKey,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return _buildRoute(
                settings,
                BenefitCalendarSection(
                  serviceType: widget.serviceType,
                  action: 'reschedule',
                  appointmentId: widget.appointmentId,
                  bookingType: widget.bookingType,
                  onBack: () => Navigator.of(context, rootNavigator: true).pop(),
                ),
              );

            case NavigatorName.benefit_confirm_information:
              final args = settings.arguments as Map<String, dynamic>?;
              return _buildRoute(
                settings,
                BenefitConfirmPage(
                  serviceType: args?['serviceType'] as String? ?? widget.serviceType,
                  action: 'reschedule',
                  appointmentId: widget.appointmentId,
                  bookingType: args?['bookingType'] as String? ?? widget.bookingType,
                  previousRoute: widget.previousRoute,
                  branchName: args?['branchName'] as String?,
                  branchAddress: args?['branchAddress'] as String?,
                  branchId: args?['branchId'] as int?,
                  specialtyName: args?['specialtyName'] as String?,
                ),
              );

            default:
              return null;
          }
        },
      ),
    );
  }
}
