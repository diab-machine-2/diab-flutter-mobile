import 'package:bot_toast/bot_toast.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/subscription/pages/paywall_screen.dart';
import 'package:medical/src/widget/subscription/subscription_cubit.dart';
import 'package:medical/src/widget/subscription/subscription_state.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> with Observer {
  late SubscriptionCubit _cubit;
  int _currentCarouselIndex = 0;
  final CarouselController _carouselController = CarouselController();

  // Carousel data - represents the 3 images you've provided
  final List<Map<String, dynamic>> _carouselItems = [
    {
      'image': R.drawable.subscription_image_1,
      'title': 'Giảm HbA1c,\nngừa biến chứng',
    },
    {
      'image': R.drawable.subscription_image_2,
      'title': 'Giảm 5% cân nặng\nphòng ngừa bệnh',
    },
    {
      'image': R.drawable.subscription_image_3,
      'title': 'Đạt thành tựu\nkhoa học',
    },
  ];

  @override
  void initState() {
    super.initState();
    Observable.instance.addObserver(this);
    _cubit = SubscriptionCubit();
    _cubit.checkSubscriptionStatus();
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
    if (notifyName == 'refresh_subscription') {
      _cubit.checkSubscriptionStatus();
    }
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
          child: _buildMainContent(context),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return BlocConsumer<SubscriptionCubit, SubscriptionState>(
      listener: (context, state) {
        print('Current state: $state');
        if (state is SubscriptionFailure) {
          BotToast.closeAllLoading();
          Message.showToastMessage(context, state.error);
        } else {
          BotToast.closeAllLoading();
        }
      },
      builder: (BuildContext context, SubscriptionState state) {
        print('Building with state: $state');
        if (state is SubscriptionLoading) {
          BotToast.showLoading(allowClick: false);
        } else {
          BotToast.closeAllLoading();
        }
        return _buildPage(context, state);
      },
    );
  }

  Widget _buildPage(BuildContext context, SubscriptionState state) {
    double screenWidth = MediaQuery.of(context).size.width;
    double aspectRatio = 125 / 172; // width/height
    double calculatedHeight = screenWidth / aspectRatio;
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
            hideAllBackButton: true,
            backgroundColor: Colors.transparent,
            title: Text(
              R.string.lifestyle_program.tr(),
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: R.color.white),
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              // Carousel slider
              CarouselSlider(
                carouselController: _carouselController,
                options: CarouselOptions(
                  height: calculatedHeight,
                  viewportFraction: 1.0,
                  enlargeCenterPage: false,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 5),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentCarouselIndex = index;
                    });
                  },
                ),
                items: _carouselItems.map((item) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: screenWidth,
                        height: calculatedHeight,
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Image.asset(
                          item['image'],
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              // Content overlay
              _buildCarouselContent(context,
                  _carouselItems[_currentCarouselIndex], _currentCarouselIndex),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCarouselContent(
      BuildContext context, Map<String, dynamic> item, int index) {
    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.12,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        margin: EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: R.color.white,
          boxShadow: [
            Utils.getBoxShadowDropCard(),
          ],
        ),
        child: Column(
          children: [
            Text(
              item['title'],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: R.color.color0xff111515,
              ),
            ),
            Center(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 16),
                child: SmoothPageIndicator(
                  controller:
                      PageController(initialPage: _currentCarouselIndex),
                  count: _carouselItems.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    spacing: 4,
                    expansionFactor: 2,
                    activeDotColor: R.color.greenGradientBottom,
                    dotColor: R.color.color0xffDFE4E4,
                  ),
                  onDotClicked: (index) {
                    _carouselController.animateToPage(index);
                  },
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to PaywallScreen with full-screen dialog
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (context) => PaywallScreen(),
                    fullscreenDialog: true,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: R.color.color0xff239A90,
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(200),
                ),
              ),
              child: Text(
                R.string.tim_hieu_them.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}