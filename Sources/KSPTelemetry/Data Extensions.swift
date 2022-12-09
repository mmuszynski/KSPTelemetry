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
    
    var hexEncodedString: String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}
