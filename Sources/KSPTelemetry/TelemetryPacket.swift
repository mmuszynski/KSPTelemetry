//
//  File.swift
//  
//
//  Created by Mike Muszynski on 11/17/20.
//

import Foundation
import Keplerian

@available(*, unavailable, renamed: "TelemetryPacket")
public struct TelemetryDictionary { }

public struct TelemetryPacket: Codable, Equatable {
    
    static public var exampleDataHex = "0000000f4a8e4a5b48034abe3ed44cfd3fa1551e409230ce4298303c43887b2b476a60004ed27ff100000000437f00000000000042b400004248000042480000401dc29842b60071c2b2c99b410a8ac841361c4d479462f442356cdf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
    static public var exampleData: Data = Data(hexString: TelemetryPacket.exampleDataHex)
    static public var examplePacket: TelemetryPacket = try! TelemetryPacket(with: TelemetryPacket.exampleData)
    
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
    
    public var orbit: Orbit? {
        guard let semiMajorAxis = self[.semiMajorAxis],
              let eccentricity = self[.eccentricity],
              let meanAnomaly = self[.meanAnomaly],
              let inclination = self[.inclination],
              let LAN = self[.longitudeOfAscendingNode],
              let argumentOfPeriapsis = self[.argumentOfPeriapsis],
              let centralBody = CelestialBody.allKSPBodies.first(where: { body in
                  guard let radius = self[.centralBodyRadius] else { return false }
                  return Float(body.radius) == radius
              })
        else {
            return nil
        }
        
        let orbit = Orbit(semiMajorAxis: Double(semiMajorAxis),
                          eccentricity: Double(eccentricity),
                          meanAnomaly: Double(meanAnomaly),
                          inclination: Double(inclination),
                          LAN: Double(LAN),
                          argumentOfPeriapsis: Double(argumentOfPeriapsis),
                          centralBody: centralBody)
        
        // Note that KSP uses universe time as epoch for orbits
        orbit.epoch = Double(self[.universeTime] ?? 0)
        return orbit
    }
    
    private init() {}
    
    public init(with packet: Data) throws {
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
