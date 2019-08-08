//
//  AppearLogger.swift
//  Appear
//
//  Created by Magnus Tviberg on 05/08/2019.
//

import Foundation

class AppearLogger {
    
    private var date: Date!
    private var formatter: DateFormatter!
    
    init() {
        date = Date()
        formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
    }
    
    func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        guard let options = AppearApp.debugOptions else { return }
        guard !options.contains(.hideInfoLogging) else { return }
        let output = items.map { "Appear <INFO> [\(formatter.string(from: date))] \($0)" }.joined(separator: separator)
        Swift.print(output, terminator: terminator)
    }
    
    func debugPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        guard let options = AppearApp.debugOptions else { return }
        guard options.contains(.enableDebugging) else { return }
        let output = items.map { "Appear <DEBUG> [\(formatter.string(from: date))] \($0)" }.joined(separator: separator)
        Swift.print(output, terminator: terminator)
    }
    
    func warningPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        let output = items.map { "Appear <WARNING> [\(formatter.string(from: date))] \($0)" }.joined(separator: separator)
        Swift.print(output, terminator: terminator)
    }
    
    func errorPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        let output = items.map { "Appear <ERROR> [\(formatter.string(from: date))] \($0)" }.joined(separator: separator)
        Swift.print(output, terminator: terminator)
    }
    
    func fatalErrorPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") -> Never{
        let output = items.map { "Appear <ERROR> [\(formatter.string(from: date))] \($0)" }.joined(separator: separator)
        Swift.print(output, terminator: terminator)
        fatalError()
    }
}
