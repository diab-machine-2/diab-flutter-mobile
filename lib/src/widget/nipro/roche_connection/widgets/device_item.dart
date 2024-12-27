import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigator_name.dart';
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
      onTap: () {
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
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Image.asset(
                    deviceInfo.image,
                    height: 72,
                    width: 72,
                  ),
                  SizedBox(width: 12),
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
