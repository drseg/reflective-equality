import Foundation
import XCTest

public func assertSameValue(_ lhs: Any, _ rhs: Any) {
    assertSameValue([lhs, rhs])
}

public func assertNotSameValue(_ lhs: Any, _ rhs: Any) {
    assertNotSameValue([lhs, rhs])
}

public func assertSameValue(_ args: [Any]) {
    assert(XCTAssertTrue, args)
}

public func assertNotSameValue(_ args: [Any]) {
    assert(XCTAssertFalse, args)
}

fileprivate func assert(_ assertion: (@autoclosure () throws -> Bool, @autoclosure () -> String, StaticString, UInt) -> (), _ args: [Any], file: StaticString = #file, line: UInt = #line) {
    
    let errorMessage = args.enumerated().reduce("") {
        $0 + "\nArg \($1.offset + 1): \(String(describing: $1.element))"
    }

    assertion(haveSameValue(args), errorMessage, file, line)
}
