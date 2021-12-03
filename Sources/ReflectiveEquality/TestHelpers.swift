import Foundation
import XCTest

public func assertSameValue(_ lhs: Any, _ rhs: Any, file: StaticString = #file, line: UInt = #line) {
    assertSameValue([lhs, rhs], file: file, line: line)
}

public func assertNotSameValue(_ lhs: Any, _ rhs: Any, file: StaticString = #file, line: UInt = #line) {
    assertNotSameValue([lhs, rhs], file: file, line: line)
}

public func assertSameValue(_ args: [Any], file: StaticString = #file, line: UInt = #line) {
    assert(XCTAssertTrue, args, file: file, line: line)
}

public func assertNotSameValue(_ args: [Any], file: StaticString = #file, line: UInt = #line) {
    assert(XCTAssertFalse, args, file: file, line: line)
}

fileprivate func assert(_ assertion: (@autoclosure () throws -> Bool, @autoclosure () -> String, StaticString, UInt) -> (), _ args: [Any], file: StaticString = #file, line: UInt = #line) {
    
    let errorMessage = args.enumerated().reduce("") {
        $0 + "\nArg \($1.offset + 1): \(String(describing: $1.element))"
    }

    assertion(haveSameValue(args), errorMessage, file, line)
}
