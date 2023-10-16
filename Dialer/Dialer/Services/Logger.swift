//
//  Logger.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 01/03/2023.
//

import Foundation
import OSLog

enum Log {

    static func add(_ message: StaticString, file: String = #file, dso: UnsafeRawPointer? = #dsohandle, log: OSLog = .default, type: OSLogType = .default, _ args: CVarArg...) {
        // 1. log the message using OSLog
         os_log(message, dso: dso, log: log, type: type, args)
        let filename = String(file.split(separator: "/").last ?? "")
        let formatter = DateFormatter(format: "MM/dd/yyyy HH:mm")
        let logs: [String : Any] = [
            "date": formatter.string(from: Date()),
            "message": "\(message)",
            "args": "\(args)",
            "file": filename
        ]
        // 2. log an event depending on
        if !AppConfiguration.isDebug {
            let logType: LogEvent = type == .error ? .error : .debugInfo
            Tracker.shared.logEvent(name: logType, parameters: logs)
        }
    }
    
    static func debug(_ items: Any...) {
        guard AppConfiguration.isDebug else { return }
        debugPrint(items)
    }
}
