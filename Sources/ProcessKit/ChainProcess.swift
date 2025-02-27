import Foundation

struct ChainProcess : ProcessProtocol {
    
    let inProc : ProcessProtocol
    let outProc : ProcessProtocol
    
    func run(stdin: Pipe) async throws -> Pipe {
        let stdout = try await inProc.run(stdin: stdin)
        return try await outProc.run(stdin: stdout)
    }
    
}

struct TypedChainProcess<InProc : TypedProcess, OutProc : TypedProcess> : TypedProcess where InProc.Output == OutProc.Input {
    
    typealias Input = InProc.Input
    typealias Output = OutProc.Output
    
    let inProc : InProc
    let outProc : OutProc
    
    func makeProcess() throws -> some ProcessProtocol {
        try ChainProcess(inProc: inProc.makeProcess(), outProc: outProc.makeProcess())
    }
    
}
