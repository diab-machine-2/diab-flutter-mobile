import UIKit
import Flutter
import Foundation
import CoreBluetooth
import ibtFramework

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    static var sink: FlutterEventSink?
    private var arrDevices: [btInfo]? = []
    private var arrResult: [String]? = []
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let iBleMethodChannel = FlutterMethodChannel(name: "iBleSdk",
                                               binaryMessenger: controller.binaryMessenger)
        
        iBleMethodChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if call.method == "request_permission" {
                self.initIBle()
            } else if call.method == "init_IBle_Sdk" {
                self.initIBle()
            } else if call.method == "start_scan" {
                self.startScan()
            } else if call.method == "get_data" {
                self.getData()
            } else {
                result(FlutterMethodNotImplemented)
                return
            }
            
            
        })

        let eventChannel = FlutterEventChannel(name: "eventChannelStreamiBle", binaryMessenger: controller.binaryMessenger)
        
   
        eventChannel.setStreamHandler(IBleStreamHandler())
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func initIBle() {
        let iManager = iDeviceManager.shared
        iManager.m_delegate = self
        iManager.initialize()
        
        // If you would like to use the iDeviceManager log function, please set the "printOn"
        iManager.bPrintOn = true
        let manager = iBTManager.shared
        manager.m_delegate = self
        
        // Setting Unit
        iDeviceManager.shared.setUnit(0)
//        AppDelegate.sink!("init_success")
    }
    
    private func startScan() {
        
//        var allowCBUUID: [String]? = []
//        let iManager: iDeviceManager? = iDeviceManager.shared
//        guard let lists = iManager?.allowedDevices
//
//        else {
//            result("Not found devices")
//            return
//        }
//
//        for uuid in lists {
//            allowCBUUID?.append(uuid.description)
//        }
//        result(allowCBUUID)
        iBTManager.shared.startScanDevice()
    }
    
    private func getData() {
       
        let control = iDeviceManager.shared
        let currPeri = control.getPeripheral()
        let status = iBTManager.shared.isConnected
        
        arrResult?.removeAll()
        
        control.callType = .download_all
        
        if status == true {
            control.reqDataCurrentAll(currPeri)
        }
    }
}

class IBleStreamHandler: NSObject, FlutterStreamHandler {
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        AppDelegate.sink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        AppDelegate.sink = nil
        return nil
    }
    
    
}


extension AppDelegate: iBTManagerDelegate {
    func centralClientUpdateState(_ central: CBCentralManager) {
        // after checkig the current bluetooth status, check the permission
        if #available(iOS 13.0, *) {
            if (central.state == .poweredOn && iBTManager.shared.checkPermission()) {
                AppDelegate.sink!("permission_grand")
            } else {
                print("bluetooth off")
            }
        }
        else {
            if (central.state == .poweredOn) {
                print("bluetooth on")
                AppDelegate.sink!("permission_grand")
            } else {
                print("bluetooth off")
            }
        }
        

    }
    
    func centralClientStateError(_ central: iBTManager) {
        // Error! : client Bluetooth State
        print("Error has occurred! [centralClientStateError]")
        
        // after finishing the scan
//        btnControlLeft.isEnabled = true
//        btnControlRight.isEnabled = !btnControlLeft.isEnabled
    }
    
    func centralClientSearched(_ device: btInfo) {
        // showing the searched device
        LoadingManager.shared.hideIndicator()
        print("centralClientSearched")
        //
        arrDevices?.append(device)
    var arrResult: [[String:String]]? = []
        arrDevices?.forEach({ btInfo in
            arrResult?.append(["address" : btInfo.periUUID ?? ""])
            arrResult?.append(["name" : btInfo.periName ?? ""])
        })
        
        AppDelegate.sink!(["new_device": arrResult])
//        if (arrDevices?.count != 0) {
//            iBTManager.shared.connect(device: arrDevices![0])
//        }
//        DispatchQueue.main.async {
//            self.deviceTableView.reloadData()
//        }
    }
    
    func centralClientSearchFinish() {
        // finished the searching status.
        ToastManager.shared.show(text: "Scanning has been finished.") {
            LoadingManager.shared.hideIndicator()
            
            print("centralClientSearchFinish")
            // call scan stop in the bluetooth manager, not here.
            
//            self.btnControlLeft.isEnabled = true
//            self.btnControlRight.isEnabled = !self.btnControlLeft.isEnabled
        }
    }
    
    func centralClientDidDisconnect(_ bError: Bool) {
        // received call back of disconnected
        print("centralClientDidDisconnect")
        ToastManager.shared.show(text: "The Device has been disconnected") {
            LoadingManager.shared.hideIndicator()
            
//            self.btnControlLeft.isEnabled = false
//            self.btnControlRight.isEnabled = true
//            self.btnControlRight.tag = 30
//            self.btnControlRight.setTitle("Reset", for: .normal)
        }
    }
    
    func centralClientDidConnectFail(_ central: iBTManager, msg: String) {
        // failed to connect the device
        print("centralClientDidConnectFail")
        
    }
}

// ================================================================================================================ by isens
extension AppDelegate: iDeviceManagerDelegate {
    func receivedError(_ str: String) {
        LoadingManager.shared.hideIndicator()
        
        ToastManager.shared.show(text: str) {
            // Error
        }
        print("receivedError")
    }
    
    func makeDisconnect() {
        LoadingManager.shared.showIndicator()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            iBTManager.shared.disconnect()
        }
        print("makeDisconnect")
    }
    
    func receivedLowVersion(_ bCheck: Bool) {
        if bCheck == true {
//            self.lbVersion.text = "Low Version"
        }
        print("receivedLowVersion")
    }
    
    func receivedManufactureName(_ name: String, _ productName: String) {
        var fullName = productName.count > 0 ? productName : "failed!"
        fullName += " by "
        fullName += (name.count > 0) ? name : "faild!"
        //self.lbName.text = fullName
        print("receivedManufactureName")
    }
    
    func receivedSWRevision(_ version: String ) {
        //self.lbVersion.text = version.count > 0 ? version : "failed!"
        print("receivedSWRevision")
    }
    
    func receivedSerialNumber(_ number: String) {
        //self.lbSN.text = number.count > 0 ? number : "failed!"
        print("receivedSerialNumber")
    }

    func completeBonded() {
        // after connecting the device, check and request more detailed information, then make complete
        LoadingManager.shared.hideIndicator()
        
        ToastManager.shared.show(text: "The selected Device has been connected") {
            //
            iBTManager.shared.procType = .connected
            
            // showing the information of device
            //self.setControlPanelUI()
        }
        print("completeBonded")
    }
    
    func receivedTotalCount(_ count: Int, _ sequence: String) {
        // setting the total count
        LoadingManager.shared.hideIndicator()
        print("receivedTotalCount")
//        self.nlimitSeq = count
//        self.lbCount.text = count > 0 ? "\(count)" : "failed"
    }
    
    func receivedGlucose(_ obj: RecordInfo?) {
        print("receivedGlucose")
        guard let data = obj else { return }
        let str = "## Seq:\(data.sequence), Glucose: \(data.glucose) \(data.glucoseUnit), Date: \(data.date), TimeOffset: \(data.timeOffset),  HiLo: \(data.HiLo), Meal: -"

        if str.count > 0 {
            
            DispatchQueue.main.async {
                AppDelegate.sink!(str)
            }
        }
        
        
    }
    
    func receivedContext(_ obj: RecordInfo?) {
        print("receivedContext")
        guard let data = obj else { return }
        
        //strResult = ", ketone: \(ketoneValue) mmol/L"
        //strResult = ", Meal: \(strMealFlagString)"
        var str: String = ""
        if data.ketone != 0 {
            str = "## Seq:\(data.sequence), ketone: \(data.ketone) \(data.ketoneUnit), Date: \(data.date), TimeOffset: \(data.timeOffset)"
        }
        else if data.Meal.count > 0 || data.Meal != "-" {
            str = ", Meal: \(data.Meal)"
        }
        
        if str.count > 0 {
//            if resultPanel.isHidden == true {
//                resultPanel.isHidden = false
//            }
//
//            if controlPanel.isHidden == false {
//                controlPanel.isHidden = true
//            }
//
//            // if it has meal or ketone information, add or fix the text
//            let strResult = arrResult?.last
//            var stradd = strResult?.replacingOccurrences(of: ", Meal: -", with: "")
//
//            if data.ketone != 0 {
//                stradd = str
//            }
//            else {
//                stradd?.append(str)
//            }
//
//            arrResult?.removeLast()
//            arrResult?.append(stradd!)
//            resultTableView.reloadData()
        }
    }
    
    func receivedSyncTime(_ str: String) {
        print("receivedSyncTime")
        if str.count > 0 {
            //self.lbSyncTime.text = str
        }
        else {
            //self.lbSyncTime.text = "failed!"
        }
    }
    
    func receivedDownloadComplete() {
        print("receivedDownloadComplete")
        uprint("Download Complete for new version of the Device")
        ToastManager.shared.show(text: "Complete to download")
        
        /*
         If you call this function with "false" the device would be disconnected automatically.
         If not, the connection would be kept.
         */
        iDeviceManager.shared.operateTimer(false)
    }
    
    func receivedNoRecords() {
        print("receivedNoRecords")
        uprint("There is no records for legacy version")
        ToastManager.shared.show(text: "Complete to download")
        
        /*
         If you call this function with "false" the device would be disconnected automatically.
         If not, the connection would be kept.
         */
        iDeviceManager.shared.operateTimer(false)
    }

}
