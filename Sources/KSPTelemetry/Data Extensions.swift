//
//  File.swift
//  
//
//  Created by Mike Muszynski on 12/9/22.
//

import Foundation

public protocol NetworkRepresentable {
    var networkRepresentation: Data { get }
    init?(withNetworkRepresentation: Data)
}

extension NetworkRepresentable {
    public init?(withNetworkRepresentation networkRepresentation: Data) {
        let data = Data(networkRepresentation.reversed())
        self = data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) -> Self in
            return ptr.load(as: Self.self)
        }
    }
    
    public var networkRepresentation: Data {
        var f = self
        let newData = Data(bytes: &f, count: MemoryLayout<Self>.stride).reversed()
        return Data(newData)
    }
}

extension Bool: NetworkRepresentable {}
extension Int8: NetworkRepresentable {}
extension Int16: NetworkRepresentable {}
extension Int32: NetworkRepresentable {}
extension Int: NetworkRepresentable {}
extension UInt8: NetworkRepresentable {}
extension UInt16: NetworkRepresentable {}
extension UInt32: NetworkRepresentable {}
extension UInt: NetworkRepresentable {}
extension Float: NetworkRepresentable {}
extension Double: NetworkRepresentable {}

extension String: NetworkRepresentable {
    public init?(withNetworkRepresentation networkRepresentation: Data) {
        guard let string = String(bytes: networkRepresentation, encoding: .utf8) else {
            return nil
        }
        self = string
    }
    
    public var networkRepresentation: Data {
        guard let data = self.data(using: .utf8) else {
            fatalError()
        }
        return data
    }
}


public extension Data {
    func decode<T: NetworkRepresentable>(atOffset offset: inout Int) throws -> T {
        let value = try self.decode(T.self, atOffset: offset)
        offset += MemoryLayout.size(ofValue: value)
        return value
    }
    
    func decode<T: NetworkRepresentable>(atOffset offset: Int) throws -> T {
        return try self.decode(T.self, atOffset: offset)
    }
    
    func decode<T: NetworkRepresentable>(_: T.Type, atOffset offset: Int, withLength length: Int = MemoryLayout<T>.stride) throws -> T {
        let range = offset..<(offset + length)
        let subData = self[range]
        guard let value = T(withNetworkRepresentation: Data(subData)) else {
            fatalError("Couldn't decode \(T.self)")
        }
        return value
    }
}

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return self.map { String(format: format, $0) }.joined()
    }
    
    
    init(hexString: String) {
        // Get the UTF8 characters of this string
        let chars = Array(hexString.utf8)

        // Keep the bytes in an UInt8 array and later convert it to Data
        var bytes = [UInt8]()
        bytes.reserveCapacity(hexString.count / 2)

        // It is a lot faster to use a lookup map instead of strtoul
        let map: [UInt8] = [
          0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, // 01234567
          0x08, 0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // 89:;<=>?
          0x00, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x00, // @ABCDEFG
          0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  // HIJKLMNO
        ]

        // Grab two characters at a time, map them and turn it into a byte
        for i in stride(from: 0, to: hexString.count, by: 2) {
          let index1 = Int(chars[i] & 0x1F ^ 0x10)
          let index2 = Int(chars[i + 1] & 0x1F ^ 0x10)
          bytes.append(map[index1] << 4 | map[index2])
        }

        self = Data(bytes)
    }
}
