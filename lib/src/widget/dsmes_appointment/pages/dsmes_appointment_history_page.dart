import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_model.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_state.dart';
import 'package:medical/src/widget/dsmes_appointment/widgets/dsmes_appointment_item.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class DsmesAppointmentHistoryPage extends StatefulWidget {
  @override
  _DsmesAppointmentHistoryPageState createState() =>
      _DsmesAppointmentHistoryPageState();
}

class _DsmesAppointmentHistoryPageState
    extends State<DsmesAppointmentHistoryPage> {
  final RefreshController _refreshController = RefreshController();
  late DsmesAppointmentCubit _cubit;

  @override
  void initState() {
    super.initState();
    final AppRepository repository = AppRepository();
    _cubit = DsmesAppointmentCubit(repository);
    _cubit.getDsmesAppointmentList(page: 1);
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
                BotToast.closeAllLoading();
              }
              if (state is DsmesAppointmentLoaded) {
                _refreshController.loadComplete();
                _refreshController.refreshCompleted();
              }
            },
            builder: (context, state) {
              return Column(
                children: [
                  CustomAppBar(
                    backgroundColor: Colors.transparent,
                    title: Text(
                      R.string.consulting_history.tr(),
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          // fontFamily: 'sfpro',
                          color: R.color.textDark),
                    ),
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
                      controller: _refreshController,
                      enablePullUp: _cubit.hasMore,
                      onRefresh: () => _cubit.getDsmesAppointmentList(
                          isRefresh: true, page: 1),
                      onLoading: () => _cubit.getDsmesAppointmentList(
                          page: _cubit.currentPage + 1),
                      child: ListView.separated(
                        padding: EdgeInsets.all(16),
                        itemCount: _cubit.listData.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          DsmesAppointment data = _cubit.listData[index];
                          return DsmesAppointmentItem(
                            data: data,
                            onChooseService: () {
                              // Handle on tap detail
                            },
                            cubit: _cubit,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
