//
//  Orbit+KSP.swift
//  Keplerian
//
//  Created by Mike Muszynski on 5/29/20.
//  Copyright © 2020 Mike Muszynski. All rights reserved.
//

import Foundation
import Keplerian

private extension Double {
    var deg2rad: Double {
        return self * .pi / 180
    }
}

extension Orbit {
    public static var moho = Orbit(semiMajorAxis: 5263138304.0.meters,
                                   eccentricity: 0.2,
                                   meanAnomaly: 3.14.rad,
                                   inclination: 7.0.deg,
                                   LAN: 70.0.deg,
                                   argumentOfPeriapsis: 15.0.deg,
                                   centralBody: .kerbol)
    
    public static var eve = Orbit(semiMajorAxis: 9832684544.meters,
                                  eccentricity: 0.01,
                                  meanAnomaly: 3.14.radians,
                                  inclination: 2.1.degrees,
                                  LAN: 15.degrees,
                                  argumentOfPeriapsis: 0.degrees,
                                  centralBody: .kerbol)

    public static var kerbin = Orbit(semiMajorAxis: 13599840256,
                                     eccentricity: 0,
                                     meanAnomaly: 3.14,
                                     inclination: 0,
                                     LAN: 0,
                                     argumentOfPeriapsis: 0,
                                     centralBody: .kerbol)
    
    public static var mun = Orbit(semiMajorAxis: 1.2e7,
                                  eccentricity: 0,
                                  meanAnomaly: 1.7,
                                  inclination: 0,
                                  LAN: 0,
                                  argumentOfPeriapsis: 0,
                                  centralBody: .kerbin)
    
    public static var minmus = Orbit(semiMajorAxis: 4.7e7.meters,
                                     eccentricity: 0.0,
                                     meanAnomaly: 0.9.radians,
                                     inclination: 6.0.degrees,
                                     LAN: 78.0.degrees,
                                     argumentOfPeriapsis: 38.0.degrees,
                                     centralBody: .kerbin)
    
    public static var duna = Orbit(semiMajorAxis: 20726155264.meters,
                                   eccentricity: 0.051,
                                   meanAnomaly: 3.14.radians,
                                   inclination: 0.06.degrees,
                                   LAN: 135.5.degrees,
                                   argumentOfPeriapsis: 0.degrees,
                                   centralBody: .kerbol)
    
    public static var jool = Orbit(semiMajorAxis: 68773560320.0.meters,
                                   eccentricity: 0.05,
                                   meanAnomaly: 1.304.radians,
                                   inclination: 0.1.degrees,
                                   LAN: 52.0.degrees,
                                   argumentOfPeriapsis: 0.0.degrees,
                                   centralBody: .kerbol)
    
    public static var dres = Orbit(semiMajorAxis: 40839348203.0.meters,
                                   eccentricity: 0.145,
                                   meanAnomaly: 5.radians,
                                   inclination: 3.14.degrees,
                                   LAN: 280.degrees,
                                   argumentOfPeriapsis: 90.degrees,
                                   centralBody: .kerbol)
    
    public static var eeloo = Orbit(semiMajorAxis: 90118820000.0.meters,
                                    eccentricity: 0.26,
                                    meanAnomaly: 6.15.radians,
                                    inclination: 3.14.degrees,
                                    LAN: 50.degrees,
                                    argumentOfPeriapsis: 260.degrees,
                                    centralBody: .kerbol)
}
