//
//  iBTManager.swift
//  bt
//
//  Created by David on 2021/05/24.
//  Copyright © 2021 i-SENS, Inc. All rights reserved.
//

import Foundation
import CoreBluetooth
import ibtFramework

private let PROCESS_SEARCHING_INTERVAL: TimeInterval = 1800.0   // 1800 sec   < Searching Process Timeout Interval >
private let PROCESS_CONNECION_INTERVAL: TimeInterval = 60.0     // 60 sec   < Connection Process Timeout Interval >

// delegate for bluetooth connection
protocol iBTManagerDelegate {
    func centralClientUpdateState(_ central: CBCentralManager)
    func centralClientSearched(_ device: btInfo)
    func centralClientSearchFinish()
    func centralClientStateError(_ central: iBTManager)
    
    func centralClientDidDisconnect(_ bError: Bool)
    func centralClientDidConnectFail(_ central: iBTManager, msg: String)
}

// struct for Bluetooth device information
struct btInfo {
    var mainPeripheral: CBPeripheral? = nil
    var periName: String? = nil
    var periUUID: String? = nil
    var periRSSI: Int? = nil
    var advertise: [String: Any]? = nil
    var isConnected: Bool = false
}

// current process
enum ProcessType {
    case None
    case Searching
    case Connecting
    case Preparing
    case connected
}

private var manager: iBTManager? = nil

class iBTManager: NSObject {
    public static let shared: iBTManager = {
        if manager == nil {
            manager = iBTManager()
        }
        
        return manager!
    }()
    
    // Bluetooth Base Manager
    public var currManager: CBCentralManager? = nil
    public var searchedPeri: [CBPeripheral]? = []
    public var connectedPeri: CBPeripheral? = nil
    public var connectedChar: CBCharacteristic? = nil
    
    // Manager Delegate
    public var m_delegate: iBTManagerDelegate?
    
    // Task Management
    private var requestTask: DispatchWorkItem?
    private var isBluetoothActive: Bool = false       // check for iOS Device
    public var procType: ProcessType = .None
    
    // Session Information
    private var connectedbt: btInfo? = nil
    private var searchedbt: [btInfo]? = []
    private var allowCBUUID: [CBUUID]? = []
    
    private var isReconnectWhenReady: Bool = false
    private var isConnectedDevice: Bool = false
    private var strBleError: String?
    
    private var sequenceIndex:UInt8 = 0
    private var bRequestConnect: Bool = false
    private var bConnectionComplete: Bool = false
    
    private var iManager: iDeviceManager? = nil
    
    private var processTask: DispatchWorkItem? = nil
    
    public var isConnected: Bool = false
    
    public override init() {
        super.init()
        
        // Initialize the Manager
        self.isBluetoothActive = false
        
        // Create CBCentralManager
        let opt = [CBCentralManagerOptionShowPowerAlertKey: true]
        let centralManager = CBCentralManager.init(delegate: self, queue: .main, options: opt)
        currManager = centralManager
        
        // ================================================================================================================ by isens
        // specific info of allowed connection
        iManager = iDeviceManager.shared
        let lists = iManager?.allowedDevices
        for uuid in lists! {
            allowCBUUID?.append(uuid)
        }
        // ================================================================================================================ by isens
    }
    
    // MARK: - Public Functions
    // reset the internal data
    public func resetListInfo() {
        searchedPeri?.removeAll()
        searchedbt?.removeAll()
    }
    
    // check the status of Central Manager
    public func isStatePoweredOn() -> Bool {
        guard let manager = currManager else { return false }
        
        return (manager.state == .poweredOn)
    }
    
    // check the permission of Central Manager
    @available(iOS 13.0, *)
    public func checkPermission() -> Bool {
        guard let manager = currManager else { return false }
        
        //case notDetermined = 0
        //case restricted = 1
        //case denied = 2
        //case allowedAlways = 3
        return (manager.authorization == .allowedAlways)
    }
    
    // Scan Device
    public func startScanDevice() {
        if currManager != nil {
            if currManager?.isScanning == true {
                currManager?.stopScan()
            }
        }
        procType = .Searching
        scanPeripherals()
        
        // Internal Bluetooth Timeout Monitor
        self.startTimeoutMonitor(procType)
    }

    // Stop Scan
    public func stopScan() {
        stopTimeoutMonitor()
        
        DispatchQueue.main.async {
            self.currManager?.stopScan()
        }
    }
    
    // start to connect - check the response from delegate
    public func connect(device: btInfo) {
        if let uuid = device.periUUID {
            for device in searchedPeri! {
                if device.identifier.uuidString == uuid {
                    DispatchQueue.main.async {
                        self.procType = .Connecting
                        self.currManager?.connect(device, options: nil)
                        self.startTimeoutMonitor(self.procType)
                    }
                    
                    return
                }
            }
        }
        
        // failed to connect
        if self.m_delegate != nil {
            self.m_delegate?.centralClientDidConnectFail(self, msg: "failed to connect")
        }
    }
    
    // make disconnect - check the response from delegate
    public func disconnect(_ device: btInfo? = nil) {
        guard let connected = self.connectedPeri else { return }
        
        iDeviceManager.shared.operateTimer(false)
        if self.currManager != nil {
            if device == nil {
                self.currManager?.stopScan()
                return
            }
            
            self.currManager?.stopScan()
            self.currManager?.cancelPeripheralConnection(connected)
            
            if self.connectedbt != nil {
                self.connectedbt = nil
            }
            
            if self.m_delegate != nil {
                self.m_delegate?.centralClientDidDisconnect(false)
            }
        }
    }
    
    // get the connected device Info
    public func getDeviceInfo() -> btInfo {
        if self.connectedbt != nil {
            return self.connectedbt!
        }
        
        return btInfo()
    }
    
    // MARK: - Private Functions : Connection & Scanning Functions
    private func scanPeripherals () {
        // Scan Devices
        let opt = [CBCentralManagerOptionShowPowerAlertKey: true]
        if currManager == nil {
            currManager = CBCentralManager.init(delegate: self, queue: .main, options: opt)
        }
        
        currManager?.scanForPeripherals(withServices: allowCBUUID, options: opt)
    }
    
    public func findService() -> Bool {
        guard self.connectedbt != nil, let peri = self.connectedPeri else { return false }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // setting the Timeout Monitor 60 sec
            self.startTimeoutMonitor(.Connecting)

            // Find Service
            peri.discoverServices(nil)
        }
        
        return true
    }
    
    public func findCharacteristics() -> Bool {
        guard self.connectedbt != nil, let peri = self.connectedPeri else { return false }
        guard let services = self.connectedPeri?.services else { return false }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // setting the Timeout Monitor 60 sec
            self.startTimeoutMonitor(.Connecting)

            // ================================================================================================================ by isens
            // Find Characteristics
            for service in services {
                if service.uuid.uuidString == ServiceType.BloodGlucose.rawValue {
                    self.iManager?.currServiceType = .BloodGlucose
                }
                else if service.uuid.uuidString == ServiceType.BloodPressure.rawValue {
                    self.iManager?.currServiceType = .BloodPressure
                }
                else {
                    self.iManager?.currServiceType = .BloodDevice
                }
                
                // do not save the found services by David 2021.05.31
                peri.discoverCharacteristics(nil, for: service)
            }
            // ================================================================================================================ by isens
        }
        
        return true
    }
    
    // MARK: - Check Timeout for Work Process
    private func startTimeoutMonitor(_ type: ProcessType) {
        self.stopTimeoutMonitor()
        
        // setting timeinterval of process
        var interval: DispatchTime = .now()
        switch type {
        case .None:
            print("The Process Type should be set for checking the process")
        case .Searching:
            interval = .now() + PROCESS_SEARCHING_INTERVAL
        case .Connecting, .Preparing:
            interval = .now() + PROCESS_CONNECION_INTERVAL
        case .connected:
            return
        }
        
        self.processTask = DispatchWorkItem { self.checkTimeoutMonitor() }
        DispatchQueue.main.asyncAfter(deadline: interval, execute: self.processTask!)
    }
    
    private func stopTimeoutMonitor() {
        if self.processTask != nil {
            if self.processTask?.isCancelled == false {
                self.processTask?.cancel()
            }
            
            self.processTask = nil
        }
    }
    
    private func checkTimeoutMonitor() {
        self.stopTimeoutMonitor()
        
        guard let delegate = self.m_delegate else { return }
        
        switch self.procType {
        case .Searching:
            self.stopScan()
            delegate.centralClientSearchFinish()
        case .Connecting:
            self.disconnect()
            delegate.centralClientDidConnectFail(self, msg: "failed to connect the device")
        default:
            break
        }
    }
}

// for Start Connection
extension iBTManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        isBluetoothActive = false
        
        switch central.state {
        case .poweredOn:
            print("Bluetooth is powered ON")
            isBluetoothActive = true
            // Create the service Information
            if (m_delegate != nil) { m_delegate?.centralClientUpdateState(central) }
        case .poweredOff:
            print("Bluetooth is powered OFF")
            if (m_delegate != nil) { m_delegate?.centralClientUpdateState(central) }
        case .unsupported:
            print("Bluetooth is not support")
            if (m_delegate != nil) { m_delegate?.centralClientUpdateState(central) }
        case .unauthorized:
            print("Bluetooth is not authorized")
            if (m_delegate != nil) { m_delegate?.centralClientUpdateState(central) }
        case .unknown:
            print("unknown State")
            if (m_delegate != nil) { m_delegate?.centralClientUpdateState(central) }
        default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("didDisconnectPeripheral is called")
        
        if self.connectedbt != nil {
            self.connectedbt = nil
        }
        
        if self.connectedPeri != nil {
            self.connectedPeri = nil
        }
        
        self.isConnected = false
        
        // release the timer
        iDeviceManager.shared.operateTimer(false)
        
        if m_delegate != nil {
            self.m_delegate?.centralClientDidDisconnect(true)
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //bprint("didDiscover is called")
        stopTimeoutMonitor()
        
        for peri in searchedbt! {
            if peri.periUUID == peripheral.identifier.uuidString {
                //bprint("This device has been already searched!")
                return
            }
        }

        // ================================================================================================================ by isens
        // if devices do not have the name information, we do not permit the connection by David 2021.05.27
        guard let nameInfo = advertisementData["kCBAdvDataLocalName"] else {
            return
        }
        // ================================================================================================================ by isens
        
        var searched: btInfo = btInfo()
        searched.isConnected = false
        searched.periName = nameInfo as? String
        searched.periUUID = peripheral.identifier.uuidString
        searched.periRSSI = RSSI.intValue
        searched.advertise = advertisementData
        searched.mainPeripheral = peripheral
        
        if (searched.periName != nil && searched.periName != "") {
            var str: String = "\n"
            str += "==========================================\n"
            str += "Name : \(String(describing: searched.periName))\n"
            str += "UUID : \(String(describing: searched.periUUID))\n"
            str += "RSSI : \(String(describing: searched.periRSSI))\n"
            //str += "Advertise : \(String(describing: searched.advertise))\n"
            if let uuids = advertisementData["kCBAdvDataServiceUUIDs"] as? [CBUUID] {
                for uuid in uuids {
                    str += "spec : \(uuid) - \(uuid.uuidString)\n"
                }
            }
            
            str += "=========================================="
            print("\(str)")
            
            searchedbt?.append(searched)
            searchedPeri?.append(peripheral)
            
            if m_delegate != nil {
                m_delegate?.centralClientSearched(searched)
            }
        }
        
        startTimeoutMonitor(.Searching)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        self.stopTimeoutMonitor()
        self.stopScan()
        
        for peri in searchedbt! {
            if peri.periUUID == peripheral.identifier.uuidString {
                self.connectedbt = peri
            }
        }
        
        if self.connectedbt != nil && (self.connectedbt?.periUUID!.count)! > 0 {
            // the device has been connected
            self.connectedbt?.isConnected = true
            
            // ================================================================================================================ by isens
            
            
            self.startTimeoutMonitor(.Connecting)
            
            // saved connected peripherals for using device manager or UI setting
            connectedPeri = peripheral
            connectedPeri?.delegate = self
            
            // transfer the current central manager to device manager
            iDeviceManager.shared.setCurrentPeripheral(self.currManager)
            
            // find BLE Service of device
            _ = self.findService()
            
            self.isConnected = true
            // ================================================================================================================ by isens
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
        
        if self.connectedbt != nil {
            self.connectedbt = nil
        }
        
        // ================================================================================================================ by isens
        if m_delegate != nil {
            self.m_delegate?.centralClientDidDisconnect(false)
        }
        // ================================================================================================================ by isens
    }
}

// after Connection
extension iBTManager: CBPeripheralDelegate {
    
    // discover the services
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            // Error!!!
            
            self.disconnect(self.connectedbt)
            
            if m_delegate != nil {
                m_delegate?.centralClientDidConnectFail(self, msg: String(describing: error))
            }
        }
        
        // ================================================================================================================ by isens
        // Find Chracteristics
        self.startTimeoutMonitor(.Preparing)
        let bCheck = self.findCharacteristics()
        if bCheck == false {
            // make disconnect
            self.disconnect(self.connectedbt)
        }
        // ================================================================================================================ by isens
    }
    
    // discover the chracteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let chars = service.characteristics, self.connectedPeri != nil else { return }
        if chars.count > 0 {
            for ch in chars {
                // ================================================================================================================ by isens
                // saveing the searched characteristics for request Notification or Updated Data
                iDeviceManager.shared.connectedChars![ch.uuid.uuidString] = ch
                
                if ch.uuid.uuidString == charDeviceManufacturer {
                    // Manufacture name
                    self.startTimeoutMonitor(.Preparing)
                    self.connectedChar = ch
                    iDeviceManager.shared.reqManufacture(self.connectedPeri)
                }
                // ================================================================================================================ by isens
            }
        }
    }
    
    // check the write data
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let e = error as NSError? {
            print("Error : \(e), Description : \(e.userInfo.description)")
            
            if e.domain == CBATTErrorDomain {
                self.disconnect(self.connectedbt)
                return
            }
        }
    }
    
    // Notification Received
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        self.stopTimeoutMonitor()
        
        if let e = error as NSError? {
            print("Error : \(e), Description : \(e.userInfo.description)")
            
            if e.domain == CBATTErrorDomain {
                self.disconnect(self.connectedbt)
                return
            }
        }
        
        // ================================================================================================================ by isens
        // After received Notification, do check the data on the device manager
        print("didUpdateNotificationStateFor : \(String(describing: characteristic.value))")
        self.startTimeoutMonitor(.Preparing)
        self.connectedChar = characteristic
        iDeviceManager.shared.receivedNotification(peripheral, ch: characteristic)
        // ================================================================================================================ by isens
    }
    
    // Data Received
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let e = error as NSError? {
            print("Error : \(e), Description : \(e.userInfo.description)")
            
            if e.domain == CBATTErrorDomain {
                self.disconnect(self.connectedbt)
            }
            
            return
        }
        
        // ================================================================================================================ by isens
        // After received update value, do check the data on the device manager
        //print("didUpdateValueFor : \(String(describing: characteristic.value))")
        self.connectedChar = characteristic
        iDeviceManager.shared.receivedData(peripheral, ch: characteristic)
        // ================================================================================================================ by isens
    }
}
