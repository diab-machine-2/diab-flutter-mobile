import 'dart:async';
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/user/schedule_glucose_time.dart';
import 'package:medical/src/repo/glucose/glucose_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/app_media_query.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/custom_checkbox_widget.dart';
import '../blocs/rocheConnection_cubit.dart';
import '../data/models/GlucoseMeasurementRecord.dart';
import '../data/models/glucose_config.dart';
import '../data/models/glucose_functions.dart';
import '../widgets/condition_widget.dart';
import '../widgets/result_sync_data_new.dart';

enum AppStatus {
  isScanning,
  isConnected,
  isConnecting,
  isSyncing,
  isSyncCompleted,
  isNoDeviceFound
}

class ScanDeviceView extends StatefulWidget {
  final RocheConnectionCubit cubit;
  const ScanDeviceView({Key? key, required this.cubit}) : super(key: key);

  @override
  State<ScanDeviceView> createState() => _ScanDeviceViewState();
}

class _ScanDeviceViewState extends State<ScanDeviceView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<ScanResult> resultList = [];
  BluetoothDevice? device;
  bool isLoading = false;
  bool selectAllData = false;
  AppStatus appStatus = AppStatus.isScanning;
  StreamController<int> secondsStreamController = StreamController<int>();
  Stream<int> get secondsStream => secondsStreamController.stream;
  StreamSubscription? characteristicListener;
  StreamSubscription? valueReceivedCharacteristicListener;

  List<GlucoseMeasurementRecord> glucoseMeasurementRecordList = [];
  List<GlucoseMeasurementRecord> dataSelected = [];
  List<Map<String, String>> selectedGlucose = [];
  List<Map<String, String>> glucosedList = [];
  bool deviceFound = false;
  int previousDataCount = 0;
  late GlucoseUnitsFlag glucoseUnits;
  String? modelName;
  String? modelNumber;

  @override
  void initState() {
    startScan();
    checkAppStatus();
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  void checkAppStatus() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      secondsStreamController.add(DateTime.now().second);
    });
  }

  @override
  void dispose() {
    if (device != null) {
      device!.disconnect();
    }
    characteristicListener?.cancel();
    valueReceivedCharacteristicListener?.cancel();
    _controller.dispose();
    super.dispose();
  }

  double _angle = 0.0;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      BotToast.showLoading();
    } else {
      BotToast.closeAllLoading();
    }

    return BlocProvider(
      create: (context) => widget.cubit,
      child: Scaffold(
        body: Builder(builder: (context) {
          return Padding(
            padding: EdgeInsets.symmetric(
              vertical: AppMediaQuery.deviceSafeAreaTop,
              horizontal: 15,
            ),
            child: StreamBuilder<int>(
              stream: secondsStream,
              initialData: 0,
              builder: (context, snapshot) {
                switch (appStatus) {
                  case AppStatus.isNoDeviceFound:
                    return _noDeviceFound();
                  case AppStatus.isScanning:
                  case AppStatus.isConnected:
                  case AppStatus.isSyncing:
                    return _scanDeviceWidget();
                  case AppStatus.isConnecting:
                    return _enterPinCode();
                  case AppStatus.isSyncCompleted:
                    return _selectData(context);
                  default:
                    return Container();
                }
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _btnClose(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: InkWell(
        onTap: () async {
          if (device != null) {
            await device!.disconnect();
          }
          await FlutterBluePlus.stopScan();
          Navigator.pop(context);
        },
        child: Container(
          height: 32,
          width: 32,
          margin: EdgeInsets.only(top: 15),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF141416),
          ),
          child: Center(
            child: Icon(
              Icons.close,
              size: 18,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> submitSyncDataNew(List<Map<String, String>> selectedGlucose) async {
    setState(() {
      isLoading = true;
    });
    bool result = await GlucoseClient()
        .postGlucoseInputs(selectedGlucose, modelName: modelName, modelNumber: modelNumber);
    setState(() {
      isLoading = false;
    });
    if (result) {
      Observable.instance.notifyObservers([], notifyName: Const.NAVIGATE_TO_PROFILE_TAB);
      Navigator.of(context).popUntil((route) => route.settings.name == NavigatorName.tabbar);
      Navigator.pushNamed(context, NavigatorName.detail_blood_sugar);
      Message.showToastMessage(context, "Đồng bộ chỉ số đường huyết thành công!");
      Future.delayed(Duration(seconds: 2)).then((value) => Observable.instance
          .notifyObservers([], notifyName: "glucose_change_data", map: {'index': 1}));
    } else {
      Message.showToastMessage(context, 'Không thể đồng bộ dữ liệu, xin vui lòng thử lại sau.');
    }
  }

  Widget _selectData(BuildContext context) {
    glucosedList.sort(((a, b) {
      return int.parse(b['date']!).compareTo(int.parse(a['date']!));
    }));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _btnClose(context),
            Text(
              "Kết nối thành công",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "Chọn chỉ số bạn muốn cập nhật lên ứng dụng",
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            SizedBox(height: 25),
          ],
        ),
        if (glucosedList.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                "Không tìm thấy dữ liệu mới",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        if (glucosedList.isNotEmpty)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: glucosedList.map((glucoseData) {
                  return ResultSyncDataNew(
                    glucoseData,
                    isSelected: isSelected(glucoseData),
                    onTap: () {
                      if (isSelected(glucoseData)) {
                        selectedGlucose.remove(glucoseData);
                      } else {
                        selectedGlucose.add(glucoseData);
                      }
                      setState(() {
                        selectAllData = selectedGlucose.length == glucosedList.length;
                      });
                    },
                    glucoseUnits: glucoseUnits,
                  );
                }).toList(),
              ),
            ),
          ),
        SizedBox(height: 15),
        CustomCheckboxWidget(
          isChecked: selectAllData,
          onTap: () {
            if (selectAllData) {
              setState(() {
                selectedGlucose = [];
                selectAllData = !selectAllData;
              });
            } else {
              setState(() {
                selectAllData = !selectAllData;
                selectedGlucose = [...glucosedList];
              });
            }
          },
          title: 'Chọn tất cả dữ liệu',
        ),
        Container(
          margin: EdgeInsets.only(top: 25),
          width: double.infinity,
          child: ButtonWidget(
            title: 'Xác nhận & Xem dữ liệu',
            onPressed: selectedGlucose.isEmpty
                ? null
                : () {
                    submitSyncDataNew(selectedGlucose);
                  },
          ),
        )
      ],
    );
  }

  Widget _scanDeviceWidget() {
    Widget returnWidget = Column(
      children: [
        Stack(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, Widget? child) {
                _angle = -_controller.value * 2.0 * 3.1415;
                return Transform.rotate(
                  angle: _angle,
                  child: Image.asset(
                    R.drawable.rada_effect,
                  ),
                );
              },
            ),
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              left: 0,
              child: Center(
                child: Image.asset(
                  R.drawable.icon_bluetooth,
                  width: 54,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 30),
        Text(
          'Đang kết nối thiết bị ...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 15),
          constraints: BoxConstraints(
            maxWidth: 250,
          ),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: 'Hãy đảm bảo thiết bị kết nối đang ở trạng thái ',
              style: R.style.normalTextStyle.copyWith(
                color: Color(0xFF777E90),
              ),
              children: [
                TextSpan(
                  text: '“Paring”',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (appStatus == AppStatus.isSyncing) {
      returnWidget = Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget? child) {
              _angle = -_controller.value * 2.0 * 3.1415;
              return Transform.rotate(
                angle: _angle,
                child: Image.asset(
                  R.drawable.img_loading,
                ),
              );
            },
          ),
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            left: 0,
            child: Container(
              padding: EdgeInsets.all(45),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AutoSizeText(
                    'Đang cập nhật dữ liệu',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 15),
                  AutoSizeText(
                    'Dữ liệu đang được lấy từ thiết bị.\nXin vui lòng chờ trong giây lát.',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: TextStyle(fontSize: 16, color: Color(0xFF777E91)),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _btnClose(context),
        returnWidget,
        SizedBox(height: 40),
      ],
    );
  }

  Widget _noDeviceFound() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _btnClose(context),
        Container(
          constraints: BoxConstraints(minHeight: AppMediaQuery.deviceHeigthAvailable - 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Image.asset(
                    R.drawable.img_error,
                    width: 170,
                  ),
                  Text(
                    'Không tìm thấy thiết bị',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: 281,
                    ),
                    child: Text(
                      'Hãy đảm bảo thiết bị kết nối đang ở trạng thái “Paring”',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF777E90),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  SizedBox(
                    height: 30,
                    child: Divider(),
                  ),
                  ConditionWidget(deviceInfo: widget.cubit.deviceInfo!),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          child: ButtonWidget(
            title: 'Kết nối lại',
            onPressed: () async {
              await FlutterBluePlus.stopScan();
              setState(() {
                deviceFound = false;
                appStatus = AppStatus.isScanning;
              });
              startScan();
            },
          ),
        )
      ],
    );
  }

  Widget _enterPinCode() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _btnClose(context),
        Column(
          children: [
            Text(
              "Nhập mã PIN",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 15),
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 15, color: R.color.textDark),
                children: [
                  TextSpan(
                    text: 'Nhập mã PIN ở',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  TextSpan(
                    text: ' 6 số ',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: 'ở ',
                  ),
                  TextSpan(
                    text: 'phía sau màn hình',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 55),
            Image.asset(
              widget.cubit.deviceInfo!.imagePin!,
            ),
          ],
        ),
        Container(
          width: double.infinity,
          child: ButtonWidget(
            title: 'Tôi đã hiểu',
            onPressed: () => connectDevice(device!),
          ),
        )
      ],
    );
  }

  void startScan() async {
    List<BluetoothDevice> connectedDevices = FlutterBluePlus.connectedDevices;
    // for in
    for (final device in connectedDevices) {
      await device.disconnect();
    }

    FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 25),
      withServices: [
        Guid.fromString(GlucoseProfileConfiguration.GLUCOSE_SERVICE_UUID),
        Guid.fromString(GlucoseProfileConfiguration.ROCHE_SERVICE_UUID),
      ],
    );
    final scanResultSub = FlutterBluePlus.scanResults.listen((scanResultList) {
      if (!deviceFound && appStatus == AppStatus.isScanning) {
        connectToAvailableDevice(scanResultList);
      }
    });
    final isScanningSub = FlutterBluePlus.isScanning.listen((event) {
      if (event == false && appStatus == AppStatus.isScanning) {
        appStatus = AppStatus.isNoDeviceFound;
      }
    });
    FlutterBluePlus.cancelWhenScanComplete(scanResultSub);
    FlutterBluePlus.cancelWhenScanComplete(isScanningSub);
  }

  void connectToAvailableDevice(List<ScanResult> scanResultList) async {
    for (var i = 0; i < scanResultList.length; i++) {
      print("device: " + scanResultList[i].device.platformName);
      final result = scanResultList[i];
      if (result.device.platformName.contains('meter')) {
        deviceFound = true;
        await result.device.connect();
        connectDevice(result.device);
        device = result.device;
        appStatus = AppStatus.isConnecting;
        await FlutterBluePlus.stopScan();
        // return;
      }
    }
  }

  bool isSelected(Map<String, String> glucose) {
    bool isSelected = false;
    selectedGlucose.forEach((element) {
      if (element['glucose'] == glucose['glucose'] && element['date'] == glucose['date']) {
        isSelected = true;
      }
    });
    return isSelected;
  }

  Future<void> connectDevice(BluetoothDevice deviceFounded) async {
    List<BluetoothService> services = await deviceFounded.discoverServices(
      subscribeToServicesChanged: false,
    );

    // Tìm Service 0x1808
    BluetoothService serviceGlucoseMeasurement = services.firstWhere((service) {
      return service.serviceUuid.str128 == GlucoseProfileConfiguration.GLUCOSE_SERVICE_UUID;
    });

    // Tim Characteristic 0x2A18
    BluetoothCharacteristic charGlucoseMeasurement = serviceGlucoseMeasurement.characteristics
        .firstWhere((characteristic) =>
            characteristic.characteristicUuid.str128 ==
            GlucoseProfileConfiguration.GLUCOSE_MEASUREMENT_CHARACTERISTIC_UUID);

    // Bật noti cho 0x2A18
    await charGlucoseMeasurement.setNotifyValue(true);
    appStatus = AppStatus.isConnected;

    BluetoothService rocheService = services.firstWhere((service) {
      return service.serviceUuid.str128 == GlucoseProfileConfiguration.ROCHE_SERVICE_UUID;
    });

    for (BluetoothCharacteristic rocheCharacteristic in rocheService.characteristics) {
      if (rocheCharacteristic.characteristicUuid.str128 ==
          GlucoseProfileConfiguration.MODEL_NUMBER_STRING_UUID) {
        List<int> modelNumberStringValue = await rocheCharacteristic.read();
        String modelNo = utf8.decode(modelNumberStringValue);
        if (GlucoseProfileConfiguration.mgPerDLModels.contains(modelNo)) {
          glucoseUnits = GlucoseUnitsFlag.mgPerDL;
        } else {
          glucoseUnits = GlucoseUnitsFlag.mmolPerL;
        }
        String modelName = '';
        GlucoseProfileConfiguration.rocheModels.forEach((name, values) {
          if (values.contains(modelNo)) {
            modelName = name;
            return;
          }
        });
        updateGlucoseUnit(glucoseUnits, modelNameParam: modelName, modelNoParam: modelNo);
      }
    }

    for (BluetoothCharacteristic characteristic in serviceGlucoseMeasurement.characteristics) {
      // Tim Characteristic 0x2A18
      if (characteristic.characteristicUuid.str128 ==
          GlucoseProfileConfiguration.GLUCOSE_MEASUREMENT_CHARACTERISTIC_UUID) {
        print('validating characteristic GLUCOSE_MEASUREMENT_CHARACTERISTIC_UUID');
        await characteristic.setNotifyValue(true);
        appStatus = AppStatus.isSyncing;
        previousDataCount = 0;
        glucoseMeasurementRecordList.clear();
        characteristicListener = characteristic.lastValueStream.listen((data) async {
          print('lastValueStream: $data');
          if (data.isEmpty) {
            return;
          }
          GlucoseMeasurementRecord glucoseMeasurementRecord =
              GlucoseFunctions().readDataFrom2A18(data);
          if (glucoseMeasurementRecord.isBloodGlucose) {
            glucoseMeasurementRecordList.add(glucoseMeasurementRecord);
          }
        });

        // valueReceivedCharacteristicListener = characteristic.onValueReceived.listen((event) {
        //   print('onValueReceived: $event');
        // });
      }

      // Tim Characteristic 0x2A52
      if (characteristic.characteristicUuid.str128 ==
          GlucoseProfileConfiguration.RECORD_ACCESS_CONTROL_POINT_CHARACTERISTIC_UUID) {
        print('validating characteristic RECORD_ACCESS_CONTROL_POINT_CHARACTERISTIC_UUID');
        await characteristic.setNotifyValue(true);
        List<int> requestData = [0x01, 0x01];
        await characteristic.write(requestData, withoutResponse: true);
        await Future.delayed(Duration(seconds: 20));
        startCheckingData();
      }
    }
  }

  Future<void> updateGlucoseUnit(GlucoseUnitsFlag glucoseUnitsFlag,
      {String? modelNameParam, String? modelNoParam}) async {
    bool isMilligramPerDeciliter = AppSettings.userInfo!.glucoseUnit == 1;
    if (glucoseUnitsFlag == GlucoseUnitsFlag.mgPerDL && !isMilligramPerDeciliter) {
      ScheduleGlucoseTimeModel timeModel = await UserClient().fetchScheduleGlucoseSetting();
      await UserClient().updateScheduleGlucoseSetting(ScheduleGlucoseTimeModel(
        beforeEat: timeModel.beforeEat,
        afterEat: timeModel.afterEat,
        beforeSleeping: timeModel.beforeSleeping,
        glucoseUnit: 1,
      ));
      await UserClient().fetchUser();
      Observable.instance.notifyObservers([], notifyName: "refresh_home");
    } else if (glucoseUnitsFlag == GlucoseUnitsFlag.mmolPerL && isMilligramPerDeciliter) {
      ScheduleGlucoseTimeModel timeModel = await UserClient().fetchScheduleGlucoseSetting();
      await UserClient().updateScheduleGlucoseSetting(ScheduleGlucoseTimeModel(
        beforeEat: timeModel.beforeEat,
        afterEat: timeModel.afterEat,
        beforeSleeping: timeModel.beforeSleeping,
        glucoseUnit: 2,
      ));
      await UserClient().fetchUser();
      Observable.instance.notifyObservers([], notifyName: "refresh_home");
    }
    modelName = modelNameParam;
    modelNumber = modelNoParam;
  }

  void startCheckingData() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      // Kiểm tra số lượng dữ liệu sau mỗi khoảng thời gian
      if (glucoseMeasurementRecordList.length > previousDataCount) {
        // Nếu dữ liệu đã tăng, cập nhật previousDataCount và tiếp tục đợi
        previousDataCount = glucoseMeasurementRecordList.length;
      } else {
        // Nếu dữ liệu không tăng, ngưng lại và gọi hàm fetchGlucoseInputNotExist
        timer.cancel(); // Ngưng timer
        fetchGlucoseInputNotExist();
      }
    });
  }

  Future<void> fetchGlucoseInputNotExist() async {
    List<Map<String, String>> glucoseDataList = [];
    List<Map<String, String>> glucoseDataRequest = [];

    Set<DateTime> uniqueValues = Set<DateTime>();

    if (glucoseMeasurementRecordList.isNotEmpty) {
      glucoseMeasurementRecordList.forEach((element) {
        final glucose = roundAsFixed(
            roundDouble(element.convertGlucoseConcentrationValueToMilligramsPerDeciliter()));

        if (!uniqueValues.contains(element.calendar)) {
          glucoseDataRequest.add({
            'glucose': glucose.toString(),
            'date': DateUtil.getDayInMillis(element.calendar!).toString(),
          });
          uniqueValues.add(element.calendar!);
        }
      });

      final result = await GlucoseClient().fetchGlucoseInputNotExist(glucoseDataRequest);

      result.forEach((element) {
        glucoseDataList.add(
            {'glucose': element['glucose'].toString(), 'date': element['createDate'].toString()});
      });

      selectAllData = true;
      glucosedList = glucoseDataList;
      appStatus = AppStatus.isSyncCompleted;
      selectedGlucose = [...glucoseDataList];
    } else {
      appStatus = AppStatus.isSyncCompleted;
    }
  }
}
