
infix operator |> : AdditionPrecedence

public extension TypedProcess {
    
    static func |><Next: TypedProcess>(lhs: Self, rhs: Next) -> some TypedProcess<Input, Next.Output> where Output == Next.Input {
        TypedChainProcess(inProc: lhs, outProc: rhs)
    }
    
}
