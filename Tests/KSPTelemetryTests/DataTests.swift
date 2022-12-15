//
//  DataTests.swift
//  
//
//  Created by Mike Muszynski on 12/15/22.
//

import XCTest
@testable import KSPTelemetry

final class DataTests: XCTestCase {

    func testExampleData() throws {
        let decoder = JSONDecoder()
        let url = Bundle.module.url(forResource: "encodedData", withExtension: "")!
        let data = try Data(contentsOf: url)
        let array = try decoder
            .decode(Array<Data>.self, from: data)
        
        let packets = array
            .compactMap { packetData in
                try? TelemetryPacket(with: packetData)
            }
        
        print(packets.map { $0[.epoch] })
    }

}
