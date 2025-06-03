import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/exercrises/exercrises_bloc.dart';
import 'package:medical/src/modal/exercrises/exercrises_Category.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/debouncer.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/network_image_widget.dart';

class ExercisesCategories extends StatefulWidget {
  const ExercisesCategories(
      {Key? key, this.validator, this.onChanged, this.selected})
      : super(key: key);
  final String? Function(String)? validator;
  final void Function(ExercrisesCategoryModel?)? onChanged;
  final ExercrisesCategoryModel? selected;
  @override
  _ExercisesCategoriesState createState() => _ExercisesCategoriesState();
}

class _ExercisesCategoriesState extends State<ExercisesCategories>
    with WidgetsBindingObserver, Observer {
  late BuildContext currentContext;
  ExercrisesCategoryModel? selectedCateroty;
  @override
  void update(
      Observable observable, String? notifyName, Map<dynamic, dynamic>? map) {
    if (notifyName == 'active_change_data_v2') {
      // overViewKey.currentState!.reloadData(periodFilterType);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.selected != null) {
      selectedCateroty = widget.selected;
    }
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(covariant ExercisesCategories oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != null && widget.selected != oldWidget.selected) {
      selectedCateroty = widget.selected;
    }
  }

  @override
  void dispose() {
    Observable.instance.removeObserver(this); // Hủy đăng ký observer
    super.dispose(); // Gọi super.dispose() để giải phóng tài nguyên
  }

  _onSelectedChange(
    bool isSelected,
    ExercrisesCategoryModel e,
  ) {
    var newSelectedCateroty = selectedCateroty;
    if (isSelected) {
      newSelectedCateroty = null;
    } else {
      newSelectedCateroty = e;
    }
    setState(() {
      selectedCateroty = newSelectedCateroty;
    });
    if (widget.onChanged != null) {
      widget.onChanged!(newSelectedCateroty);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: R.color.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                R.string.hoat_dong.tr(),
                style: TextStyle(
                    fontSize: 20,
                    color: R.color.textDark,
                    fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                child: BlocProvider<ExercrisesBloc>(
                    create: (context) => ExercrisesBloc(),
                    child: BlocBuilder<ExercrisesBloc, ExercrisesState>(
                        builder: (BuildContext context, ExercrisesState state) {
                      currentContext = context;
                      if (state is ExercrisesInitial) {
                        BlocProvider.of<ExercrisesBloc>(currentContext)
                            .add(FetchCategory(page: 1));
                      }
                      if (state is ExercrisesLoading) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (state is ExercrisesCategoryModelLoaded) {
                        if (state.category?.exerciseCategories == null &&
                            state.category?.exerciseCategoryCommons == null &&
                            state.category?.exerciseCategoryRegularlies ==
                                null) {
                          return Center(
                            child: Text(R.string.no_data.tr()),
                          );
                        }
                        List<ExercrisesCategoryModel>? data = [];
                        if (state.category?.exerciseCategoryRegularlies !=
                            null) {
                          data.addAll(
                              state.category!.exerciseCategoryRegularlies);
                        }
                        if (state.category?.exerciseCategories != null) {
                          data.addAll(state.category!.exerciseCategories);
                        }
                        if (state.category?.exerciseCategoryCommons != null) {
                          data.addAll(state.category!.exerciseCategoryCommons);
                        }
                        // sort for selected on top
                        if (selectedCateroty != null) {
                          data.sort((a, b) {
                            final aSelected =
                                selectedCateroty?.categoryId == a.categoryId;
                            final bSelected =
                                selectedCateroty?.categoryId == b.categoryId;
                            if (aSelected == true && bSelected == false) {
                              return -1;
                            } else if (aSelected == false &&
                                bSelected == true) {
                              return 1;
                            }
                            return 0;
                          });
                        }
                        data = data.take(3).toList();
                        if (data.length == 0 || data.isEmpty) {
                          return Center(
                            child: Text(R.string.no_data.tr()),
                          );
                        }
                        return _buildContainer(data);
                      } else if (state is ExercrisesError) {
                        return Center(
                          child: Text(state.message ?? 'Error loading data'),
                        );
                      }
                      return Container();
                    })),
              ),
            ]));
  }

  _buildContainer(List<ExercrisesCategoryModel> data) {
    final imageSize = 64.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...data.map((e) {
          final isSelected = (e.categoryId == selectedCateroty?.categoryId);
          return InkWell(
              onTap: () {
                _onSelectedChange(
                  isSelected,
                  e,
                );
              },
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(200),
                    child: Container(
                      width: (1.sw - 16.w * 4) / 4 * 0.75,
                      height: (1.sw - 16.w * 4) / 4 * 0.75,
                      padding: EdgeInsets.all(12),
                      color: isSelected
                          ? R.color.main_1.withOpacity(0.8)
                          : R.color.greenGradientTop.withOpacity(0.1),
                      child: NetWorkImageWidget(
                        imageUrl: e.cover?.url ?? '',
                        isSelected: isSelected,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: imageSize.w,
                    height: 20,
                    child: Text(
                      e.category ?? '',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isSelected
                            ? R.color.greenGradientBottom
                            : R.color.textDark,
                        fontSize: 14,
                        fontFamily: 'sfpro',
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ));
        }),
        InkWell(
          onTap: () {
            Navigator.of(context)
                .pushNamed(NavigatorName.exercrise_select_category, arguments: {
              'selected': selectedCateroty,
              'onChanged': (ExercrisesCategoryModel? selected) {
                setState(() {
                  selectedCateroty = selected;
                });
                if (widget.onChanged != null) {
                  widget.onChanged!(selected);
                }
              }
            });
          },
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(200),
                child: SizedBox(
                  width: imageSize.w,
                  height: imageSize.h,
                  child: Container(
                    color: R.color.textDark.withOpacity(0.1),
                    child: Icon(
                      Icons.more_horiz,
                      color: R.color.textDark,
                      size: imageSize / 2,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                R.string.khac.tr(),
                style: TextStyle(
                  color: R.color.textDark,
                  fontSize: 14,
                  fontFamily: 'sfpro',
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ExercisesSelectCategory extends StatefulWidget {
  const ExercisesSelectCategory({Key? key, this.onChanged, this.selected})
      : super(key: key);
  final void Function(ExercrisesCategoryModel?)? onChanged;
  final ExercrisesCategoryModel? selected;

  @override
  _ExercisesSelectCategoryState createState() =>
      _ExercisesSelectCategoryState();
}

class _ExercisesSelectCategoryState extends State<ExercisesSelectCategory>
    with WidgetsBindingObserver, Observer {
  late BuildContext currentContext;
  ExercrisesCategoryModel? selectedCateroty;
  TextEditingController _controllerSearch = TextEditingController();
  @override
  void update(
      Observable observable, String? notifyName, Map<dynamic, dynamic>? map) {
    if (notifyName == 'active_change_data_v2') {
      // overViewKey.currentState!.reloadData(periodFilterType);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.selected != null) {
      selectedCateroty = widget.selected;
    }
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Observable.instance.removeObserver(this); // Hủy đăng ký observer
    super.dispose(); // Gọi super.dispose() để giải phóng tài nguyên
  }

  void _goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      BotToast.showText(
        text: 'Opps! You can not go back',
        duration: Duration(seconds: 2),
        backgroundColor: R.color.black,
        textStyle: TextStyle(color: R.color.white),
      );
    }
  }

  _onSelectedChange(
    bool isSelected,
    ExercrisesCategoryModel e,
  ) {
    var newSelectedCateroty = selectedCateroty;
    if (isSelected) {
      newSelectedCateroty = null;
    } else {
      newSelectedCateroty = e;
    }
    setState(() {
      selectedCateroty = newSelectedCateroty;
    });
    if (widget.onChanged != null) {
      widget.onChanged!(newSelectedCateroty);
    }
  }

  final Debouncer _debouncer = Debouncer(milliseconds: 500);
  void _onSearchChange(String? value) {
    _debouncer.run(() {
      BlocProvider.of<ExercrisesBloc>(currentContext)
          .add(SearchCategory(key: value ?? ''));
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _goBack();
        return false;
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.white,
            appBar: AppBar(
              leading: IconButton(
                  splashColor: R.color.transparent,
                  highlightColor: R.color.transparent,
                  icon: Icon(Icons.arrow_back, color: R.color.white),
                  onPressed: _goBack),
              title: Transform(
                transform: Matrix4.translationValues(-20, 0.0, 0.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    R.string.them_hoat_dong.tr(),
                    style: TextStyle(
                      color: R.color.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                      fontFamily: 'sfpro',
                    ),
                  ),
                ),
              ),
              backgroundColor: R.color.transparent, //No more green
              elevation: 0.0, //Shadow gone
              flexibleSpace: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                      Color(0xFF0DAB9C),
                      Color(0xFF01847A),
                    ])),
              ),
            ),
            body: Container(width: double.infinity, child: _buildContainer())),
      ),
    );
  }

  Widget _buildContainer() {
    // = screen width / 4 - 16;
    final containerSize = (1.sw - 16.w * 4) / 4;
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thanh tìm kiếm
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: R.color.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: R.color.textDark.withOpacity(0.25),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: R.color.textDark),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _controllerSearch,
                        decoration: InputDecoration(
                          hintText: R.string.tim_kiem_hoat_dong.tr(),
                          hintStyle: TextStyle(
                            color: R.color.textDark.withOpacity(0.5),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          // Xử lý tìm kiếm
                          _onSearchChange(value);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // GridView hiển thị danh sách hoạt động
              Expanded(
                flex: 1,
                child: BlocProvider<ExercrisesBloc>(
                    create: (context) => ExercrisesBloc(),
                    child: BlocBuilder<ExercrisesBloc, ExercrisesState>(
                        builder: (BuildContext context, ExercrisesState state) {
                      currentContext = context;
                      if (state is ExercrisesInitial) {
                        BlocProvider.of<ExercrisesBloc>(currentContext)
                            .add(FetchCategory(page: 1));
                      }
                      if (state is ExercrisesLoading) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (state is ExercrisesCategoryModelLoaded) {
                        if (state.category?.exerciseCategories == null &&
                            state.category?.exerciseCategoryRegularlies ==
                                null) {
                          return Center(
                            child: Text(R.string.no_data.tr()),
                          );
                        }
                        List<ExercrisesCategoryModel>? data = [];
                        if (_controllerSearch.text.isNotEmpty) {
                          if (state.categorySearch
                                  ?.exerciseCategoryRegularlies !=
                              null) {
                            data.addAll(state
                                .categorySearch!.exerciseCategoryRegularlies);
                          }
                          if (state.categorySearch?.exerciseCategories !=
                              null) {
                            data.addAll(
                                state.categorySearch!.exerciseCategories);
                          }
                        } else {
                          if (state.category?.exerciseCategoryRegularlies !=
                              null) {
                            data.addAll(
                                state.category!.exerciseCategoryRegularlies);
                          }
                          if (state.category?.exerciseCategories != null) {
                            data.addAll(state.category!.exerciseCategories);
                          }
                        }

                        data = data.toList();
                        if (data.length == 0 || data.isEmpty) {
                          return Center(
                            child: Text(R.string.no_data.tr()),
                          );
                        }
                        return GridView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final e = data![index];
                            final isSelected =
                                (e.categoryId == selectedCateroty?.categoryId);
                            return GestureDetector(
                              onTap: () {
                                _onSelectedChange(isSelected, e);
                              },
                              child: Column(
                                // mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Hình ảnh hoạt động
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(200),
                                    child: Container(
                                      width: containerSize * 0.75,
                                      height: containerSize * 0.75,
                                      padding: EdgeInsets.all(12),
                                      color: isSelected
                                          ? R.color.main_1.withOpacity(0.8)
                                          : R.color.greenGradientTop
                                              .withOpacity(0.1),
                                      child: NetWorkImageWidget(
                                        imageUrl: e.cover?.url ?? '',
                                        isSelected: isSelected,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  // Tên hoạt động
                                  Container(
                                    height: 38,
                                    width: double.infinity,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 2),
                                    child: Text(
                                      e.category ?? '',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isSelected
                                            ? R.color.greenGradientBottom
                                            : R.color.textDark,
                                        fontSize: 14,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        );
                      } else if (state is ExercrisesError) {
                        return Center(
                          child: Text(state.message ?? 'Error loading data'),
                        );
                      }
                      return Container();
                    })),
              ),

              SizedBox(height: 60),
            ],
          ),
        ),
        Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: KeyboardVisibilityProvider(
              child: KeyboardVisibilityBuilder(
                builder: (context, isKeyboardVisible) {
                  return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      height: isKeyboardVisible ? 0 : 60,
                      width: double.infinity,
                      child: Container(
                        // height: 60,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: R.color.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ButtonWidget(
                          title: R.string.confirm.tr(),
                          onPressed: _submitData,
                        ),
                      ));
                },
              ),
            ))
      ],
    );
  }

  _submitData() {
    if (widget.onChanged != null) {
      widget.onChanged!(selectedCateroty);
    }
    Navigator.pop(context);
  }
}
