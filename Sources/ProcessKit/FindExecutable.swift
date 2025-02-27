import Foundation

public extension URL {
    
    static func findExecutable(named name: String) throws -> URL {
        guard let path = ProcessInfo.processInfo.environment["PATH"] else {
            throw NoPathError()
        }
        for dir in path.split(separator: ":") {
            let candidate = URL(filePath: String(dir)).appending(path: name)
            if FileManager.default.fileExists(atPath: candidate.path()) {
                return candidate
            }
        }
        throw ExecutableNotFound(name: name)
    }
    
}

struct NoPathError : LocalizedError {
    let errorDescription: String? = "PATH environment variable not set"
    let failureReason: String? = "Cannot find executable without PATH"
}

struct ExecutableNotFound : LocalizedError {
    let name : String
    var errorDescription: String? {
        "Executable \(name) not found"
    }
    var failureReason: String? {
        "Cannot find executable \(name)"
    }
}
