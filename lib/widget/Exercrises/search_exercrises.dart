import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/bloc/exercrises/exercrises_bloc.dart';
import 'package:medical/modal/exercrises/exercrises_Category.dart';
import 'package:medical/modal/exercrises/exercrises_categogy_request.dart';
import 'package:medical/theme/app_theme.dart';
import 'package:medical/widget/Exercrises/input_detail_exercrise.dart';
import 'package:medical/widget/base/base_state.dart';
import 'package:medical/widget/base/custom_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:medical/widget/helper/helper.dart';
import 'package:medical/widget/helper/show_message.dart';

typedef ExercrisesCategorycallback = Function(
    List<ExercrisesCategoryModel>, int);

class SearchExercrisesController extends StatefulWidget {
  final List<ExercrisesCategoryModel> model;
  final ExercrisesCategorycallback callback;
  final String type;
  final String id;
  SearchExercrisesController({this.type, this.id, this.callback, this.model});

  @override
  _SearchExercrisesControllerState createState() =>
      _SearchExercrisesControllerState();
}

class _SearchExercrisesControllerState
    extends BaseState<SearchExercrisesController> {
  ScrollController _scrollController = ScrollController();
  bool isClicked = false;
  BuildContext currentContext;
  int selectedItem;
  int sumCalories = 0;
  int page = 1;
  bool hasMore = false;
  bool isLoading = false;

  List<String> removeIDs = [];

  void initState() {
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  // loadDetail() async {
  //   BotToast.showLoading();
  //   model = await ExercrisesClient().fetchCategory(1);
  //   print(model);
  //   BotToast.closeAllLoading();
  //   setState(() {});
  //

  @override
  Widget build(BuildContext context) {
    //  super.build(context);
    return BlocProvider<ExercrisesBloc>(
        create: (context) => ExercrisesBloc(),
        child: BlocBuilder<ExercrisesBloc, ExercrisesState>(
            builder: (BuildContext context, ExercrisesState state) {
          currentContext = context;
          ExercrisesListCategoryModel model;
          List<ExercrisesCategoryModel> selectedCategories = [];

          if (state is ExercrisesInitial) {
            BlocProvider.of<ExercrisesBloc>(context)
                .add(FetchCategory(page: 1, selectedModel: []));
          }
          if (state is ExercrisesError) {
            Message.showToastMessage(context, state.message);
          }
          if (state is ExercrisesCategoryModelLoaded) {
            model = state.category;
            if (state.categorySearch != null) {
              model = state.categorySearch;
            }
            selectedCategories = state.selectedModel;
          }
          selectedItem = selectedCategories != [] && selectedCategories != null
              ? selectedCategories.length
              : 0;
          sumCalories = selectedCategories
              .fold(
                  0,
                  (previousValue, element) =>
                      previousValue + element.burnedCalorie)
              .round();
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Scaffold(
              backgroundColor: backgroundColor,
              body: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image:
                            AssetImage('assets/images/background_splash.png'),
                        fit: BoxFit.cover)),
                child: Column(
                  children: [
                    CustomAppBar(
                      backgroundColor: Colors.transparent,
                      title: Text(
                          widget.type == 'update'
                              ? 'Chỉnh sửa vận động'
                              : 'Chọn loại vận động',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: textDark)),
                      leadingIcon: IconButton(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          icon: Icon(Icons.arrow_back, color: textDark),
                          onPressed: () {
                            Navigator.pop(context);

                            // _showDialogSave();
                          }),
                      // actions: [
                      //   GestureDetector(
                      //     onTap: () {
                      //       setState(() {
                      //         isClicked = !isClicked;
                      //       });
                      //     },
                      //     child: Padding(
                      //       padding: const EdgeInsets.only(left: 16, right: 16),
                      //       child: isClicked
                      //           ? Image.asset(
                      //               'assets/images/help_circle_active.png',
                      //               width: 24,
                      //               height: 24)
                      //           : Image.asset('assets/images/help_circle.png',
                      //               width: 24, height: 24),
                      //     ),
                      //   ),
                      // ],
                    ),
                    Expanded(
                      child: Column(children: [
                        Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, bottom: 16),
                            child: isClicked
                                ? Image.asset('assets/images/Bg_add_HbA1c.png')
                                : SizedBox()),
                        Container(
                            height: 54,
                            margin: EdgeInsets.only(left: 16, right: 16),
                            padding: EdgeInsets.only(left: 16, right: 16),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: grayComponentBorder)),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Container(
                                        height: 30,
                                        child: TextField(
                                          onChanged: _search,
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.only(top: -20),
                                              hintText: 'Tìm kiếm hoạt động',
                                              fillColor: textDark),
                                        )),
                                  ),
                                  Image.asset('assets/images/search.png',
                                      width: 24, height: 24, color: mainColor),
                                ])),
                        model == null
                            ? Center(child: CircularProgressIndicator())
                            : Expanded(
                                child: ListView(
                                    keyboardDismissBehavior:
                                        ScrollViewKeyboardDismissBehavior
                                            .onDrag,
                                    padding: EdgeInsets.all(0),
                                    shrinkWrap: true,
                                    children: [
                                      buildActivities(
                                          model, selectedCategories, 0),
                                      buildActivities(
                                          model, selectedCategories, 1),
                                      buildActivities(
                                          model, selectedCategories, 2),
                                    ]),
                              )
                      ]),
                    ),
                    GestureDetector(
                      onTap: () async {
                        // _submitData();
                      },
                      child: Container(
                        color: Colors.white,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, right: 16, top: 8, bottom: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('$selectedItem hoạt động'),
                                  Row(
                                    children: [
                                      Text(formatNumber(sumCalories.toDouble()),
                                          style: TextStyle(
                                              color: textDark,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700)),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 2.0, left: 2),
                                        child: Text(
                                          'kcal',
                                          style: TextStyle(
                                              color: textDark,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SafeArea(
                              top: false,
                              child: widget.type == 'input'
                                  ? GestureDetector(
                                      onTap: () {
                                        widget.callback(
                                            selectedCategories, sumCalories);
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            bottom: 16, top: 16),
                                        height: 48,
                                        width: 195,
                                        decoration: BoxDecoration(
                                            color: mainColor,
                                            borderRadius:
                                                BorderRadius.circular(200),
                                            gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.centerRight,
                                                colors: [
                                                  greenGradientTop,
                                                  greenGradientBottom
                                                ])),
                                        child: Center(
                                            child: Text('Lưu',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16))),
                                      ))
                                  : Container(
                                      margin:
                                          EdgeInsets.only(bottom: 16, top: 16),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16, right: 16),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  widget.callback([], 0);
                                                  Navigator.pop(context);
                                                },
                                                child: Container(
                                                    height: 48,
                                                    width: 164,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(200),
                                                        border: Border.all(
                                                            color: red,
                                                            width: 2)),
                                                    child: Center(
                                                      child: Text('Xoá dữ liệu',
                                                          style: TextStyle(
                                                              color: Colors.red,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600)),
                                                    )),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  widget.callback(
                                                      selectedCategories,
                                                      sumCalories);
                                                  Navigator.pop(context);
                                                },
                                                child: Container(
                                                  height: 48,
                                                  width: 164,
                                                  decoration: BoxDecoration(
                                                      color: mainColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              200),
                                                      gradient: LinearGradient(
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment
                                                              .centerRight,
                                                          colors: [
                                                            greenGradientTop,
                                                            greenGradientBottom
                                                          ])),
                                                  child: Center(
                                                    child: Text('Lưu',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600)),
                                                  ),
                                                ),
                                              ),
                                            ]),
                                      ),
                                    ),
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
        }));
  }

  Widget buildActivities(ExercrisesListCategoryModel data,
      List<ExercrisesCategoryModel> selectedCategories, int type) {
    final title = type == 0
        ? 'Hoạt động phổ biến'
        : type == 1
            ? 'Hoạt động thường xuyên'
            : 'Các hoạt động khác';
    final model = type == 0
        ? data.exerciseCategoryCommons
        : type == 1
            ? data.exerciseCategoryRegularlies
            : data.exerciseCategories;

    return model.length == 0
        ? SizedBox()
        : Column(children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(title,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
              ),
            ),
            model == null
                ? Center(child: CircularProgressIndicator())
                : ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.all(0),
                    itemCount: model.length,
                    separatorBuilder: (context, index) {
                      return Container(height: 1, color: Color(0xffD6D8E0));
                    },
                    itemBuilder: (BuildContext context, int index) {
                      final filterResult = selectedCategories.where((element) =>
                          model[index].categoryId == element.categoryId);
                      final selectedModel =
                          filterResult.length > 0 ? filterResult.first : null;
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) =>
                                    InputDetailExercrisesController(
                                  model: selectedModel ?? model[index],
                                  datacallback: (modelCallback) {
                                    BlocProvider.of<ExercrisesBloc>(context)
                                        .add(AddCategory(
                                            selectedModel: modelCallback));
                                  },
                                ),
                              ));
                        },
                        child: Container(
                            padding: EdgeInsets.only(
                                left: 16, right: 16, top: 8, bottom: 8),
                            decoration: BoxDecoration(
                                color: selectedModel == null
                                    ? Colors.transparent
                                    : Color(0xffC3E8D3).withOpacity(0.5),
                                border: Border.all(
                                    color: selectedModel == null
                                        ? Colors.transparent
                                        : Color(0xff72CB9C))),
                            child: Row(
                              children: [
                                Stack(
                                    alignment: AlignmentDirectional.center,
                                    children: [
                                      Image.asset(
                                          'assets/images/activity_empty.png',
                                          width: 50,
                                          height: 50),
                                      Image.network(
                                          model[index].cover.url ?? '',
                                          width: 35,
                                          height: 35)
                                    ]),
                                SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(model[index].category,
                                        style: TextStyle(
                                            color: textDark,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600)),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    selectedModel == null
                                        ? SizedBox()
                                        : Row(
                                            children: [
                                              Text(
                                                  selectedModel == null
                                                      ? ''
                                                      : selectedModel.duration
                                                                  .round() ==
                                                              selectedModel
                                                                  .duration
                                                          ? selectedModel
                                                              .duration
                                                              .round()
                                                              .toString()
                                                          : selectedModel
                                                              .duration
                                                              .toString(),
                                                  style: TextStyle(
                                                      color: textDark,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400)),
                                              SizedBox(
                                                width: 4,
                                              ),
                                              selectedModel == null
                                                  ? SizedBox()
                                                  : Text('phút,',
                                                      style: TextStyle(
                                                          color: textDark,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400)),
                                              SizedBox(
                                                width: 4,
                                              ),
                                              Text(
                                                  selectedModel == null
                                                      ? ''
                                                      : formatNumber(
                                                          selectedModel
                                                              .burnedCalorie),
                                                  style: TextStyle(
                                                      color: textDark,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400)),
                                              SizedBox(
                                                width: 2,
                                              ),
                                              Text(
                                                  selectedModel == null
                                                      ? ''
                                                      : selectedModel.unit
                                                          .toString(),
                                                  style: TextStyle(
                                                      color: textDark,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400)),
                                            ],
                                          )
                                  ],
                                ),
                              ],
                            )),
                      );
                    })
          ]);
  }

  void _search(String queryString) {
    BlocProvider.of<ExercrisesBloc>(currentContext)
        .add(SearchCategory(key: queryString));
  }
}
