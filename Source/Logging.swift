// The MIT License (MIT)
//
// Copyright (c) 2017 Polidea
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import CoreBluetooth

/**
 RxBluetoothKit specific logging class which gives access to its settings.
 */
public class RxBluetoothKitLog {

    fileprivate static var currentLogLevel: LogLevel = .none

    private init() {
    }

    /// Log levels for internal logging mechanism.
    public enum LogLevel: UInt8 {
        /// Logging is disabled
        case none = 255
        /// All logs are monitored.
        case verbose = 0
        /// Only debug logs and of higher importance are logged.
        case debug = 1
        /// Only info logs and of higher importance are logged.
        case info = 2
        /// Only warning logs and of higher importance are logged.
        case warning = 3
        /// Only error logs and of higher importance are logged.
        case error = 4
    }

    /**
     * Set new log level.
     * - Parameter logLevel: New log level to be applied.
     */
    public static func setLogLevel(_ logLevel: LogLevel) {
        currentLogLevel = logLevel
    }

    /**
     * Get current log level.
     * - Returns: Currently set log level.
     */
    public static func getLogLevel() -> LogLevel {
        return currentLogLevel
    }

    fileprivate static func tag(with logLevel: LogLevel) -> String {
        let prefix: String

        switch logLevel {
        case .none:
            prefix = "[RxBLEKit|NONE|"
        case .verbose:
            prefix = "[RxBLEKit|VERB|"
        case .debug:
            prefix = "[RxBLEKit|DEBG|"
        case .info:
            prefix = "[RxBLEKit|INFO|"
        case .warning:
            prefix = "[RxBLEKit|WARN|"
        case .error:
            prefix = "[RxBLEKit|ERRO|"
        }
        let time = Date().timeIntervalSinceReferenceDate
        return prefix + String(format: "%02.0f:%02.0f:%02.0f.%03.f]:",
                               floor(time / 3600.0).truncatingRemainder(dividingBy: 24),
                               floor(time / 60.0).truncatingRemainder(dividingBy: 60),
                               floor(time).truncatingRemainder(dividingBy: 60),
                               floor(time * 1000).truncatingRemainder(dividingBy: 1000))
    }

    fileprivate static func log(with logLevel: LogLevel, message: @autoclosure () -> String) {
        if currentLogLevel <= logLevel {
            print(tag(with: logLevel), message())
        }
    }

    static func v(_ message: @autoclosure () -> String) {
        log(with: .verbose, message: message)
    }

    static func d(_ message: @autoclosure () -> String) {
        log(with: .debug, message: message)
    }

    static func i(_ message: @autoclosure () -> String) {
        log(with: .info, message: message)
    }

    static func w(_ message: @autoclosure () -> String) {
        log(with: .warning, message: message)
    }

    static func e(_ message: @autoclosure () -> String) {
        log(with: .error, message: message)
    }
}

extension RxBluetoothKitLog.LogLevel: Comparable {
    public static func < (lhs: RxBluetoothKitLog.LogLevel, rhs: RxBluetoothKitLog.LogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    public static func <= (lhs: RxBluetoothKitLog.LogLevel, rhs: RxBluetoothKitLog.LogLevel) -> Bool {
        return lhs.rawValue <= rhs.rawValue
    }

    public static func > (lhs: RxBluetoothKitLog.LogLevel, rhs: RxBluetoothKitLog.LogLevel) -> Bool {
        return lhs.rawValue > rhs.rawValue
    }

    public static func >= (lhs: RxBluetoothKitLog.LogLevel, rhs: RxBluetoothKitLog.LogLevel) -> Bool {
        return lhs.rawValue >= rhs.rawValue
    }

    public static func == (lhs: RxBluetoothKitLog.LogLevel, rhs: RxBluetoothKitLog.LogLevel) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

protocol Loggable {
    var logDescription: String { get }
}

extension Data: Loggable {
    var logDescription: String {
        return map { String(format: "%02x", $0) }.joined()
    }
}

extension BluetoothState: Loggable {
    var logDescription: String {
        switch self {
        case .unknown: return "unknown"
        case .resetting: return "resetting"
        case .unsupported: return "unsupported"
        case .unauthorized: return "unauthorized"
        case .poweredOff: return "poweredOff"
        case .poweredOn: return "poweredOn"
        }
    }
}

extension CBCentralManager: Loggable {
    @objc var logDescription: String {
        return "CentralManager(\(UInt(bitPattern: ObjectIdentifier(self))))"
    }
}

extension CBPeripheralManager: Loggable {
    @objc var logDescription: String {
        return "PeripheralManager(\(UInt(bitPattern: ObjectIdentifier(self))))"
    }
}

extension CBPeripheral: Loggable {
    @objc var logDescription: String {
        return "Peripheral(uuid: \(value(forKey: "identifier") as! NSUUID as UUID), name: \(String(describing: name)))"
    }
}

extension CBCharacteristic: Loggable {
    @objc var logDescription: String {
        return "Characteristic(uuid: \(uuid), id: \((UInt(bitPattern: ObjectIdentifier(self)))))"
    }
}

extension CBService: Loggable {
    @objc var logDescription: String {
        return "Service(uuid: \(uuid), id: \((UInt(bitPattern: ObjectIdentifier(self)))))"
    }
}

extension CBDescriptor: Loggable {
    @objc var logDescription: String {
        return "Service(uuid: \(uuid), id: \((UInt(bitPattern: ObjectIdentifier(self)))))"
    }
}

extension CBATTRequest: Loggable {
    @objc var logDescription: String {
        return """
               ATTRequest(characteristic: \(characteristic.logDescription),
               offset: \(offset)
               id: \((UInt(bitPattern: ObjectIdentifier(self)))))
               """
    }
}

extension Array where Element: Loggable {
    var logDescription: String {
        return "[\(map { $0.logDescription }.joined(separator: ", "))]"
    }
}
