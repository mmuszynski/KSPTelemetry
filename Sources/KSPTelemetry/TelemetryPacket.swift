//
//  File.swift
//  
//
//  Created by Mike Muszynski on 11/17/20.
//

import Foundation

public struct TelemetryPacket: Codable {
    
    public var packetType: Int32 = 0
    public var unixTime: Int32 = 0
    
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
