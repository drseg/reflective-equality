func generateEqualErrorMessage(_ args: [Any]) -> String {
    var oneArgErrorMessage: String {
        "\(String(describing:args.first!)) must equal itself"
    }
    
    var twoArgsErrorMessage: String {
        "\nActual: \(String(describing: args[0]))" +
        "\nExpected: \(String(describing: args[1]))"
    }
    
    var multiArgsErrorMessage: String {
        args.enumerated().reduce("") {
            $0 + "\nArg \($1.offset + 1): \(String(describing: $1.element))"
        }
    }
    
    switch args.count {
    case 1: return oneArgErrorMessage
    case 2: return twoArgsErrorMessage
    case 3...: return multiArgsErrorMessage
    default: return ""
    }
}

func generateNonEqualErrorMessage(_ args: [Any]) -> String {
    "All arguments were unexpectedly equal to \(String(describing: args.first ?? "empty"))"
}
