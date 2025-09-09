import 'dart:async';
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/bloc/nipro/model/glucose_data.dart';
import 'package:medical/src/modal/user/schedule_glucose_time.dart';
import 'package:medical/src/repo/glucose/glucose_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/app_media_query.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/custom_checkbox_widget.dart';
import '../blocs/rocheConnection_cubit.dart';
import '../data/models/GlucoseMeasurementRecord.dart';
import '../data/models/glucose_config.dart';
import '../data/models/glucose_functions.dart';
import '../widgets/condition_widget.dart';
import '../widgets/result_sync_data_new.dart';
import '../utils/glucose_sync_cache.dart';

enum AppStatus {
  isScanning,
  isConnected,
  isConnecting,
  isSyncing,
  isSyncCompleted,
  isNoDeviceFound,
  isManualForget, // Case 2.1: Xóa history bluetooth trên điện thoại
  isDeviceUnpair, // Case 3.1: Xóa pair trên máy đường huyết
  isDeviceAlreadyPaired // Device đã pair - show solution screen
}

class ScanDeviceView extends StatefulWidget {
  final RocheConnectionCubit cubit;
  const ScanDeviceView({Key? key, required this.cubit}) : super(key: key);

  @override
  State<ScanDeviceView> createState() => _ScanDeviceViewState();
}

class _ScanDeviceViewState extends State<ScanDeviceView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<ScanResult> resultList = [];
  BluetoothDevice? device;
  bool isLoading = false;
  bool selectAllData = false;
  AppStatus appStatus = AppStatus.isScanning;
  StreamController<int> secondsStreamController = StreamController<int>();
  Stream<int> get secondsStream => secondsStreamController.stream;
  StreamSubscription? characteristicListener;

  List<GlucoseMeasurementRecord> glucoseMeasurementRecordList = [];
  List<GlucoseMeasurementRecord> dataSelected = [];
  List<Map<String, String>> selectedGlucose = [];
  List<Map<String, String>> glucosedList = [];
  bool deviceFound = false;
  int previousDataCount = 0;
  
  // Cache variables for performance optimization
  DateTime? lastSyncTime;
  Map<String, dynamic>? lastSyncDevice;
  bool shouldPerformFullSync = true;
  bool isConnectionInProgress = false; // Track if connection is in progress
  late GlucoseUnitsFlag glucoseUnits;
  String? modelName;
  String? modelNumber;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _initializeCache();
    _startScan();
    _checkAppStatus();
  }
  
  /// Initialize cache and check sync history
  Future<void> _initializeCache() async {
    try {
      // Load cache info
      lastSyncTime = await GlucoseSyncCache.getLastSyncTime();
      lastSyncDevice = await GlucoseSyncCache.getLastSyncDevice();
      
      // Print cache info for debugging
      await GlucoseSyncCache.printCacheInfo();
      
      print('🚀 Cache initialized successfully');
    } catch (e) {
      print('❌ Error initializing cache: $e');
    }
  }
  
  /// Determine sync strategy based on device and last sync info
  Future<void> _determineSyncStrategy(BluetoothDevice currentDevice) async {
    try {
      final currentDeviceId = currentDevice.remoteId.str;
      shouldPerformFullSync = await GlucoseSyncCache.shouldFullSync(currentDeviceId);
      
      if (shouldPerformFullSync) {
        print('📋 FULL SYNC: Will request all data from device');
      } else {
        final incrementalStartTime = await GlucoseSyncCache.getIncrementalSyncStartTime();
        print('⚡ INCREMENTAL SYNC: Will request data newer than ${incrementalStartTime?.toIso8601String()}');
      }
    } catch (e) {
      print('❌ Error determining sync strategy: $e');
      // Default to full sync on error
      shouldPerformFullSync = true;
    }
  }
  
  /// Save sync success information to cache
  Future<void> _saveSyncSuccessInfo() async {
    try {
      if (device != null) {
        // Save current time as last sync time
        final now = DateTime.now();
        await GlucoseSyncCache.saveLastSyncTime(now);
        
        // Save device info
        await GlucoseSyncCache.saveLastSyncDevice(
          deviceId: device!.remoteId.str,
          deviceName: device!.platformName,
          modelName: modelName,
          modelNumber: modelNumber,
        );
        
        print('✅ Sync success info saved to cache');
        print('📅 Sync time: ${now.toIso8601String()}');
        print('📱 Device: ${device!.platformName} (${device!.remoteId.str})');
      }
    } catch (e) {
      print('❌ Error saving sync success info: $e');
    }
  }
  
  /// Clear sync cache (for debugging or reset purposes)
  Future<void> _clearSyncCache() async {
    try {
      await GlucoseSyncCache.clearCache();
      // Reset local variables
      lastSyncTime = null;
      lastSyncDevice = null;
      shouldPerformFullSync = true;
      print('🗑️ Sync cache cleared successfully');
    } catch (e) {
      print('❌ Error clearing sync cache: $e');
    }
  }
  
  /// Debug method to test cache functionality
  Future<void> _debugCacheInfo() async {
    await GlucoseSyncCache.printCacheInfo();
  }

  /// Build RACP (Record Access Control Point) request command
  /// Returns time-filtered request if incremental sync, otherwise requests all records
  Future<List<int>> _buildRACPRequest() async {
    if (!shouldPerformFullSync && lastSyncTime != null) {
      // Incremental sync: Request records newer than lastSyncTime
      // Convert DateTime to seconds since epoch (UNIX timestamp)
      final timeOffsetSeconds = lastSyncTime!.millisecondsSinceEpoch ~/ 1000;
      
      print('⚡ INCREMENTAL RACP REQUEST:');
      print('   📅 Request data after: ${lastSyncTime!.toIso8601String()}');
      print('   🕐 Time offset (seconds): $timeOffsetSeconds');
      
      // RACP Command Format for time-based filtering:
      // [OpCode, Operator, FilterType, TimeFilter_Low, TimeFilter_High]
      // 0x01 = Report stored records
      // 0x06 = Greater than or equal to
      // 0x01 = Time offset filter type
      final List<int> racpCommand = [
        0x01, // OpCode: Report stored records
        0x06, // Operator: Greater than or equal to  
        0x01, // Filter Type: Time offset
        timeOffsetSeconds & 0xFF,        // Time filter low byte
        (timeOffsetSeconds >> 8) & 0xFF, // Time filter high byte
      ];
      
      return racpCommand;
    } else {
      // Full sync: Request all records
      print('📋 FULL RACP REQUEST: Request all stored records');
      return [0x01, 0x01]; // OpCode: Report all stored records
    }
  }

  Timer? _statusTimer;
  
  void _safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }
  
  void _checkAppStatus() {
    _statusTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!secondsStreamController.isClosed) {
        secondsStreamController.add(DateTime.now().second);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    if (device != null) {
      device!.disconnect();
    }
    characteristicListener?.cancel();
    if (!secondsStreamController.isClosed) {
      secondsStreamController.close();
    }
    _controller.dispose();
    super.dispose();
  }

  double _angle = 0.0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => widget.cubit,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
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
                case AppStatus.isManualForget:
                  return _manualForgetDeviceWidget(); // Case 2.1
                case AppStatus.isDeviceUnpair:
                  return _deviceUnpairWidget(); // Case 3.1
                case AppStatus.isDeviceAlreadyPaired:
                  return _deviceAlreadyPairedWidget(); // Device đã pair
                case AppStatus.isSyncCompleted:
                    return _selectData(context);
                  default:
                    return Container();
                }
              },
            ),
          ),
        ),
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

  Future<void> submitSyncDataNew(
      List<Map<String, String>> selectedGlucose) async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    bool result = await GlucoseClient().postGlucoseInputs(selectedGlucose,
        modelName: modelName, modelNumber: modelNumber);
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
    if (result) {
      Message.showToastMessage(
          context, "Đồng bộ chỉ số đường huyết thành công!");
      
      // Save successful sync info to cache ONLY after API success
      print('✅ API postGlucoseInputs() successful - saving sync cache');
      await _saveSyncSuccessInfo();
      
      Set<String> uniqueDays = selectedGlucose.map((e) => e['date']!).toSet();
      await TrackingManager.trackEvent(
        'glucose_sync',
        'kpi_glucose_sync',
        params: {
          'device_day': uniqueDays.length,
          'device_record': selectedGlucose.length,
          'status': 'success',
        },
      );
      await TrackingManager.trackEvent(
        'glucose_add',
        'kpi_glucose_add',
        params: {"index_time": 'Kết nối máy', 'method': 'device'},
      );

      Future.delayed(Duration(seconds: 2)).then((value) => Observable.instance
          .notifyObservers([],
              notifyName: "glucose_change_data", map: {'index': 1}));
    } else {
      // API postGlucoseInputs() failed - do NOT save cache
      print('❌ API postGlucoseInputs() failed - cache NOT saved');
      
      await TrackingManager.trackEvent(
        'glucose_sync',
        'kpi_glucose_sync',
        params: {
          'device_record': selectedGlucose.length,
          'status': 'fail',
          'error_message': 'Không thể đồng bộ dữ liệu.',
        },
      );
      Message.showToastMessage(
          context, 'Không thể đồng bộ dữ liệu, xin vui lòng thử lại sau.');
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
                      _safeSetState(() {
                        selectAllData =
                            selectedGlucose.length == glucosedList.length;
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
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Image.asset(
                  R.drawable.img_error,
                  width: 150,
                ),
                SizedBox(height: 20),
                Text(
                  'Không tìm thấy thiết bị',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Hãy đảm bảo thiết bị kết nối đang ở trạng thái "Paring"',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF777E90),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Divider(),
                SizedBox(height: 10),
                ConditionWidget(deviceInfo: widget.cubit.deviceInfo!),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 20),
          width: double.infinity,
          child: ButtonWidget(
            title: 'Kết nối lại',
            onPressed: () async {
              await FlutterBluePlus.stopScan();
              setState(() {
                deviceFound = false;
                appStatus = AppStatus.isScanning;
                isConnectionInProgress = false; // Reset connection flag
              });
              _startScan();
            },
          ),
        )
      ],
    );
  }


  Widget _manualForgetDeviceWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _btnClose(context),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),
                Icon(
                  Icons.bluetooth,
                  size: 120,
                  color: Color(0xFF007AFF),
                ),
                SizedBox(height: 30),
                Text(
                  'Cần xóa thiết bị khỏi Bluetooth',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Thiết bị đã được ghép nối trước đó',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6C757D),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFFE9ECEF)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hướng dẫn xử lý:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF495057),
                        ),
                      ),
                      SizedBox(height: 15),
                      _buildStep('1', 'Vào Settings > Bluetooth trên iPhone'),
                      _buildStep('2', 'Tìm thiết bị "${device?.platformName ?? "máy đo đường huyết"}" trong "MY DEVICES"'),
                      _buildStep('3', 'Nhấn vào biểu tượng (i) bên cạnh tên thiết bị'),
                      _buildStep('4', 'Chọn "Forget This Device" và xác nhận'),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFFFFE69C)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFF856404), size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Sau khi xóa thiết bị khỏi Bluetooth, quay lại ứng dụng để kết nối lại.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF856404),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(
            left: 15,
            right: 15,
            bottom: MediaQuery.of(context).padding.bottom + 15,
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                child: ButtonWidget(
                  title: 'Tìm kiếm lại thiết bị',
                  onPressed: () async {
                    try {
                      _safeSetState(() {
                        isLoading = true;
                        appStatus = AppStatus.isScanning;
                      });
                      // Restart scan để tìm device lại
                      _startScan();
                    } catch (e) {
                      _safeSetState(() {
                        isLoading = false;
                      });
                    }
                  },
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: double.infinity,
                child: ButtonWidget(
                  title: 'Thử lại kết nối',
                  backgroundColor: Colors.transparent,
                  textColor: Color(0xFF007AFF),
                  borderColor: Color(0xFF007AFF),
                  onPressed: () async {
                    if (device != null) {
                      try {
                        print('=== CASE 2.1: USER PRESSED "THỬ LẠI KẾT NỐI" ===');
                        print('Device: ${device!.platformName}');
                        print('Retrying connection after manual forget...');
                        _safeSetState(() {
                          isLoading = true;
                        });
                        await connectDevice(device!);
                      } finally {
                        _safeSetState(() {
                          isLoading = false;
                        });
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _deviceUnpairWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _btnClose(context),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),
                Icon(
                  Icons.bluetooth,
                  size: 120,
                  color: Color(0xFF007AFF),
                ),
                SizedBox(height: 30),
                Text(
                  'Lỗi kết nối thiết bị',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Máy đường huyết đang kết nối với điện thoại\nnhưng điện thoại đã bị xóa kết nối',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6C757D),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFFE9ECEF)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hướng dẫn xử lý:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF495057),
                        ),
                      ),
                      SizedBox(height: 15),
                      _buildStep('1', 'Mở máy đường huyết'),
                      _buildStep('2', 'Chọn cài đặt và xóa pair với điện thoại đang kết nối'),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFFFFE69C)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFF856404), size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Sau khi xóa pair trên máy, quay lại ứng dụng và thử kết nối lại.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF856404),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(
            left: 15,
            right: 15,
            bottom: MediaQuery.of(context).padding.bottom + 15,
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                child: ButtonWidget(
                  title: 'Đã xóa pair trên máy',
                  onPressed: () async {
                    try {
                      _safeSetState(() {
                        isLoading = true;
                        appStatus = AppStatus.isScanning;
                      });
                      // Restart scan để tìm device lại
                      _startScan();
                    } catch (e) {
                      _safeSetState(() {
                        isLoading = false;
                      });
                    }
                  },
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: double.infinity,
                child: ButtonWidget(
                  title: 'Thử lại kết nối',
                  backgroundColor: Colors.transparent,
                  textColor: Color(0xFF007AFF),
                  borderColor: Color(0xFF007AFF),
                  onPressed: () async {
                    if (device != null) {
                      try {
                        print('=== CASE 3.1: USER PRESSED "THỬ LẠI KẾT NỐI" ===');
                        print('Device: ${device!.platformName}');
                        print('Retrying connection after device unpair...');
                        _safeSetState(() {
                          isLoading = true;
                        });
                        await connectDevice(device!);
                      } finally {
                        _safeSetState(() {
                          isLoading = false;
                        });
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Color(0xFF007AFF),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF495057),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
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
          margin:
              EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          width: double.infinity,
          child: ButtonWidget(
            title: 'Tôi đã hiểu',
            onPressed: () async {
              if (device != null && !isConnectionInProgress) {
                try {
                  print('=== USER PRESSED "TÔI ĐÃ HIỂU" ===');
                  print('Device: ${device!.platformName}');
                  print('Starting connection attempt...');
                  _safeSetState(() {
                    isLoading = true;
                    isConnectionInProgress = true;
                  });
                  // Chỉ gọi connectDevice() - nó đã có logic error handling
                  await connectDevice(device!);
                } finally {
                  _safeSetState(() {
                    isLoading = false;
                    isConnectionInProgress = false;
                  });
                }
              } else if (isConnectionInProgress) {
                print('⚠️ Connection already in progress, ignoring duplicate tap');
                Message.showToastMessage(
                    context, 'Đang kết nối, vui lòng đợi...');
              }
            },
          ),
        )
      ],
    );
  }

  void _startScan() async {
    try {
      List<BluetoothDevice> connectedDevices = FlutterBluePlus.connectedDevices;

      for (final device in connectedDevices) {
        await device.disconnect();
      }

      Timer? scanTimeout; // Add a Timer variable to manage the timeout
      scanTimeout = Timer(Duration(seconds: 25), () {
        if (!deviceFound || appStatus == AppStatus.isScanning) {
          setState(() {
            appStatus = AppStatus.isNoDeviceFound;
          });
          FlutterBluePlus.stopScan();
        }
      });

      FlutterBluePlus.startScan(
        timeout: Duration(seconds: 25),
        withServices: [
          Guid.fromString(GlucoseProfileConfiguration.GLUCOSE_SERVICE_UUID),
          Guid.fromString(GlucoseProfileConfiguration.ROCHE_SERVICE_UUID),
        ],
      );

      final scanResultSub =
          FlutterBluePlus.scanResults.listen((scanResultList) {
        if (!deviceFound && appStatus == AppStatus.isScanning) {
          connectToAvailableDevice(scanResultList);
          scanTimeout?.cancel(); // Cancel the timeout when a device is found
        }
      });
      FlutterBluePlus.cancelWhenScanComplete(scanResultSub);
    } catch (e, s) {
      setState(() {
        deviceFound = false;
        appStatus = AppStatus.isNoDeviceFound;
      });
      TrackingManager.recordError(e, s);
    }
  }

  void connectToAvailableDevice(List<ScanResult> scanResultList) async {
    for (var i = 0; i < scanResultList.length; i++) {
      final result = scanResultList[i];
      if (result.device.platformName.contains('meter')) {
        setState(() {
          deviceFound = true;
          device = result.device;
          appStatus = AppStatus.isConnecting;
        });
        await FlutterBluePlus.stopScan();
        
        // Skip auto-detection for Transfer Data flow - go directly to PIN UI
        // User wants the original flow without solution screen popup
        print('🔄 Skipping auto-detection - proceeding with original Transfer Data flow');
        return;
      }
    }
  }
  
  /// Check if device is already paired
  /// If paired, show solution screen instead of PIN UI
  /// Check if device is paired at iOS system level
  /// iOS doesn't have bondedDevices API, so we use connection behavior to detect pairing
  Future<bool> _checkIfDeviceIsSystemPaired(BluetoothDevice targetDevice) async {
    try {
      print('🔍 iOS pairing detection: Testing connection behavior...');
      print('📱 Device: ${targetDevice.platformName} (${targetDevice.remoteId})');
      
      // On iOS, if device is paired, connection will either:
      // 1. Connect immediately (already paired)
      // 2. Fail with specific pairing-related error
      await targetDevice.connect(timeout: Duration(seconds: 2));
      
      // If we reach here, device connected = already paired
      print('✅ Device connected immediately - already paired!');
      await targetDevice.disconnect();
      return true;
      
    } catch (e) {
      print('⚠️ Connection test failed: $e');
      
      // Check for iOS pairing-related errors that indicate device is known but needs auth
      String errorStr = e.toString().toLowerCase();
      bool isPairingError = errorStr.contains('pairing') || 
                           errorStr.contains('authentication') ||
                           errorStr.contains('bonding') ||
                           errorStr.contains('fbp-code: 10') ||
                           errorStr.contains('fbp-code: 1'); // iOS quick timeout when device is paired
      
      if (isPairingError) {
        print('✅ Pairing error detected - device is known to iOS but needs re-auth');
        return true; // Device is known to system
      }
      
      print('❌ Pure connection timeout - device not paired');
      return false;
    }
  }

  Future<void> _checkIfDeviceAlreadyPaired(BluetoothDevice targetDevice) async {
    if (isConnectionInProgress) {
      print('⚠️ Connection already in progress, skipping pairing check');
      return;
    }
    
    try {
      print('🔍 Checking if device is already paired: ${targetDevice.platformName}');
      print('📱 Device ID: ${targetDevice.remoteId.str}');
      
      isConnectionInProgress = true;
      
      // Show loading state during auto-detection
      _safeSetState(() {
        isLoading = true;
      });
      
      // First: Check if device is in iOS bonded devices list
      bool isSystemPaired = await _checkIfDeviceIsSystemPaired(targetDevice);
      
      if (isSystemPaired) {
        print('✅ Device found in iOS bonded devices - already paired!');
        print('📱 System pairing detected → Show solution screen');
        
        _safeSetState(() {
          deviceFound = true;
          device = targetDevice;
          appStatus = AppStatus.isDeviceAlreadyPaired; // Show solution screen
        });
        
        print('🎯 AUTO-DETECT SUCCESS: System pairing detected → Solution screen');
        return;
      }
      
      // Fallback: Try quick connection with optimized timeout to detect pairing status
      await targetDevice.connect(timeout: Duration(seconds: 5)).timeout(
        Duration(seconds: 5),
        onTimeout: () {
          print('⏰ Quick connection check timed out after 5s - device not paired');
          throw TimeoutException('Quick pairing check timed out');
        },
      );
      
      print('✅ Device is already paired! Showing solution screen');
      print('🎯 AUTO-DETECT SUCCESS: Device connected within 5s → Already paired');
      
      // Disconnect immediately since we only want to check pairing status
      try {
        await targetDevice.disconnect();
        print('📱 Disconnected after pairing check');
      } catch (_) {}
      
      // Device is paired - show solution screen
      _safeSetState(() {
        appStatus = AppStatus.isDeviceAlreadyPaired;
      });
      
    } catch (e) {
      print('⚠️ Device not paired yet, showing PIN UI: $e');
      print('🎯 AUTO-DETECT FAILED: Device timeout within 5s → Need manual pairing');
      
      // Connection failed - device needs pairing, show PIN UI
      try {
        await targetDevice.disconnect();
      } catch (_) {}
      
      // Show PIN code UI for user to complete pairing
      _safeSetState(() {
        appStatus = AppStatus.isConnecting;
      });
    } finally {
      isConnectionInProgress = false;
      // Hide loading state
      _safeSetState(() {
        isLoading = false;
      });
    }
  }

  bool isSelected(Map<String, String> glucose) {
    bool isSelected = false;
    selectedGlucose.forEach((element) {
      if (element['glucose'] == glucose['glucose'] &&
          element['date'] == glucose['date']) {
        isSelected = true;
      }
    });
    return isSelected;
  }

  Widget _deviceAlreadyPairedWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _btnClose(context),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                // Bluetooth icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Color(0xFF007AFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Icon(
                    Icons.bluetooth_connected,
                    size: 40,
                    color: Color(0xFF007AFF),
                  ),
                ),
                SizedBox(height: 24),
                
                // Title
                Text(
                  'Thiết bị đã được ghép nối',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8),
                
                // Subtitle
                Text(
                  'Thiết bị "${device?.platformName ?? "máy đo đường huyết"}" đã sẵn sàng chuyển dữ liệu',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6C757D),
                  ),
                ),
                SizedBox(height: 40),
                
                // Instructions box
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFFE9ECEF)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Color(0xFF6C757D),
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Hướng dẫn kết nối',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF495057),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        '1. Máy đường huyết chuyển qua chế độ "Transfer Data" (không phải "Pair Data")',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6C757D),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '2. Sau khi chuyển xong, nhấn nút "Kết nối thiết bị" bên dưới',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6C757D),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
        
        // Buttons
        Container(
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          child: Column(
            children: [
              // Main button - Continue to data transfer
              Container(
                width: double.infinity,
                child: ButtonWidget(
                  title: 'Kết nối thiết bị',
                  onPressed: () async {
                    if (device != null && !isLoading) {
                      try {
                        _safeSetState(() {
                          isLoading = true;
                        });
                        print('🔄 User chose to continue with data transfer');
                        await connectDevice(device!);
                      } finally {
                        _safeSetState(() {
                          isLoading = false;
                        });
                      }
                    }
                  },
                ),
              ),
              SizedBox(height: 10),
              
              // Secondary button - Scan for other devices
              Container(
                width: double.infinity,
                child: ButtonWidget(
                  title: 'Tìm thiết bị khác',
                  backgroundColor: Colors.transparent,
                  textColor: Color(0xFF007AFF),
                  borderColor: Color(0xFF007AFF),
                  onPressed: () async {
                    await FlutterBluePlus.stopScan();
                    setState(() {
                      deviceFound = false;
                      appStatus = AppStatus.isScanning;
                    });
                    _startScan();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> connectDevice(BluetoothDevice deviceFounded) async {
    try {
      await deviceFounded.connect(timeout: Duration(seconds: 15)).timeout(
        Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Connection timed out after 15 seconds');
        },
      );

      List<BluetoothService> services = await deviceFounded.discoverServices(
        subscribeToServicesChanged: false,
      );

      // Tìm Service 0x1808
      BluetoothService serviceGlucoseMeasurement =
          services.firstWhere((service) {
        return service.serviceUuid.str128 ==
            GlucoseProfileConfiguration.GLUCOSE_SERVICE_UUID;
      });

      // Tìm Characteristic 0x2A18
      BluetoothCharacteristic charGlucoseMeasurement = serviceGlucoseMeasurement
          .characteristics
          .firstWhere((characteristic) =>
              characteristic.characteristicUuid.str128 ==
              GlucoseProfileConfiguration
                  .GLUCOSE_MEASUREMENT_CHARACTERISTIC_UUID);

      // Bật noti cho 0x2A18
      await charGlucoseMeasurement.setNotifyValue(true);
      _safeSetState(() {
        appStatus = AppStatus.isConnected;
      });

      BluetoothService rocheService = services.firstWhere((service) {
        return service.serviceUuid.str128 ==
            GlucoseProfileConfiguration.ROCHE_SERVICE_UUID;
      });

      for (BluetoothCharacteristic rocheCharacteristic
          in rocheService.characteristics) {
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
          
          // Store model info for caching
          this.modelName = modelName;
          this.modelNumber = modelNo;
          
          await updateGlucoseUnit(glucoseUnits,
              modelNameParam: modelName, modelNoParam: modelNo);
              
          // Check if we need full sync or incremental sync
          await _determineSyncStrategy(deviceFounded);
        }
      }

      for (BluetoothCharacteristic characteristic
          in serviceGlucoseMeasurement.characteristics) {
        // Tìm Characteristic 0x2A18
        if (characteristic.characteristicUuid.str128 ==
            GlucoseProfileConfiguration
                .GLUCOSE_MEASUREMENT_CHARACTERISTIC_UUID) {
          await characteristic.setNotifyValue(true);
          _safeSetState(() {
            appStatus = AppStatus.isSyncing;
          });
          previousDataCount = 0;
          glucoseMeasurementRecordList.clear();
          characteristicListener =
              characteristic.lastValueStream.listen((data) async {
            if (data.isEmpty) {
              return;
            }
            GlucoseMeasurementRecord glucoseMeasurementRecord =
                GlucoseFunctions().readDataFrom2A18(data);
            if (glucoseMeasurementRecord.isBloodGlucose) {
              glucoseMeasurementRecordList.add(glucoseMeasurementRecord);
            }
          });
        }

        // Tìm Characteristic 0x2A52
        if (characteristic.characteristicUuid.str128 ==
            GlucoseProfileConfiguration
                .RECORD_ACCESS_CONTROL_POINT_CHARACTERISTIC_UUID) {
          await characteristic.setNotifyValue(true);
          
          // Đợi một chút để đảm bảo notification đã được setup
          await Future.delayed(Duration(milliseconds: 500));
          
          // Thử gửi lệnh request data với retry mechanism (Cải tiến cho case 1.1)
          bool dataRequestSuccess = false;
          int retryCount = 0;
          const maxRetries = 3;
          
          while (!dataRequestSuccess && retryCount < maxRetries) {
            try {
              // Build RACP request with time filter if incremental sync
              List<int> requestData = await _buildRACPRequest();
              print('📡 RACP Request: $requestData');
              await characteristic.write(requestData);
              
              // Đợi lâu hơn cho lần đầu tiên để device có thời gian xử lý
              int delaySeconds = retryCount == 0 ? 8 : 5;
              await Future.delayed(Duration(seconds: delaySeconds));
              
              dataRequestSuccess = true;
              print('Data request sent successfully on attempt ${retryCount + 1}');
            } catch (e) {
              retryCount++;
              print('Data request failed on attempt $retryCount: $e');
              if (retryCount < maxRetries) {
                await Future.delayed(Duration(seconds: 2));
              }
            }
          }
          
          if (dataRequestSuccess) {
            await TrackingManager.trackEvent(
              'glucose_pair',
              'kpi_glucose_device',
              params: {
                'status': 'success',
              },
            );
            startCheckingData();
          } else {
            throw Exception('Failed to send data request after $maxRetries attempts');
          }
        }
      }
    } catch (e, s) {
      // Debug logging để track error patterns
      print('=== CONNECTION ERROR DEBUG ===');
      print('Error: $e');
      print('Error type: ${e.runtimeType}');
      print('Stack trace: $s');
      print('===============================');
      
      // Phân biệt giữa Case 2.1 và Case 3.1
      bool isNonConnectionError = e.toString().contains('Service not found') ||
                                 e.toString().contains('Characteristic not found') ||
                                 e.toString().contains('Permission denied') ||
                                 e.toString().contains('Invalid') ||
                                 e.toString().contains('Parse error');
      
      if (isNonConnectionError) {
        // Những lỗi technical không liên quan đến pairing
        print('Technical error (non-pairing): $e');
        _safeSetState(() {
          appStatus = AppStatus.isNoDeviceFound;
        });
        TrackingManager.recordError(e, s);
        Message.showToastMessage(
            context, 'Lỗi kỹ thuật, xin vui lòng thử lại.');
      } else {
        // Phân biệt Case 2.1 vs 3.1 dựa trên error patterns cụ thể
        bool isCase21 = e.toString().contains('Peer removed pairing') || 
                        e.toString().contains('pairing information') ||
                        e.toString().contains('authentication failed') ||
                        e.toString().contains('apple-code: 14'); // iOS specific pairing error
        
        // Check for specific pairing-in-progress error (fbp-code: 10) or iOS paired device timeout (fbp-code: 1)
        bool isPairingInProgress = (e.toString().contains('fbp-code: 10') &&
                                   e.toString().contains('connection canceled')) ||
                                  (e.toString().contains('fbp-code: 1') &&
                                   e.toString().contains('Timed out'));
        
        // Alternative check: any connection canceled might indicate device is ready
        bool isConnectionCanceled = e.toString().contains('connection canceled') ||
                                   e.toString().contains('FlutterBluePlusException');
        
        // Check if this is a paired device with connection issues
        bool isPairedDeviceConnectionDrop = e.toString().contains('TimeoutException') &&
                                           e.toString().contains('Connection timed out') &&
                                           !e.toString().contains('Quick pairing check'); // Exclude auto-detection timeouts
        
        // Debug: Print detailed error analysis
        print('🔍 ERROR ANALYSIS:');
        print('   - Contains fbp-code: 10: ${e.toString().contains('fbp-code: 10')}');
        print('   - Contains fbp-code: 1: ${e.toString().contains('fbp-code: 1')}');
        print('   - Contains fbp-code: 6: ${e.toString().contains('fbp-code: 6')}');
        print('   - Contains connection canceled: ${e.toString().contains('connection canceled')}');
        print('   - Contains Timed out: ${e.toString().contains('Timed out')}');
        print('   - Contains FlutterBluePlusException: ${e.toString().contains('FlutterBluePlusException')}');
        print('   - Contains TimeoutException: ${e.toString().contains('TimeoutException')}');
        print('   - Contains Connection timed out: ${e.toString().contains('Connection timed out')}');
        print('   - Contains Device is disconnected: ${e.toString().contains('Device is disconnected')}');
        print('   - Contains discoverServices: ${e.toString().contains('discoverServices')}');
        print('   - isPairingInProgress: $isPairingInProgress');
        print('   - isConnectionCanceled: $isConnectionCanceled');
        print('   - isPairedDeviceConnectionDrop: $isPairedDeviceConnectionDrop');
        
        // Calculate isCase31 before printing
        bool isCase31 = (e.toString().contains('Failed to connect') ||
                        e.toString().contains('didFailToConnectPeripheral') ||
                        e.toString().contains('fbp-code: 6') || // Device is disconnected  
                        e.toString().contains('Device is disconnected') ||
                        e.toString().contains('discoverServices') ||
                        e.toString().contains('Connection timeout') ||
                        e.toString().contains('TimeoutException')) &&
                        !isPairingInProgress && // Exclude pairing-in-progress errors
                        !isPairedDeviceConnectionDrop; // Exclude paired device connection drops
        
        print('   - isCase21: ${isCase21}');
        print('   - isCase31: $isCase31');
        print('   - Full error: $e');
        
        if (isPairingInProgress) {
          // Connection canceled - device đã paired và ready for data transfer
          print('✅ EXACT MATCH: Connection canceled (fbp-code: 10) - device already paired and ready for data transfer: $e');
          print('📱 Phone has history + Device is connected → Show solution screen');
          _safeSetState(() {
            deviceFound = true; // Giữ device info để có thể transfer
            appStatus = AppStatus.isDeviceAlreadyPaired; // Show solution screen
          });
        } else if (isPairedDeviceConnectionDrop) {
          // Paired device with connection drop - show solution screen
          print('✅ PAIRED DEVICE CONNECTION DROP: Device is paired but connection dropped: $e');
          print('📱 Device paired + Connection interrupted → Show solution screen for retry');
          _safeSetState(() {
            deviceFound = true; // Giữ device info để có thể transfer
            appStatus = AppStatus.isDeviceAlreadyPaired; // Show solution screen
          });
        } else if (isConnectionCanceled && e.toString().contains('fbp-code: 10')) {
          // Fallback: Any connection canceled with fbp-code: 10
          print('✅ FALLBACK MATCH: Connection canceled with fbp-code: 10 - device may be ready: $e');
          print('📱 Trying alternative detection → Show solution screen');
          _safeSetState(() {
            deviceFound = true; // Giữ device info để có thể transfer
            appStatus = AppStatus.isDeviceAlreadyPaired; // Show solution screen
          });
        } else if (isCase21) {
          // Case 2.1: Máy xóa pair, phone giữ history → Xóa trên phone
          print('Detected Case 2.1 (phone forget device): $e');
          _safeSetState(() {
            deviceFound = true; // Giữ device info để có thể retry
            appStatus = AppStatus.isManualForget;
          });
        } else if (isCase31) {
          // Case 3.1: Phone xóa history, máy vẫn nhớ → Xóa trên máy
          print('Detected Case 3.1 (device unpair): $e');
          _safeSetState(() {
            deviceFound = true; // Giữ device info để có thể retry
            appStatus = AppStatus.isDeviceUnpair;
          });
        } else {
          // Fallback: Lỗi không xác định → về no device found để user thử lại
          print('Unknown connection error: $e');
          _safeSetState(() {
            appStatus = AppStatus.isNoDeviceFound;
          });
          TrackingManager.recordError(e, s);
          Message.showToastMessage(
              context, 'Lỗi kết nối không xác định, xin vui lòng thử lại.');
        }
      }
    }
  }



  Future<void> updateGlucoseUnit(GlucoseUnitsFlag glucoseUnitsFlag,
      {String? modelNameParam, String? modelNoParam}) async {
    bool isMilligramPerDeciliter = AppSettings.userInfo!.glucoseUnit == 1;
    if (glucoseUnitsFlag == GlucoseUnitsFlag.mgPerDL &&
        !isMilligramPerDeciliter) {
      ScheduleGlucoseTimeModel timeModel =
          await UserClient().fetchScheduleGlucoseSetting();
      await UserClient().updateScheduleGlucoseSetting(ScheduleGlucoseTimeModel(
        beforeEat: timeModel.beforeEat,
        afterEat: timeModel.afterEat,
        beforeSleeping: timeModel.beforeSleeping,
        glucoseUnit: 1,
      ));
      await UserClient().fetchUser();
      Observable.instance.notifyObservers([], notifyName: "refresh_home");
    } else if (glucoseUnitsFlag == GlucoseUnitsFlag.mmolPerL &&
        isMilligramPerDeciliter) {
      ScheduleGlucoseTimeModel timeModel =
          await UserClient().fetchScheduleGlucoseSetting();
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
    int noDataCount = 0;
    const maxNoDataCount = 15; // Đợi tối đa 15 giây cho dữ liệu
    
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (glucoseMeasurementRecordList.length > previousDataCount) {
        previousDataCount = glucoseMeasurementRecordList.length;
        noDataCount = 0; // Reset counter khi có dữ liệu mới
      } else {
        noDataCount++;
        
        // Nếu đã đợi đủ lâu mà không có dữ liệu mới, kết thúc
        if (noDataCount >= maxNoDataCount) {
          timer.cancel();
          fetchGlucoseInputNotExist();
        }
      }
    });
  }

  Future<void> fetchGlucoseInputNotExist() async {
    List<Map<String, String>> glucoseDataList = [];
    List<GlucoseData> glucoseDataRequest = [];

    Set<DateTime> uniqueValues = Set<DateTime>();

    if (glucoseMeasurementRecordList.isNotEmpty) {
      // Filter records based on sync strategy
      List<GlucoseMeasurementRecord> recordsToProcess = glucoseMeasurementRecordList;
      
      // ✅ NEW LOGIC: Device already filtered data based on RACP request
      // No need for app-side filtering since device only returns requested data
      if (!shouldPerformFullSync && lastSyncTime != null) {
        print('⚡ INCREMENTAL SYNC: Device returned ${glucoseMeasurementRecordList.length} new records after ${lastSyncTime!.toIso8601String()}');
      } else {
        print('📋 FULL SYNC: Device returned all ${glucoseMeasurementRecordList.length} stored records');
      }
      
      // Process all records returned by device (they're already filtered)
      recordsToProcess = glucoseMeasurementRecordList;
      
      if (recordsToProcess.isEmpty) {
        print('✅ No data returned from device - all records up to date');
      } else {
        print('📊 Processing ${recordsToProcess.length} records from device');
      }
      
      recordsToProcess.forEach((element) {
        final glucose = roundAsFixed(roundDouble(element
            .convertGlucoseConcentrationValueToMilligramsPerDeciliter()));

        if (!uniqueValues.contains(element.calendar)) {
          glucoseDataRequest.add(GlucoseData(
            glucose: glucose.toString(),
            date: DateUtil.getDayInMillis(element.calendar!).toString(),
          ));
          uniqueValues.add(element.calendar!);
        }
      });

      final result =
          await GlucoseClient().fetchGlucoseInputNotExist(glucoseDataRequest);

      result.forEach((element) {
        glucoseDataList.add({
          'glucose': element['glucose'].toString(),
          'date': element['createDate'].toString()
        });
      });

      _safeSetState(() {
        selectAllData = true;
        glucosedList = glucoseDataList;
        appStatus = AppStatus.isSyncCompleted;
        selectedGlucose = [...glucoseDataList];
      });
    } else {
      _safeSetState(() {
        appStatus = AppStatus.isSyncCompleted;
      });
    }
  }
}