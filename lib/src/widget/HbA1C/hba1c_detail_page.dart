import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/HbA1C/HbA1C_bloc.dart';
import 'package:medical/src/modal/HbA1C/HbA1C_Input.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';

class HbA1cDetailPage extends StatefulWidget {
  final int? initPeriodFilterType;

  const HbA1cDetailPage({Key? key, this.initPeriodFilterType})
      : super(key: key);

  @override
  State<HbA1cDetailPage> createState() => _HbA1cDetailPageState();
}

class _HbA1cDetailPageState extends State<HbA1cDetailPage> {
  String formatDateOrToday(int timeStamp) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime itemDate = DateTime(date.year, date.month, date.day);

    if (itemDate == today) {
      return 'Hôm nay';
    } else if (itemDate == today.subtract(Duration(days: 1))) {
      return 'Hôm qua';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  HbA1CBloc _hbA1CBloc = HbA1CBloc();
  int _periodFilterType = 3; // API period filter type (3 = 24 months)
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  ScrollController _scrollController = ScrollController();
  List<InputHbA1CModel> _allItems = [];

  @override
  void initState() {
    super.initState();
    _periodFilterType = widget.initPeriodFilterType == 0
        ? 3
        : (widget.initPeriodFilterType ?? 3);
    _scrollController.addListener(_onScroll);
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _hbA1CBloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  void _loadData() {
    _currentPage = 1;
    _hasMore = true;
    _allItems = [];
    _hbA1CBloc.add(FetchInputHbA1C(
      currentDateTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      periodFilterType: _periodFilterType,
      page: _currentPage,
      takeAll: false,
    ));
  }

  void _loadMore() {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    _currentPage++;
    _hbA1CBloc.add(FetchInputHbA1C(
      currentDateTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      periodFilterType: _periodFilterType,
      page: _currentPage,
      takeAll: false,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF9F7),
      appBar: _buildAppBar(),
      body: BlocProvider<HbA1CBloc>.value(
        value: _hbA1CBloc,
        child: BlocConsumer<HbA1CBloc, HbA1CState>(
          listener: (context, state) {
            if (state is HbA1CError) {
              Message.showToastMessage(context, state.message);
            } else if (state is HbA1CDetailLoaded) {
              // Update list in listener to avoid concurrent modification during build
              if (_currentPage == 1) {
                // First page - replace all items with a new list copy
                _allItems = List<InputHbA1CModel>.from(state.inputHbA1CModel);
              } else {
                // Subsequent pages - create a new list with existing items + new items
                final newItems =
                    List<InputHbA1CModel>.from(state.inputHbA1CModel);
                _allItems = List<InputHbA1CModel>.from(_allItems)
                  ..addAll(newItems);
              }
              _hasMore = state.hasMore ?? false;
              _isLoadingMore = false;
            }
          },
          builder: (context, state) {
            // Update loading state and model based on state
            bool isLoading = state is HbA1CLoading || state is HbA1CInitial;
            List<InputHbA1CModel>? model;

            if (state is HbA1CDetailLoaded) {
              // Use the already updated _allItems from listener
              model = _allItems;
              isLoading = false;
            }

            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFEAF9F7),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: _buildContent(isLoading, model),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: R.color.greenGradientBottom,
      titleSpacing: 8,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(Icons.arrow_back, color: R.color.white),
      ),
      centerTitle: false,
      title: Text(
        R.string.detail.tr(),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: R.color.white,
          fontFamily: R.font.sfpro,
        ),
      ),
    );
  }

  Widget _buildContent(bool isLoading, List<InputHbA1CModel>? model) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (model == null || model.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadData();
      },
      child: ListView.builder(
        controller: _scrollController,
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: 100, top: 10, left: 16, right: 16),
        itemCount: model.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == model.length) {
            // Loading indicator at the end
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
          return _buildDetailItem(model[index], index);
        },
      ),
    );
  }

  Widget _buildDetailItem(InputHbA1CModel item, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          NavigatorName.add_hba1c,
          arguments: {
            'type': 'update',
            'id': item.id,
          },
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: R.color.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Date and Status Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatDateOrToday(item.date!),
                    style: TextStyle(
                      fontFamily: R.font.sfpro,
                      color: R.color.textDark,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.32,
                      letterSpacing: 0.2,
                    ),
                  ),
                  Container(
                    height: 26,
                    // padding: EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: R.color.transparent,
                      border: Border.all(
                        color: R.color.transparent,
                        width: 0,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(13),
                        topRight: Radius.circular(13),
                        bottomLeft: Radius.circular(13),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        item.type!,
                        style: TextStyle(
                          color: toColor(item.backgroundColor),
                          fontFamily: R.font.sfpro,
                          fontSize: 18,
                          height: 1.32,
                          letterSpacing: 0.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              // HbA1c Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    R.string.hba1c.tr(),
                    style: TextStyle(
                      fontFamily: R.font.sfpro,
                      color: R.color.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                      letterSpacing: 0.4,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        item.hbA1C.toString().split('.').join('.'),
                        style: TextStyle(
                          fontFamily: R.font.sfpro,
                          // color: toColor(item.percentColor),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1.32,
                          letterSpacing: 0.2,
                        ),
                      ),
                      Text(
                        ' %',
                        style: TextStyle(
                          // color: toColor(item.percentColor),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8),
              // Blood Sugar Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    R.string.duong_huyet.tr(),
                    style: TextStyle(
                      fontFamily: R.font.sfpro,
                      color: R.color.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.46,
                      letterSpacing: 0.4,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        item.glucose!.round().toString(),
                        style: TextStyle(
                          fontFamily: R.font.sfpro,
                          color: R.color.black,
                          fontSize: 15,
                          height: 1.46,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 2),
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          '${item.unit.toString()}',
                          style: TextStyle(
                            fontFamily: R.font.sfpro,
                            color: R.color.black,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SizedBox.expand(),
    );
  }
}
