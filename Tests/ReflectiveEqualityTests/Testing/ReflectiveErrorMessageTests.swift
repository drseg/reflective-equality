import XCTest
@testable import ReflectiveEquality

class ErrorHandlingTests: XCTestCase {
    func testEqualErrorConditions() {
        let error = generateEqualErrorMessage
        
        XCTAssertEqual(error([]), "")
        XCTAssertEqual(error([1]), "1 must equal itself")
        XCTAssertEqual(error([1, 2]), "\nActual: 1\nExpected: 2")
        XCTAssertEqual(error([1, 2, 3]), "\nArg 1: 1\nArg 2: 2\nArg 3: 3")
        XCTAssertEqual(error([1, 2, 3, 4]), "\nArg 1: 1\nArg 2: 2\nArg 3: 3\nArg 4: 4")
    }
    
    func testNonEqualErrorConditions() {
        let prefix = "All arguments were unexpectedly equal to "
        let error = generateNonEqualErrorMessage
        
        XCTAssertEqual(error([]), prefix + "empty")
        XCTAssertEqual(error([1]), prefix + "1")
        XCTAssertEqual(error([1, 1]), prefix + "1")
        XCTAssertEqual(error([1, 1, 1]), prefix + "1")
    }
}
