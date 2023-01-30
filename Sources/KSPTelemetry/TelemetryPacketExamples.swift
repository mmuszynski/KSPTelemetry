//
//  File.swift
//  
//
//  Created by Mike Muszynski on 1/29/23.
//

import Foundation
import simd

extension TelemetryPacket {
    
    public static var trivialDockingExample: TelemetryPacket {
        let state = VesselState(isRCSActive: true,
                                isSASActive: true,
                                fuelCapacity: 100,
                                fuelRemaining: 100,
                                rcsCapacity: 100,
                                rcsRemaining: 100,
                                powerCapacity: 100,
                                powerRemaining: 100,
                                upDirection: simd_normalize(simd_float3(1, 0, 0)),
                                position: simd_float3(0,0,0),
                                forwardDirection: simd_normalize(simd_float3(0, 1, 0)),
                                targetUpDirection: simd_float3(-1, 0, 0),
                                targetPosition: simd_float3(-1,0,0),
                                targetForwardDirection: simd_normalize(simd_float3(0, -1, 0)))
        var packet = examplePacket
        packet.vesselState = state
        return packet
    }
    
}
