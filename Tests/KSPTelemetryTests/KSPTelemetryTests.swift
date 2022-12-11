//
//  KSPTelemetryTests.swift
//  KSPTelemetryTests
//
//  Created by Mike Muszynski on 8/7/17.
//  Copyright © 2017 Mike Muszynski. All rights reserved.
//

import XCTest
@testable import KSPTelemetry

class KSPTelemetryTests: XCTestCase {
    
//    func testPacketReceive() {
//        let expectation = self.expectation(description: "waiting on timeout")
//        DispatchQueue.global().async {
//            do {
//                let controller = TLMDataController()
//                controller.ipAddress = "localhost"
//
//                var count = 0
//                controller.packetDebugHandler = { data in
//                    print(data.hex)
//                    count += 1
//                    if count == 5 {
//                        expectation.fulfill()
//                    }
//                }
//
//                try controller.openConnection()
//            } catch {
//                XCTFail("\(error)")
//                expectation.fulfill()
//            }
//        }
//        self.waitForExpectations(timeout: 5, handler: nil)
//    }
    
    func testDataDecode() {
        //a real packet
        let hex: [UInt8] = [0x00, 0x00, 0x00, 0x0F, 0x4B, 0x8D, 0x64, 0xCB, 0x47, 0xBD, 0x57, 0x97, 0x3C, 0xA0, 0xE5, 0xBE, 0x40, 0x3A, 0xD6, 0x43, 0x42, 0xB4, 0xBC, 0x4E, 0x43, 0x6D, 0xE5, 0x28, 0x41, 0xA3, 0xB5, 0x40, 0x47, 0x6A, 0x60, 0x00, 0x4E, 0xD2, 0x7F, 0xF1, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x42, 0xE2, 0x8B, 0x92, 0x42, 0xF1, 0x33, 0x33, 0x44, 0x4A, 0x80, 0x00, 0x44, 0x4A, 0x80, 0x00, 0xC1, 0x03, 0x6A, 0x6B, 0xC2, 0x97, 0x1B, 0xB0, 0x41, 0x83, 0x46, 0x4C, 0xC3, 0x03, 0x1D, 0xF7, 0x41, 0x90, 0x68, 0x84, 0x47, 0x17, 0x93, 0x3F, 0x3F, 0x10, 0x03, 0xC1, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
        
        XCTAssertNoThrow(try TelemetryPacket(with: Data(hex)))
    }
    
    /// Tests to see whether the connection will time out
    func testTimeout() {
        let timeoutExpectation = XCTestExpectation(description: "shouldTimeout")
        let controller = TLMDataController()
        controller.timeout = 1
        controller.onTimeout {
            timeoutExpectation.fulfill()
        }
        
        do {
            try controller.connect(to: "192.168.1.1", on: "9999")
            wait(for: [timeoutExpectation], timeout: 5)
            XCTAssertFalse(controller.isConnected)
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }
    
    /// This should only be tested when the server is running on the same device
    func testActiveConnection() {
        let timeoutExpectation = XCTestExpectation(description: "shouldTimeout")
        timeoutExpectation.isInverted = true
        
        let controller = TLMDataController()
        controller.timeout = 1
        controller.onTimeout {
            print("timeout")
            timeoutExpectation.fulfill()
        }
        
        controller.packetDebugHandler = { data in
            print(data.count)
        }
        
        do {
            try controller.connect(to: "192.168.1.2", on: "7000")
            wait(for: [timeoutExpectation], timeout: 3)
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }
    
    func testContinousConnection() {
        let timeoutExpectation = XCTestExpectation(description: "just wait for a long time")
        timeoutExpectation.isInverted = true
        
        let controller = TLMDataController()
        controller.timeout = 5
        
        controller.onTimeout {
            XCTFail("Controller timed out after receiving \(controller.packetHistory.count) packets")
            timeoutExpectation.fulfill()
        }
        
        let minutes = 60 * 6.0
        var connectionTime = Date()
        
        controller.packetDebugHandler = { _ in
            if controller.packetHistory.count == 1 {
                connectionTime = Date()
            }
            if controller.packetHistory.count % 1000 == 1 {
                print("connection has been active for \(Date().timeIntervalSince(connectionTime))s")
            }
        }
        
        do {
            try controller.connect(to: "192.168.1.2", on: "7000", until: .distantFuture)
            wait(for: [timeoutExpectation], timeout: 60 * minutes)
            XCTFail("Controller received \(controller.packetHistory.count) packets")
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }
    
}

extension Data {
    var hex: String {
        var hexString = ""
        for byte in self {
            hexString += String(format: "%02X", byte)
        }

        return hexString
    }
}
