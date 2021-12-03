import Foundation
import XCTest

public func assertSameValue(_ lhs: Any, _ rhs: Any, file: StaticString = #file, line: UInt = #line) {
    assertSameValue([lhs, rhs], file: file, line: line)
}

public func assertNotSameValue(_ lhs: Any, _ rhs: Any, file: StaticString = #file, line: UInt = #line) {
    assertNotSameValue([lhs, rhs], file: file, line: line)
}

public func assertSameValue(_ args: [Any], file: StaticString = #file, line: UInt = #line) {
    assert(XCTAssertTrue, args, generateEqualErrorMessage(args), file: file, line: line)
}

public func assertNotSameValue(_ args: [Any], file: StaticString = #file, line: UInt = #line) {
    assert(XCTAssertFalse, args, generateNonEqualErrorMessage(args), file: file, line: line)
}

fileprivate func assert(_ assertion: (@autoclosure () throws -> Bool, @autoclosure () -> String, StaticString, UInt) -> (), _ args: [Any], _ message: String, file: StaticString = #file, line: UInt = #line) {
    assertion(haveSameValue(args), message, file, line)
}

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
