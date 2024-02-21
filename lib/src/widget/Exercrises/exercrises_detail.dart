import 'package:flutter/material.dart';
import 'package:loadmore/loadmore.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/exercrises/exercrises_bloc.dart';
import 'package:medical/src/modal/exercrises/exercrise_input.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/widget/Exercrises/exercrises_detail_tabbar.dart';
import 'package:medical/src/widget/components/load_more.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';

import 'widget/exercrises_list_card.dart';

class ExercrisesDetailController extends StatefulWidget {
  ExercrisesDetailController({Key? key}) : super(key: key);
  @override
  ExercrisesDetailControllerState createState() =>
      ExercrisesDetailControllerState();
}

class ExercrisesDetailControllerState extends State<ExercrisesDetailController>
    with AutomaticKeepAliveClientMixin<ExercrisesDetailController> {
  @override
  bool get wantKeepAlive => true;

  late BuildContext currentContext;
  ScrollController scrollController = ScrollController();

  int page = 1;
  bool? hasMore = false;
  bool isLoading = false;
  int periodFilterType = 1;

  @override
  void initState() {
    periodFilterType =
        ExercrisesDetailTabbarController.of(context)!.periodFilterType;
    super.initState();
  }

  reloadData(int periodFilter) {
    scrollController.jumpTo(0);
    periodFilterType = periodFilter;
    _refresh();
  }

  Future<bool> _loadMore() async {
    if (isLoading || !hasMore!) {
      return true;
    } else {
      isLoading = true;
      BlocProvider.of<ExercrisesBloc>(currentContext).add(FetchInputExercrises(
        page: page,
        currentDateTime:
            (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
        periodFilterType: periodFilterType.toString(),
      ));
    }
    return true;
  }

  Future<bool> _refresh() async {
    page = 1;
    BlocProvider.of<ExercrisesBloc>(currentContext).add(FetchInputExercrises(
      page: 1,
      currentDateTime:
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      periodFilterType: periodFilterType.toString(),
    ));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider<ExercrisesBloc>(
        create: (context) => ExercrisesBloc(),
        child: BlocBuilder<ExercrisesBloc, ExercrisesState>(
            builder: (BuildContext context, ExercrisesState state) {
          currentContext = context;
          List<InputDataExercriseModel>? model;
          if (state is ExercrisesInitial) {
            BlocProvider.of<ExercrisesBloc>(context).add(FetchInputExercrises(
                currentDateTime:
                    (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
                periodFilterType: periodFilterType.toString(),
                page: 1));
          }
          if (state is ExercrisesError) {
            Message.showToastMessage(context, state.message);
          }
          if (state is ExercrisesLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (state is ExercrisesDataLoaded) {
            model = state.inputExercrisesModel;
            hasMore = state.hasMore;
            if (hasMore!) {
              page += 1;
            }
            isLoading = false;
          }

          return RefreshIndicator(
              onRefresh: _refresh,
              child: Scaffold(
                backgroundColor: R.color.backgroundColor,
                body: model == null
                    ? Center(child: CircularProgressIndicator())
                    : Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                          image: AssetImage(R.drawable.bg_detail),
                          fit: BoxFit.cover,
                        )),
                        child: LoadMore(
                            onLoadMore: _loadMore,
                            isFinish: !hasMore!,
                            whenEmptyLoad: false,
                            delegate: CustomLoadMoreDelegate(),
                            textBuilder: DefaultLoadMoreTextBuilder.english,
                            child: ListView.builder(
                              controller: scrollController,
                              physics: AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.only(bottom: 80, top: 10),
                              itemCount: model.length,
                              itemBuilder: (BuildContext context, int index) {
                                final item = model![index];
                                return Padding(
                                  padding: EdgeInsets.only(
                                      top: 16, left: 16, right: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(convertCustomDate(item.date!),
                                          style: TextStyle(
                                              color: R.color.textDark,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700)),
                                      SizedBox(height: 16),
                                      ListView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          padding: EdgeInsets.all(0),
                                          itemCount: item.exerciseInput.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            final itemInput =
                                                item.exerciseInput[index];
                                            return ExercrisesListCard(
                                                itemInput: itemInput);
                                          }),
                                    ],
                                  ),
                                );
                              },
                            ))),
              ));
        }));
  }
}
