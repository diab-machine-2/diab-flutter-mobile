import 'package:bot_toast/bot_toast.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../../../data/models/voucherList_response.dart';
import '../blocs/voucherDetail_bloc.dart';

class VoucherDetailView extends StatefulWidget {
  final String voucherId;
  final Function updateVoucherList;
  const VoucherDetailView(
      {Key? key, required this.voucherId, required this.updateVoucherList})
      : super(key: key);

  @override
  State<VoucherDetailView> createState() => _VoucherDetailViewState();
}

class _VoucherDetailViewState extends State<VoucherDetailView> {
  late BuildContext currentContext;
  @override
  Widget build(BuildContext context) {
    return BlocProvider<VoucherDetailBloc>(
      create: (_) =>
          VoucherDetailBloc()..add(EventGetVoucherDetail(widget.voucherId)),
      child: BlocListener<VoucherDetailBloc, VoucherDetailState>(
        listener: (context, state) {
          if (state.blocStatus == BlocStatus.loading) {
            BotToast.showLoading();
          } else {
            BotToast.closeAllLoading();
          }
          if (state.blocStatus == BlocStatus.useVoucherSuccess) {
            widget.updateVoucherList();
          }
        },
        child: Container(
          color: R.color.color0xffB1DDDB,
          child: BlocBuilder<VoucherDetailBloc, VoucherDetailState>(
              builder: (context, state) {
            currentContext = context;
            final VoucherModel? voucherDetail = state.voucherDetail;
            if (voucherDetail == null) return SizedBox();
            return Scaffold(
              bottomSheet: _btnShare(voucherDetail),
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
              body: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 25, horizontal: 15),
                  color: R.color.color0xfff5f5f5,
                  child: _sectionContent(context),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _sectionContent(BuildContext context) {
    double paddingBottom = MediaQuery.of(context).padding.bottom + 10;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Chúc mừng bạn đã nhận được voucher khuyến mãi.",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 20),
        Image.asset(R.drawable.voucher_reward),
        SizedBox(height: 20),
        Text(
          "DiaB tặng bạn mã giảm giá 50k cho tất cả hoá đơn khi mua sắm tại nhà thuốc Long Châu. Xem cách sử dụng dưới đây nhé!",
          style: TextStyle(
            height: 1.4,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 15),
        Text(
          "Hướng dẫn sử dụng:",
          style: TextStyle(
            height: 1.4,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 10),
        Text(
          "Trên màn hình có “Mã Voucher” cung cấp mã Voucher cho nhân viên tại quầy thu ngân để được giảm giá cho tất cả đơn hàng.",
          style: TextStyle(
            height: 1.4,
            fontSize: 16,
            color: R.color.color0xff666666,
          ),
        ),
        SizedBox(height: 15),
        Text(
          "Hệ thống áp dụng:",
          style: TextStyle(
            height: 1.4,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 10),
        Text(
          "Mã khuyến mãi được áp dụng cho tất cả các cửa hàng nhà thuốc Long Châu.",
          style: TextStyle(
            height: 1.4,
            fontSize: 16,
            color: R.color.color0xff666666,
          ),
        ),
        SizedBox(height: 15),
        Text(
          "Quy định về thẻ voucher:",
          style: TextStyle(
            height: 1.4,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 10),
        Text(
          " - Được cộng Gộp nhiều thẻ Voucher cho 1  đơn hàng.",
          style: TextStyle(
            height: 1.4,
            fontSize: 16,
            color: R.color.color0xff666666,
          ),
        ),
        SizedBox(height: 10),
        Text(
          " - Thẻ quà tặng không có giá trị quy đổi thành tiền.",
          style: TextStyle(
            height: 1.4,
            fontSize: 16,
            color: R.color.color0xff666666,
          ),
        ),
        SizedBox(
          height: 65 + paddingBottom,
        )
      ],
    );
  }

  _useVoucher(VoucherModel voucherDetail) {
    showBarModalBottomSheet(
      context: currentContext,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        color: R.color.white,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: voucherDetail.code))
                      .then((_) {
                    Message.showToastMessage(context, "Đã copy mã Voucher");
                    Navigator.pop(context);
                  });
                  if (voucherDetail.status == 0) {
                    currentContext
                        .read<VoucherDetailBloc>()
                        .add(SubmitUseVoucher());
                  }
                },
                child: DottedBorder(
                  dashPattern: [3, 3],
                  strokeWidth: 1,
                  radius: Radius.circular(18),
                  color: R.color.greenGradientBottom,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Mã Voucher: ",
                          style: TextStyle(
                            fontSize: 16,
                            color: R.color.greenGradientBottom,
                          ),
                        ),
                        Text(
                          voucherDetail.code,
                          style: TextStyle(
                            fontSize: 17,
                            color: R.color.greenGradientBottom,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(
                          Icons.copy,
                          size: 14,
                          color: R.color.captionColorGray,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _btnShare(VoucherModel voucherDetail) {
    double paddingBottom = MediaQuery.of(currentContext).padding.bottom + 10;
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
        radius: 8,
        title: R.string.use_voucher.tr(),
        onPressed: () {
          _useVoucher(voucherDetail);
        },
      ),
    );
  }
}
