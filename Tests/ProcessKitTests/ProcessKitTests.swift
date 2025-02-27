import Foundation
import Testing
import ProcessKit

struct Echo : Proc {
    typealias Input = VoidPipe
    typealias Output = StringPipe
    let msg : String
    func path() throws -> URL {
        try .findExecutable(named: "echo")
    }
    var arguments: [String] {
        [msg]
    }
}

struct Grep : Proc {
    typealias Input = StringPipe
    typealias Output = StringPipe
    let pattern : String
    func path() throws -> URL {
        if let path = Bundle.module.path(forResource: "MyGrep", ofType: "sh") {
            return URL(filePath: path)
        }
        throw NSError()
    }
    var arguments: [String] {
        [pattern]
    }
}

@Test func snooper() async throws {
    
    let proc = Echo(msg: snooper) |> Grep(pattern: "bug")
    
    let result = try await proc.run(VoidPipe()).read()
    
    let expected =
"""
No general procedure for bug checks will do.
must find our own bugs. Our computers are losers! 

"""
    
    #expect(result == expected)
    
}

@Test func run() async throws {
    
    // mostly a check that this compiles
    let result1 = try await runProcess(()) {
        Echo(msg: snooper)
        Grep(pattern: "b")
        Grep(pattern: "u")
        Grep(pattern: "g")
        Grep(pattern: "bug")
    }
    
    // mostly a check that this compiles
    let proc = Pipeline {
        Echo(msg: snooper)
        Grep(pattern: "b")
        Grep(pattern: "u")
        Grep(pattern: "g")
        Grep(pattern: "bug")
    }
    
    let result2 = try await proc.run(VoidPipe()).read()
    
    #expect(result2 == result1)
    
}
