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


