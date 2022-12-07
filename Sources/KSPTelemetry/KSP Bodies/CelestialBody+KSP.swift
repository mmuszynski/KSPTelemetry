//
//  CelestialBody+KSP.swift
//  Keplerian
//
//  Created by Mike Muszynski on 5/29/20.
//  Copyright © 2020 Mike Muszynski. All rights reserved.
//

import Foundation
import Keplerian

extension CelestialBody {
    public static var kerbol = CelestialBody(gravitationalParameter: 1.1723328e18, radius: 261600000, mass: 1.7565459e28)
    
    public static var moho = CelestialBody(gravitationalParameter: 1.6860938e11, radius: 250000, mass: 2.5263314e21, orbit: .moho)
    
    public static var eve = CelestialBody(gravitationalParameter: 8.1717302e12, radius: 700000, mass: 1.2243980e23, orbit: .eve)

    public static var kerbin = CelestialBody(gravitationalParameter: 3.5316000e12, radius: 6e5, mass: 5.2915158e22, orbit: .kerbin)
    public static var mun = CelestialBody(gravitationalParameter: 6.5138398e10, radius: 2e5, mass: 9.7599066e20, orbit: .mun)
    public static var minmus = CelestialBody(gravitationalParameter: 1.7658000e9, radius: 6e5, mass: 2.6457580e19, orbit: .minmus)
    
    public static var duna = CelestialBody(gravitationalParameter: 3.0136321e11, radius: 320000, mass: 4.5154270e21, orbit: .duna)
    
    public static var jool = CelestialBody(gravitationalParameter: 2.8252800e14, radius: 6000000, mass: 4.2332127e24, orbit: .jool)
    
    public static var dres = CelestialBody(gravitationalParameter: 2.1484489e10, radius: 138000, mass: 3.2190937e20, orbit: .dres)
    
    public static var eeloo = CelestialBody(gravitationalParameter: 7.4410815e10, radius: 210000, mass: 1.1149224e21, orbit: .eeloo)
}
