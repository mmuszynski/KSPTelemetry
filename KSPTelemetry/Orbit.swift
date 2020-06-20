//
//  Orbit.swift
//  KSPCockpitPanel
//
//  Created by Mike Muszynski on 7/22/17.
//  Copyright © 2017 Mike Muszynski. All rights reserved.
//

import Foundation

public class Orbit: CustomDebugStringConvertible {
    public var debugDescription: String {
        let sma = String(describing: semiMajorAxis)
        let ecc = String(describing: eccentricity)
        let meA = String(describing: meanAnomaly)
        let inc = String(describing: inclination)
        let lan = String(describing: LAN)
        let arg = String(describing: argumentOfPeriapsis)
        
        var string = "semiMajorAxis: " + sma + "\r"
        string += "eccentricity: " + ecc + "\r"
        string += "meanAnomaly: " + meA + "\r"
        string += "inclination: " + inc + "\r"
        string += "LAN: " + lan + "\r"
        string += "argumentOfPeriapsis: " + arg + "\r"
        string += "bodyRadius: " + String(describing: centralBody.radius) + "\r"
        string += "bodyGravParameter: " + String(describing: centralBody.gravitationalParameter)

        return string
    }
    
    public class var testEscapeOrbit: Orbit {
        let mun = CelestialBody(gravitationalParameter: 65138397184.0, radius: 2e6)
        let orbit = Orbit(semiMajorAxis: -944427.0625, eccentricity: 1.22502624988556, meanAnomaly: 0.196598216891289, inclination: 0.129754841327667, LAN: 162.380401611328, argumentOfPeriapsis: 356.085906982422, centralBody: mun)
        return orbit
    }
    
    //The Keplerian Orbital elements
    public var semiMajorAxis: Double
    public var eccentricity: Double
    public var meanAnomaly: Double
    public var inclination: Double
    public var LAN: Double
    public var argumentOfPeriapsis: Double
    
    public var centralBody: CelestialBody
    
    public var isSubOrbital: Bool {
        return self.semiMajorAxis < self.centralBody.radius
    }
    
    public var isEscapeOrbit: Bool {
        return self.eccentricity >= 1.0
    }
    
    /// Initializes an `Orbit` with the prescribed Keplerian orbital elements
    ///
    /// - Parameters:
    ///   - semiMajorAxis: The semi-major axis of the orbit
    ///   - eccentricity: The eccentricity of the orbit
    ///   - meanAnomaly: The mean anomaly of the orbot
    ///   - inclination: The inclination of the orbit
    ///   - LAN: The longitude of ascending node of the orbit
    ///   - argumentOfPeriapsis: The argument of periapsis of the orbit
    public init(semiMajorAxis: Double, eccentricity: Double, meanAnomaly: Double, inclination: Double, LAN: Double, argumentOfPeriapsis: Double, centralBody: CelestialBody) {
        self.semiMajorAxis = semiMajorAxis
        self.eccentricity = eccentricity
        self.meanAnomaly = meanAnomaly <= 0 ? meanAnomaly + 2.0 * Double.pi : meanAnomaly
        self.inclination = inclination
        self.LAN = LAN
        self.argumentOfPeriapsis = argumentOfPeriapsis
        
        self.centralBody = centralBody
    }
    
    public convenience init(semiMajorAxis: Float, eccentricity: Float, meanAnomaly: Float, inclination: Float, LAN: Float, argumentOfPeriapsis: Float, centralBody: CelestialBody) {
        self.init(semiMajorAxis: Double(semiMajorAxis),
                  eccentricity: Double(eccentricity),
                  meanAnomaly: Double(meanAnomaly),
                  inclination: Double(inclination),
                  LAN: Double(LAN),
                  argumentOfPeriapsis: Double(argumentOfPeriapsis),
                  centralBody: centralBody)
    }
    
    /// The maximum distance from the center of mass of the body that is being orbited
    public var apoapsis: Double {
        return (1 + eccentricity) * semiMajorAxis
    }
    
    /// The minimum distance from the center of mass of the body that is being orbited
    public var periapsis: Double {
        return (1 - eccentricity) * semiMajorAxis
    }
    
    public var periapsisAltitude: Double {
        return periapsis - centralBody.radius
    }
    
    public var apoapsisAltitude: Double {
        return apoapsis - centralBody.radius
    }
    
    public func altitude(atTimeFromEpoch time: Double = 0) -> Double {
        return radius(atTimeFromEpoch: time) - centralBody.radius
    }
    
    public var semiMinorAxis: Double {
        return semiMajorAxis * sqrt(1.0 - eccentricity * eccentricity)
    }
    
    public var meanMotion: Double {
        let gm = centralBody.gravitationalParameter
        return sqrt(gm / pow(semiMajorAxis, 3))
    }
    
    public var period: Double {
        let gm = centralBody.gravitationalParameter
        return 2.0 * Double.pi * sqrt(pow(semiMajorAxis, 3) / gm)
    }
    
    public func meanAnomaly(atTimeFromEpoch time: Double = 0) -> Double {
        var meanAnomalyAtTime = self.meanMotion * time + meanAnomaly;
        while meanAnomalyAtTime > (2.0 * Double.pi) {
            meanAnomalyAtTime -= 2.0 * Double.pi
        }
        return meanAnomalyAtTime
    }
    
    public func eccentricAnomaly(fromMeanAnomaly meanAnomaly: Double) -> Double {
        let tolerance = 0.0005
        let eccentricity = self.eccentricity
        
        //need to solve M=E-e\sin E for E
        
        let M = meanAnomaly
        
        var E: Double
        if (eccentricity < 0.8 ) {
            E = meanAnomaly
        } else {
            E = Double.pi
        }
        
        var delta = Double.greatestFiniteMagnitude
        
        while abs(delta) > tolerance {
            delta = (M - E + eccentricity * sin(E)) / (1 - eccentricity * cos(E))
            E = E + delta
        }
        
        return E
    }
    
    public func eccentricAnomaly(atTimeFromEpoch time: Double = 0) -> Double {
        let meanAnomaly = self.meanAnomaly(atTimeFromEpoch: time)
        let eccentricAnomaly = self.eccentricAnomaly(fromMeanAnomaly: meanAnomaly)
        
        return eccentricAnomaly
    }
    
    public func trueAnomaly(atTimeFromEpoch time: Double = 0) -> Double {
        let E = self.eccentricAnomaly(atTimeFromEpoch: time)
        let ecc = eccentricity

        let numerator = cos(E) - ecc
        let denominator = 1 - ecc * cos(E)
        
        return acos(numerator/denominator)
        
    }
    
    public func radius(atTimeFromEpoch time: Double = 0) -> Double {
        let trueAnomaly = self.trueAnomaly(atTimeFromEpoch: time)
        return semiMajorAxis * (1 - eccentricity * eccentricity) / (1 + eccentricity * cos(trueAnomaly))
    }
    
    public func orbitalSpeed(atTimeFromEpoch time: Double = 0) -> Double {
        let gm = centralBody.gravitationalParameter
        let radius = self.radius(atTimeFromEpoch: time)
        return sqrt(gm * (2.0 / radius - 1 / self.semiMajorAxis))
    }
    
    public func timeToApoapsis(atTimeFromEpoch time: Double = 0) -> Double {
        let effectiveMeanAnomaly = self.meanAnomaly(atTimeFromEpoch: time)
        var target = Double.pi
        if effectiveMeanAnomaly > target {
            target += 2.0 * Double.pi
        }
        
        let meanAnomalyFractionRemaining = (target - effectiveMeanAnomaly) / (2.0 * Double.pi)
        let period = self.period
        
        return period * meanAnomalyFractionRemaining
    }
    
    public func timeToPeriapsis(atTimeFromEpoch time: Double = 0) -> Double {
        let effectiveMeanAnomaly = self.meanAnomaly(atTimeFromEpoch: time)
        
        let meanAnomalyFractionRemaining = (2.0 * Double.pi - effectiveMeanAnomaly) / (2.0 * Double.pi)
        let period = self.period
        
        return period * meanAnomalyFractionRemaining
    }
    
    
}
