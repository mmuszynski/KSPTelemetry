//
//  File.swift
//  
//
//  Created by Mike Muszynski on 11/17/20.
//

import Foundation

public struct TelemetryPacket: Codable, Equatable {
    
    public var packetType: Int32 = 0
    public var unixTime: Int32 = 0
    
    public var keys: [TelemetryKey] {
        return Array(floatValues.keys)
    }
    public var sortedKeys: [TelemetryKey] = []
    private mutating func sortKeys() {
        self.sortedKeys = keys.sorted(by: { $0.rawValue > $1.rawValue })
    }
    
    private var floatValues: [TelemetryKey : Float] = [:]
    
    public subscript(_ key: TelemetryKey) -> Float? {
        get {
            return floatValues[key]
        }
        set {
            floatValues[key] = newValue
            self.sortKeys()
        }
    }
}
