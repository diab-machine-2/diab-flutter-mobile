import 'package:auto_size_text/auto_size_text.dart';
import 'package:medical/res/R.dart';
import 'package:flutter/material.dart';
import 'package:medical/src/widget/profile/delete_account/presentation/widgets/widgets.dart';
import '../blocs/shareAppDetail_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/utils/navigator_name.dart';

class BannerShareApp extends StatefulWidget {
  const BannerShareApp({Key? key}) : super(key: key);

  @override
  State<BannerShareApp> createState() => _BannerShareAppState();
}

class _BannerShareAppState extends State<BannerShareApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ShareAppDetailBloc>(
      create: (_) => ShareAppDetailBloc()..add(CheckVoucherAvailable()),
      child: BlocBuilder<ShareAppDetailBloc, ShareAppDetailState>(
          builder: (context, state) {
        final bool? isVoucherAvailable = state.isVoucherAvailable;
        if (isVoucherAvailable == null) return SizedBox();
        return InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              NavigatorName.share_app_detail,
              arguments: {"isVoucherAvailable": isVoucherAvailable},
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: AspectRatio(
              aspectRatio: 686 / 300,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage(
                      R.drawable.banner_share_app,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 281,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            AutoSizeText(
                              isVoucherAvailable
                                  ? "Mời bạn bè và nhận thêm 10K tiền thưởng"
                                  : "Mời bạn bè",
                              maxLines: 2,
                              minFontSize: 15,
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF172823),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              isVoucherAvailable
                                  ? "Nhận ngay phiếu quà tặng mua thuốc khi giới thiệu DiaB App đến bạn bè và người thân thành công."
                                  : "Sử dụng DiaB để biết cách ăn uống, vận động, nghỉ ngơi đúng cách cho người đái tháo đường.",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF172823),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Container(
                              height: 28,
                              width: 72,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    R.color.greenGradientTop,
                                    R.color.greenGradientBottom
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(200),
                              ),
                              child: Text(
                                "Mời ngay",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: R.color.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(flex: 210),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
