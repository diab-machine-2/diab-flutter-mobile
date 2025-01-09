import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/firebase_remote_config.dart';
import 'package:medical/src/modal/glucose/glucose_faq.dart';
import 'package:medical/src/utils/app_media_query.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widgets/common_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'blocs/rocheConnection_cubit.dart';
import 'blocs/rocheConnection_state.dart';
import 'data/models/device_info_model.dart';
import 'widgets/device_item.dart';

class RocheConnectionView extends StatefulWidget {
  const RocheConnectionView({Key? key}) : super(key: key);

  @override
  State<RocheConnectionView> createState() => _RocheConnectionViewState();
}

class _RocheConnectionViewState extends State<RocheConnectionView> {
  late RocheConnectionCubit _cubit;

  @override
  void initState() {
    _cubit = RocheConnectionCubit();
    super.initState();
  }

  void _doManualInput() {
    Navigator.of(context)
        .pushReplacementNamed(NavigatorName.add_blood_sugar_new, arguments: {'type': 'input'});
  }

  void _navigateFAQ(GlucoseFaq faq) async {
    if (faq.url.isNotEmpty) {
      if (await canLaunchUrl(Uri.parse(faq.url))) {
        await launchUrl(Uri.parse(faq.url));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AppMediaQuery().init(context);
    return BlocProvider(
      create: (context) => _cubit,
      child: Scaffold(
        body: CommonPage(
          title: 'Các loại máy hỗ trợ kết nối',
          background: R.drawable.bg_glucose,
          child: BlocConsumer<RocheConnectionCubit, RocheConnectionState>(
            listener: (context, state) async {},
            builder: (context, state) {
              return SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Column(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: examples
                          .map((deviceInfo) => Container(
                            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: R.color.white,
                            ),
                            child: DeviceItemWidget(
                                  deviceInfo,
                                  bloc: _cubit,
                                  isNiproDevice: deviceInfo.tutorials.isEmpty,
                                ),
                          ))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildConnectManually(),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildFaq(),
                    ),
                    const SafeArea(
                      top: false,
                      child: SizedBox(height: 20),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildConnectManually() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 235,
          height: 20,
          alignment: Alignment.center,
          child: Row(
            children: [
              Expanded(child: Container(height: 1, color: R.color.greenGradientBottom)),
              Text(
                '   ${R.string.or.tr()}   ',
                style: TextStyle(
                  fontSize: 14,
                  color: R.color.greenGradientBottom,
                ),
              ),
              Expanded(child: Container(height: 1, color: R.color.greenGradientBottom)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        InkWell(
          onTap: _doManualInput,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: R.color.white,
              borderRadius: BorderRadius.circular(16),
            ),
            height: 64,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(R.drawable.im_glucose_input_manual, width: 40, height: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Nhập thủ công',
                    style: TextStyle(
                      fontSize: 15,
                      color: R.color.dark,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.chevron_right,
                  color: R.color.primaryGreyColor,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFaq() {
    final faqs = FirebaseRemoteSetting.instance.glucoseFaqs;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: R.color.grayBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            R.string.faq.tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: R.color.dark,
            ),
          ),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            color: R.color.color0xffE5E5E5,
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => _buildFaqItem(faqs[index]),
            separatorBuilder: (context, index) => const Divider(height: 32),
            itemCount: faqs.length,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFaqItem(GlucoseFaq faq) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          faq.title,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: R.color.textDark,
            fontSize: 15,
            height: 24 / 15,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => _navigateFAQ(faq),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  faq.linkTitle,
                  style: TextStyle(
                    color: R.color.mainColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    height: 20 / 14,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward, size: 20, color: R.color.mainColor)
            ],
          ),
        ),
      ],
    );
  }
}
