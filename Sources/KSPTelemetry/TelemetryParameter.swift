//
//  TelemetryParameter.swift
//  KSPDataRecorder
//
//  Created by Mike Muszynski on 7/28/17.
//  Copyright © 2017 Mike Muszynski. All rights reserved.
//

import Foundation

public enum TelemetryParameter: String, Hashable, Codable {
    case packetType
    case unixEpochTime
    
    //These are the parameters as they exist in the KSPUDPConnection.h file
    case universeTime
    
    //orbital definition elements
    case semiMajorAxis
    case eccentricity
    case argumentOfPeriapsis
    case longitudeOfAscendingNode
    case meanAnomaly
    case inclination
    case epoch
    case centralBodyRadius
    case centralBodyGravitationalParameter
    
    //other orbital elements
    //K_ORBITALVELOCITY has been named orbitalSpeed
    case apoapsisRadius
    case periapsisRadius
    case apoapsisAltitude
    case periapsisAltitude
    case orbitalSpeed
    case trueAnomaly
    case eccentricAnomaly
    case orbitalPeriod
    case timeToAp
    case timeToPe
    
    //surface elements
    case altitude
    case heightFromTerrain
    case surfaceVelocityX
    case surfaceVelocityY
    case surfaceVelocityZ
    case verticalSpeed
    case latitude
    case longitude
    
    //orientation elements
    case shipUpAxisX
    case shipUpAxisY
    case shipUpAxisZ
    case orientationQuaternionX
    case orientationQuaternionY
    case orientationQuaternionZ
    case orientationQuaternionW
    case progradeX
    case progradeY
    case progradeZ
    case translatedProgradeVector
    
    //ship state
    case throttle
    case fuelRemaining
    case fuelCapacity
    case rcsRemaining
    case rcsCapacity
    case powerRemaining
    case powerCapacity
    case isRCSactive
    case isSASactive
    
    //countdown timer
    case currentCountdownTime
    case isCountdownTimerRunning
    
    public func parseValue(fromCsvString string: String) -> Any? {
        switch self {
        case .packetType:
            return Int(string)
        default:
            return Float(string)
        }
    }
    
    public static var graphableParameters: [TelemetryParameter] {
        return [.universeTime,
                .semiMajorAxis,
                .eccentricity,
                .argumentOfPeriapsis,
                .longitudeOfAscendingNode,
                .meanAnomaly,
                .inclination,
                .periapsisRadius,
                .periapsisAltitude,
                .apoapsisRadius,
                .apoapsisAltitude,
                .altitude,
                .heightFromTerrain,
                .verticalSpeed,
                .latitude,
                .longitude]
    }
}
