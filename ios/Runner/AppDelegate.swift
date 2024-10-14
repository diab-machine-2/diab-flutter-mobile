import UIKit
import Flutter
import Foundation
import CoreBluetooth
import ibtFramework
import ZaloSDK
import BranchSDK
// import MobileRTC

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    static var sink: FlutterEventSink?
    private var arrDevices: [btInfo]? = []
    private var selectedDevice: btInfo?
    private var arrResult: [String]? = []
    private var glucoseData: [RecordInfo]? = []
    private var isInit: Bool = false
    
    // private var zoomInited: Bool = false
    // private var zoomAuthResult: FlutterResult?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        //Branch.setUseTestBranchKey(true)        
        Branch.getInstance().initSession(launchOptions: launchOptions) { (params, error) in
            print(params as? [String: AnyObject] ?? {})
            // Access and use Branch Deep Link data here (nav to page, display content, etc.)
        }
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let iBleMethodChannel = FlutterMethodChannel(name: "iBleSdk",
                                                     binaryMessenger: controller.binaryMessenger)
    
        iBleMethodChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if call.method == "request_permission" {
                self.requestPermission(result: result)
            } else if call.method == "init_IBle_Sdk" {
                self.initIBle()
            } else if call.method == "start_scan" {
                self.startScan()
            } else if call.method == "stop_scan" {
                self.stopScan()
            }  else if call.method == "connect", let data = call.arguments as? String {
                self.connect(deviceID: data)
            } else if call.method == "dis_connect" {
                self.disConnect()
            } else if call.method == "get_data" {
                self.getData()
            } else if call.method == "destroy_sdk" {
                self.destroySDK();
            } else {
                result(FlutterMethodNotImplemented)
                return
            }
        })
        
        let eventChannel = FlutterEventChannel(name: "eventChannelStreamiBle", binaryMessenger: controller.binaryMessenger)
        eventChannel.setStreamHandler(IBleStreamHandler())
        
        // Start method-channel handler for zoom-meeting-sdk
        // let zoomMeetingSdkMC = FlutterMethodChannel(name: "DiaB_MeetingMC", binaryMessenger: controller.binaryMessenger)
        // zoomMeetingSdkMC.setMethodCallHandler({
        //     (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        //     if call.method == "initZoom" {
        //         self.initZoom(info: call.arguments as! Dictionary<String, Any>, result: result)
        //     } else if call.method == "joinMeeting" {
        //         self.joinMeeting(info: call.arguments as! Dictionary<String, Any>, result: result)
        //     } else {
        //         result(FlutterMethodNotImplemented)
        //         return
        //     }
        // })
        
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return ZDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
    }
    
    // override func applicationWillResignActive(_ application: UIApplication) {
    //     super.applicationWillResignActive(application)
    //     MobileRTC.shared().appWillResignActive()
    // }
    
    // override func applicationDidBecomeActive(_ application: UIApplication) {
    //     super.applicationDidBecomeActive(application)
    //     MobileRTC.shared().appDidBecomeActive()
    // }
    
    // override func applicationDidEnterBackground(_ application: UIApplication) {
    //     super.applicationDidEnterBackground(application)
    //     MobileRTC.shared().appDidEnterBackgroud()
    // }
    
    // override func applicationWillTerminate(_ application: UIApplication) {
    //     super.applicationWillTerminate(application)
    //     MobileRTC.shared().appWillTerminate()
    // }
    
    private func requestPermission(result: FlutterResult) {
        
        if #available(iOS 13.0, *) {
            if (iBTManager.shared.isStatePoweredOn() && iBTManager.shared.checkPermission()) {
                result("ble_already")
                
            } else {
                result("ble_off")
                
            }
        }
        else {
            if (iBTManager.shared.isStatePoweredOn()) {
                result("ble_already")
                
            } else {
                result("ble_off")
                
            }
        }
    }
    
    private func initIBle() {
        let iManager = iDeviceManager.shared
        iManager.m_delegate = self
        // for setting internal data as base
        iManager.initialize()
        // to set the option for showing internal data log.
        iManager.bPrintOn = true
        // for converting glucose value by specific unit (mg/dL, mmol/L) - Int (0: mg/dL, 1: mmol/L)
        iManager.setUnit(0)
        // to set the callback service for managing the received data.
        iBTManager.shared.m_delegate = self
    }
    
    private func startScan() {
        glucoseData?.removeAll()
        arrDevices?.removeAll()
        iBTManager.shared.resetListInfo()
        iBTManager.shared.procType = .Searching
        iBTManager.shared.startScanDevice()
    }
    private func stopScan() {
       // iBTManager.shared.stopScan();
    }
    
    private func connect(deviceID: String) {
        if let device = arrDevices?.first(where: { btInfo in
            btInfo.periUUID == deviceID
        }) {
            selectedDevice = device
            DispatchQueue.main.async {
                //iBTManager.shared.disconnect(device)
                // to re-initialize the internal data
                iDeviceManager.shared.resetSettings()
                //iDeviceManager.shared.setCurrentPeripheral(iBTManager.shared.currManager)
                iBTManager.shared.connect(device: device)
            }
            
        } else {
            AppDelegate.sink!(["event":"device_not_connect", "data": []])
        }
    }
    
    private func disConnect() {
//        DispatchQueue.main.async {
//            iBTManager.shared.disconnect()
//        }
    }
    
    private func destroySDK() {
        
    }
    
    private func getData() {
        let control = iDeviceManager.shared
        let currPeri = control.getPeripheral()
        let status = iBTManager.shared.isConnected
        
        arrResult?.removeAll()
        
        control.callType = .download_all
        control.reqDataCurrentAll(currPeri)
//        if status == true {
//            control.reqDataCurrentAll(currPeri)
//        }
    }
}

class IBleStreamHandler: NSObject, FlutterStreamHandler {
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        AppDelegate.sink = events
        AppDelegate.sink!(["event":"on_listen_done", "data": []])
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        //AppDelegate.sink = nil
        return nil
    }
    
    
}


extension AppDelegate: iBTManagerDelegate {
    func centralClientUpdateState(_ central: CBCentralManager) {
        // after checkig the current bluetooth status, check the permission
        if #available(iOS 13.0, *) {
            if (central.state == .poweredOn && iBTManager.shared.checkPermission()) {
                AppDelegate.sink!(["event":"ble_already", "data": []])
            } else {
                AppDelegate.sink!(["event":"ble_off", "data": []])
            }
        }
        else {
            if (central.state == .poweredOn) {
                AppDelegate.sink!(["event":"ble_already", "data": []])
            } else {
                AppDelegate.sink!(["event":"ble_off", "data": []])
            }
        }
        
        
    }
    
    func centralClientStateError(_ central: iBTManager) {
        AppDelegate.sink!(["event":"scan_error", "data": []])
    }
    
    func centralClientSearched(_ device: btInfo) {
        arrDevices?.append(device)
        
        DispatchQueue.main.async {
            var devices: [[String: String]] = []
            self.arrDevices?.forEach({ btInfo in
                devices.append(["name" : btInfo.periName!, "address": btInfo.periUUID!])
            })
            AppDelegate.sink!(["event":"new_device", "data": devices])
        }
    }
    
    func centralClientSearchFinish() {
        AppDelegate.sink!(["event":"stop_scan", "data": []])
    }
    
    func centralClientDidDisconnect(_ bError: Bool) {
        AppDelegate.sink!(["event":"device_disconnect", "data": []])
        
    }
    
    func centralClientDidConnectFail(_ central: iBTManager, msg: String) {
        AppDelegate.sink!(["event":"connect_error", "data": []])
    }
}

// ================================================================================================================ by isens
extension AppDelegate: iDeviceManagerDelegate {
    // Definition
    // public var callType: ibtFramework.TaskType
    // - with_idle: normal process
    // - total_count: request total count of saved data
    // - download_all: request all data from device
    // - download_after: request data from device with specific range
    // - sync_time: request time synchronization
    
    // When the error has occurred, send a notification
    func receivedError(_ str: String) {
        AppDelegate.sink!(["event":"connect_error", "data": []])
    }
    
    // When the user wants to make disconnect or error has occurred
    func makeDisconnect() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            iBTManager.shared.disconnect()
//        }
//        AppDelegate.sink!(["event":"device_disconnect", "data": []])
    }
    
    // The FW Version of device is too old
    func receivedLowVersion(_ bCheck: Bool) {
        //AppDelegate.sink!(["event":"receivedLowVersion", "data": []])
    }
    
    // When it receives the information of device (device name, Manufacture)
    func receivedManufactureName(_ name: String, _ productName: String) {
        var fullName = productName.count > 0 ? productName : "failed!"
        fullName += " by "
        fullName += (name.count > 0) ? name : "faild!"
        AppDelegate.sink!(["event":fullName, "data": []])
    }
    
    // When it receives the information of revision version
    func receivedSWRevision(_ version: String ) {
        //AppDelegate.sink!(["event": (version.count > 0 ? version : "failed!"), "data": []])
    }
    
    // When it receives the information of serial number
    func receivedSerialNumber(_ number: String) {
        //AppDelegate.sink!(["event": "receivedSerialNumber", "data": []])
        iBTManager.shared.procType = .connected
    }
    
    // When the device has connected
    func completeBonded() {
//        iBTManager.shared.procType = .connected
//        //AppDelegate.sink!(["event": "device_connected", "data": []])
//
//        let control = iDeviceManager.shared
//        let currPeri = control.getPeripheral()
//        let status = iBTManager.shared.isConnected
//
//        arrResult?.removeAll()
//
//        control.callType = .download_all
//
//        if status == true {
//            control.reqDataCurrentAll(currPeri)
//        }
        iBTManager.shared.procType = .connected
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            AppDelegate.sink!(["event": "device_connected", "data": []])
        }
    }
    
    // When it receives the total count of data
    func receivedTotalCount(_ count: Int, _ sequence: String) {
        //AppDelegate.sink!(["event": (count > 0 ? "\(count)" : "failed"), "data": []])
        
    }
    
    // When it receives the measured data
    func receivedGlucose(_ obj: RecordInfo?) {
        guard let data = obj else { return }
        glucoseData?.append(data)
        print("Tổng là: " + String(glucoseData?.count ?? 0))
//        let str = "## Seq:\(data.sequence), Glucose: \(data.glucose) \(data.glucoseUnit), Date: \(data.date), TimeOffset: \(data.timeOffset),  HiLo: \(data.HiLo), Meal: -"
//
//        DispatchQueue.main.async {
//            AppDelegate.sink!(["event": "get_data_success", "data": [["glucose": String(data.glucose), "date": String(data.date)]]])
//        }
        

    }
    
    // When it receives the context data, (input data by user)
    // In this case, it shows only meal type or ketone info.
    func receivedContext(_ obj: RecordInfo?) {
        AppDelegate.sink!(["event": "receivedContext", "data": []])
    }
    
    // When it receives the response for time sync
    func receivedSyncTime(_ str: String) {

        if str.count > 0 {
            AppDelegate.sink!(["event": str, "data": []])
        }
        
    }
    
    func receivedDownloadComplete() {
        iDeviceManager.shared.operateTimer(false)
    }
    
    func receivedNoRecords() {
        var data: [[String: String]?] = []
        glucoseData?.forEach({ recordInfo in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = dateFormatter.date(from: recordInfo.date)
            let interval: String = String(Int(date?.timeIntervalSince1970 ?? 0))
            data.append(["glucose": String(recordInfo.glucose), "date": interval])
        })
        AppDelegate.sink!(["event": "get_data_success", "data": data])
//        DispatchQueue.main.async {
//
//           iBTManager.shared.disconnect()
//iBTManager.shared.resetListInfo()
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            iBTManager.shared.disconnect(self.selectedDevice)
//        }
        
//            iBTManager.shared.stopScan()
//            iBTManager.shared.procType = .None
//        }
        iDeviceManager.shared.operateTimer(false)
    }
}
// extension AppDelegate: MobileRTCAuthDelegate, MobileRTCMeetingServiceDelegate {
//     func initZoom(info: Dictionary<String, Any>, result: @escaping FlutterResult) {
//         if (MobileRTC.shared().getAuthService()?.isLoggedIn() == true) {
//             return result(true)
//         }
//         let jwtToken = info["jwtToken"] as! String
//         let domain: String = "https://zoom.us"
//         zoomAuthResult = result

//         if (!zoomInited) {
//             // init zoom sdk
//             let initContext = MobileRTCSDKInitContext()
//             initContext.domain = domain
//             // Set your Apple AppGroupID here
//             // initContext.appGroupId = appGroupId
//             // Turn on SDK logging
//             initContext.enableLog = true
//             initContext.locale = .default
            
//             let sdkInitSuccess = MobileRTC.shared().initialize(initContext)
//             if (!sdkInitSuccess) {
//                 print("Failed to initialize Zoom SDK")
//                 result(FlutterError(code: "SDK_INIT_FAILED", message: "Failed to initialize Zoom SDK", details: nil))
//                 return
//             }
            
//             zoomInited = true
//         }

//         // Set the Zoom SDK root controller
//     //    let rootController = UIApplication.shared.windows.first?.rootViewController?.navigationController
//     //    let sdkRootController = MobileRTC.shared().setMobileRTCRootController(rootController)
//     //    if (sdkRootController == nil) {
//     //        print("Failed to set Zoom SDK root controller")
//     //        result(FlutterError(code: "SDK_INIT_FAILED", message: "Failed to set Zoom SDK root controller", details: nil))
//     //        return
//     //    }

//         // Set auth service delegate
//         let authService = MobileRTC.shared().getAuthService()
//         if (authService != nil && authService?.isLoggedIn() == false) {

//             print("Auth service is not nil")

//             // Auth with JWT
//             authService!.delegate = self
//             authService!.jwtToken = jwtToken
//             authService!.sdkAuth()
            
//         }
//         print("Zoom SDK initialized successfully")
// //        result(true)
//     }

//     // join meeting
//     func joinMeeting(info: Dictionary<String, Any>, result: @escaping FlutterResult) {
//         // Join
//         let username = info["username"] as! String
//         let password = info["password"] as! String
//         let meetingNo = info["meetingID"] as! String

//         let options = MobileRTCMeetingJoinParam()
//         options.noAudio = false
//         options.noVideo = false
//         options.meetingNumber = meetingNo
//         options.password = password
//         options.userName = username
        
//         if let meetingSetting = MobileRTC.shared().getMeetingSettings() {
//             meetingSetting.setAutoConnectInternetAudio(true)
//             meetingSetting.disableDriveMode(true)
//             meetingSetting.enableVideoCallPicture(inPicture: true)
            
//             meetingSetting.meetingPasswordHidden = true
//             meetingSetting.meetingInviteHidden = true
//             meetingSetting.meetingInviteUrlHidden = true
//             meetingSetting.meetingShareHidden = true
//             meetingSetting.recordButtonHidden = true
            
//             meetingSetting.setMuteAudioWhenJoinMeeting(true)
//             meetingSetting.disableMinimizeMeeting(false)
//             meetingSetting.disableCopyMeetingUrl(true)
//         }
        

//         if let meetingService = MobileRTC.shared().getMeetingService() {
//             meetingService.delegate = self
//             let ret = meetingService.joinMeeting(with: options)
//             print(ret)
//             result(nil)
//         }
        
//         print("Meeting Service empty")
//         return result(nil)
//     }

//     // print log for MobileRTCAuthDelegate functions
//     func onMobileRTCAuthReturn(_ returnValue: MobileRTCAuthError) {
//         print("onMobileRTCAuthReturn \(returnValue)")
//         if (zoomAuthResult == nil) {
//             return
//         }
//         if (returnValue == .success) {
//             zoomAuthResult!(true)
//         } else {
//             zoomAuthResult!(false)
//         }
//     }

//     func onMobileRTCAuthExpired() {
//         print("onMobileRTCAuthExpired")
//     }

//     func onMobileRTCLoginResult(_ returnValue: MobileRTCLoginFailReason) {
//         print("onMobileRTCLoginResult \(returnValue)")
//     }

//     func onMobileRTCLogoutReturn(_ returnValue: Int) {
//         print("onMobileRTCLogoutReturn \(returnValue)")
//     }

//     // onNotificationServiceStatus
//     func onNotificationServiceStatus(_ status: MobileRTCNotificationServiceStatus, _ error: MobileRTCNotificationServiceError) {
//         print("onNotificationServiceStatus \(status) \(error)")
//     }
//     // END MobileRTCAuthDelegate functions

//     // print log for MobileRTCMeetingServiceDelegate functions
//     func onMeetingError(_ error: MobileRTCMeetError, message: String?) {
//         print("onMeetingError \(error) \(message ?? "")")
//     }

//     // onMeetingStateChange
//     func onMeetingStateChange(_ state: MobileRTCMeetingState) {
//         print("onMeetingStateChange \(state)")
//     }

// }
