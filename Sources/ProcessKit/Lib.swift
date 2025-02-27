import Foundation

public struct VoidPipe : PipeCodable {
    public typealias SwiftType = Void
    let pipe : Pipe
    public init(pipe: Pipe) {
        self.pipe = pipe
    }
    public init() {
        self.pipe = Pipe()
    }
    public init(_ swiftType: Void, options: NoOptions) {
        self.pipe = Pipe()
    }
    public consuming func read(options: NoOptions) throws -> Void {
        ()
    }
    consuming public func getPipe() -> Pipe {
        pipe
    }
}

public struct StringPipe : PipeCodable {
    public typealias SwiftType = String
    let pipe : Pipe
    public init(pipe: Pipe) {
        self.pipe = pipe
    }
    public init(_ swiftType: String, options: String.Encoding) throws {
        self.pipe = Pipe()
        try pipe.fileHandleForWriting.write(contentsOf: swiftType.data(using: options) ?? Data())
    }
    public consuming func read(options: String.Encoding) throws -> String {
        guard let data = try pipe.fileHandleForReading.readToEnd() else {
            return ""
        }
        return String(data: data, encoding: options) ?? ""
    }
    consuming public func getPipe() -> Pipe {
        pipe
    }
    public static func defaultEncodingOptions() -> String.Encoding {
        .utf8
    }
    public static func defaultDecodingOptions() -> String.Encoding {
        .utf8
    }
}

public struct JSONPipe<SwiftType> : Tipe {
    let pipe : Pipe
    public init(pipe: Pipe) {
        self.pipe = pipe
    }
    consuming public func getPipe() -> Pipe {
        pipe
    }
}

extension JSONPipe : PipeDecodable where SwiftType : Decodable {
    public consuming func read(options: (JSONDecoder) -> Void = {_ in }) throws -> SwiftType {
        let decoder = JSONDecoder()
        options(decoder)
        return try decoder.decode(SwiftType.self, from: pipe.fileHandleForReading.readToEnd() ?? Data())
    }
    public static func defaultDecodingOptions() -> (JSONDecoder) -> Void {
        {_ in }
    }
}

extension JSONPipe : PipeEncodable where SwiftType : Encodable {
    public init(_ swiftType: SwiftType, options: (JSONEncoder) -> Void = {_ in }) throws {
        self.pipe = Pipe()
        let encoder = JSONEncoder()
        options(encoder)
        try pipe.fileHandleForWriting.write(contentsOf: encoder.encode(swiftType))
    }
    public static func defaultEncodingOptions() -> (JSONEncoder) -> Void {
        {_ in }
    }
}
