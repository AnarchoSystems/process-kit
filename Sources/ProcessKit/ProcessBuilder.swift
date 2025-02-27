
@resultBuilder
public struct ProcessBuilder {
    public static func buildPartialBlock<P1 : TypedProcess>(first: P1) -> P1 {
        first
    }
    public static func buildPartialBlock<PAcc : TypedProcess, P2 : TypedProcess>(accumulated: PAcc, next: P2) -> some TypedProcess<PAcc.Input, P2.Output> where PAcc.Output == P2.Input {
        accumulated |> next
    }
}

public func runProcess<Proc: TypedProcess>(_ input: Proc.Input.SwiftType,
                                           encodingOpts: Proc.Input.EncodingOptions = Proc.Input.defaultEncodingOptions(),
                                           decodingOpts: Proc.Output.DecodingOptions = Proc.Output.defaultDecodingOptions(),
                                           @ProcessBuilder process: () throws -> Proc) async throws -> Proc.Output.SwiftType
where Proc.Input : PipeEncodable, Proc.Output : PipeDecodable {
    try await process().run(.init(input, options: encodingOpts)).read(options: decodingOpts)
}

public struct Pipeline<P: TypedProcess> : TypedProcess {
    public typealias Input = P.Input
    public typealias Output = P.Output
    public let process: P
    public init(@ProcessBuilder _ process: () throws -> P) rethrows {
        self.process = try process()
    }
    public func makeProcess() throws -> some ProcessProtocol {
        try process.makeProcess()
    }
 
}
