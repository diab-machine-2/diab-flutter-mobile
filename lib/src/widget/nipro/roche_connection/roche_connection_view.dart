import 'package:flutter/material.dart';
import 'package:medical/src/widgets/app_bar_widget.dart';
import 'package:medical/src/widgets/normal_template.dart';

import 'widgets/device_item.dart';

class RocheConnectionView extends StatefulWidget {
  const RocheConnectionView({Key? key}) : super(key: key);

  @override
  State<RocheConnectionView> createState() => _RocheConnectionViewState();
}

class _RocheConnectionViewState extends State<RocheConnectionView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NormalTemplate(
        appBar: AppBarWidget(
          title: 'Danh sách thiết bị',
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DeviceItemWidget(),
            DeviceItemWidget(),
            DeviceItemWidget(),
          ],
        ),
      ),
    );
  }
}
