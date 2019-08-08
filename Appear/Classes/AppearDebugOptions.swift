//
//  AppearDebugOptions.swift
//  Appear
//
//  Created by Magnus Tviberg on 07/08/2019.
//

import Foundation

public struct AppearDebugOptions: OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let enableDebugging = AppearDebugOptions(rawValue: 1)
    public static let hideInfoLogging = AppearDebugOptions(rawValue: 2)
    
}
