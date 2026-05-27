import 'dart:async';
import 'dart:convert';
import 'dart:developer';
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
import '../utils/glucose_sync_cache.dart';
import '../widgets/condition_widget.dart';
import '../widgets/result_sync_data_new.dart';

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
  StreamSubscription? _racpResponseListener;

  List<GlucoseMeasurementRecord> glucoseMeasurementRecordList = [];
  List<Map<String, String>> selectedGlucose = [];
  List<Map<String, String>> glucosedList = [];
  bool deviceFound = false;
  int previousDataCount = 0;
  bool isConnectionInProgress = false; // Track if connection is in progress
  bool _racpCompleted =
      false; // Flag: device finished sending all records via RACP
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
    _clearCacheIfNeeded(); // Clear cache khi app mới cài
    _startScan();
    _checkAppStatus();
  }

  /// Clear cache khi app mới cài để đảm bảo sync đầy đủ
  Future<void> _clearCacheIfNeeded() async {
    try {
      // Kiểm tra xem có phải lần đầu mở app không
      final isFirstLaunch = await GlucoseSyncCache.isFirstLaunch();
      if (isFirstLaunch) {
        log('🔄 First launch detected - clearing sync cache');
        await GlucoseSyncCache.clearAllCache();
        await GlucoseSyncCache.setFirstLaunchCompleted();
      }
    } catch (e) {
      log('⚠️ Error clearing cache: $e');
    }
  }

  /// Build RACP (Record Access Control Point) request command.
  ///
  /// Always requests all stored records from the device (`[0x01, 0x01]`).
  /// The Accu-Chek Guide does NOT support RACP time-based filters — it
  /// silently disconnects when receiving any filter type (0x02 or 0x05).
  /// Server-side filtering via `fetchGlucoseInputNotExist` handles
  /// deduplication of already-synced records instead.
  Future<List<int>> _buildRACPRequest() async {
    log('📋 RACP REQUEST: Full sync (Report All Stored Records)');
    return [0x01, 0x01];
  }

  int? _parseEpochSeconds(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    final text = value.toString().trim();
    if (text.isEmpty) return null;
    return num.tryParse(text)?.toInt();
  }

  double? _parseGlucoseValue(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().trim());
  }

  String? _glucoseMapKey(Map<String, String> glucose) {
    final epochSeconds = _parseEpochSeconds(glucose['date']);
    final glucoseValue = _parseGlucoseValue(glucose['glucose']);
    if (epochSeconds == null || glucoseValue == null) return null;
    return '$epochSeconds|${glucoseValue.toStringAsFixed(3)}';
  }

  String? _glucoseRecordKey(GlucoseMeasurementRecord record) {
    if (record.calendar == null || !record.isBloodGlucose) return null;
    final glucose = roundAsFixed(roundDouble(
        record.convertGlucoseConcentrationValueToMilligramsPerDeciliter()));
    final glucoseValue = _parseGlucoseValue(glucose);
    if (glucoseValue == null) return null;
    final epochSeconds = DateUtil.getDayInMillis(record.calendar!);
    return '$epochSeconds|${glucoseValue.toStringAsFixed(3)}';
  }

  void _removeSelectedGlucose(Map<String, String> glucose) {
    final key = _glucoseMapKey(glucose);
    if (key == null) {
      selectedGlucose.remove(glucose);
      return;
    }
    selectedGlucose.removeWhere((element) => _glucoseMapKey(element) == key);
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
    _racpResponseListener?.cancel();
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

      // API postGlucoseInputs() successful

      // Save cache time and device info after successful sync
      if (device != null) {
        final deviceId = device!.remoteId.str;
        final userId = AppSettings.userInfo?.id ?? '';

        // ⚠️ CRITICAL: Cache time must be set so that ALL unselected records
        // will be included in the NEXT incremental sync.
        //
        // Strategy:
        //   1. Build the set of all selected record timestamps (exact DateTime)
        //   2. Find ALL device records that were NOT selected
        //   3. Set cache = (oldest unselected record time) - 1s
        //      → RACP filter on next sync: ≥ cache + 1s = oldest unselected time
        //      → Device will return that record and everything after ✅
        //   4. If all records were selected, set cache = latest selected time
        //      → Next sync: filter ≥ latest + 1s (only truly new records) ✅
        //
        // Example:
        //   Device: [R1@09:00, R2@09:04:28]   User selects only R1
        //   Unselected = [R2@09:04:28]
        //   cache = 09:04:27  → next filter ≥ 09:04:28 → R2 appears ✅

        log('🔍 CACHE DEBUG: Total device records: ${glucoseMeasurementRecordList.length}');
        log('🔍 CACHE DEBUG: Selected records count: ${selectedGlucose.length}');

        // Build exact selected keys. The API can return JSON numbers as
        // doubles, so compare normalized numeric values instead of strings like
        // "1778724435" vs "1778724435.0".
        final selectedRecordKeys =
            selectedGlucose.map(_glucoseMapKey).whereType<String>().toSet();
        final displayedRecordKeys =
            glucosedList.map(_glucoseMapKey).whereType<String>().toSet();
        log('🔍 CACHE DEBUG: Selected record keys: $selectedRecordKeys');
        log('🔍 CACHE DEBUG: Displayed record keys: $displayedRecordKeys');

        // Partition device records into selected vs unselected
        final List<DateTime> unselectedTimes = [];
        final List<DateTime> selectedTimes = [];
        for (final r in glucoseMeasurementRecordList) {
          if (r.calendar == null || !r.isBloodGlucose) continue;
          final recordEpochSeconds = DateUtil.getDayInMillis(r.calendar!);
          final recordKey = _glucoseRecordKey(r);
          if (displayedRecordKeys.isNotEmpty &&
              (recordKey == null || !displayedRecordKeys.contains(recordKey))) {
            log('   → Ignoring hidden/already-synced record for cache: ${r.calendar!.toIso8601String()} (key=$recordKey, epochSeconds=$recordEpochSeconds)');
            continue;
          }
          if (recordKey != null && selectedRecordKeys.contains(recordKey)) {
            selectedTimes.add(r.calendar!);
          } else {
            unselectedTimes.add(r.calendar!);
            log('   → Unselected record: ${r.calendar!.toIso8601String()} (key=$recordKey, epochSeconds=$recordEpochSeconds)');
          }
        }

        DateTime syncTime;
        if (unselectedTimes.isNotEmpty) {
          // Set cache just BEFORE the oldest unselected record
          // so the next incremental sync will fetch it
          final oldestUnselected =
              unselectedTimes.reduce((a, b) => a.isBefore(b) ? a : b);
          syncTime = oldestUnselected.subtract(Duration(seconds: 1));
          log('⚠️ CACHE: ${unselectedTimes.length} unselected record(s). '
              'Setting cache to 1s before oldest unselected: ${syncTime.toIso8601String()}');
          log('   ↳ Next sync will filter ≥ ${syncTime.add(Duration(seconds: 1)).toIso8601String()} → covers all unselected records');
        } else if (selectedTimes.isNotEmpty) {
          // All records were selected → cache = latest selected time
          syncTime = selectedTimes.reduce((a, b) => a.isAfter(b) ? a : b);
          log('✅ CACHE: All records selected. Cache set to latest record time: ${syncTime.toIso8601String()}');
        } else {
          // No blood glucose records at all → fallback to now
          syncTime = DateTime.now();
          log('⚠️ CACHE: No blood glucose records found, using DateTime.now(): ${syncTime.toIso8601String()}');
        }

        log('💾 Final cache syncTime = ${syncTime.toIso8601String()}');

        // Lưu cache mới với deviceId + userId + lastSyncTime
        if (deviceId.isNotEmpty && userId.isNotEmpty) {
          await GlucoseSyncCache.saveSyncCache(
            deviceId: deviceId,
            userId: userId,
            lastSyncTime: syncTime,
            deviceName: device!.platformName,
            modelName: modelName,
            modelNumber: modelNumber,
          );
          log('💾 New cache saved: Device=$deviceId, User=$userId, Time=${syncTime.toIso8601String()}');
        }


      }

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
      // API postGlucoseInputs() failed

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
      return (_parseEpochSeconds(b['date']) ?? 0)
          .compareTo(_parseEpochSeconds(a['date']) ?? 0);
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
                        _removeSelectedGlucose(glucoseData);
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
          child: Column(
            children: [
              Container(
                width: double.infinity,
                child: ButtonWidget(
                  title: 'Xác nhận & Xem dữ liệu',
                  onPressed: selectedGlucose.isEmpty
                      ? null
                      : () {
                          submitSyncDataNew(selectedGlucose);
                        },
                ),
              ),
              if (glucosedList.isEmpty &&
                  GlucoseSyncCache.isAccuChekDevice(modelNumber)) ...[
                SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  child: ButtonWidget(
                    title: 'Xóa Cache & Thử lại',
                    backgroundColor: Colors.grey,
                    onPressed: () async {
                      log('🔄 Manual cache clear requested from sync screen');
                      await GlucoseSyncCache.clearAllCache();
                      await FlutterBluePlus.stopScan();
                      setState(() {
                        deviceFound = false;
                        appStatus = AppStatus.isScanning;
                        isConnectionInProgress = false;
                      });
                      _startScan();
                      Message.showToastMessage(
                          context, 'Đã xóa cache, kết nối lại...');
                    },
                  ),
                ),
              ],
            ],
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
          child: Column(
            children: [
              Container(
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
              ),
              if (GlucoseSyncCache.isAccuChekDevice(modelNumber)) ...[
                SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  child: ButtonWidget(
                    title: 'Xóa Cache & Kết nối lại',
                    backgroundColor: Colors.orange,
                    onPressed: () async {
                      log('🔄 Manual cache clear requested');
                      await GlucoseSyncCache.clearAllCache();
                      await FlutterBluePlus.stopScan();
                      setState(() {
                        deviceFound = false;
                        appStatus = AppStatus.isScanning;
                        isConnectionInProgress = false;
                      });
                      _startScan();
                      Message.showToastMessage(
                          context, 'Đã xóa cache, kết nối lại...');
                    },
                  ),
                ),
              ],
            ],
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
                      _buildStep('2',
                          'Tìm thiết bị "${device?.platformName ?? "máy đo đường huyết"}" trong "MY DEVICES"'),
                      _buildStep(
                          '3', 'Nhấn vào biểu tượng (i) bên cạnh tên thiết bị'),
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
                      Icon(Icons.info_outline,
                          color: Color(0xFF856404), size: 20),
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
                        log('=== CASE 2.1: USER PRESSED "THỬ LẠI KẾT NỐI" ===');
                        log('Device: ${device!.platformName}');
                        log('Retrying connection after manual forget...');
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
                      _buildStep('2',
                          'Chọn cài đặt và xóa pair với điện thoại đang kết nối'),
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
                      Icon(Icons.info_outline,
                          color: Color(0xFF856404), size: 20),
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
                        log('=== CASE 3.1: USER PRESSED "THỬ LẠI KẾT NỐI" ===');
                        log('Device: ${device!.platformName}');
                        log('Retrying connection after device unpair...');
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
                  log('=== USER PRESSED "TÔI ĐÃ HIỂU" ===');
                  log('Device: ${device!.platformName}');
                  log('Starting connection attempt...');
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
                log('⚠️ Connection already in progress, ignoring duplicate tap');
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
    if (scanResultList.isNotEmpty) {
      final result = scanResultList.first;
      // Since startScan is already filtered with required service UUIDs,
      // any result here should be a valid glucose device. Do not rely on name.
      setState(() {
        deviceFound = true;
        device = result.device;
        appStatus = AppStatus.isConnecting;
      });
      await FlutterBluePlus.stopScan();

      // Skip auto-detection for Transfer Data flow - go directly to PIN UI
      log('🔄 Proceeding with Transfer Data flow (no name check)');
    }
  }

  /// Check if device is already paired
  /// If paired, show solution screen instead of PIN UI
  /// Check if device is paired at iOS system level
  /// iOS doesn't have bondedDevices API, so we use connection behavior to detect pairing
  Future<bool> _checkIfDeviceIsSystemPaired(
      BluetoothDevice targetDevice) async {
    try {
      log('🔍 iOS pairing detection: Testing connection behavior...');
      log('📱 Device: ${targetDevice.platformName} (${targetDevice.remoteId})');

      // On iOS, if device is paired, connection will either:
      // 1. Connect immediately (already paired)
      // 2. Fail with specific pairing-related error
      await targetDevice.connect(timeout: Duration(seconds: 2));

      // If we reach here, device connected = already paired
      log('✅ Device connected immediately - already paired!');
      await targetDevice.disconnect();
      return true;
    } catch (e) {
      log('⚠️ Connection test failed: $e');

      // Check for iOS pairing-related errors that indicate device is known but needs auth
      String errorStr = e.toString().toLowerCase();
      bool isPairingError = errorStr.contains('pairing') ||
          errorStr.contains('authentication') ||
          errorStr.contains('bonding') ||
          errorStr.contains('fbp-code: 10') ||
          errorStr.contains(
              'fbp-code: 1'); // iOS quick timeout when device is paired

      if (isPairingError) {
        log('✅ Pairing error detected - device is known to iOS but needs re-auth');
        return true; // Device is known to system
      }

      log('❌ Pure connection timeout - device not paired');
      return false;
    }
  }

  Future<void> _checkIfDeviceAlreadyPaired(BluetoothDevice targetDevice) async {
    if (isConnectionInProgress) {
      log('⚠️ Connection already in progress, skipping pairing check');
      return;
    }

    try {
      log('🔍 Checking if device is already paired: ${targetDevice.platformName}');
      log('📱 Device ID: ${targetDevice.remoteId.str}');

      isConnectionInProgress = true;

      // Show loading state during auto-detection
      _safeSetState(() {
        isLoading = true;
      });

      // First: Check if device is in iOS bonded devices list
      bool isSystemPaired = await _checkIfDeviceIsSystemPaired(targetDevice);

      if (isSystemPaired) {
        log('✅ Device found in iOS bonded devices - already paired!');
        log('📱 System pairing detected → Show solution screen');

        _safeSetState(() {
          deviceFound = true;
          device = targetDevice;
          appStatus = AppStatus.isDeviceAlreadyPaired; // Show solution screen
        });

        log('🎯 AUTO-DETECT SUCCESS: System pairing detected → Solution screen');
        return;
      }

      // Fallback: Try quick connection with optimized timeout to detect pairing status
      await targetDevice.connect(timeout: Duration(seconds: 5)).timeout(
        Duration(seconds: 5),
        onTimeout: () {
          log('⏰ Quick connection check timed out after 5s - device not paired');
          throw TimeoutException('Quick pairing check timed out');
        },
      );

      log('✅ Device is already paired! Showing solution screen');
      log('🎯 AUTO-DETECT SUCCESS: Device connected within 5s → Already paired');

      // Disconnect immediately since we only want to check pairing status
      try {
        await targetDevice.disconnect();
        log('📱 Disconnected after pairing check');
      } catch (_) {}

      // Device is paired - show solution screen
      _safeSetState(() {
        appStatus = AppStatus.isDeviceAlreadyPaired;
      });
    } catch (e) {
      log('⚠️ Device not paired yet, showing PIN UI: $e');
      log('🎯 AUTO-DETECT FAILED: Device timeout within 5s → Need manual pairing');

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
    final key = _glucoseMapKey(glucose);
    if (key == null) return false;
    return selectedGlucose.any((element) => _glucoseMapKey(element) == key);
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
          margin:
              EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
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
                        log('🔄 User chose to continue with data transfer');
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
          // Reset display state for fresh sync session
          glucosedList = [];
          selectedGlucose = [];
          selectAllData = false;
          characteristicListener =
              characteristic.lastValueStream.listen((data) async {
            if (data.isEmpty) {
              log('🔍 DEBUG: Received empty data from device');
              return;
            }
            log('🔍 DEBUG: Received data from device, length: ${data.length}');
            log('🔍 DEBUG: Data bytes: ${data.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ')}');

            GlucoseMeasurementRecord glucoseMeasurementRecord =
                GlucoseFunctions().readDataFrom2A18(data);

            log('🔍 DEBUG: Parsed record - calendar: ${glucoseMeasurementRecord.calendar}, isBloodGlucose: ${glucoseMeasurementRecord.isBloodGlucose}');

            if (glucoseMeasurementRecord.isBloodGlucose) {
              glucoseMeasurementRecordList.add(glucoseMeasurementRecord);
              log('🔍 DEBUG: Added blood glucose record. Total records: ${glucoseMeasurementRecordList.length}');
            } else {
              log('🔍 DEBUG: Skipped non-blood glucose record');
            }
          });
        }

        // Tìm Characteristic 0x2A52
        if (characteristic.characteristicUuid.str128 ==
            GlucoseProfileConfiguration
                .RECORD_ACCESS_CONTROL_POINT_CHARACTERISTIC_UUID) {
          await characteristic.setNotifyValue(true);

          // Listen for RACP response to know when device finishes sending records
          _racpCompleted = false;
          _racpResponseListener?.cancel();
          _racpResponseListener =
              characteristic.lastValueStream.listen((data) async {
            if (data.length >= 4 && data[0] == 0x06) {
              // OpCode 0x06 = Response Code
              // data[1] = Operator (0x00 = Null)
              // data[2] = Request Op Code (0x01 = Report stored records)
              // data[3] = Response Code Value
              //   0x01 = Success
              //   0x06 = No records found
              log('📡 RACP Response received: ${data.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ')}');
              if (data[2] == 0x01) {
                if (data[3] == 0x01) {
                  log('✅ RACP: Success - all records have been sent');
                } else if (data[3] == 0x06) {
                  log('ℹ️ RACP: No records found matching the filter');
                } else {
                  log('⚠️ RACP: Response code = ${data[3]}');
                }
                _racpCompleted = true;
              }
            }
          });

          // Wait longer to ensure all notification descriptor writes are fully
          // flushed on Android before sending RACP. The GATT_NO_RESOURCES (128)
          // error seen in logs was caused by writing RACP while previous
          // descriptor write operations were still pending in the BLE stack.
          await Future.delayed(Duration(milliseconds: 1000));

          // Thử gửi lệnh request data với retry mechanism (Cải tiến cho case 1.1)
          bool dataRequestSuccess = false;
          int retryCount = 0;
          const maxRetries = 3;

          while (!dataRequestSuccess && retryCount < maxRetries) {
            try {
              // Build RACP request for all data
              List<int> requestData = await _buildRACPRequest();
              log('📡 RACP Request (attempt ${retryCount + 1}): $requestData');
              await characteristic.write(requestData);

              dataRequestSuccess = true;
              log('Data request sent successfully on attempt ${retryCount + 1}');
            } catch (e) {
              retryCount++;
              log('Data request failed on attempt $retryCount: $e');
              if (retryCount < maxRetries) {
                await Future.delayed(Duration(seconds: 3));
              }
            }
          }

          if (dataRequestSuccess) {
            log('🔍 DEBUG: Data request successful, starting data check');
            await TrackingManager.trackEvent(
              'glucose_pair',
              'kpi_glucose_device',
              params: {
                'status': 'success',
              },
            );
            log('🔍 DEBUG: About to call startCheckingData()');
            startCheckingData(characteristic);
            log('🔍 DEBUG: startCheckingData() called');
          } else {
            // Hết số lần retry: về màn hình lỗi
            try {
              await deviceFounded.disconnect();
            } catch (_) {}
            _safeSetState(() {
              appStatus = AppStatus.isNoDeviceFound;
            });
            Message.showToastMessage(
                context, 'Không thể lấy dữ liệu từ thiết bị, xin thử lại.');
            return;
          }
        }
      }
    } catch (e, s) {
      // Debug logging để track error patterns
      log('=== CONNECTION ERROR DEBUG ===');
      log('Error: $e');
      log('Error type: ${e.runtimeType}');
      log('Stack trace: $s');
      log('===============================');

      // Phân biệt giữa Case 2.1 và Case 3.1
      bool isNonConnectionError = e.toString().contains('Service not found') ||
          e.toString().contains('Characteristic not found') ||
          e.toString().contains('Permission denied') ||
          e.toString().contains('Invalid') ||
          e.toString().contains('Parse error');

      if (isNonConnectionError) {
        // Những lỗi technical không liên quan đến pairing
        log('Technical error (non-pairing): $e');
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
            e
                .toString()
                .contains('apple-code: 14'); // iOS specific pairing error

        // Check for specific pairing-in-progress error (fbp-code: 10) or iOS paired device timeout (fbp-code: 1)
        bool isPairingInProgress = (e.toString().contains('fbp-code: 10') &&
                e.toString().contains('connection canceled')) ||
            (e.toString().contains('fbp-code: 1') &&
                e.toString().contains('Timed out'));

        // Alternative check: any connection canceled might indicate device is ready
        bool isConnectionCanceled =
            e.toString().contains('connection canceled') ||
                e.toString().contains('FlutterBluePlusException');

        // Check if this is a paired device with connection issues
        bool isPairedDeviceConnectionDrop =
            e.toString().contains('TimeoutException') &&
                e.toString().contains('Connection timed out') &&
                !e.toString().contains(
                    'Quick pairing check'); // Exclude auto-detection timeouts

        // Debug: log detailed error analysis
        log('🔍 ERROR ANALYSIS:');
        log('   - Contains fbp-code: 10: ${e.toString().contains('fbp-code: 10')}');
        log('   - Contains fbp-code: 1: ${e.toString().contains('fbp-code: 1')}');
        log('   - Contains fbp-code: 6: ${e.toString().contains('fbp-code: 6')}');
        log('   - Contains connection canceled: ${e.toString().contains('connection canceled')}');
        log('   - Contains Timed out: ${e.toString().contains('Timed out')}');
        log('   - Contains FlutterBluePlusException: ${e.toString().contains('FlutterBluePlusException')}');
        log('   - Contains TimeoutException: ${e.toString().contains('TimeoutException')}');
        log('   - Contains Connection timed out: ${e.toString().contains('Connection timed out')}');
        log('   - Contains Device is disconnected: ${e.toString().contains('Device is disconnected')}');
        log('   - Contains discoverServices: ${e.toString().contains('discoverServices')}');
        log('   - isPairingInProgress: $isPairingInProgress');
        log('   - isConnectionCanceled: $isConnectionCanceled');
        log('   - isPairedDeviceConnectionDrop: $isPairedDeviceConnectionDrop');

        // Calculate isCase31 before loging
        bool isCase31 = (e.toString().contains('Failed to connect') ||
                e.toString().contains('didFailToConnectPeripheral') ||
                e
                    .toString()
                    .contains('fbp-code: 6') || // Device is disconnected
                e.toString().contains('Device is disconnected') ||
                e.toString().contains('discoverServices') ||
                e.toString().contains('Connection timeout') ||
                e.toString().contains('TimeoutException')) &&
            !isPairingInProgress && // Exclude pairing-in-progress errors
            !isPairedDeviceConnectionDrop; // Exclude paired device connection drops

        log('   - isCase21: ${isCase21}');
        log('   - isCase31: $isCase31');
        log('   - Full error: $e');

        if (isPairingInProgress) {
          // Connection canceled - device đã paired và ready for data transfer
          log('✅ EXACT MATCH: Connection canceled (fbp-code: 10) - device already paired and ready for data transfer: $e');
          log('📱 Phone has history + Device is connected → Show solution screen');
          _safeSetState(() {
            deviceFound = true; // Giữ device info để có thể transfer
            appStatus = AppStatus.isDeviceAlreadyPaired; // Show solution screen
          });
        } else if (isPairedDeviceConnectionDrop) {
          // Paired device with connection drop - show solution screen
          log('✅ PAIRED DEVICE CONNECTION DROP: Device is paired but connection dropped: $e');
          log('📱 Device paired + Connection interrupted → Show solution screen for retry');
          _safeSetState(() {
            deviceFound = true; // Giữ device info để có thể transfer
            appStatus = AppStatus.isDeviceAlreadyPaired; // Show solution screen
          });
        } else if (isConnectionCanceled &&
            e.toString().contains('fbp-code: 10')) {
          // Fallback: Any connection canceled with fbp-code: 10
          log('✅ FALLBACK MATCH: Connection canceled with fbp-code: 10 - device may be ready: $e');
          log('📱 Trying alternative detection → Show solution screen');
          _safeSetState(() {
            deviceFound = true; // Giữ device info để có thể transfer
            appStatus = AppStatus.isDeviceAlreadyPaired; // Show solution screen
          });
        } else if (isCase21) {
          // Case 2.1: Máy xóa pair, phone giữ history → Xóa trên phone
          log('Detected Case 2.1 (phone forget device): $e');
          _safeSetState(() {
            deviceFound = true; // Giữ device info để có thể retry
            appStatus = AppStatus.isManualForget;
          });
        } else if (isCase31) {
          // Case 3.1: Phone xóa history, máy vẫn nhớ → Xóa trên máy
          log('Detected Case 3.1 (device unpair): $e');
          _safeSetState(() {
            deviceFound = true; // Giữ device info để có thể retry
            appStatus = AppStatus.isDeviceUnpair;
          });
        } else {
          // Fallback: Lỗi không xác định → về no device found để user thử lại
          log('Unknown connection error: $e');
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

  void startCheckingData(BluetoothCharacteristic racpCharacteristic) {
    int noDataCount = 0;
    const maxNoDataCount =
        15; // Increased timeout to 15 seconds for slow BLE connections
    bool hasReceivedData = false; // Flag để track xem đã nhận được dữ liệu chưa

    log('🔍 DEBUG: startCheckingData called, initial records: ${glucoseMeasurementRecordList.length}');

    Timer.periodic(Duration(seconds: 1), (timer) async {
      log('🔍 DEBUG: Checking data - current: ${glucoseMeasurementRecordList.length}, previous: $previousDataCount, noDataCount: $noDataCount, hasReceivedData: $hasReceivedData, racpCompleted: $_racpCompleted');

      // Check 1: If RACP response indicates completion, process immediately
      if (_racpCompleted) {
        // Give a small grace period (2s) after RACP completion for any remaining BLE packets
        if (noDataCount >= 2 || (noDataCount >= 1 && !hasReceivedData)) {
          log('✅ RACP completed + grace period elapsed → processing ${glucoseMeasurementRecordList.length} records');
          timer.cancel();
          _racpResponseListener?.cancel();
          fetchGlucoseInputNotExist();
          return;
        }
      }

      if (glucoseMeasurementRecordList.length > previousDataCount) {
        previousDataCount = glucoseMeasurementRecordList.length;
        noDataCount = 0; // Reset counter khi có dữ liệu mới
        hasReceivedData = true; // Đánh dấu đã nhận được dữ liệu
        log('🔍 DEBUG: New data detected, reset counter');
      } else {
        noDataCount++;
        log('🔍 DEBUG: No new data, counter: $noDataCount/$maxNoDataCount');

        // Nếu đã có dữ liệu và đợi đủ lâu (3s of no new data), xử lý ngay
        if (hasReceivedData && noDataCount >= 3) {
          log('🔍 DEBUG: Data available and no new data for 3s, calling fetchGlucoseInputNotExist');
          timer.cancel();
          _racpResponseListener?.cancel();
          fetchGlucoseInputNotExist();
        }
        // Timeout reached without receiving any data → process what we have
        else if (!hasReceivedData && noDataCount >= maxNoDataCount) {
          log('🔍 DEBUG: Timeout reached (${maxNoDataCount}s) without data, calling fetchGlucoseInputNotExist');
          timer.cancel();
          _racpResponseListener?.cancel();
          fetchGlucoseInputNotExist();
        }
      }
    });
  }

  Future<void> fetchGlucoseInputNotExist() async {
    List<Map<String, String>> glucoseDataList = [];
    List<GlucoseData> glucoseDataRequest = [];

    Set<DateTime> uniqueValues = Set<DateTime>();

    log('🔍 DEBUG: fetchGlucoseInputNotExist called');
    log('🔍 DEBUG: glucoseMeasurementRecordList.length = ${glucoseMeasurementRecordList.length}');

    if (glucoseMeasurementRecordList.isNotEmpty) {
      // Process all records from device (original behavior)
      List<GlucoseMeasurementRecord> recordsToProcess =
          glucoseMeasurementRecordList;

      log('📊 Processing ${recordsToProcess.length} records from device');

      recordsToProcess.forEach((element) {
        log('🔍 DEBUG: Processing record - calendar: ${element.calendar}, isBloodGlucose: ${element.isBloodGlucose}');

        if (element.calendar != null && element.isBloodGlucose) {
          final glucose = roundAsFixed(roundDouble(element
              .convertGlucoseConcentrationValueToMilligramsPerDeciliter()));

          log('🔍 DEBUG: Glucose value: $glucose, calendar: ${element.calendar}');

          if (!uniqueValues.contains(element.calendar)) {
            glucoseDataRequest.add(GlucoseData(
              glucose: glucose.toString(),
              date: DateUtil.getDayInMillis(element.calendar!).toString(),
            ));
            uniqueValues.add(element.calendar!);
            log('🔍 DEBUG: Added to request - glucose: $glucose, date: ${DateUtil.getDayInMillis(element.calendar!)}');
          } else {
            log('🔍 DEBUG: Skipped duplicate calendar: ${element.calendar}');
          }
        } else {
          log('🔍 DEBUG: Skipped record - calendar: ${element.calendar}, isBloodGlucose: ${element.isBloodGlucose}');
        }
      });

      log('🔍 DEBUG: glucoseDataRequest.length = ${glucoseDataRequest.length}');

      if (glucoseDataRequest.isNotEmpty) {
        log('🔍 DEBUG: Calling API with data: ${glucoseDataRequest.map((e) => 'glucose: ${e.glucose}, date: ${e.date}').toList()}');
        final result =
            await GlucoseClient().fetchGlucoseInputNotExist(glucoseDataRequest);

        log('🔍 DEBUG: API result.length = ${result.length}');
        log('🔍 DEBUG: API result content: $result');

        // Nếu API trả về dữ liệu, sử dụng dữ liệu từ API
        if (result.isNotEmpty) {
          result.forEach((element) {
            final createDate = _parseEpochSeconds(element['createDate']);
            if (createDate == null) {
              log('🔍 DEBUG: Skipped API record with invalid createDate: ${element['createDate']}');
              return;
            }
            glucoseDataList.add({
              'glucose': element['glucose'].toString(),
              'date': createDate.toString(),
            });
            log('🔍 DEBUG: Added to display list from API - glucose: ${element['glucose']}, date: $createDate');
          });
        } else {
          // API returned empty → all records already exist on server.
          // Regardless of whether we used full-sync recovery or not,
          // fall back to device data so the user can see and act on
          // records that were previously deselected.
          //
          // NOTE: We intentionally removed the _usedFullSyncRecovery
          // guard here because it caused the screen to show empty when
          // a partial sync (deselected records) was followed by a
          // reconnect via "Data Transfer". The API correctly filters
          // already-uploaded records; if it returns empty it means all
          // fetched device records are already on the server — the
          // device-data fallback is safe to show.
          log('🔍 DEBUG: API returned empty, using device data as fallback');
          glucoseDataRequest.forEach((element) {
            glucoseDataList.add({
              'glucose': element.glucose.toString(),
              'date': element.date.toString()
            });
            log('🔍 DEBUG: Added to display list from device - glucose: ${element.glucose}, date: ${element.date}');
          });
        }

        log('🔍 DEBUG: Final glucoseDataList.length = ${glucoseDataList.length}');

        _safeSetState(() {
          selectAllData = true;
          glucosedList = glucoseDataList;
          appStatus = AppStatus.isSyncCompleted;
          selectedGlucose = [...glucoseDataList];
        });
      } else {
        log('🔍 DEBUG: No valid data to process, showing empty list');
        _safeSetState(() {
          appStatus = AppStatus.isSyncCompleted;
        });
      }
    } else {
      log('🔍 DEBUG: No records from device, showing empty list');
      _safeSetState(() {
        appStatus = AppStatus.isSyncCompleted;
      });
    }
  }
}
