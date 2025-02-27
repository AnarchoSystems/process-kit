import Foundation

public protocol ProcessProtocol {
    func run(stdin: Pipe) async throws -> Pipe
}

extension Process : ProcessProtocol {
    
    public func run(stdin: Pipe) async throws -> Pipe {
        
        standardInput = stdin
        standardOutput = Pipe()
        standardError = Pipe()
        
        return try await withCheckedThrowingContinuation { continuation in
            
            terminationHandler = {process in
                do {
                    if process.terminationStatus == EXIT_SUCCESS {
                        guard let pipe = self.standardOutput as? Pipe else {
                            return continuation.resume(throwing: ProcessError(failureReason: "Stdout is not a pipe"))
                        }
                        return continuation.resume(returning: pipe)
                    }
                    else {
                        guard let pipe = self.standardError as? Pipe else {
                            return continuation.resume(throwing: ProcessError(failureReason: "Stderr is not a pipe"))
                        }
                        guard let err = try pipe.fileHandleForReading.readToEnd() else {
                            return continuation.resume(throwing: ProcessError(failureReason: "Could not read stderr"))
                        }
                        return continuation.resume(throwing: ProcessError(failureReason: String(data: err, encoding: .utf8)))
                    }
                }
                catch {
                    continuation.resume(throwing: error)
                }
            }
            
            do {
                try run()
            }
            catch {
                continuation.resume(throwing: error)
            }
        }
        
    }
    
}
