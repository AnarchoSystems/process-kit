import Foundation

struct ProcessError : LocalizedError {
    var errorDescription: String? {
        "Process failed"
    }
    let failureReason: String?
}
