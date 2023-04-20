import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/src/app_setting/health_setting.dart';
import 'package:medical/src/utils/app_storages.dart';
import 'package:medical/src/widgets/button_widget.dart';
import '../blocs/healthApp_bloc.dart';

class RequestHealthConnect extends StatelessWidget {
  final bool isSyncing;
  const RequestHealthConnect({Key? key, required this.isSyncing})
      : super(key: key);

  static showModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.white,
      builder: (context) => RequestHealthConnect(isSyncing: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    String appTitle = Platform.isIOS ? 'Apple Health' : 'Google Fit';
    return BlocProvider<HealthAppBloc>(
      create: (_) => HealthAppBloc()..add(SubmitSyncData(isSyncing)),
      child: BlocBuilder<HealthAppBloc, HealthAppState>(
        builder: (context, state) {
          if (isSyncing == true && state.blocStatus == BlocStatus.success)
            return SizedBox();
          if (isSyncing == true && state.blocStatus == BlocStatus.loading) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.yellow,
                      )),
                  SizedBox(width: 15),
                  Text(
                    "Đang đồng bộ Health App",
                    style: TextStyle(
                      color: AppColors.yellow,
                    ),
                  ),
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(
                top: 100, left: 20, right: 20, bottom: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          R.drawable.logo_diab,
                          width: 72,
                        ),
                        SizedBox(width: 15),
                        Image.asset(
                          R.drawable.logo_healthkit,
                          width: 72,
                        )
                      ],
                    ),
                    SizedBox(height: 30),
                    Text(
                      "Kết nối diaB với $appTitle",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "Chúng tôi sẽ tự động lấy dữ liệu từ $appTitle để giúp bạn theo dõi sức khỏe và hoạt động thể dục của mình.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          height: 1.4,
                          fontSize: 16,
                          color: R.color.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 105),
                Column(
                  children: [
                    SizedBox(height: 25),
                    ButtonWidget(
                      title: "Để sau",
                      textColor: R.color.textDark,
                      backgroundColor: R.color.grayBorder,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(height: 15),
                    ButtonWidget(
                      title: "Kết nỗi với $appTitle",
                      onPressed: () async {
                        bool? _hasPermission = await HealthSetting.instance
                            .requestConnectionPermission();
                        if (_hasPermission != null) {
                          AppStorages.setHealthAppPermission(_hasPermission);
                          Navigator.pop(context);
                          context
                              .read<HealthAppBloc>()
                              .add(SubmitSyncData(true));
                        }
                      },
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
