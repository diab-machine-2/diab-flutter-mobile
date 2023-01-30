import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';

import '../../../data/models/voucherList_response.dart';
import '../blocs/voucherList_bloc.dart';
import '../widgets/index.dart';

class VoucherListView extends StatefulWidget {
  final String? voucherId;
  const VoucherListView({Key? key, this.voucherId}) : super(key: key);

  @override
  State<VoucherListView> createState() => _VoucherListViewState();
}

class _VoucherListViewState extends State<VoucherListView> {
  late BuildContext currentContext;

  Future<bool> _pullToRefresh() async {
    BlocProvider.of<VoucherListBloc>(currentContext)
        .add(EventGetVoucherList(isReload: true));
    return true;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VoucherListBloc>(
      create: (_) => VoucherListBloc()..add(EventGetVoucherList()),
      child: BlocListener<VoucherListBloc, VoucherListState>(
        listener: (context, state) {
          if (state.blocStatus == BlocStatus.loading) {
            BotToast.showLoading();
          } else {
            BotToast.closeAllLoading();
          }
          if (state.blocStatus == BlocStatus.getVoucherListSuccess &&
              widget.voucherId != null) {
            Navigator.pushNamed(
              context,
              NavigatorName.voucher_detail,
              arguments: {
                "voucherId": widget.voucherId,
                "updateVoucherList": () {
                  BlocProvider.of<VoucherListBloc>(currentContext)
                      .add(EventGetVoucherList(isReload: true));
                }
              },
            );
          }
        },
        child: RefreshIndicator(
          onRefresh: _pullToRefresh,
          child: Scaffold(
            appBar: CustomAppBar(
              backgroundColor: R.color.transparent,
              title: Text(
                R.string.voucher_list.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: R.color.textDark,
                ),
              ),
              leadingIcon: IconButton(
                splashColor: R.color.transparent,
                highlightColor: R.color.transparent,
                icon: Icon(Icons.arrow_back, color: R.color.textDark),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: Container(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(R.drawable.bg_splash),
                ),
              ),
              child: BlocBuilder<VoucherListBloc, VoucherListState>(
                  builder: (context, state) {
                currentContext = context;
                final List<VoucherModel>? voucherList = state.voucherList;
                if (voucherList == null) return SizedBox();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      R.string.voucher_have.tr().replaceFirst(
                          "[NUMBER_VOUCHER]", "${voucherList.length}"),
                    ),
                    SizedBox(height: 25),
                    Expanded(
                      child: ListView(
                          children: voucherList
                              .map((voucherData) => VoucherListItem(
                                    voucherData: voucherData,
                                  ))
                              .toList()),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
