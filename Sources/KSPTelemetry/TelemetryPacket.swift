//
//  File.swift
//  
//
//  Created by Mike Muszynski on 11/17/20.
//

import Foundation

@available(*, unavailable, renamed: "TelemetryPacket")
public struct TelemetryDictionary { }

public struct TelemetryPacket: Codable, Equatable {
    
    public var packetType: Int32 = 0
    public var unixTime: Int32 = 0
    
    public var keys: [TelemetryKey] {
        return Array(floatValues.keys)
    }
    
    private var floatValues: [TelemetryKey : Float] = [:]
    
    public subscript(_ key: TelemetryKey) -> Float? {
        get {
            return floatValues[key]
        }
        set {
            floatValues[key] = newValue
        }
    }
}
