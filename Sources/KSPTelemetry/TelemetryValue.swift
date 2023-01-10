//
//  File.swift
//  
//
//  Created by Mike Muszynski on 11/17/20.
//

import Foundation

public protocol TelemetryValue: Codable {}

extension Bool: TelemetryValue {}
extension Int: TelemetryValue {}
extension Int8: TelemetryValue {}
extension Int16: TelemetryValue {}
extension Int32: TelemetryValue {}
extension Int64: TelemetryValue {}
extension Float: TelemetryValue {}
extension Double: TelemetryValue {}
