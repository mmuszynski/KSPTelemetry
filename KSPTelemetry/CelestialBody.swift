//
//  CelestialBody.swift
//  KSPCockpitPanel
//
//  Created by Mike Muszynski on 7/22/17.
//  Copyright © 2017 Mike Muszynski. All rights reserved.
//

import Foundation

public struct CelestialBody {
    public var gravitationalParameter: Double
    public var radius: Double
    
    public init(gravitationalParameter: Double, radius: Double) {
        self.gravitationalParameter = gravitationalParameter
        self.radius = radius
    }
    
    public init(gravitationalParameter: Float, radius: Float) {
        self.gravitationalParameter = Double(gravitationalParameter)
        self.radius = Double(radius)
    }
}
