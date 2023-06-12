import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/utils/app_media_query.dart';
import 'package:medical/src/widgets/app_bar_widget.dart';
import 'package:medical/src/widgets/normal_template.dart';
import 'blocs/rocheConnection_cubit.dart';
import 'blocs/rocheConnection_state.dart';
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

  @override
  Widget build(BuildContext context) {
    AppMediaQuery().init(context);
    return BlocProvider(
      create: (context) => _cubit,
      child: Scaffold(
        body: NormalTemplate(
          appBar: AppBarWidget(
            title: 'Danh sách thiết bị',
          ),
          child: BlocConsumer<RocheConnectionCubit, RocheConnectionState>(
              listener: (context, state) async {},
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DeviceItemWidget(bloc: _cubit),
                    DeviceItemWidget(bloc: _cubit),
                    DeviceItemWidget(bloc: _cubit),
                  ],
                );
              }),
        ),
      ),
    );
  }
}
