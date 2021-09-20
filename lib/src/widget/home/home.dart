import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/bloc/home/home_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/src/modal/home/home_model.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/widget/Food/widget/energy_chart.dart';
import 'package:medical/src/widget/HbA1C/widget/course_%20suggest.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/home/widget/header.dart';
import 'package:medical/src/widget/tabbar/tabbar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeController extends StatefulWidget {
  @override
  _HomeControllerState createState() => _HomeControllerState();
}

class _HomeControllerState extends State<HomeController> {
  var data = [
    {
      'name': 'Đường huyết',
      'image': '',
      'icon': 'assets/images/icon_bloodSugar.png',
      'dataDetail': []
    },
    {
      'name': 'Huyết áp',
      'image': 'assets/images/im_bloodPresser.png',
      'icon': 'assets/images/icon_heartPresse.png',
      'dataDetail': []
    },
    {
      'name': 'Cân nặng',
      'image': 'assets/images/im_weight.png',
      'icon': 'assets/images/icon_weight.png',
      'dataDetail': []
    },
    {
      'name': 'Cảm xúc',
      'image': 'assets/images/im_emotion.png',
      'icon': 'assets/images/icon_emotion.png',
      'dataDetail': [
        {'name': 'Vui vẻ', 'image': 'assets/images/laughing.png'},
        {'name': 'Buồn ngủ', 'image': 'assets/images/sleeping.png'},
        {'name': 'Ốm', 'image': 'assets/images/sick.png'}
      ]
    },
    // {
    //   'name': 'Vận động',
    //   'image': 'assets/images/im_active.png',
    //   'icon': 'assets/images/icon_active.png',
    //   'dataDetail': []
    // },
    // {
    //   'name': 'Dinh dưỡng',
    //   'image': 'assets/images/im_nutrition.png',
    //   'icon': 'assets/images/icon_nutrition.png',
    //   'dataDetail': []
    // }
  ];

  var dataDetail = [{}];
  BuildContext currentContext;

  int page = 1;
  bool isLoading = false;

  HomeModel model;

  @override
  void initState() {
    super.initState();
    DartNotificationCenter.subscribe(
        channel: 'BloodPressure_change_data',
        observer: this,
        onNotification: (_) {
          _refresh();
          checkScreen('/detail_bloodPressure');
        });
    DartNotificationCenter.subscribe(
        channel: 'glucose_change_data',
        observer: this,
        onNotification: (_) {
          _refresh();
          checkScreen('/detail_bloodSugar');
        });
    DartNotificationCenter.subscribe(
        channel: 'Weight_change_data',
        observer: this,
        onNotification: (_) {
          _refresh();
          checkScreen('/detail_bmi');
        });
    DartNotificationCenter.subscribe(
        channel: 'Emotion_change_data',
        observer: this,
        onNotification: (_) {
          _refresh();
          checkScreen('/detail_emotion');
        });
    DartNotificationCenter.subscribe(
        channel: 'active_change_data',
        observer: this,
        onNotification: (_) {
          _refresh();
          checkScreen('/detail_exercrises');
        });
    DartNotificationCenter.subscribe(
        channel: 'food_change_data',
        observer: this,
        onNotification: (_) {
          _refresh();
          checkScreen('/detail_food');
        });
    DartNotificationCenter.subscribe(
        channel: 'hba1c_change_data',
        observer: this,
        onNotification: (_) {
          _refresh();
          checkScreen('/detail_hba1c');
        });
    DartNotificationCenter.subscribe(
        channel: 'goal_calo_changed',
        observer: this,
        onNotification: (_) {
          _refresh();
        });
    DartNotificationCenter.subscribe(
        channel: 'refresh_home',
        observer: this,
        onNotification: (_) {
          _refresh();
        });
    //getData();
    TrackingManager.analytics.setCurrentScreen(screenName: 'Home');
  }

  @override
  void dispose() {
    DartNotificationCenter.unsubscribe(
        channel: 'BloodPressure_change_data', observer: this);
    DartNotificationCenter.unsubscribe(
        channel: 'glucose_change_data', observer: this);
    DartNotificationCenter.unsubscribe(
        channel: 'Weight_change_data', observer: this);
    DartNotificationCenter.unsubscribe(
        channel: 'Emotion_change_data', observer: this);
    DartNotificationCenter.unsubscribe(
        channel: 'active_change_data', observer: this);
    DartNotificationCenter.unsubscribe(
        channel: 'food_change_data', observer: this);
    DartNotificationCenter.unsubscribe(
        channel: 'hba1c_change_data', observer: this);
    DartNotificationCenter.unsubscribe(
        channel: 'goal_calo_changed', observer: this);
    DartNotificationCenter.unsubscribe(channel: 'refresh_home', observer: this);
    super.dispose();
  }

  getData() async {
    final result = await AppSettings.getHome();
    if (result != null) {
      setState(() {
        model = result;
      });
    }
  }

  checkScreen(String routeName) {
    Navigator.popUntil(context, (route) {
      if (route.settings.name == routeName) {
        return true;
      } else if (route.isFirst) {
        Navigator.pushNamed(context, routeName);
        return true;
      }
      return false;
    });
  }

  Future<bool> _refresh() async {
    page = 1;
    BlocProvider.of<HomeBloc>(currentContext).add(FetchHome());
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width - 32;
    return BlocProvider<HomeBloc>(
        create: (context) => HomeBloc(),
        child: BlocBuilder<HomeBloc, HomeState>(
            builder: (BuildContext context, HomeState state) {
          currentContext = context;

          if (state is HomeInitial) {
            BlocProvider.of<HomeBloc>(context).add(FetchHome());
          }
          if (state is HomeLoading) {
            model = state.model;
          }
          if (state is HomeLoaded) {
            model = state.model;

            isLoading = false;
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: Scaffold(
              body: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                  image: AssetImage('assets/images/bg_home.jpg'),
                  fit: BoxFit.fill,
                )),
                child: Column(
                  children: [
                    HomeHeader(),
                    Expanded(
                      child: SafeArea(
                        top: false,
                        child: ListView(
                            padding: EdgeInsets.only(bottom: 16),
                            children: [
                              GridView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  padding: EdgeInsets.only(left: 16, right: 16),
                                  itemCount: data.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 24,
                                          mainAxisSpacing: 16,
                                          childAspectRatio: 160 / 140),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    // if (index == 2) {
                                    final name = data[index]['name'];
                                    final image = data[index]['image'];
                                    final icon = data[index]['icon'];
                                    if (index == 0 &&
                                        model != null &&
                                        model.glucoseIndex.index != 0) {
                                      return _buildBloodSuger(
                                          context,
                                          index,
                                          name,
                                          image,
                                          icon,
                                          model.glucoseIndex);
                                    }
                                    if (index == 1 &&
                                        model != null &&
                                        model.bloodPressureIndex.diastolic !=
                                            0) {
                                      return _buildBloodPressure(
                                          context,
                                          index,
                                          name,
                                          image,
                                          icon,
                                          model.bloodPressureIndex);
                                    }
                                    if (index == 2 &&
                                        model != null &&
                                        model.weightCard.weight != 0) {
                                      return _buildWeight(context, index, name,
                                          image, icon, model.weightCard);
                                    }
                                    if (index == 3 &&
                                        model != null &&
                                        model.emotionCard.details != null) {
                                      return _buildEmotion(context, index, name,
                                          image, icon, model.emotionCard);
                                    }

                                    return _buildItem(
                                        context, index, name, image, icon);
                                  }),
                              SizedBox(height: 16),
                              Padding(
                                  padding: EdgeInsets.only(left: 16, right: 16),
                                  child: model != null &&
                                          (model.energyCard.consumedEnergy !=
                                                  0 ||
                                              model.exercise.index != 0)
                                      ? buildFoodAndExcercise(model)
                                      : Container(
                                          height: width * 160 / 343,
                                          child: Stack(children: [
                                            Positioned.fill(
                                              child: Container(
                                                padding: EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Text(
                                                    'Dinh dưỡng & Vận động',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                              ),
                                            ),
                                            Positioned(
                                                top: 60,
                                                bottom: 0,
                                                left: 0,
                                                child: Image.asset(
                                                    'assets/images/im_food_and_excersire.png')),
                                            Center(
                                                child: Image.asset(
                                                    'assets/images/icon_food_and_excersire.png',
                                                    width: 58,
                                                    height: 58)),
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                      child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.pushNamed(
                                                          context,
                                                          '/detail_food');
                                                    },
                                                    child: Container(
                                                        color:
                                                            Colors.transparent),
                                                  )),
                                                  Expanded(
                                                      child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.pushNamed(
                                                          context,
                                                          '/detail_exercrises');
                                                    },
                                                    child: Container(
                                                        color:
                                                            Colors.transparent),
                                                  ))
                                                ])
                                          ]),
                                        )),
                              SizedBox(height: 16),
                              Padding(
                                padding: EdgeInsets.only(left: 16, right: 16),
                                child: GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, '/detail_hba1c');
                                    },
                                    child: model != null &&
                                            model.hbA1CIndex.index != 0
                                        ? buildHbA1C(model.hbA1CIndex)
                                        : Container(
                                            height: width * 90 / 343,
                                            child: Stack(children: [
                                              Positioned.fill(
                                                child: Container(
                                                  padding: EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Text('HbA1C',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                ),
                                              ),
                                              Positioned(
                                                  top: 0,
                                                  bottom: 0,
                                                  right: 0,
                                                  child: Image.asset(
                                                      'assets/images/im_hba1c.png')),
                                              Center(
                                                  child: Image.asset(
                                                      'assets/images/icon_HbA1Cn.png',
                                                      width: 58,
                                                      height: 58))
                                            ]),
                                          )),
                              ),
                              buildServiceButton(),
                              CourseSuggest(position: 1),
                            ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }));
  }

  Widget _buildItem(
      BuildContext context, int index, String name, String image, String icon) {
    return GestureDetector(
      onTap: () {
        if (index == 0)
          Navigator.pushNamed(context, '/detail_bloodSugar');
        else if (index == 1) {
          Navigator.pushNamed(context, '/detail_bloodPressure');
        } else if (index == 2) {
          Navigator.pushNamed(context, '/detail_bmi');
        } else if (index == 3) {
          Navigator.pushNamed(context, '/detail_emotion');
        } else if (index == 4) {
          Navigator.pushNamed(context, '/detail_food');
        } else if (index == 2) {
          Navigator.pushNamed(context, '/detail_exercrises');
        }

        return null;
      },
      child: Stack(children: [
        Positioned.fill(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Text(name,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
        image.isEmpty
            ? SizedBox()
            : Positioned(
                top: 0, bottom: 0, right: 0, child: Image.asset(image)),
        Center(
            child: Padding(
                padding: EdgeInsets.only(top: 20),
                child: Image.asset(icon, width: 58, height: 58)))
      ]),
    );
  }

  Widget _buildBloodSuger(BuildContext context, int index, String name,
      String image, String icon, GloucoseIndexModel model) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/detail_bloodSugar');
      },
      child: Stack(children: [
        Positioned.fill(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text(
                      getStringToday(model.createDateTime).isEmpty
                          ? convertToUTC(model.createDateTime, 'dd/MM/yyyy')
                          : getStringToday(model.createDateTime),
                      style: TextStyle(
                          color: Color(0xff9C9C9C),
                          fontSize: 12,
                          fontWeight: FontWeight.w400)),
                ]),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(roundNumber(model.index),
                        style: TextStyle(
                            fontFamily: 'Viga',
                            color: toColor(model.color),
                            fontSize: 26,
                            fontWeight: FontWeight.w400)),
                    SizedBox(width: 4),
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(model.unit,
                          style: TextStyle(
                              color: Color(0xff9C9C9C),
                              fontSize: 12,
                              fontWeight: FontWeight.w400)),
                    )
                  ],
                ),
                model.indexChange == 0
                    ? SizedBox(height: 25)
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.network(model.icon.url ?? '',
                              width: 25, height: 25),
                          SizedBox(width: 4),
                          Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                                (model.indexChange > 0 ? '+' : '') +
                                    roundNumber(
                                        roundAsFixed(model.indexChange)),
                                style: TextStyle(
                                    color: Color(0xff9C9C9C),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400)),
                          )
                        ],
                      )
              ],
            ),
          ),
        )
      ]),
    );
  }

  Widget _buildBloodPressure(BuildContext context, int index, String name,
      String image, String icon, BloodPressureIndexModel model) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/detail_bloodPressure');
      },
      child: Stack(children: [
        Positioned.fill(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text(
                      getStringToday(model.createDateTime ?? 0).isEmpty
                          ? convertToUTC(
                              model.createDateTime ?? 0, 'dd/MM/yyyy')
                          : getStringToday(model.createDateTime ?? 0),
                      style: TextStyle(
                          color: Color(0xff9C9C9C),
                          fontSize: 12,
                          fontWeight: FontWeight.w400)),
                ]),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                        model.systolic.round().toString() +
                            '/' +
                            model.diastolic.round().toString(),
                        style: TextStyle(
                            fontFamily: 'Viga',
                            color: toColor(model.color),
                            fontSize: 26,
                            fontWeight: FontWeight.w400)),
                    SizedBox(width: 4),
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('mmHg',
                          style: TextStyle(
                              color: Color(0xff9C9C9C),
                              fontSize: 12,
                              fontWeight: FontWeight.w400)),
                    )
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.network(model.icon.url ?? '', width: 25, height: 25),
                    SizedBox(width: 4),
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                          (model.systolicChange > 0 ? '+' : '') +
                              model.systolicChange.round().toString() +
                              '/' +
                              (model.diastolicChange > 0 ? '+' : '') +
                              model.diastolicChange.round().toString(),
                          style: TextStyle(
                              color: Color(0xff9C9C9C),
                              fontSize: 12,
                              fontWeight: FontWeight.w400)),
                    )
                  ],
                )
              ],
            ),
          ),
        )
      ]),
    );
  }

  Widget _buildWeight(BuildContext context, int index, String name,
      String image, String icon, WeightCardModel model) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/detail_bmi');
      },
      child: Stack(children: [
        Positioned.fill(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text(
                      getStringToday(model.weightDateTime ?? 0).isEmpty
                          ? convertToUTC(
                              model.weightDateTime ?? 0, 'dd/MM/yyyy')
                          : getStringToday(model.weightDateTime ?? 0),
                      style: TextStyle(
                          color: Color(0xff9C9C9C),
                          fontSize: 12,
                          fontWeight: FontWeight.w400)),
                ]),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(model.weight.round().toString(),
                        style: TextStyle(
                            fontFamily: 'Viga',
                            color: toColor(model.weightColorCode),
                            fontSize: 26,
                            fontWeight: FontWeight.w400)),
                    SizedBox(width: 4),
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('/ ${model.goalWeight.round()} kg',
                          style: TextStyle(
                              color: Color(0xff9C9C9C),
                              fontSize: 12,
                              fontWeight: FontWeight.w400)),
                    )
                  ],
                )
              ],
            ),
          ),
        )
      ]),
    );
  }

  Widget _buildEmotion(BuildContext context, int index, String name,
      String image, String icon, EmotionCardModel model) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/detail_emotion');
      },
      child: Stack(children: [
        Positioned.fill(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text(
                      getStringToday(model.emotionDateTime ?? 0).isEmpty
                          ? convertToUTC(
                              model.emotionDateTime ?? 0, 'dd/MM/yyyy')
                          : getStringToday(model.emotionDateTime ?? 0),
                      style: TextStyle(
                          color: Color(0xff9C9C9C),
                          fontSize: 12,
                          fontWeight: FontWeight.w400)),
                ]),
                Column(
                  children: List.generate(
                      model.details.length,
                      (index) => Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(model.details[index].text,
                                    style: TextStyle(
                                        color: textDark,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400)),
                                SizedBox(width: 4),
                                Image.network(
                                    model.details[index].icon.url ?? '',
                                    width: 25,
                                    height: 25),
                              ],
                            ),
                          )),
                )
              ],
            ),
          ),
        )
      ]),
    );
  }

  Widget buildHbA1C(HbA1CIndexModel model) {
    final width = MediaQuery.of(context).size.width - 32;
    return Container(
      height: 95,
      child: Stack(children: [
        Positioned.fill(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('HbA1C',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    SizedBox(height: 4),
                    Text(
                        getStringToday(model.createDateTime ?? 0).isEmpty
                            ? convertToUTC(
                                model.createDateTime ?? 0, 'dd/MM/yyyy')
                            : getStringToday(model.createDateTime ?? 0),
                        style: TextStyle(
                            color: Color(0xff9C9C9C),
                            fontSize: 12,
                            fontWeight: FontWeight.w400))
                  ],
                ),
                Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(roundNumber(model.index),
                              style: TextStyle(
                                  fontFamily: 'Viga',
                                  color: toColor(model.color),
                                  fontSize: 26,
                                  fontWeight: FontWeight.w400)),
                          SizedBox(width: 4),
                          Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text('%',
                                style: TextStyle(
                                    color: Color(0xff9C9C9C),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400)),
                          )
                        ],
                      ),
                      model.indexChange == 0
                          ? SizedBox()
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.network(model.icon.url ?? '',
                                    width: 25, height: 25),
                                SizedBox(width: 4),
                                Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(
                                      (model.indexChange > 0 ? '+' : '') +
                                          roundNumber(model.indexChange) +
                                          '% so với lần trước!',
                                      style: TextStyle(
                                          color: Color(0xff9C9C9C),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400)),
                                )
                              ],
                            )
                    ])
              ],
            ),
          ),
        )
      ]),
    );
  }

  Widget buildFoodAndExcercise(HomeModel model) {
    final width = (MediaQuery.of(context).size.width - 32);
    final height = width / 1029 * 480;
    final heightApple = 126 * height / 160;

    final heightLA = height * 14 / 160;
    final top = height * 42 / 160;

    return Container(
      height: height,
      width: width,
      child: Stack(alignment: AlignmentDirectional.bottomCenter, children: [
        Stack(alignment: AlignmentDirectional.topCenter, children: [
          SizedBox(
              width: heightApple,
              height: heightApple,
              child: CustomPaint(
                  painter: GradientArcPainter(
                progress: 1,
                startColor: Colors.white,
                endColor: Colors.white,
                width: 36,
              ))),
          SizedBox(
              width: heightApple,
              height: heightApple,
              child: CustomPaint(
                  painter: GradientArcPainter(
                progress: model.energyExerciseCard.value < 0
                    ? 1
                    : (model.energyExerciseCard.value /
                        model.energyExerciseCard.energyGoal),
                startColor: toColor(model.energyExerciseCard.corlorCode)
                    .withOpacity(0.3),
                endColor: toColor(model.energyExerciseCard.corlorCode),
                width: 36.0,
              ))),
        ]),
        Positioned(
          top: top,
          left: 0,
          right: 0,
          child: Center(
              child: Container(
                  height: heightLA,
                  width: heightLA * 4,
                  color: toColor(model.energyExerciseCard.corlorCode))),
        ),
        Image.asset('assets/images/apple_home.png'),
        Positioned.fill(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dinh dưỡng',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        SizedBox(height: 4),
                        Text(
                            model.energyCard == null
                                ? ''
                                : getStringToday(model.energyCard
                                                .consumedEnergyDateTime ??
                                            0)
                                        .isEmpty
                                    ? convertToUTC(
                                        model.energyCard
                                                .consumedEnergyDateTime ??
                                            0,
                                        'dd/MM/yyyy')
                                    : getStringToday(model.energyCard
                                            .consumedEnergyDateTime ??
                                        0),
                            style: TextStyle(
                                color: Color(0xff9C9C9C),
                                fontSize: 12,
                                fontWeight: FontWeight.w400))
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Vận động',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        SizedBox(height: 4),
                        Text(
                            model.exercise.createDateTime == 0
                                ? ''
                                : getStringToday(
                                            model.exercise.createDateTime ?? 0)
                                        .isEmpty
                                    ? convertToUTC(
                                        model.exercise.createDateTime ?? 0,
                                        'dd/MM/yyyy')
                                    : getStringToday(
                                        model.exercise.createDateTime ?? 0),
                            style: TextStyle(
                                color: Color(0xff9C9C9C),
                                fontSize: 12,
                                fontWeight: FontWeight.w400))
                      ],
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Image.asset('assets/images/icon_home_energy.png',
                                width: 20, height: 20),
                            SizedBox(width: 4),
                            Text('Đã nạp',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                                model.energyCard == null
                                    ? '0'
                                    : formatNumber(
                                        model.energyCard.consumedEnergy),
                                style: TextStyle(
                                    fontFamily: 'Viga',
                                    color: Colors.black,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w400)),
                            SizedBox(width: 4),
                            Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text('kcal',
                                  style: TextStyle(
                                      color: Color(0xff9C9C9C),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400)),
                            )
                          ],
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Image.asset('assets/images/icon_home_excercise.png',
                                width: 20, height: 20),
                            SizedBox(width: 4),
                            Text('Tiêu hao',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(formatNumber(model.exercise.index),
                                style: TextStyle(
                                    fontFamily: 'Viga',
                                    color: Colors.black,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w400)),
                            SizedBox(width: 4),
                            Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text('kcal',
                                  style: TextStyle(
                                      color: Color(0xff9C9C9C),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400)),
                            )
                          ],
                        )
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        Positioned(
            top: 16,
            child: Container(width: 1, height: 20, color: Color(0xffC0C2C5))),
        Stack(alignment: AlignmentDirectional.bottomCenter, children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                  (model.energyExerciseCard.value < 0 ? '-' : '') +
                      formatNumber(model.energyExerciseCard.value),
                  style: TextStyle(
                      fontFamily: 'Viga',
                      color: toColor(model.energyExerciseCard.corlorCode),
                      fontSize: 24,
                      fontWeight: FontWeight.w400)),
              SizedBox(height: 3),
              Text('/' + formatNumber(model.energyExerciseCard.energyGoal),
                  style: TextStyle(
                      color: Color(0xff9C9C9C),
                      fontSize: 11,
                      fontWeight: FontWeight.w400)),
              Text(model.energyExerciseCard.text,
                  style: TextStyle(
                      color: Color(0xff9C9C9C),
                      fontSize: 11,
                      fontWeight: FontWeight.w400)),
              SizedBox(height: height * 34 / 160)
            ],
          )
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
              child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/detail_food');
            },
            child: Container(color: Colors.transparent),
          )),
          Expanded(
              child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/detail_exercrises');
            },
            child: Container(color: Colors.transparent),
          ))
        ])
      ]),
    );
  }

  Widget buildServiceButton() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(16.h),
      height: 64.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.h),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4BB2AB), Color(0xFF01857A), Color(0xFF008479)],
        ),
      ),
      child: MaterialButton(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: StadiumBorder(),
        child: Text(
          R.string.upgrade_account.tr(),
          style: TextStyle(color: R.color.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        onPressed: () {

        },
      ),
    );
  }
}
