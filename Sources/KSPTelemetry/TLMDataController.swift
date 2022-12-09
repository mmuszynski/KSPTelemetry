//
//  TLMDataController.swift
//  KSPCockpitPanel
//
//  Created by Mike Muszynski on 7/21/17.
//  Copyright © 2017 Mike Muszynski. All rights reserved.
//

import Foundation
import Network

public class TLMDataController: ObservableObject {
    
    private var connection: NWConnection?
    
    public static let shared = TLMDataController()
    public var ipAddress: String = "192.168.1.1"
    public var port: Int = 7000
    public var timeout: Double = 5.0
    
    private var connectionExpiry: Date = Date()
    
    public var packetDebugHandler: ((Data)->Void)?
    
    var packetHistory: [TelemetryPacket] = []
    @Published var currentPacket: TelemetryPacket? {
        didSet {
            if let currentPacket {
                packetHistory.append(currentPacket)
            }
        }
    }
    
    public var isConnected = false
    
    @available(*, unavailable, renamed: "connect(to:on:until:)")
    public func openConnection(until expiration: Date? = nil, atAddress newAddress: String? = nil, onPort newPort: Int? = nil) throws {
        fatalError()
    }
    
    @available(*, unavailable)
    func reopen() {
        fatalError()
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
        let message = "connect:\(intSeconds)"
        let messageData = message.data(using: .utf8)
        connection.send(content: messageData, completion: .contentProcessed { error in
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
            
            do {
                let packet = try TelemetryPacket(with: data!)
                self.currentPacket = packet
            } catch {
                print("Error decoding packet: \(error)")
            }
            
            self.receive(on: connection)
        }
    }
}

public extension TLMDataController {
    enum ConnectionError: LocalizedError {
        case timeout
    }
}
