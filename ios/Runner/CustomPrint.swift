//
//  App Extension
//
//  Created by David on 2019/05/18.
//

import Foundation

public let DEFINE_SHOW_ALL_LOG: Int = 1
public let DEFINE_NETWORK_MESSAGE: Int = 0     // print option for network
public let DEFINE_SOCKET_MESSAGE: Int = 0      // print message for Socket network
public let DEFINE_UI_MESSAGE: Int = 0          // print option for UI refresh
public let DEFINE_DATA_MESSAGE: Int = 0        // print option for Data check
public let DEFINE_BLUETOOTH_MESSAGE: Int = 0   // print option for Bluetooth check


// print Extension - for Network
public func nprint(_ items: Any..., separator : String = " ", terminator: String = "\n", fName:String = #file, funcName:String = #function, lNumner:Int = #line) {
    let cName = (fName as NSString).lastPathComponent
    let output = items.map {"\($0)"}.joined(separator: separator)
    
    if (DEFINE_NETWORK_MESSAGE == 1 || DEFINE_SHOW_ALL_LOG == 1) {
        Swift.print("nprint : [\(cName):\(lNumner)] <\(funcName)> is called -> \(output)", terminator:terminator)
    }
}

// print message for Socket Network
public func sprint(_ items: Any..., separator : String = " ", terminator: String = "\n", fName:String = #file, funcName:String = #function, lNumner:Int = #line) {
    let cName = (fName as NSString).lastPathComponent
    let output = items.map {"\($0)"}.joined(separator: separator)
    
    if (DEFINE_SOCKET_MESSAGE == 1 || DEFINE_SHOW_ALL_LOG == 1) {
        Swift.print("sprint : [\(cName):\(lNumner)] <\(funcName)> is called -> \(output)", terminator:terminator)
    }
}

// print Extension - for UI refresh
public func uprint(_ items: Any..., separator : String = " ", terminator: String = "\n", fName:String = #file, funcName:String = #function, lNumner:Int = #line) {
    let cName = (fName as NSString).lastPathComponent
    let output = items.map {"\($0)"}.joined(separator: separator)
    
    if (DEFINE_UI_MESSAGE == 1 || DEFINE_SHOW_ALL_LOG == 1) {
        Swift.print("uprint : [\(cName):\(lNumner)] <\(funcName)> is called ->  \(output)", terminator:terminator)
    }
}

// print Extension - for Data check
public func dprint(_ items: Any..., separator : String = " ", terminator: String = "\n", fName:String = #file, funcName:String = #function, lNumner:Int = #line) {
    let cName = (fName as NSString).lastPathComponent
    let output = items.map {"\($0)"}.joined(separator: separator)
    
    if (DEFINE_DATA_MESSAGE == 1 || DEFINE_SHOW_ALL_LOG == 1) {
        Swift.print("dprint : [\(cName):\(lNumner)] <\(funcName)> is called -> \(output)", terminator:terminator)
    }
}

// print Extension - for Bluetooth check
public func bprint(_ items: Any..., separator : String = " ", terminator: String = "\n", fName:String = #file, funcName:String = #function, lNumner:Int = #line) {
    let cName = (fName as NSString).lastPathComponent
    let output = items.map {"\($0)"}.joined(separator: separator)
    
    if (DEFINE_BLUETOOTH_MESSAGE == 1 || DEFINE_SHOW_ALL_LOG == 1) {
        //Swift.print("bprint : [\(cName):\(lNumner)] <\(funcName)> is called -> \(output)", terminator:terminator)
        Swift.print(items)
    }
}
