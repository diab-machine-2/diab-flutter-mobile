import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loadmore/loadmore.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/debouncer.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/components/load_more.dart';
import 'package:medical/src/widgets/common_page.dart';
import 'package:medical/src/widgets/stack_loading_view.dart';

import '../change_menu/widgets/food_item_widget.dart';
import 'search_food.dart';

class SeachFoodPage extends StatefulWidget {
  const SeachFoodPage({required this.onTapYes});

  final Function(FoodModel foodModel) onTapYes;

  @override
  _SeachFoodPageState createState() => _SeachFoodPageState();
}

class _SeachFoodPageState extends State<SeachFoodPage> {
  late final SearchFoodCubit _cubit;
  TextEditingController controller = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    final AppRepository appRepository = AppRepository();
    _cubit = SearchFoodCubit(appRepository);
    _cubit.searchFood();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocConsumer<SearchFoodCubit, SearchFoodState>(
          listener: (context, state) {},
          builder: (context, state) {
            return StackLoadingView(
              visibleLoading: state is SearchFoodLoading,
              child: CommonPage(
                title: R.string.choose_alternative_dish.tr(),
                background: R.drawable.bg_detail_pro,
                icon: Icons.clear_rounded,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, top: 8, bottom: 16),
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                              color: R.color.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                  color: R.color.grayComponentBorder)),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16, right: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: CupertinoTextField(
                                    autofocus: true,
                                    controller: controller,
                                    placeholder: R.string.tim_kiem_mon_an.tr(),
                                    decoration:
                                        const BoxDecoration(border: null),
                                    onChanged: (value) {
                                      _debouncer.run(() {
                                        _cubit.searchFood(keyWord: value);
                                      });
                                    },
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Image.asset(R.drawable.ic_clear,
                                      width: 35, height: 35),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          _cubit.searchFood();
                        },
                        child: LoadMore(
                          onLoadMore: () async {
                            return _cubit.searchFood(isLoadMore: true);
                          },
                          isFinish: !_cubit.hasMore,
                          whenEmptyLoad: false,
                          delegate: const CustomLoadMoreDelegate(),
                          textBuilder: DefaultLoadMoreTextBuilder.english,
                          child: ListView.separated(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount:
                                _cubit.foods.isEmpty ? 1 : _cubit.foods.length,
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return Container(
                                  height: 1, color: R.color.color0xffE5E5E5);
                            },
                            itemBuilder: (BuildContext context, int index) {
                              if (_cubit.foods.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      left: 64, right: 64, top: 100),
                                  child: Image.asset(
                                      R.drawable.img_near_food_empty),
                                );
                              } else {
                                return FoodItemWidget(
                                  model: _cubit.foods[index],
                                  onFavorite: () async {
                                    _cubit.toogleFavorite(index);
                                  },
                                  onTapYes: () {
                                    widget.onTapYes(_cubit.foods[index]);
                                    NavigationUtil.pop(context);
                                  },
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
