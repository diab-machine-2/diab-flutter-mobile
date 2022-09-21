import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widgets/button_widget.dart';

import '../blocs/voucherDetail_bloc.dart';

class VoucherDetailView extends StatelessWidget {
  const VoucherDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double paddingBottom = MediaQuery.of(context).padding.bottom + 10;
    return BlocProvider<VoucherDetailBloc>(
      create: (_) => VoucherDetailBloc()..add(EventGetVoucherDetail()),
      child: BlocListener<VoucherDetailBloc, VoucherDetailState>(
        listener: (context, state) {},
        child: Container(
          color: R.color.color0xffB1DDDB,
          child: Scaffold(
            bottomSheet: _btnShare(context),
            appBar: CustomAppBar(
              backgroundColor: R.color.transparent,
              title: Text(
                R.string.voucher_detail.tr(),
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
              padding: EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 55 + paddingBottom,
              ),
              color: R.color.color0xfff5f5f5,
              child: _sectionContent(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionContent(BuildContext context) {
    double paddingBottom = MediaQuery.of(context).padding.bottom + 10;
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(0),
      children: [
        Text(
          "Mời bạn và nhận thưởng",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 20),
        Text(
          "Khi chia sẻ app Diab thành công bạn sẽ nhận được Voucher khuyến mãi được áp dụng cho tất cả cửa hàng của Long Châu. Chia sẻ app DiaB giúp bạn bè cải thiện sức khoẻ tốt hơn.",
          style: TextStyle(
            height: 1.4,
            fontSize: 16,
            color: R.color.color0xff666666,
          ),
        ),
        SizedBox(height: 10),
        Text(
          "Phần này anh Việt nhờ team MKT update thêm content giúp em với .... Diab thành công bạn sẽ nhận được Voucher khuyến mãi được áp dụng cho tất cả cửa hàng của Long Châu.",
          style: TextStyle(
            height: 1.4,
            fontSize: 16,
            color: R.color.color0xff666666,
          ),
        ),
        SizedBox(
          height: 55 + paddingBottom,
        )
      ],
    );
  }

  Widget _btnShare(BuildContext context) {
    double paddingBottom = MediaQuery.of(context).padding.bottom + 10;
    return Container(
      padding: EdgeInsets.fromLTRB(15, 15, 15, paddingBottom),
      decoration: BoxDecoration(
        color: R.color.white,
        boxShadow: [
          BoxShadow(
            color: R.color.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 7,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ButtonWidget(
        title: R.string.share_now.tr(),
        onPressed: () {},
      ),
    );
  }
}
