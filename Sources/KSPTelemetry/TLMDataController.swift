//
//  TLMDataController.swift
//  KSPCockpitPanel
//
//  Created by Mike Muszynski on 7/21/17.
//  Copyright © 2017 Mike Muszynski. All rights reserved.
//

import Foundation
import Network

public class TLMDataController {
    
    private var connectionQueue = DispatchQueue(label: "NWConnectionQueue", qos: .utility)
    private var connection: NWConnection?
    
    public static let shared = TLMDataController()
    public init() {}
    
    public var timeout: Double = 5.0
    private var timeoutTimer: Timer?
    private var timeoutHandler: (()->())?
    
    /// Sets a completion handler when the connection times out
    ///
    /// - Parameter handler: The handler
    public func onTimeout(_ handler: @escaping ()->()) {
        self.timeoutHandler = handler
    }
    
    public typealias TelemetryPacketHandler = (TelemetryPacket)->Void
    
    /// A completion handler for the receipt of a packet handler from the server
    private var packetHandler: TelemetryPacketHandler?
    
    /// Sets a completion handler for each new packet
    /// - Parameter handler: The code to run when a new packet has been received
    public func onPacket(_ handler: TelemetryPacketHandler?) {
        self.packetHandler = handler
    }
    
    private var connectionExpiry: Date = Date()
    
    public typealias PacketDebugHandlerType = (Data)->Void
    public var packetDebugHandler: PacketDebugHandlerType?
    
    public var packetHistory: [TelemetryPacket] = []
    public var currentPacket: TelemetryPacket? {
        didSet {
            if let currentPacket {
                packetHistory.append(currentPacket)
            }
        }
    }
    
    public var isConnected: Bool {
        get {
            connection != nil
        }
    }
    
    /*
     - MARK: NWConnection Methods
     ==========================================================================================
     This section marks the change from SocketWrapper to Network Protocol
     ==========================================================================================
     */
    
    /// When an error has been made in configuring the socket
    /// e.g. the port has been supplied, but it cannot be made into a valid port for NWConnection
    enum ConfigurationError: Error {
        case invalidAddress(_ address: String)
        case invalidPort(_ port: String)
    }
    
    /// Creates a connection to the remote server and sends a connection request packet, opening the connection to the remote
    /// - Parameters:
    ///   - address: A string describing the address of the remote server
    ///   - port: A string representing the port of the remote server
    ///   - expiration: The date at which the connection should reconnect, or `nil` for the default value
    public func connect(to address: String, on port: String, until expiration: Date? = nil) throws {
        //Ensure the address is able to be constructed or throw a configuration error
        guard let address = IPv4Address(address) else {
            throw ConfigurationError.invalidAddress(address)
        }
        
        //Ensure the port supplied represents a valid integer
        guard let portInt = NWEndpoint.Port.IntegerLiteralType(port) else {
            throw ConfigurationError.invalidPort(port)
        }
        
        //Construct the host and port
        let host = NWEndpoint.Host.ipv4(address)
        let port = NWEndpoint.Port(integerLiteral: portInt)
        
        //Create the connection using the host and port
        let connection = NWConnection(host: host, port: port, using: .udp)
        connection.start(queue: self.connectionQueue)
        
        //come up with expiration date
        if let date = expiration {
            self.connectionExpiry = date
        } else {
            self.connectionExpiry = Date().addingTimeInterval(60)
        }
        
        //why did i feel it necessary to round this?
        //will it still work without?
        let seconds = self.connectionExpiry.timeIntervalSince(Date())
        let rounded = round(seconds)
        let intSeconds = Int(rounded)
        
        //register this device with the receiver
        //"connect:3600" asks to be connected for 3600 seconds
        //
        // i don't know if i ever got to these but here they are:
        //"disconnect" asks to be disconnected
        //"continuous" asks for a continuous connection. not sure if this will be robust enough
        //"debug" asks for one message to be sent back
        var message = "connect:\(intSeconds)"
        if self.connectionExpiry == .distantFuture {
            message = "continuous"
        }
        let messageData = message.data(using: .utf8)
        
        self.resetTimeout()
        
        connection.send(content: messageData, completion: .contentProcessed { error in
            self.resetTimeout()
            self.receive(on: connection)
        })
    }
    
    /// Receives data from the remote server
    /// - Parameter connection: The connection on which to receive data
    private func receive(on connection: NWConnection) {
        connection.receiveMessage { data, contentContext, isComplete, error in
            
            //Was there an error?
            if let error {
                print(error)
            }
            
            //did any data actually come through?
            if data == nil {
                print("connection received no data")
            }
            
            //if the data did come through, run the debug handler if it exists
            self.packetDebugHandler?(data!)
            
            do {
                let packet = try TelemetryPacket(with: data!)
                self.currentPacket = packet
                self.packetHandler?(packet)
            } catch {
                print("Error decoding packet: \(error)")
            }
            
            self.resetTimeout()
            self.receive(on: connection)
        }
    }
    
    func resetTimeout() {
        self.timeoutTimer?.invalidate()
        self.timeoutTimer = Timer(timeInterval: self.timeout, repeats: false) { timer in
            self.timeoutHandler?()
            self.connection = nil
            self.timeoutTimer = nil
        }
        RunLoop.main.add(self.timeoutTimer!, forMode: .common)
    }
}

public extension TLMDataController {
    enum ConnectionError: LocalizedError {
        case timeout
    }
}
