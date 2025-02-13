import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/firebase_remote_config.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/booking_clinic/helper/booking_clinic_helper.dart';
import 'package:medical/src/widget/booking_clinic/model/clinic_specialty_model.dart';
import 'package:medical/src/widget/booking_clinic/pages/booking_clinic_provider_page.dart';
import 'package:medical/src/widget/booking_clinic/pages/other_diseases_page.dart';
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
import 'package:medical/src/widget/question_answer/all_question_answer/model/question_model.dart';
import 'package:medical/src/widgets/gap_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BookingClinicPage extends StatefulWidget {
  const BookingClinicPage({Key? key}) : super(key: key);

  @override
  _BookingClinicPageState createState() => _BookingClinicPageState();
}

class _BookingClinicPageState extends State<BookingClinicPage> with Observer {
  final RefreshController _controller = RefreshController();
  late DsmesAppointmentCubit _cubit;
  String _currentRoute = '/';
  Map<String, bool> isProcessing = {
    'chooseService': false,
    'onlineConsulting': false,
    'offlineConsulting': false,
  };

  @override
  void initState() {
    super.initState();
    Observable.instance.addObserver(this);
    final AppRepository repository = AppRepository();
    _cubit = DsmesAppointmentCubit(repository);
    // _cubit.getDsmesAppointmentList();
    _cubit.initDsmesBooking();
    _initDeviceLocation();
  }

  _initDeviceLocation() async {
    final position = await getPositionPreferences();
    if (position == null || position.isEmpty) {
      final geolocation = await determinePosition();
      if (geolocation != null) {
        await saveLocationPreferences(geolocation);
      }
    }
  }

  @override
  void dispose() {
    BotToast.closeAllLoading();
    Observable.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void update(
      Observable observable, String? notifyName, Map<dynamic, dynamic>? map) {
    if (notifyName == 'refresh_booking_clinic') {
      _refresh();
    }
  }

  void _refresh() async {
    await _cubit.getDsmesAppointmentList(isRefresh: true, page: 1);
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
                        DsmesNavigationMixin.navigationKey.currentContext!)
                    .unfocus();

                // final route = ModalRoute.of(
                //         DsmesNavigationMixin.navigationKey.currentContext!)
                //     ?.settings;
                // print('[POP] route: $route');
                // final args = route?.arguments as Map<String, dynamic>?;
                // print('[POP] Args: ${route?.arguments}');
                // final previousRoute = args?['previousRoute'] as String?;

                // if (previousRoute == NavigatorName.dsmes_booking_history ||
                //     previousRoute == NavigatorName.dsmes_clinic_detail) {
                //   DsmesNavigationMixin.navigationKey.currentState?.pop();
                //   return false;
                // }
                DsmesNavigationMixin.navigationKey.currentState
                    ?.popUntil((route) => route.isFirst);
                Observable.instance.notifyObservers([],
                    notifyName: "refresh_dsmes_appointment");
                return false;
              }

              final route = ModalRoute.of(
                      DsmesNavigationMixin.navigationKey.currentContext!)
                  ?.settings;
              final args = route?.arguments as Map<String, dynamic>?;
              final isEditing = args?['isEditing'] ?? false;
              final previousRoute = args?['previousRoute'];

              if (isEditing && previousRoute != null) {
                DsmesNavigationMixin.navigationKey.currentState
                    ?.pushReplacementNamed(previousRoute, arguments: {
                  'serviceType': args?['serviceType'],
                  'action': args?['action'],
                });
                return false;
              }

              if (DsmesNavigationMixin.navigationKey.currentState?.canPop() ??
                  false) {
                DsmesNavigationMixin.navigationKey.currentState?.pop();
                return false;
              } else {
                BotToast.closeAllLoading();
                Navigator.of(context, rootNavigator: true).pop();
              }
              return true;
            },
            child: Navigator(
              key: DsmesNavigationMixin.navigationKey,
              onGenerateRoute: (settings) {
                // Log current route name
                print('[ROUTE] Current Route: ${settings.name}');
                _currentRoute = settings.name ?? '/';
                // Log full navigator stack
                print(
                    '[ROUTE] Navigator Stack: ${DsmesNavigationMixin.navigationKey.currentState?.toString()}');
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
        if (state is DsmesAppointmentFailure) {
          BotToast.closeAllLoading();
          Message.showToastMessage(context, state.error);
        } else {
          BotToast.closeAllLoading();
          _controller.refreshCompleted();
        }
      },
      builder: (
        BuildContext context,
        DsmesAppointmentState state,
      ) {
        print('Building with state: $state');
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

  List<ClinicSpecialty> getDiabSpecialties() {
    final specialtyOrder = FirebaseRemoteSetting.instance.specialtyOrder ?? '';
    if (specialtyOrder.isEmpty) {
      return [];
    }

    final slugs = specialtyOrder.split(',');

    final Map<String, ClinicSpecialty> specialtyMap = {
      'cao-huyet-ap': ClinicSpecialty(
        id: 29,
        name: 'Cao huyết áp',
        banner: R.drawable.banner_cao_huyet_ap,
      ),
      'tieu-duong': ClinicSpecialty(
        id: 17,
        name: 'Tiểu đường',
        banner: R.drawable.banner_tieu_duong,
      ),
      'suy-than-man': ClinicSpecialty(
        id: 42,
        name: 'Suy thận mạn',
        banner: R.drawable.banner_suy_than_man,
      ),
      'suc-khoe-tim-mach': ClinicSpecialty(
        id: 29,
        name: 'Sức khỏe tim mạch',
        banner: R.drawable.banner_suc_khoe_tim_mach,
      ),
      'benh-khac': ClinicSpecialty(
        id: 0,
        name: 'Bệnh khác',
        banner: R.drawable.banner_benh_khac,
      ),
    };

    return slugs.map((slug) => specialtyMap[slug]!).toList();
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
              R.string.chon_nhu_cau_kham.tr(),
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

                  DsmesNavigationMixin.navigationKey.currentState
                      ?.pushNamed(NavigatorName.dsmes_booking_history);
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
                              await _cubit.getClinicDetail(id: data.clinicId);
                              final appointment =
                                  await _cubit.getDsmesAppointmentDetail(
                                      appointmentId: data.id);

                              DsmesNavigationMixin.navigationKey.currentState
                                  ?.pushNamed(
                                NavigatorName.dsmes_booking_detail,
                                arguments: {
                                  'serviceType': appointment?.mode,
                                  'appointment': appointment
                                },
                              );
                            } finally {
                              isProcessing['chooseService'] = false;
                            }
                          },
                          cubit: _cubit,
                        );
                      },
                    ),
                    GapH(16),
                    _buildDiabSpecialty(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  _buildDiabSpecialty() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final containerWidth = constraints.maxWidth;
        final itemsPerRow = (containerWidth - 24) ~/ 170;
        final spacing =
            ((containerWidth - 24) - (170 * itemsPerRow)) / (itemsPerRow - 1);
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Wrap(
            spacing: spacing,
            runSpacing: 12,
            alignment: WrapAlignment.start,
            children: getDiabSpecialties().map((specialty) {
              return GestureDetector(
                onTap: () async {
                  if (specialty.name == "Bệnh khác") {
                    final specialties = await _cubit.getCLinicSpecialtyList();
                    DsmesNavigationMixin.navigationKey.currentState
                        ?.pushNamed(NavigatorName.other_diseases, arguments: {
                      "specialties": specialties,
                    });
                  } else {
                    _cubit.clearClinicProviders();
                    DsmesNavigationMixin.navigationKey.currentState
                        ?.pushNamed(NavigatorName.clinic_providers, arguments: {
                      "specialtyId": specialty.id,
                    });
                  }
                },
                child: SizedBox(
                  width: 170,
                  height: 238,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        // Background Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            specialty.banner ?? '',
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Blur Container at bottom
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 80,
                            padding: EdgeInsets.fromLTRB(12, 16, 8, 0),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.center,
                                end: Alignment.bottomCenter,
                                colors: [
                                  R.color.color0xffFAF0D2,
                                  R.color.color0xffFAF0D2.withOpacity(0.8),
                                  R.color.color0xffFAF0D2.withOpacity(0.5),
                                ],
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    specialty.name,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: R.color.color0xff111515,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: R.color.color0xff111515,
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
            }).toList(),
          ),
        );
      },
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
