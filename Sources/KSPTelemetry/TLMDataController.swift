//
//  TLMDataController.swift
//  KSPCockpitPanel
//
//  Created by Mike Muszynski on 7/21/17.
//  Copyright © 2017 Mike Muszynski. All rights reserved.
//

import Foundation
import SocketWrapper

public protocol TLMDataControllerDelegate {
    func connectionDidConnect()
    func connectionDidLoseConnection()
    func remoteServerClosedConnection()
    func connectionDidReturnNewData(packet: [TLMDataController.TelemetryKey:TLMDataController.TelemetryValue])
    func connectionDidFailWithError(error: Error)
}

public class TLMDataController: NSObject {
    public typealias TelemetryKey = TelemetryParameter
    public typealias TelemetryValue = Any
    
    private let tunnelSocket = Socket(format: .udp)
    
    public static let shared = TLMDataController()
    public var ipAddress: String = "192.168.1.1"
    public var port: Int = 7000
    public var delegate: TLMDataControllerDelegate?
    public var timeout: Double = 5.0
    
    public var keepAlive = true
    private var keepAliveTime: TimeInterval = 0.0
    private var connectionExpiry: Date = Date()
    
    //Telemetry should not be accessed directly and should instead be taken from the delegate methods for thread safety
    private var telemetry = Dictionary<AnyHashable,Any>()
    
    private var listenerShouldContinue = true
    private func listenMethod() {
        //This is the listener which will be called when the background thread is initialized
        //To stop the thread and end, set self.listenerShouldContinue = false
        while self.listenerShouldContinue {
            do {
                //This is the receive method that implements recvfrom() in the blocking form
                try self.tunnelSocket.blockingReceive()
                
                if !self.isConnected {
                    //check the data message to see if the connection is received
                    let buffer = self.tunnelSocket.messageBuffer!
                    let data = Data(buffer)
                    let packet = try self.decodeTelemetry(packet: data)
                    if packet[.unixEpochTime] != nil {
                        self.isConnected = true
                        
                        DispatchQueue.main.async {
                            self.delegate?.connectionDidConnect()
                        }
                    }
                } else {
                    //The data needs to be parsed at some point and then returned as a new object
                    //Until connectionDidReturnNewData() is updated to take an argument, the data will just be ignored
                    let buffer = self.tunnelSocket.messageBuffer!
                    let data = Data(buffer)
                    let packet = try self.decodeTelemetry(packet: data)
                    
                    //This represents a connection type packet
                    //If it is connected, then it's probably a disconnection packet
                    if let time = packet[.unixEpochTime] as? Int32 {
                        self.isConnected = time > 0
                        if !self.isConnected {                            
                            DispatchQueue.main.async {
                                self.delegate?.remoteServerClosedConnection()
                            }
                            return
                        }
                    }

                    DispatchQueue.main.async {
                        self.delegate?.connectionDidReturnNewData(packet: packet)
                    }
                }
            } catch {
                print("Listen Method: \(error)")
                self.isConnected = false
                
                DispatchQueue.main.async {
                    self.delegate?.connectionDidLoseConnection()
                    self.delegate?.connectionDidFailWithError(error: ConnectionError.timeout)
                }
                return
            }
        }
    }
    
    public var isConnected = false
    
    public override init() {
        do {
            try self.tunnelSocket.open()
        } catch {
            fatalError()
        }
    }
    
    public func openConnection(until expiration: Date? = nil, atAddress newAddress: String? = nil, onPort newPort: Int? = nil) throws {
        //if the connection ip and port are set here, set them in the instance variable
        if let newAddress = newAddress {
            self.ipAddress = newAddress
        }
        
        if let newPort = newPort {
            self.port = newPort
        }
        
        if let date = expiration {
            self.connectionExpiry = date
        } else {
            self.connectionExpiry = Date().addingTimeInterval(60)
        }
        
        let seconds = self.connectionExpiry.timeIntervalSince(Date())
        let rounded = round(seconds)
        let intSeconds = Int(rounded)
        
        //set the timeout for the socket to whatever the class wants
        try tunnelSocket.setReceiveTimeout(seconds: self.timeout)
        
        //register this device with the receiver
        //currently, there are a few messages planned
        //"connect:3600" asks to be connected for 3600 seconds
        //"disconnect" asks to be disconnected
        //"continuous" asks for a continuous connection. not sure if this will be robust enough
        //"debug" asks for one message to be sent back
        let message = "connect:\(intSeconds)"
        try tunnelSocket.send(message, toAddress: self.ipAddress, onService: .port(self.port))
        
        if keepAlive {
            keepAliveTime = rounded
            let timer = Timer(fireAt: connectionExpiry.addingTimeInterval(-5.0), interval: 1.0, target: self, selector: #selector(TLMDataController.reopen), userInfo: nil, repeats: false)
            RunLoop.main.add(timer, forMode: RunLoop.Mode.default)
        }
        
        //once the message is sent, start the
        beginBackgroundListening()
    }
    
    @objc func reopen() {
        do {
            try self.openConnection(until: Date().addingTimeInterval(keepAliveTime))
        } catch {
            delegate?.connectionDidFailWithError(error: error)
        }
    }
    
    func beginBackgroundListening() {
        DispatchQueue.global().async { self.listenMethod() }
    }
    
    func decodeTelemetry(packet: Data) throws -> [TelemetryKey:TelemetryValue] {
        //Initialize the output dictionary and set the offset cursor position to zero
        var output = [TelemetryKey:TelemetryValue]()
        var offset = 0
        
        //Packets will always start with a packet type
        let packetType: Int32 = try packet.decode(atOffset: &offset)
        output[.packetType] = packetType
        
        var bitfieldCheck: Int32 = 1
        
        //If the packet type is zero, then this represents a connection received packet
        //otherwise, the packet type represents a test bitfield that can represent a variety of data
        if packetType == 0 {
            //returned an acknowledgement packet
            let unixTime: Int32 = try packet.decode(atOffset: &offset)
            output[.unixEpochTime] = unixTime
            return output
        }
        
        let universeTime: Float = try packet.decode(atOffset: &offset)
        output[.universeTime] = universeTime
        
        //The first bit is for orbital data, since it is used so often
        if (packetType & bitfieldCheck) == bitfieldCheck {
            let semiMajorAxis: Float = try packet.decode(atOffset: &offset)
            let eccentricity: Float = try packet.decode(atOffset: &offset)
            let meanAnomaly: Float = try packet.decode(atOffset: &offset)
            let inclination: Float = try packet.decode(atOffset: &offset)
            let longitudeOfAscendingNode: Float = try packet.decode(atOffset: &offset)
            let argumentOfPeriapsis: Float = try packet.decode(atOffset: &offset)
            let planetRadius: Float = try packet.decode(atOffset: &offset)
            let planetGravitationalParameter: Float = try packet.decode(atOffset: &offset)
            
            output[.semiMajorAxis] = semiMajorAxis
            output[.eccentricity] = eccentricity
            output[.meanAnomaly] = meanAnomaly
            output[.inclination] = inclination
            output[.argumentOfPeriapsis] = argumentOfPeriapsis
            output[.longitudeOfAscendingNode] = longitudeOfAscendingNode
            output[.centralBodyRadius] = planetRadius
            output[.centralBodyGravitationalParameter] = planetGravitationalParameter
        }
        
        //the next check is for RCS capacity
        //and liquid fuel
        bitfieldCheck = bitfieldCheck << 1
        if (packetType & bitfieldCheck) == bitfieldCheck {
            let rcs: Float = try packet.decode(atOffset: &offset)
            let rcsCapacity: Float = try packet.decode(atOffset: &offset)
            output[.rcsRemaining] = rcs
            output[.rcsCapacity] = rcsCapacity
            
            let liquidFuel: Float = try packet.decode(atOffset: &offset)
            let liquidFuelCapacity: Float = try packet.decode(atOffset: &offset)
            output[.fuelRemaining] = liquidFuel
            output[.fuelCapacity] = liquidFuelCapacity
        }
        
        //the next check is for launch items
        bitfieldCheck = bitfieldCheck << 1
        if (packetType & bitfieldCheck) == bitfieldCheck {
            let lat: Float = try packet.decode(atOffset: &offset)
            let lon: Float = try packet.decode(atOffset: &offset)
            
            output[.latitude] = lat
            output[.longitude] = lon
        }
        
        //the next check is for surface velocity
        //currently surface velocity is screwed up, but why?
        bitfieldCheck = bitfieldCheck << 1
        if (packetType & bitfieldCheck) == bitfieldCheck {
            let shipSurfaceVelocityX: Float = try packet.decode(atOffset: &offset)
            let shipSurfaceVelocityY: Float = try packet.decode(atOffset: &offset)
            let shipSurfaceVelocityZ: Float = try packet.decode(atOffset: &offset)
            let heightFromTerrain: Float = try packet.decode(atOffset: &offset)
            let verticalSpeed: Float = try packet.decode(atOffset: &offset)
            
            output[.surfaceVelocityX] = shipSurfaceVelocityX
            output[.surfaceVelocityY] = shipSurfaceVelocityY
            output[.surfaceVelocityZ] = shipSurfaceVelocityZ
            output[.heightFromTerrain] = heightFromTerrain
            output[.verticalSpeed] = verticalSpeed
        }
        
        return output
    }
    
    public func closeConnection() {
        do {
            try tunnelSocket.send("disconnect", toAddress: self.ipAddress, onService: .port(self.port))
        } catch {
            print("\(error)")
        }
    }
    
    public func sendCommand(named command: String, info: [AnyHashable:Any]?) {
        
    }
}

public extension TLMDataController {
    enum ConnectionError: LocalizedError {
        case timeout
    }
}
