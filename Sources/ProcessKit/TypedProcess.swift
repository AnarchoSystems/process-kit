import Foundation

public protocol TypedProcess<Input, Output> : Sendable {
    
    associatedtype Input : Tipe
    associatedtype Output : Tipe
    associatedtype Proc : ProcessProtocol
    
    func makeProcess() throws -> Proc
    
}

public extension TypedProcess {
    
    func run(_ pipe: consuming Input) async throws -> Output {
        return try await Output(pipe: makeProcess().run(stdin: pipe.getPipe()))
    }
}

public protocol Proc<Input, Output> : TypedProcess where Proc == Process {
    
    associatedtype Input
    associatedtype Output
    
    func path() throws -> URL
    var arguments : [String] {get}
}

public extension Proc {
    
    func makeProcess() throws -> Process {
        let proc = Process()
        proc.executableURL = try path()
        proc.arguments = arguments
        return proc
    }
    
}
