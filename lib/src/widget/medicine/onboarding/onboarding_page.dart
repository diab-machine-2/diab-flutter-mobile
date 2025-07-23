import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../res/R.dart';
import '../../../utils/navigator_name.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
          NavigatorName.tabbar,
              (route) => false, // This removes all routes from stack
        );
        return false;
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: R.color.white,
          appBar: AppBar(
            leading: IconButton(
                splashColor: R.color.transparent,
                highlightColor: R.color.transparent,
                icon: Icon(Icons.arrow_back, color: R.color.white),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
                    NavigatorName.tabbar,
                        (route) => false,
                  );
                }),
            title: Transform(
              transform: Matrix4.translationValues(-20, 0.0, 0.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  R.string.schedule_medicine.tr(),
                  style: TextStyle(color: R.color.white, fontSize: 20, fontWeight: FontWeight.w400),
                ),
              ),
            ),
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Hướng dẫn',
                    style: TextStyle(color: R.color.white, fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ],
            backgroundColor: R.color.transparent,
            //No more green
            elevation: 0.0,
            //Shadow gone
            flexibleSpace: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [R.color.greenGradientMid, R.color.greenGradientBottom])),
            ),
          ),
          body: _buildContainer(),
        ),
      ),
    );
  }

  Widget _buildContainer() {
    return Container(
      color: R.color.backgroundColorNew,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _buildBanner(),
              _buildDoYouKnow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Image.asset(R.drawable.medicine_banner, fit: BoxFit.fitWidth);
  }

  Widget _buildDoYouKnow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE4E4E7), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            R.string.do_you_know.tr(),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: R.color.color0xff111515,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            R.string.do_you_know_content.tr(),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Color(0xff5E6566),
            ),
          ),

          GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.only(top: 16),
              height: 48,
              decoration: BoxDecoration(
                color: R.color.mainColor,
                borderRadius: BorderRadius.circular(200),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.centerRight,
                  colors: [R.color.greenGradientTop, R.color.greenGradientBottom],
                ),
              ),
              child: Center(
                child: Text(
                  R.string.add_schedule_medicine.tr(),
                  style: TextStyle(color: R.color.white, fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
