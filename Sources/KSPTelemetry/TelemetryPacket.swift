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
    
    private init() {}
    
    init(with packet: Data) throws {
        //Initialize the output dictionary and set the offset cursor position to zero
        var telemetryPacket = TelemetryPacket()
        var offset = 0
        
        //Packets will always start with a packet type
        let packetType: Int32 = try packet.decode(atOffset: &offset)
        telemetryPacket.packetType = packetType
        
        var bitfieldCheck: Int32 = 1
        
        //If the packet type is zero, then this represents a connection received packet
        //otherwise, the packet type represents a test bitfield that can represent a variety of data
        if packetType == 0 {
            //returned an acknowledgement packet
            let unixTime: Int32 = try packet.decode(atOffset: &offset)
            telemetryPacket.unixTime = unixTime
            self = telemetryPacket
        } else {
            
            let universeTime: Float = try packet.decode(atOffset: &offset)
            telemetryPacket[.universeTime] = universeTime
            
            //The first bit is for orbital data, since it is used so often
            if (packetType & bitfieldCheck) == bitfieldCheck {
                telemetryPacket[.semiMajorAxis] = try packet.decode(atOffset: &offset)
                telemetryPacket[.eccentricity] = try packet.decode(atOffset: &offset)
                telemetryPacket[.meanAnomaly] = try packet.decode(atOffset: &offset)
                telemetryPacket[.inclination] = try packet.decode(atOffset: &offset)
                telemetryPacket[.longitudeOfAscendingNode] = try packet.decode(atOffset: &offset)
                telemetryPacket[.argumentOfPeriapsis] = try packet.decode(atOffset: &offset)
                telemetryPacket[.centralBodyRadius] = try packet.decode(atOffset: &offset)
                telemetryPacket[.centralBodyGravitationalParameter] = try packet.decode(atOffset: &offset)
            }
            
            //the next check is for RCS capacity
            //and liquid fuel
            bitfieldCheck = bitfieldCheck << 1
            if (packetType & bitfieldCheck) == bitfieldCheck {
                telemetryPacket[.rcsRemaining] = try packet.decode(atOffset: &offset)
                telemetryPacket[.rcsCapacity] = try packet.decode(atOffset: &offset)
                telemetryPacket[.fuelRemaining] = try packet.decode(atOffset: &offset)
                telemetryPacket[.fuelCapacity] = try packet.decode(atOffset: &offset)
                telemetryPacket[.powerRemaining] = try packet.decode(atOffset: &offset)
                telemetryPacket[.powerCapacity] = try packet.decode(atOffset: &offset)
            }
            
            //the next check is for launch items
            bitfieldCheck = bitfieldCheck << 1
            if (packetType & bitfieldCheck) == bitfieldCheck {
                telemetryPacket[.latitude] = try packet.decode(atOffset: &offset)
                telemetryPacket[.longitude] = try packet.decode(atOffset: &offset)
            }
            
            //the next check is for surface velocity
            //currently surface velocity is screwed up, but why?
            bitfieldCheck = bitfieldCheck << 1
            if (packetType & bitfieldCheck) == bitfieldCheck {
                telemetryPacket[.surfaceVelocityX] = try packet.decode(atOffset: &offset)
                telemetryPacket[.surfaceVelocityY] = try packet.decode(atOffset: &offset)
                telemetryPacket[.surfaceVelocityZ] = try packet.decode(atOffset: &offset)
                telemetryPacket[.heightFromTerrain] = try packet.decode(atOffset: &offset)
                telemetryPacket[.verticalSpeed] = try packet.decode(atOffset: &offset)
            }
            
            self = telemetryPacket
        }
    }
}
