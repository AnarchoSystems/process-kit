import Foundation

/// Typed pIPE
public protocol Tipe<SwiftType> : ~Copyable {
    associatedtype SwiftType
    init(pipe: Pipe)
    consuming func getPipe() -> Pipe
}

public struct NoOptions {
    public init() {}
}

public protocol PipeEncodable : Tipe {
    associatedtype EncodingOptions = NoOptions
    init(_ swiftType: SwiftType, options: EncodingOptions) throws
    static func defaultEncodingOptions() -> EncodingOptions
}

public extension PipeEncodable {
    static func defaultEncodingOptions() -> EncodingOptions where EncodingOptions == NoOptions {
        .init()
    }
    init(_ swiftType: SwiftType) throws {
        self = try .init(swiftType, options: Self.defaultEncodingOptions())
    }
}

public protocol PipeDecodable : Tipe {
    associatedtype DecodingOptions = NoOptions
    consuming func read(options: DecodingOptions) throws -> SwiftType
    static func defaultDecodingOptions() -> DecodingOptions
}

public extension PipeDecodable {
    static func defaultDecodingOptions() -> DecodingOptions where DecodingOptions == NoOptions {
        .init()
    }
    consuming func read() throws -> SwiftType {
        try read(options: Self.defaultDecodingOptions())
    }
}

public typealias PipeCodable = PipeEncodable & PipeDecodable
