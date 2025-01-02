import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/navigator_name.dart';
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
import 'package:pull_to_refresh/pull_to_refresh.dart';

class DsmesAppointmentPage extends StatefulWidget {
  const DsmesAppointmentPage({Key? key}) : super(key: key);

  @override
  _DsmesAppointmentPageState createState() => _DsmesAppointmentPageState();
}

class _DsmesAppointmentPageState extends State<DsmesAppointmentPage>
    with Observer {
  final RefreshController _controller = RefreshController();
  late DsmesAppointmentCubit _cubit;
  String _currentRoute = '/';

  @override
  void initState() {
    super.initState();
    Observable.instance.addObserver(this);
    final AppRepository repository = AppRepository();
    _cubit = DsmesAppointmentCubit(repository);
    // _cubit.getDsmesAppointmentList();
    _cubit.initDsmesBooking();
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
    if (notifyName == 'refresh_dsmes_appointment') {
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
                          clinic: args!["clinic"],
                          serviceType: args["serviceType"],
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
          BotToast.showLoading();
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
        CustomAppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            R.string.choose_center.tr(),
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                // fontFamily: 'sfpro',
                color: R.color.textDark),
          ),
          actions: [
            GestureDetector(
              onTap: () async {
                DsmesNavigationMixin.navigationKey.currentState
                    ?.pushNamed(NavigatorName.dsmes_booking_history);
              },
              child: Container(
                width: 140,
                height: 33,
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                margin: EdgeInsets.fromLTRB(0, 8, 16, 8),
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
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      R.string.consulting_history.tr(),
                      style: TextStyle(
                        fontSize: 14,
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
              color: R.color.textDark,
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
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
              _cubit.getDsmesAppointmentList(isRefresh: true, page: 1);
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    ListView.separated(
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: _cubit.listFilteredData.length,
                      separatorBuilder: (context, index) => SizedBox(
                        height: 16,
                      ),
                      itemBuilder: (context, index) {
                        final data = _cubit.listFilteredData[index];
                        return DsmesAppointmentItem(
                          data: data,
                          onChooseService: () async {
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
                          },
                          cubit: _cubit,
                        );
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () async {
                        final clinics = await _cubit.getClinicList();
                        if (clinics.isNotEmpty) {
                          final priorityClinic = clinics.first;
                          await _cubit.getClinicDetail(id: priorityClinic.id);
                          await _cubit.initCreateDsmesBookingRequest(
                              locale: context.locale.languageCode);

                          DsmesNavigationMixin.navigationKey.currentState
                              ?.pushNamed(NavigatorName.dsmes_select_service,
                                  arguments: {
                                'clinic': _cubit.selectedClinic,
                                'serviceType':
                                    DsmesAppointmentMode.telemedicine.toString()
                              });
                        }
                      },
                      child: Image.asset(R.drawable.online_consulting),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () async {
                        await _cubit.getClinicList();
                        DsmesNavigationMixin.navigationKey.currentState
                            ?.pushNamed(NavigatorName.dsmes_booking_offline,
                                arguments: {
                              'serviceType':
                                  DsmesAppointmentMode.atClinic.toString()
                            });
                      },
                      child: Image.asset(R.drawable.offline_consulting),
                    ),
                    // Container(
                    //     width: 128 ,
                    //     child: ButtonWidget(
                    //         title: R.string.text_continue.tr(),
                    //         onPressed: () {
                    //           NavigationUtil.navigatePage(
                    //               context, UpgradeAccountPage());
                    //         }))
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
