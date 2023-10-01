import 'package:bot_toast/bot_toast.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../../../data/models/voucherList_response.dart';
import '../blocs/voucherDetail_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

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
  void initState() {
    super.initState();
  }

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
            bool isLoading =
                voucherDetail == null && state.blocStatus == BlocStatus.loading;
            if (isLoading) return SizedBox();
            return Scaffold(
              bottomSheet:
                  voucherDetail != null ? _btnUseVoucher(voucherDetail) : null,
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
              body: voucherDetail != null
                  ? SingleChildScrollView(
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 25, horizontal: 15),
                        color: R.color.color0xfff5f5f5,
                        child: _sectionContent(context),
                      ),
                    )
                  : Column(
                      children: [
                        SizedBox(height: 25),
                        Image.asset(R.drawable.img_blood_sugar_start_survey),
                        SizedBox(height: 25),
                        Text(
                          "Không tìm thấy dữ liệu",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: R.color.accentColor,
                          ),
                        )
                      ],
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
          "Chúc mừng bạn đã nhận được mã giảm giá.",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 20),
        Image.asset(R.drawable.banner_promotion15_details),
        SizedBox(height: 20),
        RichText(
          text: TextSpan(
            style: TextStyle(
              color: R.color.textDark,
              fontSize: 16,
              wordSpacing: 3,
              height: 1.4,
            ),
            children: [
              TextSpan(
                text: 'DiaB tặng bạn',
              ),
              TextSpan(
                text: " mã giảm giá 15% ",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              TextSpan(
                text: 'lên đến 2.000.000 cho tất cả hoá đơn khi mua sắm tại ',
              ),
              TextSpan(
                text: 'cửa hàng của DiaB ',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
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
          "Bước 1: Lấy mã giảm giá",
          style: TextStyle(
            height: 1.4,
            fontSize: 16,
            color: R.color.color0xff666666,
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 15),
          width: 280,
          padding: EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: R.color.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DottedBorder(
            dashPattern: [3, 3],
            strokeWidth: 1,
            radius: Radius.circular(6),
            borderType: BorderType.RRect,
            color: R.color.greenGradientBottom,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Mã giảm giá: ",
                    style: TextStyle(
                      fontSize: 16,
                      color: R.color.greenGradientBottom,
                    ),
                  ),
                  Text(
                    "DIAB15",
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
        Text(
          "Bước 2: Truy cập vào gian hàng của DiaB",
          style: TextStyle(
            height: 1.4,
            fontSize: 16,
            color: R.color.color0xff666666,
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
            width: 280,
            padding: EdgeInsets.all(7),
            margin: EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: R.color.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Image.asset(R.drawable.promotion15_shopee),
              iconSize: 50,
              onPressed: () {
                _launchSHOPEE();
              },
            )),
        Container(
            width: 280,
            padding: EdgeInsets.all(7),
            margin: EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: R.color.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Image.asset(R.drawable.promotion15_lazada),
              iconSize: 50,
              onPressed: () {
                _launchLAZADA();
              },
            )),
        Container(
            width: 280,
            padding: EdgeInsets.all(7),
            margin: EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: R.color.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Image.asset(R.drawable.promotion15_website),
              iconSize: 50,
              onPressed: () {
                _launchWEBSITE();
              },
            )),
        SizedBox(height: 15),
        Text(
          "Lưu ý:  Khi sử dụng mã giảm giá:",
          style: TextStyle(
            height: 1.4,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 10),
        Text(
          " - Liên hệ ngay với DiaB nếu bạn gặp khó khăn khi sử dụng mã giảm giá.",
          style: TextStyle(
            height: 1.4,
            fontSize: 16,
            color: R.color.color0xff666666,
          ),
        ),
        SizedBox(height: 10),
        Container(
          width: 280,
          padding: EdgeInsets.all(7),
          margin: EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: R.color.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ButtonWidget(
            radius: 8,
            title: 'LIÊN HỆ NGAY ',
            onPressed: () {
              _launchZALO();
            },
          ),
        ),
        SizedBox(height: 10),
        Text(
          " - 1 Mã giảm giá chỉ sử dụng cho 1 đơn hàng.",
          style: TextStyle(
            height: 1.4,
            fontSize: 16,
            color: R.color.color0xff666666,
          ),
        ),
        SizedBox(height: 10),
        Text(
          " - Mã giảm giá không áp dụng cho dòng sản phẩm CGM - Theo dõi đường huyết liên tục FreeStyle Libre.",
          style: TextStyle(
            height: 1.4,
            fontSize: 16,
            color: R.color.color0xff666666,
          ),
        ),
        SizedBox(height: 10),
        Text(
          " - Mã giảm giá không có giá trị quy đổi thành tiền mặt.",
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

  void _launchSHOPEE() async {
    const url = 'https://shopee.vn/diab_official123#product_list';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _launchLAZADA() async {
    const url =
        'https://pages.lazada.vn/wow/gcp/vn/store_lp/voucher?sellerId=v8r0l559q7w&voucherId=vrroy74m2nkzoe&scene=store&domain=SHOP';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _launchWEBSITE() async {
    const url = 'https://diab.com.vn/cua-hang-diab?p=tat-ca';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _launchZALO() async {
    const url = 'https://zalo.me/4592543430802584018';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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
                    Message.showToastMessage(context, "Đã copy mã ưu đãi");
                    Navigator.pop(context);
                  });
                },
                child: DottedBorder(
                  dashPattern: [3, 3],
                  strokeWidth: 1,
                  radius: Radius.circular(6),
                  borderType: BorderType.RRect,
                  color: R.color.greenGradientBottom,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Mã ưu đãi: ",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: R.color.greenGradientBottom,
                          ),
                        ),
                        Text(
                          voucherDetail.code.toUpperCase(),
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

  Widget _btnUseVoucher(VoucherModel voucherDetail) {
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
          if (voucherDetail.status == 0) {
            currentContext.read<VoucherDetailBloc>().add(SubmitUseVoucher());
          }
          _useVoucher(voucherDetail);
        },
      ),
    );
  }
}
