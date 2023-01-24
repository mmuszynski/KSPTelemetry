//
//  File.swift
//  
//
//  Created by Mike Muszynski on 1/10/23.
//

import Foundation
import simd

///Contains information about the state of the vessel, decoded from the telemetry
public struct VesselState: Codable, Equatable, Hashable {
    public var isRCSActive: Bool = false
    public var isSASActive: Bool = false
    
    public var fuelCapacity: Float = 0
    public var fuelRemaining: Float = 0
    public var rcsCapacity: Float = 0
    public var rcsRemaining: Float = 0
    public var powerCapacity: Float = 0
    public var powerRemaining: Float = 0
    
    public var upDirection: simd_float3?
    public var position: simd_float3?
    public var forwardDirection: simd_float3?
    
    public var targetUpDirection: simd_float3?
    public var targetPosition: simd_float3?
    public var targetForwardDirection: simd_float3?
}
