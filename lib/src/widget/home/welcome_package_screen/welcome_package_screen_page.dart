import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/repository/app_repository.dart';
import '../../../utils/const.dart';
import 'welcome_package_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:easy_localization/easy_localization.dart';

class WelcomePackageScreenPage extends StatefulWidget {
  final String? icon;
  final String? title;
  final String? subTitle;
  final VoidCallback? onSkip;
  final VoidCallback? onNavigateToMyPlan;

  WelcomePackageScreenPage({Key? key, required this.icon, required this.title, required this.subTitle, required this.onSkip, required this.onNavigateToMyPlan}) : super(key: key);

  @override
  _WelcomePackageScreenPageState createState() => _WelcomePackageScreenPageState();
}

class _WelcomePackageScreenPageState extends State<WelcomePackageScreenPage> {
  late WelcomePackageScreenCubit _cubit;

  @override
  void initState() {
    super.initState();
    final AppRepository appRepository = AppRepository();
    _cubit = WelcomePackageScreenCubit(appRepository);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocListener<WelcomePackageScreenCubit, WelcomePackageScreenState>(
          listener: (context, state) {},
          child: BlocBuilder<WelcomePackageScreenCubit, WelcomePackageScreenState>(
            builder: (context, state) {
              return _buildPage(context, state);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, WelcomePackageScreenState state) {
    return WillPopScope(
      onWillPop: () => _backPressed(),
      child: Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage(R.drawable.bg_welcome),
          fit: BoxFit.cover,
        )),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Image.asset(widget.icon!, width: 220, height: 220,),
                    SizedBox(height: 30),
                    Text(widget.title ?? '',
                        style: TextStyle(color: R.color.mainColor, fontSize: 24, fontWeight: FontWeight.w700)),
                    SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.only(left: 32, right: 32),
                      child: Text(widget.subTitle ?? '',
                          style: TextStyle(color: R.color.color0xff333333, fontSize: 16, fontWeight: FontWeight.w400),
                          textAlign: TextAlign.center),
                    ),
                ],  
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () async {
                      await _backPressed();
                    },
                    child: SafeArea(
                      top: false,
                      child: Container(
                          height: 48,
                          width: 100, 
                          child: Center(
                            child: Text(R.string.skip.tr(),
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: R.color.mainColor),
                            ),
                          ),
                        ),
                      ),
                    ),
                  GestureDetector(
                    onTap: () async {
                      await _backPressed();
                      Observable.instance.notifyObservers([], notifyName: Const.NAVIGATE_TO_MY_PLAN_TAB);
                    },
                    child: SafeArea(
                      top: false,
                      child: Container(
                          height: 48,
                          width: 195,
                          margin: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: R.color.mainColor,
                              borderRadius: BorderRadius.circular(200),
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.centerRight,
                                  colors: [R.color.greenGradientTop, R.color.greenGradientBottom])),
                          child: Center(
                              child: Text(R.string.my_plan.tr(),
                                  style: TextStyle(color: R.color.white, fontSize: 16, fontWeight: FontWeight.w600)))),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Future<bool> _backPressed() async {
    await _cubit.readWelcome();
    Navigator.pop(context);
    return true;
  }
}