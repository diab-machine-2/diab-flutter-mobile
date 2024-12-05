import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_appointment_model.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_state.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_clinic_model.dart';
import 'package:medical/src/widget/dsmes_appointment/widgets/dsmes_appointment_item.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class DsmesBookingOfflinePage extends StatefulWidget {
  const DsmesBookingOfflinePage({Key? key}) : super(key: key);

  @override
  _DsmesBookingOfflinePageState createState() =>
      _DsmesBookingOfflinePageState();
}

class _DsmesBookingOfflinePageState extends State<DsmesBookingOfflinePage> {
  final RefreshController _controller = RefreshController();
  late DsmesAppointmentCubit _cubit;

  @override
  void initState() {
    super.initState();
    final AppRepository repository = AppRepository();
    _cubit = DsmesAppointmentCubit(repository);
    _cubit.getClinicDetail(id: 861);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              R.color.color0xFFFDC798.withOpacity(0.3),
              R.color.greenbg.withOpacity(0.9),
            ],
            begin: FractionalOffset(1, 1),
            end: FractionalOffset(0.9, 0.5),
            stops: [0.0, 1.0],
          ),
        ),
        child: BlocProvider(
          create: (context) => _cubit,
          child: BlocConsumer<DsmesAppointmentCubit, DsmesAppointmentState>(
            listener: (context, state) {
              if (state is DsmesAppointmentFailure) {
                Message.showToastMessage(context, state.error);
              }
            },
            builder: (
              BuildContext context,
              DsmesAppointmentState state,
            ) {
              if (state is DsmesAppointmentLoading) {
                BotToast.showLoading();
              } else {
                BotToast.closeAllLoading();
                _controller.refreshCompleted();
              }
              return _buildPage(context, state);
            },
          ),
        ),
      ),
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
                Navigator.pushNamed(
                    context, NavigatorName.dsmes_booking_history);
              },
              child: Container(
                width: 130,
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
              Navigator.pop(context);
            },
          ),
        ),
        Expanded(
          child: SmartRefresher(
            controller: _controller,
            onRefresh: () =>
                _cubit.getDsmesAppointmentList(isRefresh: true, page: 1),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListView.separated(
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: _cubit.listClinic.length,
                      separatorBuilder: (context, index) => SizedBox(
                        height: 16,
                      ),
                      itemBuilder: (context, index) {
                        DsmesClinicModel data = _cubit.listClinic[index];
                        return Container(
                          child: Text(data.name),
                        );
                      },
                    ),
                    SizedBox(
                      height: 20,
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
}
