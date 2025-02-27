# process-kit

This package provides easy to produce typesafe wrappers around Foundation's Process API.

## Usage Example

Consider the following structs:

```swift
struct Echo : Proc {
    typealias Input = VoidPipe
    typealias Output = StringPipe
    let msg : String
    func path() throws -> URL {
        // convenience to look up files in PATH
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
        // will of course also work with other urls
        if let path = Bundle.module.path(forResource: "MyGrep", ofType: "sh") {
            return URL(filePath: path)
        }
        throw NSError()
    }
    var arguments: [String] {
        [pattern]
    }
}
```

What the ```Proc``` protocol expects is an ```Input```, an ```Output```, a ```path()``` and ```arguments```. From there, it can automatically set up a process that can be executed. Also, the ```Input``` and ```Output``` types make it so that you can only chain processes that naturally form a pipeline.

Here's how:

```swift
let proc = Echo(msg: snooper) |> Grep(pattern: "bug")
```

Alternatively, you can use builder syntax:

```swift
let proc = Pipeline {
        Echo(msg: snooper)
        Grep(pattern: "b")
        Grep(pattern: "u")
        Grep(pattern: "g")
        Grep(pattern: "bug")
    }
```

You may have noticed that input and output have the suffix "Pipe". That's because they're typed wrappers around ```Pipes```. If they conform to ```PipeEncodable``` and/or ```PipeDecodable``` (which is true for the example implementations ```VoidPipe```, ```StringPipe``` and ```JSONPipe```), you can even get the plain swift types back or instantiate them with a plain swift type:

```swift
let inPipe = try StringPipe("Lorem ipsum...")
let outPipe = try await Grep(pattern: "Lo").run(inPipe)
let result = try outPipe.read()
```

And finally, there's a way to just directly run a pipeline:

```swift
let result = try await runProcess(()) {
        Echo(msg: snooper)
        Grep(pattern: "b")
        Grep(pattern: "u")
        Grep(pattern: "g")
        Grep(pattern: "bug")
    }
```