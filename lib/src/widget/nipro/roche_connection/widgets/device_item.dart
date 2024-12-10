import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import '../blocs/rocheConnection_cubit.dart';
import '../data/models/device_info_model.dart';
import '../views/device_detail_view.dart';

class DeviceItemWidget extends StatelessWidget {
  final bool isNiproDevice;
  final RocheConnectionCubit bloc;
  final DeviceInfoModel deviceInfo;
  const DeviceItemWidget(
    this.deviceInfo, {
    Key? key,
    required this.bloc,
    this.isNiproDevice = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await TrackingManager.trackEvent(
          'glucose_select_device',
          'kpi_glucose_device',
          params: {
            'object_title': deviceInfo.name,
          },
        );
        if (isNiproDevice) {
          Navigator.pushNamed(context, NavigatorName.connection_instructions);
        } else {
          bloc.setDeviceInfo(deviceInfo);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => DeviceDetailView(cubit: bloc),
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(13),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    height: 96,
                    width: 96,
                    padding: EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(0xffF2F2F2),
                      ),
                    ),
                    child: Image.asset(
                      deviceInfo.image,
                      height: 100,
                      width: 100,
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      deviceInfo.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(width: 15),
            SvgPicture.asset(
              R.icons.ic_chevron_right,
              width: 22,
              color: Color(0xffB1B5C3),
              fit: BoxFit.scaleDown,
            ),
          ],
        ),
      ),
    );
  }
}
