import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';
import 'package:flutter/material.dart';
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
                      R.drawable.banner_promotion15,
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
                            // AutoSizeText(
                            //   isVoucherAvailable
                            //       ? R.string.event_share_app_title.tr()
                            //       : R.string.diab_refferal.tr(),
                            //   maxLines: 2,
                            //   minFontSize: 15,
                            //   style: TextStyle(
                            //     fontSize: 18,
                            //     color: Color(0xFF172823),
                            //     fontWeight: FontWeight.w700,
                            //   ),
                            // ),
                            // Text(
                            //   isVoucherAvailable
                            //       ? R.string.event_share_app_content.tr()
                            //       : R.string.refferal_content.tr(),
                            //   style: TextStyle(
                            //     fontSize: 12,
                            //     color: Color(0xFF172823),
                            //     fontWeight: FontWeight.w500,
                            //   ),
                            // ),
                            // SizedBox(height: 30),
                            Spacer(),
                            Container(
                              height: 28,
                              width: 82,
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
                                R.string.invite_now.tr(),
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
