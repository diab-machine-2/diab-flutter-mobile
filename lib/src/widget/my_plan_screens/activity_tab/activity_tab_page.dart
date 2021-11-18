import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/booking_coach/booking_coach.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/button_widget.dart';

import '../../survey_screens/introduce_survey/introduce_survey.dart';
import '../my_plan/widgets/app_bar_bottom.dart';
import 'activity_tab.dart';

class ActivityTabPage extends StatefulWidget {
  const ActivityTabPage();

  @override
  _ActivityTabPageState createState() => _ActivityTabPageState();
}

class _ActivityTabPageState extends State<ActivityTabPage>
    with AutomaticKeepAliveClientMixin<ActivityTabPage> {
  late final ActivityTabCubit _cubit;

  @override
  void initState() {
    super.initState();
    final AppRepository appRepository = AppRepository();
    _cubit = ActivityTabCubit(appRepository);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider(
      create: (context) => _cubit,
      child: BlocConsumer<ActivityTabCubit, ActivityTabState>(
        listener: (context, state) {
          if (state is ActivityTabLoading) {
            BotToast.showLoading();
          } else {
            BotToast.closeAllLoading();
          }
          if (state is ActivityTabFailure) {
            Message.showToastMessage(context, state.error);
          }
        },
        builder: (context, state) {
          return AppBarBottom(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ButtonWidget(
                    title: 'Go to Survey',
                    onPressed: () {
                      NavigationUtil.navigatePage(
                          context, const IntroduceSurveyPage());
                    }),
                const SizedBox(height: 24),
                ButtonWidget(
                    title: 'Go to Booking',
                    onPressed: () {
                      NavigationUtil.navigatePage(
                          context, const BookingCoachPage());
                    }),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
