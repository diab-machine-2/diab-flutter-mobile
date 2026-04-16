import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/branchio_link_config.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_appointment_model.dart';
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
import 'package:medical/src/widget/dsmes_appointment/widgets/dsmes_appointment_item.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/gap_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class DsmesAppointmentPage extends StatefulWidget {
  final bool? pendingOnlineDeeplink;
  final int? pendingClinicId;
  final int? pendingMode;
  final bool? bloodPressureConsult;
  const DsmesAppointmentPage({
    Key? key,
    this.pendingOnlineDeeplink = false,
    this.pendingClinicId,
    this.pendingMode,
    this.bloodPressureConsult = false,
  }) : super(key: key);

  @override
  _DsmesAppointmentPageState createState() => _DsmesAppointmentPageState();
}

class _DsmesAppointmentPageState extends State<DsmesAppointmentPage>
    with Observer {
  final RefreshController _controller = RefreshController();
  late DsmesAppointmentCubit _cubit;
  String _currentRoute = '/';
  Map<String, bool> isProcessing = {
    'chooseService': false,
    'onlineConsulting': false,
    'offlineConsulting': false,
    'deeplink': false,
  };

  // Flag to track when initialization is complete
  bool _isInitialized = false;
  // Flag to track if we need to handle deep links
  bool _needToHandleDeeplinks = false;
  // Flags to track updated deep link navigate parameters
  int? _updatedClinicId;
  int? _updatedMode;
  bool _hasUpdatePending = false;

  // Track the current active flow for back button handling
  String? _activeDeeplinkType; // 'online', 'offline', or 'clinic_detail'

  // Create the navigator key as a class property, not in initState
  final _navigatorKey = DsmesNavigationMixin.createNavigatorKey();

  @override
  void initState() {
    super.initState();
    Observable.instance.addObserver(this);
    final AppRepository repository = AppRepository();
    _cubit = DsmesAppointmentCubit(repository);

    // Set it as the active navigator
    DsmesNavigationMixin.setActiveNavigator(_navigatorKey);

    // Set flag if we have pending deeplinks
    _needToHandleDeeplinks =
        widget.pendingOnlineDeeplink == true || widget.pendingClinicId != null;

    // Initialize active deeplink type based on initial parameters
    if (widget.pendingMode != null) {
      _activeDeeplinkType = widget.pendingMode == 0 ? 'online' : 'offline';
    } else if (widget.pendingClinicId != null) {
      _activeDeeplinkType = 'clinic_detail';
    }

    // Initialize without handling deeplinks yet
    _cubit.initDsmesBooking(isLoadAppointments: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.bloodPressureConsult == true) {
        _handleBloodPressureConsult();
      }
    });
  }

  @override
  void dispose() {
    BotToast.closeAllLoading();
    Observable.instance.removeObserver(this);
    _controller.dispose();
    // Reset page tracking when component is disposed
    BranchioLinkConfig.instance.resetPageTracking();
    super.dispose();
  }

  @override
  void update(
      Observable observable, String? notifyName, Map<dynamic, dynamic>? map) {
    if (notifyName == 'refresh_dsmes_appointment') {
      _refresh();
    }
    // Handle updates coming from deeplinks while DSMES page is already open
    else if (notifyName == 'update_dsmes_parameters' && map != null) {
      print('[ROUTE] Received updated parameters: $map');

      // Determine the new deeplink type
      int? newMode = map['pendingMode'] as int?;
      int? newClinicId = map['pendingClinicId'] as int?;
      String? newDeeplinkType;

      if (newMode != null) {
        newDeeplinkType = newMode == 0 ? 'online' : 'offline';
      } else if (newClinicId != null) {
        newDeeplinkType = 'clinic_detail';
      }

      // Store updated parameters and update active deeplink type
      _updatedClinicId = newClinicId;
      _updatedMode = newMode;
      _hasUpdatePending = true;

      // Update active deeplink type
      if (newDeeplinkType != null) {
        _activeDeeplinkType = newDeeplinkType;
      }

      _isInitialized = true;

      // If initialization is complete, handle the update immediately
      // Otherwise it will be handled after current load completes
      if (_isInitialized) {
        _handleParameterUpdate();
      }
    }
  }

  // Handle updates to parameters when DSMES page is already open
  void _handleParameterUpdate() async {
    if (!_hasUpdatePending) return;

    print(
        '[ROUTE] Handling parameter update - mode: $_updatedMode, clinic: $_updatedClinicId');
    _hasUpdatePending = false;

    // Clear existing navigation flow if we're not at root
    if (_currentRoute != '/') {
      _clearNavigationHistory();
      // Small delay to ensure navigation state is updated
      await Future.delayed(Duration(milliseconds: 100));
    }

    // Case 1: Handle online mode update (mode = 0)
    if (_updatedMode == 0) {
      await _handleOnlineDeeplink();
    }
    // Case 2: Handle offline mode update (mode = 1)
    else if (_updatedMode == 1) {
      await _handleOfflineDeeplink();
    }
    // Case 3: Handle clinic detail update
    else if (_updatedClinicId != null) {
      await _cubit.getClinicDetail(id: _updatedClinicId!);
      await _cubit.getClinicRate(id: _updatedClinicId!);

      // Navigate to clinic detail within DSMES navigator
      _navigatorKey.currentState?.pushNamed(NavigatorName.dsmes_clinic_detail,
          arguments: {'clinicId': _updatedClinicId});
    }

    // Clear updated parameters
    _updatedClinicId = null;
    _updatedMode = null;
  }

  // Clear navigation history by popping to root
  void _clearNavigationHistory() {
    print('[ROUTE] Clearing navigation stack from: $_currentRoute');

    if (_currentRoute == '/') {
      print('[ROUTE] Already at root, no need to clear');
      return;
    }

    // Pop all routes until we reach the root '/' route and update _currentRoute
    _navigatorKey.currentState?.popUntil((route) {
      final isFirst = route.isFirst;
      if (isFirst) {
        print(
            '[ROUTE] Setting _currentRoute to / after clearing navigation stack');
        _currentRoute = '/';
      }
      return isFirst;
    });
  }

  // Check if a specific route exists in the navigator stack
  bool _doesRouteExistInStack(String routeName) {
    bool exists = false;
    _navigatorKey.currentState?.popUntil((route) {
      if (route.settings.name == routeName) {
        exists = true;
      }
      return true; // Don't actually pop anything
    });
    return exists;
  }

  // Get current route more reliably
  String _getCurrentRoute() {
    if (_navigatorKey.currentState == null) {
      return '/';
    }

    // Create a variable to store the current route
    String currentRoute = '/';

    // Get the current stack of routes
    bool foundCurrent = false;

    _navigatorKey.currentState?.popUntil((route) {
      // Only get the top-most route (the current one)
      if (!foundCurrent) {
        currentRoute = route.settings.name ?? '/';
        foundCurrent = true;
      }
      // Don't actually pop anything
      return true;
    });

    print('[ROUTE] _getCurrentRoute identified route as: $currentRoute');
    return currentRoute;
  }

  void _refresh() async {
    await _cubit.getDsmesAppointmentList(isRefresh: true, page: 1);
  }

  // Handle any pending deeplinks that were passed as arguments
  void _handlePendingDeeplinks() async {
    // Only process if we have pending deeplinks and aren't already processing
    if (!_needToHandleDeeplinks || isProcessing['deeplink'] == true) return;

    print('[ROUTE] Handling pending deeplinks on initial load');
    isProcessing['deeplink'] = true;

    try {
      _isInitialized = true;

      // Case 1: Handle mode-specific deeplinks first (most specific)
      if (widget.pendingMode != null) {
        if (widget.pendingMode == 0) {
          await _handleOnlineDeeplink();
        } else if (widget.pendingMode == 1) {
          await _handleOfflineDeeplink();
        }
      }
      // Case 2: Handle clinic ID deeplinks next
      else if (widget.pendingClinicId != null) {
        await _handleClinicDetailDeeplink();
      }

      // Clear flag after handling
      _needToHandleDeeplinks = false;
    } catch (e) {
      print('[ROUTE] Error handling deeplink in DsmesAppointmentPage: $e');
    } finally {
      isProcessing['deeplink'] = false;
    }
  }

  // Handle online mode deeplink
  Future<void> _handleOnlineDeeplink() async {
    try {
      // Set active deeplink type for back navigation
      _activeDeeplinkType = 'online';
      await _navigateToSelectService();
    } catch (e) {
      print('[ROUTE] Error handling online deeplink: $e');
    }
  }

  Future<void> _navigateToSelectService() async {
    final clinics = await _cubit.getClinicList(type: 'online');
    if (clinics.isNotEmpty) {
      final priorityClinic = clinics.first;
      final detailSuccess = await _cubit.getClinicDetail(id: priorityClinic.id);

      if (!detailSuccess || _cubit.selectedClinic == null) {
        return;
      }

      await _cubit.initCreateDsmesBookingRequest(
          locale: context.locale.languageCode);

      _navigatorKey.currentState
          ?.pushNamed(NavigatorName.dsmes_select_service, arguments: {
        'action': 'create',
        'clinic': _cubit.selectedClinic,
        'serviceType': DsmesAppointmentMode.telemedicine.toString(),
        'isMergedSchedule': true
      });

      // Update current route
      _currentRoute = NavigatorName.dsmes_select_service;
    }
  }

  // Handle offline mode deeplink
  Future<void> _handleOfflineDeeplink() async {
    try {
      // Set active deeplink type for back navigation
      _activeDeeplinkType = 'offline';

      await _cubit.getClinicList();
      _navigatorKey.currentState
          ?.pushNamed(NavigatorName.dsmes_booking_offline, arguments: {
        'serviceType': DsmesAppointmentMode.atClinic.toString(),
      });

      // Update current route
      _currentRoute = NavigatorName.dsmes_booking_offline;
    } catch (e) {
      print('[ROUTE] Error handling offline deeplink: $e');
    }
  }

  // Handle clinic detail deeplink
  Future<void> _handleClinicDetailDeeplink() async {
    try {
      // Set active deeplink type for back navigation
      _activeDeeplinkType = 'clinic_detail';

      if (widget.pendingClinicId != null) {
        print(
            '[ROUTE] _handleClinicDetailDeeplink with clinicId: ${widget.pendingClinicId}');

        // Mark this as processing to prevent re-entry
        isProcessing['deeplink'] = true;

        final detailSuccess =
            await _cubit.getClinicDetail(id: widget.pendingClinicId!);
        if (!detailSuccess || _cubit.selectedClinic == null) {
          print(
              '[ROUTE] Failed to get clinic detail for ID: ${widget.pendingClinicId}');
          isProcessing['deeplink'] = false;
          return;
        }

        await _cubit.getClinicRate(id: widget.pendingClinicId!);

        // Navigate to clinic detail within DSMES navigator
        _navigatorKey.currentState?.pushNamed(NavigatorName.dsmes_clinic_detail,
            arguments: {'clinicId': widget.pendingClinicId});

        // Update current route
        _currentRoute = NavigatorName.dsmes_clinic_detail;
        isProcessing['deeplink'] = false;
      }
    } catch (e) {
      isProcessing['deeplink'] = false;
      print('[ROUTE] Error handling clinic detail deeplink: $e');
    }
  }

  Future<void> _handleBloodPressureConsult() async {
    await _navigateToSelectService();
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
              print(
                  '[POP] Back button pressed - current route: $_currentRoute');

              // At root, exit to tabbar
              if (_currentRoute == '/') {
                print('[POP] At root, exiting to tabbar');
                BranchioLinkConfig.instance.resetPageTracking();
                Navigator.of(context, rootNavigator: true).pop();
                return false;
              }

              // Special handling for select service page
              if (_currentRoute == NavigatorName.dsmes_select_service) {
                print('[POP] At select service page');

                if (_doesRouteExistInStack(
                    NavigatorName.dsmes_confirm_information)) {
                  Future.microtask(() {
                    _navigatorKey.currentState?.popUntil((route) =>
                        route.settings.name ==
                        NavigatorName.dsmes_confirm_information);
                    _currentRoute = _getCurrentRoute();
                  });
                } else {
                  Future.microtask(() {
                    final canPop = _navigatorKey.currentState?.canPop();
                    if (canPop ?? false) {
                      _navigatorKey.currentState?.pop();
                    } else {
                      BranchioLinkConfig.instance.resetPageTracking();
                      Navigator.of(context, rootNavigator: true).pop();
                    }
                    _currentRoute = _getCurrentRoute();
                  });
                }
                return false;
              }

              // Special case for booking detail
              if (_currentRoute == NavigatorName.dsmes_booking_detail) {
                print('[POP] Booking detail - popping to root');
                FocusScope.of(_navigatorKey.currentContext!).unfocus();

                // Use microtask to avoid navigator locked errors
                Future.microtask(() {
                  _navigatorKey.currentState
                      ?.popUntil((route) => route.isFirst);
                  _currentRoute = '/';
                  Observable.instance.notifyObservers([],
                      notifyName: "refresh_dsmes_appointment");
                });

                return false;
              }

              // For online flow handling the deep link case
              if (_activeDeeplinkType == 'online' &&
                  _currentRoute == NavigatorName.dsmes_select_service) {
                print('[POP] Online deep link flow - returning to root');

                // Use microtask to avoid navigator locked errors
                Future.microtask(() {
                  _navigatorKey.currentState
                      ?.popUntil((route) => route.isFirst);
                  _currentRoute = '/';
                  _activeDeeplinkType = null;
                });

                return false;
              }

              // For offline flow
              if (_activeDeeplinkType == 'offline' &&
                  _currentRoute == NavigatorName.dsmes_booking_offline) {
                print('[POP] Offline flow - popping to root');

                // Use microtask to avoid navigator locked errors
                Future.microtask(() {
                  _navigatorKey.currentState
                      ?.popUntil((route) => route.isFirst);
                  _currentRoute = '/';
                  _activeDeeplinkType = null;
                });

                return false;
              }

              // For clinic detail flow
              if (_activeDeeplinkType == 'clinic_detail' &&
                  _currentRoute == NavigatorName.dsmes_clinic_detail) {
                // Use microtask to avoid navigator locked errors
                Future.microtask(() {
                  _navigatorKey.currentState?.pop();
                  _currentRoute = NavigatorName.dsmes_booking_offline;
                  _activeDeeplinkType = null;
                });

                return false;
              }

              // Handle standard back navigation
              if (_navigatorKey.currentState?.canPop() ?? false) {
                print('[POP] Standard navigation - popping');

                // Use microtask to avoid navigator locked errors
                Future.microtask(() {
                  _navigatorKey.currentState?.pop();
                  // Check current route after popping
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _currentRoute = _getCurrentRoute();
                    print('[POP] New current route: $_currentRoute');
                  });
                });

                return false;
              } else {
                // No more routes to pop, exit to tabbar
                print('[POP] No more routes - exiting to tabbar');
                BotToast.closeAllLoading();
                Navigator.of(context, rootNavigator: true).pop();
                return false;
              }
            },
            child: Navigator(
              key: _navigatorKey,
              onGenerateRoute: (settings) {
                // Log current route name
                print('[ROUTE] Current Route: ${settings.name}');
                _currentRoute = settings.name ?? '/';
                // Log full navigator stack
                print(
                    '[ROUTE] Navigator Stack: ${_navigatorKey.currentState?.toString()}');
                switch (settings.name) {
                  case '/':
                    return MaterialPageRoute(
                      builder: (_) => _buildMainContent(context),
                    );
                  case NavigatorName.dsmes_booking_history:
                    return _buildRoute(
                      settings,
                      DsmesAppointmentHistoryPage(),
                    );
                  case NavigatorName.dsmes_booking_offline:
                    Map<String, dynamic>? args =
                        settings.arguments as Map<String, dynamic>?;
                    return _buildRoute(
                      settings,
                      DsmesBookingOfflinePage(
                        serviceType: args!["serviceType"],
                        pendingClinicId: args["pendingClinicId"],
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
                        ),
                      );
                    }
                  case NavigatorName.dsmes_booking_detail:
                    {
                      Map<String, dynamic>? args =
                          settings.arguments as Map<String, dynamic>?;
                      return _buildRoute(
                        settings,
                        DsmesBookingDetail(
                          serviceType: args!["serviceType"],
                          appointment: args["appointment"],
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
        print('[BLOC] Current state: $state');

        if (state is DsmesAppointmentFailure) {
          BotToast.closeAllLoading();
          Message.showToastMessage(context, state.error);
        } else if (state is DsmesAppointmentLoaded) {
          BotToast.closeAllLoading();
          _controller.refreshCompleted();

          // If we just loaded and need to handle deeplinks, do it after a short delay
          // to ensure the UI is fully built
          if (_needToHandleDeeplinks) {
            // Short delay to ensure the UI is fully built and BlocProvider has updated
            Future.delayed(const Duration(milliseconds: 500), () {
              _handlePendingDeeplinks();
            });
          }
          // If there's a parameter update pending, handle it after load completes
          else if (_hasUpdatePending) {
            Future.delayed(const Duration(milliseconds: 300), () {
              _handleParameterUpdate();
            });
          }
        } else {
          BotToast.closeAllLoading();
          _controller.refreshCompleted();
        }
      },
      builder: (
        BuildContext context,
        DsmesAppointmentState state,
      ) {
        print('[BLOC] Building UI with state: $state');
        if (state is DsmesAppointmentLoading) {
          BotToast.showLoading(allowClick: false);
        } else {
          BotToast.closeAllLoading();
          _controller.refreshCompleted();
        }
        return _buildPage(context, state);
      },
    );
  }

  Widget _buildPage(BuildContext context, DsmesAppointmentState state) {
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [R.color.greenGradientTop02, R.color.greenGradientBottom],
              stops: [0.01, 0.99],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          child: CustomAppBar(
            backgroundColor: Colors.transparent,
            title: Text(
              R.string.health_consulting.tr(),
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  // fontFamily: 'sfpro',
                  color: R.color.white),
            ),
            actions: [
              GestureDetector(
                onTap: () async {
                  _cubit.clearAppointments();

                  _navigatorKey.currentState
                      ?.pushNamed(NavigatorName.dsmes_booking_history);

                  // Update current route
                  _currentRoute = NavigatorName.dsmes_booking_history;
                },
                child: Container(
                  width: 90,
                  height: 33,
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                  margin: EdgeInsets.fromLTRB(0, 12, 16, 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: R.color.color0xffECFFFD,
                    border: Border.all(
                      color: R.color.color0xffA4E3DD,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        R.icons.ic_clock,
                        width: 16,
                        height: 16,
                        color: R.color.color0xff239A90,
                        fit: BoxFit.scaleDown,
                      ),
                      GapW(4),
                      Text(
                        R.string.consulting_history.tr(),
                        style: TextStyle(
                          fontSize: 13,
                          // fontFamily: 'sfpro',
                          fontWeight: FontWeight.w700,
                          color: R.color.color0xff239A90,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            leadingIcon: IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: Icon(
                Icons.arrow_back,
                color: R.color.white,
              ),
              onPressed: () {
                BranchioLinkConfig.instance.resetPageTracking();
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
          ),
        ),
        Expanded(
          child: SmartRefresher(
            controller: _controller,
            onRefresh: () async {
              final docosanToken = await AppSettings.getDocosanToken();
              if (docosanToken == null || docosanToken.isEmpty) {
                BotToast.closeAllLoading();
                _controller.refreshCompleted();
                return;
              }
              await _cubit.getDsmesAppointmentList(
                  isRefresh: true, page: 1, showLoading: false);
              _controller.refreshCompleted();
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                child: Column(
                  children: [
                    ListView.separated(
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: _cubit.listFilteredData.length,
                      separatorBuilder: (context, index) => GapH(16),
                      itemBuilder: (context, index) {
                        final data = _cubit.listFilteredData[index];
                        return DsmesAppointmentItem(
                          data: data,
                          onChooseService: () async {
                            if (isProcessing['chooseService']!) return;
                            isProcessing['chooseService'] = true;
                            try {
                              final detailSuccess = await _cubit
                                  .getClinicDetail(id: data.clinicId);

                              if (!detailSuccess ||
                                  _cubit.selectedClinic == null) {
                                return;
                              }
                              final appointment =
                                  await _cubit.getDsmesAppointmentDetail(
                                      appointmentId: data.id);

                              _navigatorKey.currentState?.pushNamed(
                                NavigatorName.dsmes_booking_detail,
                                arguments: {
                                  'serviceType': appointment?.mode,
                                  'appointment': appointment
                                },
                              );

                              // Update current route
                              _currentRoute =
                                  NavigatorName.dsmes_booking_detail;
                            } finally {
                              isProcessing['chooseService'] = false;
                            }
                          },
                          cubit: _cubit,
                        );
                      },
                    ),
                    GapH(16),
                    GestureDetector(
                      onTap: () async {
                        if (isProcessing['onlineConsulting']!) return;
                        isProcessing['onlineConsulting'] = true;
                        try {
                          final clinics =
                              await _cubit.getClinicList(type: 'online');
                          if (clinics.isNotEmpty) {
                            final priorityClinic = clinics.first;
                            final detailSuccess = await _cubit.getClinicDetail(
                                id: priorityClinic.id);

                            if (!detailSuccess ||
                                _cubit.selectedClinic == null) {
                              return;
                            }
                            await _cubit.initCreateDsmesBookingRequest(
                                locale: context.locale.languageCode);

                            _navigatorKey.currentState?.pushNamed(
                                NavigatorName.dsmes_select_service,
                                arguments: {
                                  'action': 'create',
                                  'clinic': _cubit.selectedClinic,
                                  'serviceType': DsmesAppointmentMode
                                      .telemedicine
                                      .toString(),
                                  'isMergedSchedule': true
                                });

                            // Update current route
                            _currentRoute = NavigatorName.dsmes_select_service;
                            // Update active deeplink type for back navigation
                            _activeDeeplinkType = 'online';
                          }
                        } finally {
                          isProcessing['onlineConsulting'] = false;
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: R.color.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            Utils.getBoxShadowDropCard(),
                          ],
                        ),
                        child: Image.asset(R.drawable.online_consulting),
                      ),
                    ),
                    GapH(16),
                    GestureDetector(
                      onTap: () async {
                        if (isProcessing['offlineConsulting']!) return;
                        isProcessing['offlineConsulting'] = true;
                        try {
                          await _cubit.getClinicList();
                          _navigatorKey.currentState?.pushNamed(
                              NavigatorName.dsmes_booking_offline,
                              arguments: {
                                'serviceType':
                                    DsmesAppointmentMode.atClinic.toString()
                              });

                          // Update current route
                          _currentRoute = NavigatorName.dsmes_booking_offline;
                          // Update active deeplink type for back navigation
                          _activeDeeplinkType = 'offline';
                        } finally {
                          isProcessing['offlineConsulting'] = false;
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: R.color.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            Utils.getBoxShadowDropCard(),
                          ],
                        ),
                        child: Image.asset(R.drawable.offline_consulting),
                      ),
                    ),
                  ],
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
